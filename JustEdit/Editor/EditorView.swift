import SwiftUI

// MARK: - Editor View

struct EditorView: View {
    @Bindable var viewModel: EditorViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Editor area
            ZStack(alignment: .leading) {
                if viewModel.showLineNumbers {
                    HStack(spacing: 0) {
                        // Line number gutter
                        LineNumberGutter(
                            totalLines: viewModel.totalLines,
                            currentLine: viewModel.currentLine,
                            font: UIFont.monospacedSystemFont(ofSize: 11, weight: .regular),
                            colorScheme: colorScheme
                        )
                        .frame(width: 44)

                        Divider()

                        // Editor with adjusted insets
                        RichTextEditor(viewModel: viewModel)
                    }
                } else {
                    RichTextEditor(viewModel: viewModel)
                }
            }
            .background(AppTheme.background(colorScheme))

            // Status bar
            statusBar

            // Formatting toolbar
            if viewModel.activeToolbar != .none {
                FormattingToolbar(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                // Undo
                Button {
                    viewModel.textView?.undoManager?.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textSecondary(colorScheme))
                }

                // Redo
                Button {
                    viewModel.textView?.undoManager?.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textSecondary(colorScheme))
                }

                // Editor settings menu
                editorSettingsMenu

                // Toggle toolbar
                Button {
                    withAnimation(AppTheme.smoothAnimation) {
                        if viewModel.activeToolbar == .none {
                            viewModel.activeToolbar = .formatting
                        } else {
                            viewModel.activeToolbar = .none
                        }
                    }
                } label: {
                    Image(systemName: viewModel.activeToolbar == .none
                        ? "textformat" : "keyboard.chevron.compact.down")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .onDisappear {
            viewModel.save()
        }
    }

    // MARK: - Status Bar

    @ViewBuilder
    private var statusBar: some View {
        HStack(spacing: 12) {
            // Line info
            HStack(spacing: 4) {
                Image(systemName: "text.line.first.and.arrowtriangle.forward")
                    .font(.system(size: 10))
                Text("Ln \(viewModel.currentLine):\(viewModel.currentColumn)")
                    .font(.caption2.monospacedDigit().weight(.medium))
            }
            .foregroundColor(AppTheme.primary)

            Divider()
                .frame(height: 12)

            // Word count
            Text("\(viewModel.wordCount) words")
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary(colorScheme))

            Text("\(viewModel.characterCount) chars")
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary(colorScheme))

            Spacer()

            // Total lines
            Text("\(viewModel.totalLines) lines")
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary(colorScheme))

            // Font info
            Text("\(viewModel.currentFontName) \(Int(viewModel.currentFontSize))pt")
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary(colorScheme))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppTheme.surfaceSecondary(colorScheme).opacity(0.8))
    }

    // MARK: - Editor Settings Menu

    @ViewBuilder
    private var editorSettingsMenu: some View {
        Menu {
            // Line numbers toggle
            Button {
                withAnimation(AppTheme.quickAnimation) {
                    viewModel.showLineNumbers.toggle()
                }
            } label: {
                Label(
                    viewModel.showLineNumbers ? "Hide Line Numbers" : "Show Line Numbers",
                    systemImage: viewModel.showLineNumbers ? "list.number" : "list.number"
                )
            }

            // Word wrap toggle
            Button {
                viewModel.wordWrapEnabled.toggle()
            } label: {
                Label(
                    viewModel.wordWrapEnabled ? "Disable Word Wrap" : "Enable Word Wrap",
                    systemImage: viewModel.wordWrapEnabled ? "text.justify.leading" : "arrow.right.to.line"
                )
            }

            Divider()

            // Go to line
            Button {
                // Future: show go-to-line dialog
            } label: {
                Label("Go to Line...", systemImage: "arrow.down.to.line")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textSecondary(colorScheme))
        }
    }
}

// MARK: - Line Number Gutter

struct LineNumberGutter: View {
    let totalLines: Int
    let currentLine: Int
    let font: UIFont
    let colorScheme: ColorScheme

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(1...max(totalLines, 1), id: \.self) { lineNumber in
                    Text("\(lineNumber)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(
                            lineNumber == currentLine
                                ? AppTheme.primary
                                : AppTheme.textSecondary(colorScheme).opacity(0.5)
                        )
                        .fontWeight(lineNumber == currentLine ? .bold : .regular)
                        .frame(height: lineHeight)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.top, 20) // Match UITextView textContainerInset.top
            .padding(.trailing, 6)
            .padding(.leading, 4)
        }
        .background(AppTheme.surfaceSecondary(colorScheme).opacity(0.3))
        .scrollDisabled(true) // Synced with main text view
    }

    private var lineHeight: CGFloat {
        // Approximate line height based on default font
        let uiFont = UIFont.systemFont(ofSize: 16)
        return uiFont.lineHeight + 4 // 4pt line spacing
    }
}
