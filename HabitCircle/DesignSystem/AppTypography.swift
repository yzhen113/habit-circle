import CoreText
import SwiftUI

enum AppTypography {
    /// Enables the "frac" OpenType feature so "7/10" renders as a diagonal
    /// fraction, matching `font-variant-numeric: diagonal-fractions` on the web.
    static func diagonalFraction(size: CGFloat, weight: UIFont.Weight) -> Font {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let feature: [UIFontDescriptor.FeatureKey: Int] = [
            .type: Int(kFractionsType),
            .selector: Int(kDiagonalFractionsSelector),
        ]
        let descriptor = base.fontDescriptor.addingAttributes([.featureSettings: [feature]])
        return Font(UIFont(descriptor: descriptor, size: size))
    }

    static func todayTitle() -> Font {
        .system(size: 36, weight: .semibold)
    }

    static func sectionHeader() -> Font {
        .system(size: 17, weight: .semibold)
    }

    static func taskTitle() -> Font {
        .system(size: 16, weight: .medium)
    }

    static func metadata() -> Font {
        .system(size: 14, weight: .regular)
    }

    static func dayLabel() -> Font {
        .system(size: 15, weight: .semibold)
    }

    static func dateNumber() -> Font {
        .system(size: 17, weight: .regular)
    }

    static func tabLabel(selected: Bool) -> Font {
        .system(size: 10, weight: selected ? .semibold : .medium)
    }

    static func photoVerification() -> Font {
        .system(size: 15, weight: .regular)
    }
}
