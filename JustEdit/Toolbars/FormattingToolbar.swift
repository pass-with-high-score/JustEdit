import SwiftUI

// MARK: - Formatting Toolbar

struct FormattingToolbar: View {
    var viewModel: EditorViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar tabs
            HStack(spacing: 0) {
                ToolbarTabButton(
                    icon: "textformat",
                    title: "Format",
                    isSelected: viewModel.activeToolbar == .formatting
                ) { viewModel.toggleToolbar(.formatting) }

                ToolbarTabButton(
                    icon: "textformat.size",
                    title: "Font",
                    isSelected: viewModel.activeToolbar == .font
                ) { viewModel.toggleToolbar(.font) }

                ToolbarTabButton(
                    icon: "textformat.size.smaller",
                    title: "Size",
                    isSelected: viewModel.activeToolbar == .fontSize
                ) { viewModel.toggleToolbar(.fontSize) }

                ToolbarTabButton(
                    icon: "paintpalette",
                    title: "Color",
                    isSelected: viewModel.activeToolbar == .color
                ) { viewModel.toggleToolbar(.color) }

                ToolbarTabButton(
                    icon: "text.alignleft",
                    title: "Para",
                    isSelected: viewModel.activeToolbar == .paragraph
                ) { viewModel.toggleToolbar(.paragraph) }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Divider()
                .padding(.vertical, 4)

            // Active toolbar content
            Group {
                switch viewModel.activeToolbar {
                case .formatting:
                    formattingContent
                case .font:
                    FontPickerView(viewModel: viewModel)
                case .fontSize:
                    FontSizePickerView(viewModel: viewModel)
                case .color:
                    ColorPickerView(viewModel: viewModel)
                case .paragraph:
                    ParagraphStyleView(viewModel: viewModel)
                case .none:
                    EmptyView()
                }
            }
            .frame(height: viewModel.activeToolbar == .none ? 0 : nil)
        }
        .glassBackground(cornerRadius: AppTheme.cornerRadius)
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Formatting Content

    @ViewBuilder
    private var formattingContent: some View {
        VStack(spacing: 8) {
            // Text style
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ToolbarSection {
                        ToolbarToggleButton(
                            icon: "bold", label: "B",
                            isActive: viewModel.isBold
                        ) { viewModel.toggleBold() }

                        ToolbarToggleButton(
                            icon: "italic", label: "I",
                            isActive: viewModel.isItalic
                        ) { viewModel.toggleItalic() }

                        ToolbarToggleButton(
                            icon: "underline", label: "U",
                            isActive: viewModel.isUnderline
                        ) { viewModel.toggleUnderline() }

                        ToolbarToggleButton(
                            icon: "strikethrough", label: "S",
                            isActive: viewModel.isStrikethrough
                        ) { viewModel.toggleStrikethrough() }
                    }

                    ToolbarSection {
                        ToolbarToggleButton(
                            icon: "text.alignleft",
                            isActive: viewModel.currentAlignment == .left
                        ) { viewModel.setAlignment(.left) }

                        ToolbarToggleButton(
                            icon: "text.aligncenter",
                            isActive: viewModel.currentAlignment == .center
                        ) { viewModel.setAlignment(.center) }

                        ToolbarToggleButton(
                            icon: "text.alignright",
                            isActive: viewModel.currentAlignment == .right
                        ) { viewModel.setAlignment(.right) }

                        ToolbarToggleButton(
                            icon: "text.justify",
                            isActive: viewModel.currentAlignment == .justified
                        ) { viewModel.setAlignment(.justified) }
                    }

                    ToolbarSection {
                        ToolbarToggleButton(icon: "h.square", label: "H1", isActive: false) {
                            viewModel.setHeading(1)
                        }
                        ToolbarToggleButton(icon: "h.square", label: "H2", isActive: false) {
                            viewModel.setHeading(2)
                        }
                        ToolbarToggleButton(icon: "h.square", label: "H3", isActive: false) {
                            viewModel.setHeading(3)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }

            // Info bar
            HStack {
                Text("\(viewModel.wordCount) words")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary(colorScheme))
                Text("·")
                    .foregroundColor(AppTheme.textSecondary(colorScheme))
                Text("\(viewModel.characterCount) chars")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary(colorScheme))
                Spacer()
                Text(viewModel.currentFontName)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary(colorScheme))
                Text("\(Int(viewModel.currentFontSize))pt")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(AppTheme.primary)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }
}
