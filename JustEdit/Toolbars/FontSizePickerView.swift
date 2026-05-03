import SwiftUI

// MARK: - Font Size Picker View

struct FontSizePickerView: View {
    var viewModel: EditorViewModel
    @State private var customSize: String = ""
    @Environment(\.colorScheme) private var colorScheme

    private let presetSizes: [CGFloat] = [8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 36, 48, 64, 72]

    var body: some View {
        VStack(spacing: 12) {
            // Current size display + stepper
            HStack(spacing: 16) {
                Button {
                    let newSize = max(8, viewModel.currentFontSize - 1)
                    viewModel.setFontSize(newSize)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.primary)
                }
                .buttonStyle(.pressable)

                VStack(spacing: 2) {
                    Text("\(Int(viewModel.currentFontSize))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary(colorScheme))
                    Text("pt")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary(colorScheme))
                }
                .frame(width: 60)

                Button {
                    let newSize = min(120, viewModel.currentFontSize + 1)
                    viewModel.setFontSize(newSize)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.primary)
                }
                .buttonStyle(.pressable)
            }

            // Slider
            Slider(
                value: Binding(
                    get: { viewModel.currentFontSize },
                    set: { viewModel.setFontSize($0) }
                ),
                in: 8...120,
                step: 1
            )
            .tint(AppTheme.primary)
            .padding(.horizontal, 16)

            // Preset grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(presetSizes, id: \.self) { size in
                        let isSelected = Int(viewModel.currentFontSize) == Int(size)
                        Button {
                            viewModel.setFontSize(size)
                        } label: {
                            Text("\(Int(size))")
                                .font(.system(size: 13, weight: isSelected ? .bold : .regular, design: .rounded))
                                .foregroundColor(isSelected ? .white : AppTheme.textPrimary(colorScheme))
                                .frame(width: 40, height: 34)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusTiny)
                                        .fill(isSelected ? AppTheme.primary : AppTheme.surfaceSecondary(colorScheme))
                                )
                        }
                        .buttonStyle(.pressable)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.vertical, 8)
    }
}
