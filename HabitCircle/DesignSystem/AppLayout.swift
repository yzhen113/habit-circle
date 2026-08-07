import SwiftUI

enum AppLayout {
    static let screenWidth: CGFloat = 402
    static let horizontalPadding: CGFloat = 16
    static let tabBarHorizontalPadding: CGFloat = 28
    static let tabBarVerticalPadding: CGFloat = 16

    static let headerVerticalPadding: CGFloat = 10
    static let sectionSpacing: CGFloat = 20
    static let taskListSpacing: CGFloat = 16

    static let tabPillWidth: CGFloat = 202
    static let tabPillHeight: CGFloat = 62
    static let tabPillInset: CGFloat = 4
    static let tabIconSize: CGFloat = 22
    static let fabOuterSize: CGFloat = 62
    static let fabInnerSize: CGFloat = 54

    static var tabInnerWidth: CGFloat { tabPillWidth - tabPillInset * 2 }
    static var tabInnerHeight: CGFloat { tabPillHeight - tabPillInset * 2 }
    static var tabSegmentWidth: CGFloat { tabInnerWidth / 2 }

    static let taskCardHeight: CGFloat = 89
    static let taskCardPhotoHeight: CGFloat = 147
    static let taskCardCornerRadius: CGFloat = 14
    static let dateStripHeight: CGFloat = 76.8
    static let selectedDateCapsuleWidth: CGFloat = 37
    static let selectedDateCapsuleHeight: CGFloat = 50

    static let heartIconSize: CGFloat = 26

    /// Height reserved above the home indicator for the floating tab bar.
    static var floatingTabBarHeight: CGFloat {
        tabBarVerticalPadding * 2 + max(tabPillHeight, fabOuterSize)
    }

    /// Space below the last task so content clears the floating tab bar.
    static var homeScrollBottomInset: CGFloat {
        floatingTabBarHeight + 24
    }

    /// iOS 26 Liquid Glass text button (Figma node 879:7145).
    static let liquidGlassButtonHeight: CGFloat = 48
    static let liquidGlassButtonHPadding: CGFloat = 20
    static let liquidGlassButtonVPadding: CGFloat = 6

    /// Chat composer row — plus button and text capsule share this height.
    static let composerRowHeight: CGFloat = 48
}

/// Native iOS 26 liquid-glass capsule button matching the design-system spec.
struct LiquidGlassCapsuleButton: View {
    let title: String
    var icon: String? = nil
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundStyle(Color(hex: 0x1A1A1A))
            .padding(.horizontal, AppLayout.liquidGlassButtonHPadding)
            .padding(.vertical, AppLayout.liquidGlassButtonVPadding)
            .frame(maxWidth: .infinity)
            .frame(height: AppLayout.liquidGlassButtonHeight)
            .background(glassBackground)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.55 : 1)
    }

    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 26.0, *) {
            Capsule(style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.interactive(), in: Capsule(style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 20, y: 4)
        } else {
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.65))
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.white.opacity(0.85), lineWidth: 0.75)
                }
                .shadow(color: .black.opacity(0.12), radius: 20, y: 4)
        }
    }
}

/// Native liquid-glass circular + button (matches home tab bar FAB).
struct GlassCircleFABButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColors.tabInactive)
                .frame(width: AppLayout.fabOuterSize, height: AppLayout.fabOuterSize)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .modifier(GlassCircleFABStyle())
    }
}

private struct GlassCircleFABStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: .circle)
        } else {
            content.background(.ultraThinMaterial, in: Circle())
        }
    }
}

/// Liquid-glass + button sized to match the chat composer text field.
struct GlassComposerAddButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.black)
                .frame(width: AppLayout.composerRowHeight, height: AppLayout.composerRowHeight)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .modifier(GlassCircleFABStyle())
    }
}

/// iMessage-style blurred header background with a soft fade at the bottom edge.
struct BlurHeaderBackground: View {
    private let fadeHeight: CGFloat = 52

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                Rectangle()
                    .fill(.clear)
                    .glassEffect(.regular, in: Rectangle())
            } else {
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
        }
        .mask {
            VStack(spacing: 0) {
                Rectangle()
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black.opacity(0.92), location: 0.25),
                        .init(color: .black.opacity(0.55), location: 0.55),
                        .init(color: .black.opacity(0.18), location: 0.82),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: fadeHeight)
            }
        }
    }
}

struct GlassCapsuleBackground: View {
    var body: some View {
        Capsule()
            .fill(Color.white.opacity(0.55))
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(Color.white.opacity(0.85), lineWidth: 0.75)
            }
            .compositingGroup()
            .shadow(color: .black.opacity(0.14), radius: 20, y: 8)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

struct GlassCircleBackground: View {
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.55))
            .background(.ultraThinMaterial, in: Circle())
            .overlay {
                Circle()
                    .strokeBorder(Color.white.opacity(0.85), lineWidth: 0.75)
            }
            .compositingGroup()
            .shadow(color: .black.opacity(0.14), radius: 20, y: 8)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
