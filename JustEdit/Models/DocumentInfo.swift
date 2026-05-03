import Foundation
import UniformTypeIdentifiers

// MARK: - Document File Type

enum DocumentFileType: String, CaseIterable, Identifiable {
    case plainText = "txt"
    case richText = "rtf"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .plainText: return "Plain Text"
        case .richText: return "Rich Text"
        }
    }

    var utType: UTType {
        switch self {
        case .plainText: return .plainText
        case .richText: return .rtf
        }
    }

    var fileExtension: String { rawValue }

    var iconName: String {
        switch self {
        case .plainText: return "doc.text"
        case .richText: return "doc.richtext"
        }
    }

    var iconColor: String {
        switch self {
        case .plainText: return "6C63FF"
        case .richText: return "FF6B6B"
        }
    }

    static func from(url: URL) -> DocumentFileType {
        switch url.pathExtension.lowercased() {
        case "rtf": return .richText
        default: return .plainText
        }
    }
}

// MARK: - Document Info

struct DocumentInfo: Identifiable, Hashable {
    let id: String
    let url: URL
    let name: String
    let fileType: DocumentFileType
    let modifiedDate: Date
    let fileSize: Int64
    let isDownloaded: Bool
    let isInICloud: Bool

    init(url: URL, isDownloaded: Bool = true, isInICloud: Bool = false) {
        self.id = url.absoluteString
        self.url = url
        self.name = url.deletingPathExtension().lastPathComponent
        self.fileType = DocumentFileType.from(url: url)
        self.isDownloaded = isDownloaded
        self.isInICloud = isInICloud

        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        self.modifiedDate = (attributes?[.modificationDate] as? Date) ?? Date()
        self.fileSize = (attributes?[.size] as? Int64) ?? 0
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: modifiedDate, relativeTo: Date())
    }
}

// MARK: - Sort Option

enum DocumentSortOption: String, CaseIterable {
    case name = "Name"
    case dateModified = "Date"
    case size = "Size"

    func sort(_ docs: [DocumentInfo], ascending: Bool) -> [DocumentInfo] {
        switch self {
        case .name:
            return docs.sorted {
                ascending
                    ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                    : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
            }
        case .dateModified:
            return docs.sorted {
                ascending ? $0.modifiedDate < $1.modifiedDate : $0.modifiedDate > $1.modifiedDate
            }
        case .size:
            return docs.sorted {
                ascending ? $0.fileSize < $1.fileSize : $0.fileSize > $1.fileSize
            }
        }
    }
}
