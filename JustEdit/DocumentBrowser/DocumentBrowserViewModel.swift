import Foundation
import Observation
import UIKit

// MARK: - Document Browser ViewModel

@Observable
final class DocumentBrowserViewModel {
    var documents: [DocumentInfo] = []
    var searchText: String = ""
    var sortOption: DocumentSortOption = .dateModified
    var sortAscending: Bool = false
    var isLoading: Bool = false
    var showCreateSheet: Bool = false
    var errorMessage: String?

    private var metadataQuery: NSMetadataQuery?
    private var iCloudURL: URL?

    var localDocumentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    var filteredDocuments: [DocumentInfo] {
        var result = documents
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        return sortOption.sort(result, ascending: sortAscending)
    }

    var activeDocumentsURL: URL {
        if AppSettings.shared.useICloud, let url = iCloudURL {
            return url
        }
        return localDocumentsURL
    }

    // MARK: - Init

    init() {
        setupICloud()
        loadDocuments()
    }

    // MARK: - iCloud Setup

    private func setupICloud() {
        guard AppSettings.shared.useICloud else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let containerURL = FileManager.default.url(
                forUbiquityContainerIdentifier: nil
            ) else {
                DispatchQueue.main.async {
                    self?.iCloudURL = nil
                }
                return
            }

            let docsURL = containerURL.appendingPathComponent("Documents")
            if !FileManager.default.fileExists(atPath: docsURL.path) {
                try? FileManager.default.createDirectory(at: docsURL, withIntermediateDirectories: true)
            }

            DispatchQueue.main.async {
                self?.iCloudURL = docsURL
                self?.startMetadataQuery()
                self?.loadDocuments()
            }
        }
    }

    // MARK: - Metadata Query (iCloud)

    private func startMetadataQuery() {
        guard iCloudURL != nil else { return }

        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(
            format: "%K LIKE '*.txt' OR %K LIKE '*.rtf'",
            NSMetadataItemFSNameKey, NSMetadataItemFSNameKey
        )

        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidUpdate,
            object: query,
            queue: .main
        ) { [weak self] _ in
            self?.processMetadataQueryResults()
        }

        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering,
            object: query,
            queue: .main
        ) { [weak self] _ in
            self?.processMetadataQueryResults()
        }

        query.start()
        self.metadataQuery = query
    }

    private func processMetadataQueryResults() {
        guard let query = metadataQuery else { return }
        query.disableUpdates()

        var newDocs: [DocumentInfo] = []
        for item in query.results {
            guard let mdItem = item as? NSMetadataItem,
                  let url = mdItem.value(forAttribute: NSMetadataItemURLKey) as? URL
            else { continue }

            let downloadStatus = mdItem.value(
                forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey
            ) as? String
            let isDownloaded = downloadStatus == NSMetadataUbiquitousItemDownloadingStatusCurrent

            newDocs.append(DocumentInfo(url: url, isDownloaded: isDownloaded, isInICloud: true))
        }

        self.documents = newDocs
        query.enableUpdates()
    }

    // MARK: - Load Documents (Local)

    func loadDocuments() {
        if iCloudURL != nil && metadataQuery != nil {
            // iCloud docs handled by metadata query
            return
        }

        isLoading = true
        let documentsURL = localDocumentsURL

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let files = try FileManager.default.contentsOfDirectory(
                    at: documentsURL,
                    includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                    options: [.skipsHiddenFiles]
                )

                let docs = files
                    .filter { ["txt", "rtf"].contains($0.pathExtension.lowercased()) }
                    .map { DocumentInfo(url: $0) }

                DispatchQueue.main.async {
                    self?.documents = docs
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }

    // MARK: - CRUD

    func createDocument(name: String, type: DocumentFileType) {
        let directory = activeDocumentsURL
        let document = TextDocument.create(name: name, fileType: type, in: directory)

        document.save(to: document.fileURL, for: .forCreating) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.loadDocuments()
                    if self?.iCloudURL != nil {
                        self?.metadataQuery?.disableUpdates()
                        self?.metadataQuery?.enableUpdates()
                    }
                }
            }
        }
    }

    func deleteDocument(_ doc: DocumentInfo) {
        do {
            try FileManager.default.removeItem(at: doc.url)
            documents.removeAll { $0.id == doc.id }
        } catch {
            errorMessage = "Failed to delete: \(error.localizedDescription)"
        }
    }

    func renameDocument(_ doc: DocumentInfo, to newName: String) {
        let newURL = doc.url.deletingLastPathComponent()
            .appendingPathComponent("\(newName).\(doc.fileType.fileExtension)")

        guard !FileManager.default.fileExists(atPath: newURL.path) else {
            errorMessage = "A file with this name already exists."
            return
        }

        do {
            try FileManager.default.moveItem(at: doc.url, to: newURL)
            loadDocuments()
            if iCloudURL != nil {
                metadataQuery?.disableUpdates()
                metadataQuery?.enableUpdates()
            }
        } catch {
            errorMessage = "Failed to rename: \(error.localizedDescription)"
        }
    }

    func duplicateDocument(_ doc: DocumentInfo) {
        var copyName = "\(doc.name) copy"
        var counter = 1
        let directory = doc.url.deletingLastPathComponent()

        while FileManager.default.fileExists(
            atPath: directory.appendingPathComponent("\(copyName).\(doc.fileType.fileExtension)").path
        ) {
            counter += 1
            copyName = "\(doc.name) copy \(counter)"
        }

        let newURL = directory.appendingPathComponent("\(copyName).\(doc.fileType.fileExtension)")
        do {
            try FileManager.default.copyItem(at: doc.url, to: newURL)
            loadDocuments()
        } catch {
            errorMessage = "Failed to duplicate: \(error.localizedDescription)"
        }
    }

    func downloadDocument(_ doc: DocumentInfo) {
        guard doc.isInICloud, !doc.isDownloaded else { return }
        try? FileManager.default.startDownloadingUbiquitousItem(at: doc.url)
    }

    // MARK: - Validation

    func isValidName(_ name: String) -> Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        let invalidChars = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return name.rangeOfCharacter(from: invalidChars) == nil
    }

    func nameExists(_ name: String, type: DocumentFileType) -> Bool {
        let url = activeDocumentsURL.appendingPathComponent("\(name).\(type.fileExtension)")
        return FileManager.default.fileExists(atPath: url.path)
    }

    deinit {
        metadataQuery?.stop()
    }
}
