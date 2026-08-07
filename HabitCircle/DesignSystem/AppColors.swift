import SwiftUI

enum AppColors {
    static let black = Color(hex: 0x000000)
    static let darkGray = Color(hex: 0x6D6D6D)
    static let mediumGray = Color(hex: 0xD1DBDE)
    static let lightGray = Color(hex: 0xEFF4F6)
    static let white = Color.white

    static let green = Color(hex: 0x0EB47F)
    static let greenTint = Color(hex: 0xE7F7F2)
    static let purple = Color(hex: 0xA378E0)
    static let purpleTint = Color(hex: 0xF5EEFF)
    static let pink = Color(hex: 0xF78FC6)
    static let pinkTint = Color(hex: 0xFEF4F9)
    static let pinkPartialTop = Color(hex: 0xFCD6EA)
    static let yellow = Color(hex: 0xFBC500)
    static let yellowTint = Color(hex: 0xFFF9E5)

    static let myTasksLabel = Color(red: 60 / 255, green: 60 / 255, blue: 67 / 255, opacity: 0.6)
    static let dateUnselected = Color(hex: 0x858585)
    static let dateSecondary = Color(hex: 0x8E8E93)
    static let tabSelectionBG = Color(hex: 0xEDEDED)
    static let tabInactive = Color(hex: 0x404040)

    /// Per-member avatar colors, assigned by roster position so the same person
    /// keeps the same color across the create flow and the circle chat.
    static let avatarPalette: [Color] = [
        Color(hex: 0x007AFF), Color(hex: 0x34C759), Color(hex: 0xFF9500), Color(hex: 0xAF52DE),
        Color(hex: 0xFF2D55), Color(hex: 0x00A5A8), Color(hex: 0x5856D6), Color(hex: 0xA2845E),
    ]

    static func avatarColor(at index: Int) -> Color {
        avatarPalette[((index % avatarPalette.count) + avatarPalette.count) % avatarPalette.count]
    }
}

extension Color {
    /// Linear RGB blend toward another color. `amount` 0 = self, 1 = `other`.
    func blended(toward other: Color, amount: Double) -> Color {
        let t = CGFloat(min(max(amount, 0), 1))
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        UIColor(self).getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        UIColor(other).getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue: Double(b1 + (b2 - b1) * t),
            opacity: Double(a1 + (a2 - a1) * t)
        )
    }

    init(hex: UInt, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
