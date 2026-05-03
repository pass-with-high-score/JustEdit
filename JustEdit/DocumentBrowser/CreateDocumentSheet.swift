import SwiftUI

// MARK: - Create Document Sheet

struct CreateDocumentSheet: View {
    var viewModel: DocumentBrowserViewModel
    @State private var fileName: String = ""
    @State private var fileType: DocumentFileType = .plainText
    @State private var showError = false
    @State private var errorText = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // File type selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("FILE TYPE")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppTheme.textSecondary(colorScheme))
                        .tracking(1)

                    HStack(spacing: 12) {
                        ForEach(DocumentFileType.allCases) { type in
                            fileTypeCard(type)
                        }
                    }
                }

                // File name
                VStack(alignment: .leading, spacing: 10) {
                    Text("FILE NAME")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppTheme.textSecondary(colorScheme))
                        .tracking(1)

                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(AppTheme.textSecondary(colorScheme))
                        TextField("Untitled", text: $fileName)
                            .font(.body)
                            .textFieldStyle(.plain)
                            .focused($isNameFocused)
                        Text(".\(fileType.fileExtension)")
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary(colorScheme))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                            .fill(AppTheme.surfaceSecondary(colorScheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                            .stroke(isNameFocused ? AppTheme.primary : Color.clear, lineWidth: 1.5)
                    )

                    if showError {
                        Text(errorText)
                            .font(.caption)
                            .foregroundColor(AppTheme.secondary)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Spacer()

                // Create button
                Button {
                    createDocument()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Create Document")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(
                                fileName.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color.gray.opacity(0.4)
                                    : AppTheme.primary
                            )
                    )
                    .shadow(
                        color: AppTheme.primary.opacity(
                            fileName.trimmingCharacters(in: .whitespaces).isEmpty ? 0 : 0.3
                        ),
                        radius: 12, y: 6
                    )
                }
                .disabled(fileName.trimmingCharacters(in: .whitespaces).isEmpty)
                .buttonStyle(.pressable)
            }
            .padding(24)
            .navigationTitle("New Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary(colorScheme))
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear { isNameFocused = true }
    }

    @ViewBuilder
    private func fileTypeCard(_ type: DocumentFileType) -> some View {
        let isSelected = fileType == type
        Button {
            withAnimation(AppTheme.smoothAnimation) {
                fileType = type
            }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                        .fill(
                            isSelected
                                ? Color(hex: type.iconColor).opacity(0.15)
                                : AppTheme.surfaceSecondary(colorScheme)
                        )
                        .frame(height: 72)

                    Image(systemName: type.iconName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(Color(hex: type.iconColor))
                }

                Text(type.displayName)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundColor(
                        isSelected
                            ? Color(hex: type.iconColor)
                            : AppTheme.textSecondary(colorScheme)
                    )
            }
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .stroke(isSelected ? Color(hex: type.iconColor) : Color.clear, lineWidth: 2)
                    .padding(.bottom, 26)
            )
        }
        .buttonStyle(.pressable)
    }

    private func createDocument() {
        let name = fileName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard viewModel.isValidName(name) else {
            errorText = "Invalid file name."
            withAnimation { showError = true }
            return
        }

        guard !viewModel.nameExists(name, type: fileType) else {
            errorText = "A file with this name already exists."
            withAnimation { showError = true }
            return
        }

        viewModel.createDocument(name: name, type: fileType)
        dismiss()
    }
}
