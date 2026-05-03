import SwiftUI

// MARK: - Font Picker View

struct FontPickerView: View {
    var viewModel: EditorViewModel
    @State private var searchText = ""
    @State private var selectedCategory: FontFamily.FontCategory?
    @Environment(\.colorScheme) private var colorScheme

    private var filteredFonts: [FontFamily] {
        var fonts = AppFontCatalog.allFonts
        if let category = selectedCategory {
            fonts = fonts.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            fonts = fonts.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        return fonts
    }

    var body: some View {
        VStack(spacing: 8) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.textSecondary(colorScheme))
                    .font(.system(size: 14))
                TextField("Search fonts...", text: $searchText)
                    .font(.subheadline)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .fill(AppTheme.surfaceSecondary(colorScheme))
            )
            .padding(.horizontal, 12)

            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryChip(title: "All", category: nil)
                    ForEach(FontFamily.FontCategory.allCases, id: \.self) { cat in
                        categoryChip(title: cat.rawValue, category: cat)
                    }
                }
                .padding(.horizontal, 12)
            }

            // Font list
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filteredFonts) { font in
                        fontRow(font)
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 160)
        }
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func categoryChip(title: String, category: FontFamily.FontCategory?) -> some View {
        let isSelected = selectedCategory == category
        Button {
            withAnimation(AppTheme.quickAnimation) {
                selectedCategory = category
            }
        } label: {
            Text(title)
                .font(.caption.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary(colorScheme))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.primary : AppTheme.surfaceSecondary(colorScheme))
                )
        }
        .buttonStyle(.pressable)
    }

    @ViewBuilder
    private func fontRow(_ font: FontFamily) -> some View {
        let isSelected = viewModel.currentFontName.contains(font.displayName)
            || font.id == "sf-pro" && viewModel.currentFontName == ".AppleSystemUIFont"

        Button {
            viewModel.setFont(font)
        } label: {
            HStack {
                Text(font.displayName)
                    .font(.custom(font.fontName == "system" ? ".AppleSystemUIFont" : font.fontName, size: 16))
                    .foregroundColor(AppTheme.textPrimary(colorScheme))
                    .lineLimit(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.primary)
                        .font(.system(size: 16))
                }

                Text(font.category.rawValue)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary(colorScheme))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusTiny)
                    .fill(isSelected ? AppTheme.primary.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
