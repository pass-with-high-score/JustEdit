import SwiftUI

// MARK: - Document Row

struct DocumentRow: View {
    let document: DocumentInfo
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 14) {
            // File icon
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .fill(Color(hex: document.fileType.iconColor).opacity(0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: document.fileType.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Color(hex: document.fileType.iconColor))
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary(colorScheme))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(document.fileType.displayName)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(hex: document.fileType.iconColor).opacity(0.8))
                        )

                    Text(document.formattedSize)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary(colorScheme))

                    Text("·")
                        .foregroundColor(AppTheme.textSecondary(colorScheme))

                    Text(document.formattedDate)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary(colorScheme))
                }
            }

            Spacer()

            // iCloud status
            if document.isInICloud {
                Image(systemName: document.isDownloaded ? "checkmark.icloud" : "icloud.and.arrow.down")
                    .font(.system(size: 16))
                    .foregroundColor(
                        document.isDownloaded
                            ? AppTheme.textSecondary(colorScheme)
                            : AppTheme.accent
                    )
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary(colorScheme).opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.surface(colorScheme))
                .shadow(color: AppTheme.softShadow, radius: 4, y: 2)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppTheme.quickAnimation, value: isPressed)
    }
}
