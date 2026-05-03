import SwiftUI

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?

    @State private var isAnimating = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(AppTheme.primaryGradient)
                    .symbolEffect(.pulse, options: .repeating)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(AppTheme.textPrimary(colorScheme))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary(colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text(actionTitle)
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(AppTheme.primaryGradient)
                    .clipShape(Capsule())
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(.pressable)
            }
        }
        .onAppear { isAnimating = true }
    }
}
