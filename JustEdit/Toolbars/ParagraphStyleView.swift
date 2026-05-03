import SwiftUI

// MARK: - Paragraph Style View

struct ParagraphStyleView: View {
    var viewModel: EditorViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 14) {
            // Line Spacing
            styleRow(
                icon: "arrow.up.and.down.text.horizontal",
                title: "Line Spacing",
                value: viewModel.currentLineSpacing,
                range: 0...20,
                step: 1,
                format: "%.0f pt"
            ) { newValue in
                viewModel.setLineSpacing(newValue)
            }

            Divider().padding(.horizontal, 12)

            // Paragraph Spacing
            styleRow(
                icon: "text.line.spacing",
                title: "Paragraph Spacing",
                value: 0,
                range: 0...40,
                step: 2,
                format: "%.0f pt"
            ) { newValue in
                viewModel.setParagraphSpacing(newValue)
            }

            Divider().padding(.horizontal, 12)

            // First Line Indent
            styleRow(
                icon: "increase.indent",
                title: "First Line Indent",
                value: 0,
                range: 0...80,
                step: 4,
                format: "%.0f pt"
            ) { newValue in
                viewModel.setFirstLineIndent(newValue)
            }
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func styleRow(
        icon: String,
        title: String,
        value: CGFloat,
        range: ClosedRange<CGFloat>,
        step: CGFloat,
        format: String,
        onChange: @escaping (CGFloat) -> Void
    ) -> some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 24)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary(colorScheme))

                Spacer()

                Text(String(format: format, value))
                    .font(.subheadline.weight(.medium).monospacedDigit())
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(.horizontal, 12)

            SliderRow(value: value, range: range, step: step, onChange: onChange)
                .padding(.horizontal, 12)
        }
    }
}

// MARK: - Slider Row

struct SliderRow: View {
    @State private var internalValue: CGFloat
    let range: ClosedRange<CGFloat>
    let step: CGFloat
    let onChange: (CGFloat) -> Void

    init(value: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, onChange: @escaping (CGFloat) -> Void) {
        self._internalValue = State(initialValue: value)
        self.range = range
        self.step = step
        self.onChange = onChange
    }

    var body: some View {
        Slider(value: $internalValue, in: range, step: step) { editing in
            if !editing {
                onChange(internalValue)
            }
        }
        .tint(AppTheme.primary)
    }
}
