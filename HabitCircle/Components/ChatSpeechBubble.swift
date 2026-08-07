import SwiftUI

enum ChatBubbleMetrics {
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 10
    static let fontSize: CGFloat = 15
    static let cornerRadius: CGFloat = 18
    /// Vertical gap between every bubble in the thread.
    static let spacing: CGFloat = 8
}

struct ChatSpeechBubble<Content: View>: View {
    let color: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .font(.system(size: ChatBubbleMetrics.fontSize))
            .multilineTextAlignment(.leading)
            .padding(.horizontal, ChatBubbleMetrics.horizontalPadding)
            .padding(.vertical, ChatBubbleMetrics.verticalPadding)
            .background(
                color,
                in: RoundedRectangle(cornerRadius: ChatBubbleMetrics.cornerRadius, style: .continuous)
            )
    }
}

/// Color-coded initial avatar for a group chat member, matching the create flow.
struct ChatMemberAvatar: View {
    var name: String?
    /// Roster position, which picks the color. Nil falls back to a neutral chip.
    var colorIndex: Int?
    var size: CGFloat = 30

    private var initial: String {
        guard let first = name?.trimmed.first else { return "?" }
        return String(first).uppercased()
    }

    var body: some View {
        Group {
            if let colorIndex {
                Text(initial)
                    .font(.system(size: size * 0.45, weight: .semibold))
                    .foregroundStyle(AppColors.white)
                    .frame(width: size, height: size)
                    .background(AppColors.avatarColor(at: colorIndex), in: Circle())
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.42))
                    .foregroundStyle(AppColors.dateSecondary)
                    .frame(width: size, height: size)
                    .background(AppColors.dateSecondary.opacity(0.25), in: Circle())
            }
        }
    }
}
