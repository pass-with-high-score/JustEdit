import SwiftUI

// MARK: - Toolbar Toggle Button

struct ToolbarToggleButton: View {
    let icon: String
    let label: String?
    let isActive: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    init(icon: String, label: String? = nil, isActive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.isActive = isActive
        self.action = action
    }

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 2) {
                if let label {
                    Text(label)
                        .font(.system(size: 15, weight: isActive ? .bold : .medium))
                        .foregroundColor(isActive ? .white : AppTheme.textPrimary(colorScheme))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: AppTheme.iconSize, weight: isActive ? .bold : .regular))
                        .foregroundColor(isActive ? .white : AppTheme.textPrimary(colorScheme))
                }
            }
            .frame(width: 40, height: 36)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusTiny)
                    .fill(isActive ? AppTheme.primary : Color.clear)
            )
            .animation(AppTheme.quickAnimation, value: isActive)
        }
        .buttonStyle(.pressable)
    }
}

// MARK: - Toolbar Section

struct ToolbarSection<Content: View>: View {
    let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack(spacing: 4) {
            content()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(AppTheme.surfaceSecondary(colorScheme).opacity(0.6))
        )
    }
}

// MARK: - Toolbar Tab Button

struct ToolbarTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textSecondary(colorScheme))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                isSelected
                    ? RoundedRectangle(cornerRadius: AppTheme.cornerRadiusTiny)
                        .fill(AppTheme.primary.opacity(0.12))
                    : nil
            )
            .animation(AppTheme.quickAnimation, value: isSelected)
        }
        .buttonStyle(.pressable)
    }
}
