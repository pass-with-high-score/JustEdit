import SwiftUI

// MARK: - Color Picker View

struct ColorPickerView: View {
    var viewModel: EditorViewModel
    @State private var mode: ColorMode = .text
    @State private var showSystemPicker = false
    @Environment(\.colorScheme) private var colorScheme

    enum ColorMode: String, CaseIterable {
        case text = "Text"
        case highlight = "Highlight"
    }

    private let textColors: [(String, UIColor)] = [
        ("Default", .label),
        ("Black", .black),
        ("Dark Gray", .darkGray),
        ("Gray", .gray),
        ("Red", UIColor(hex: "EF4444")),
        ("Orange", UIColor(hex: "F97316")),
        ("Amber", UIColor(hex: "F59E0B")),
        ("Yellow", UIColor(hex: "EAB308")),
        ("Lime", UIColor(hex: "84CC16")),
        ("Green", UIColor(hex: "22C55E")),
        ("Emerald", UIColor(hex: "10B981")),
        ("Teal", UIColor(hex: "14B8A6")),
        ("Cyan", UIColor(hex: "06B6D4")),
        ("Sky", UIColor(hex: "0EA5E9")),
        ("Blue", UIColor(hex: "3B82F6")),
        ("Indigo", UIColor(hex: "6366F1")),
        ("Violet", UIColor(hex: "8B5CF6")),
        ("Purple", UIColor(hex: "A855F7")),
        ("Fuchsia", UIColor(hex: "D946EF")),
        ("Pink", UIColor(hex: "EC4899")),
        ("Rose", UIColor(hex: "F43F5E")),
        ("White", .white),
    ]

    private let highlightColors: [(String, UIColor)] = [
        ("Yellow", UIColor(hex: "FEF08A")),
        ("Green", UIColor(hex: "BBF7D0")),
        ("Blue", UIColor(hex: "BFDBFE")),
        ("Purple", UIColor(hex: "DDD6FE")),
        ("Pink", UIColor(hex: "FBCFE8")),
        ("Orange", UIColor(hex: "FED7AA")),
        ("Red", UIColor(hex: "FECACA")),
        ("Cyan", UIColor(hex: "A5F3FC")),
    ]

    var body: some View {
        VStack(spacing: 10) {
            // Mode picker
            Picker("Mode", selection: $mode) {
                ForEach(ColorMode.allCases, id: \.self) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)

            // Color grid
            let colors = mode == .text ? textColors : highlightColors

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 8),
                spacing: 6
            ) {
                if mode == .highlight {
                    // "No highlight" button
                    Button {
                        viewModel.setHighlightColor(nil)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppTheme.surfaceSecondary(colorScheme))
                                .frame(width: 32, height: 32)
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary(colorScheme))
                        }
                    }
                    .buttonStyle(.pressable)
                }

                ForEach(colors, id: \.0) { name, color in
                    let isSelected = isColorSelected(color)
                    Button {
                        if mode == .text {
                            viewModel.setTextColor(color)
                        } else {
                            viewModel.setHighlightColor(color)
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(color))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isSelected ? AppTheme.primary : Color.clear,
                                            lineWidth: 2.5
                                        )
                                        .padding(-2)
                                )
                            if name == "White" {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                    .frame(width: 32, height: 32)
                            }
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(
                                        name == "White" || name == "Yellow"
                                            ? .black : .white
                                    )
                            }
                        }
                    }
                    .buttonStyle(.pressable)
                }
            }
            .padding(.horizontal, 12)

            // Custom color button
            Button {
                showSystemPicker = true
            } label: {
                HStack {
                    Image(systemName: "eyedropper")
                        .font(.system(size: 14))
                    Text("Custom Color")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundColor(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                        .fill(AppTheme.primary.opacity(0.08))
                )
            }
            .buttonStyle(.pressable)
            .padding(.horizontal, 12)
            .sheet(isPresented: $showSystemPicker) {
                SystemColorPickerSheet(mode: mode, viewModel: viewModel)
            }
        }
        .padding(.vertical, 8)
    }

    private func isColorSelected(_ color: UIColor) -> Bool {
        if mode == .text {
            return viewModel.currentTextColor.isApproximatelyEqual(to: color)
        } else {
            guard let highlight = viewModel.currentHighlightColor else { return false }
            return highlight.isApproximatelyEqual(to: color)
        }
    }
}

// MARK: - UIColor Comparison

extension UIColor {
    func isApproximatelyEqual(to other: UIColor, tolerance: CGFloat = 0.02) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return abs(r1 - r2) < tolerance && abs(g1 - g2) < tolerance
            && abs(b1 - b2) < tolerance
    }
}

// MARK: - System Color Picker Sheet

struct SystemColorPickerSheet: View {
    let mode: ColorPickerView.ColorMode
    var viewModel: EditorViewModel
    @State private var selectedColor = Color.blue
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ColorPicker(
                mode == .text ? "Text Color" : "Highlight Color",
                selection: $selectedColor,
                supportsOpacity: mode == .highlight
            )
            .padding()
            .navigationTitle("Custom Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        if mode == .text {
                            viewModel.setTextColor(UIColor(selectedColor))
                        } else {
                            viewModel.setHighlightColor(UIColor(selectedColor))
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
