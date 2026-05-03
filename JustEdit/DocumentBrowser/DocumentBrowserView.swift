import SwiftUI

// MARK: - Document Browser View

struct DocumentBrowserView: View {
    @State private var viewModel = DocumentBrowserViewModel()
    @State private var selectedDocument: DocumentInfo?
    @State private var documentToRename: DocumentInfo?
    @State private var renameText: String = ""
    @State private var showRenameAlert = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppTheme.background(colorScheme)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppTheme.primary)
                } else if viewModel.filteredDocuments.isEmpty {
                    if viewModel.searchText.isEmpty {
                        EmptyStateView(
                            icon: "doc.text.magnifyingglass",
                            title: "No Documents Yet",
                            subtitle: "Create your first document to start writing",
                            actionTitle: "Create Document"
                        ) {
                            viewModel.showCreateSheet = true
                        }
                    } else {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No Results",
                            subtitle: "No documents match \"\(viewModel.searchText)\""
                        )
                    }
                } else {
                    documentList
                }
            }
            .navigationTitle("Just Edit")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search documents"
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    sortMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateSheet) {
                CreateDocumentSheet(viewModel: viewModel)
            }
            .navigationDestination(item: $selectedDocument) { doc in
                EditorContainerView(documentInfo: doc, browserViewModel: viewModel)
            }
            .alert("Rename Document", isPresented: $showRenameAlert) {
                TextField("New name", text: $renameText)
                Button("Cancel", role: .cancel) {}
                Button("Rename") {
                    if let doc = documentToRename {
                        viewModel.renameDocument(doc, to: renameText)
                    }
                }
            }
            .refreshable {
                viewModel.loadDocuments()
            }
        }
    }

    // MARK: - Document List

    @ViewBuilder
    private var documentList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredDocuments) { doc in
                    DocumentRow(document: doc)
                        .onTapGesture {
                            if doc.isInICloud && !doc.isDownloaded {
                                viewModel.downloadDocument(doc)
                            } else {
                                selectedDocument = doc
                            }
                        }
                        .contextMenu {
                            contextMenu(for: doc)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteDocument(doc)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                documentToRename = doc
                                renameText = doc.name
                                showRenameAlert = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(AppTheme.primary)
                        }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
        }
    }

    // MARK: - Sort Menu

    @ViewBuilder
    private var sortMenu: some View {
        Menu {
            ForEach(DocumentSortOption.allCases, id: \.self) { option in
                Button {
                    if viewModel.sortOption == option {
                        viewModel.sortAscending.toggle()
                    } else {
                        viewModel.sortOption = option
                        viewModel.sortAscending = option == .name
                    }
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if viewModel.sortOption == option {
                            Image(systemName: viewModel.sortAscending
                                ? "chevron.up" : "chevron.down")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.textSecondary(colorScheme))
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func contextMenu(for doc: DocumentInfo) -> some View {
        Button {
            selectedDocument = doc
        } label: {
            Label("Open", systemImage: "doc.text")
        }

        Button {
            documentToRename = doc
            renameText = doc.name
            showRenameAlert = true
        } label: {
            Label("Rename", systemImage: "pencil")
        }

        Button {
            viewModel.duplicateDocument(doc)
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }

        Divider()

        Button(role: .destructive) {
            withAnimation {
                viewModel.deleteDocument(doc)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

// MARK: - Editor Container (loads UIDocument)

struct EditorContainerView: View {
    let documentInfo: DocumentInfo
    var browserViewModel: DocumentBrowserViewModel
    @State private var viewModel: EditorViewModel?
    @State private var isLoading = true
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background(colorScheme)
                .ignoresSafeArea()

            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(AppTheme.primary)
                    Text("Opening document...")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary(colorScheme))
                }
            } else if let viewModel {
                EditorView(viewModel: viewModel)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel?.save()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }

            if let vm = viewModel {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text(vm.fileName)
                            .font(.subheadline.weight(.semibold))
                        HStack(spacing: 6) {
                            Text("Ln \(vm.currentLine), Col \(vm.currentColumn)")
                                .font(.caption2.monospacedDigit())
                                .foregroundColor(AppTheme.textSecondary(colorScheme))
                            Text("·")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary(colorScheme))
                            Text(vm.hasUnsavedChanges ? "Editing" : "Saved")
                                .font(.caption2)
                                .foregroundColor(
                                    vm.hasUnsavedChanges
                                        ? AppTheme.secondary
                                        : AppTheme.textSecondary(colorScheme)
                                )
                        }
                    }
                }
            }
        }
        .task {
            await loadDocument()
        }
        .onDisappear {
            viewModel?.save()
            browserViewModel.loadDocuments()
        }
    }

    private func loadDocument() async {
        let document = TextDocument(fileURL: documentInfo.url)
        document.documentFileType = documentInfo.fileType

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            document.open { success in
                if success {
                    let vm = EditorViewModel(document: document)
                    DispatchQueue.main.async {
                        self.viewModel = vm
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
                continuation.resume()
            }
        }
    }
}
