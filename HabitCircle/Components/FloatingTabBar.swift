import SwiftUI

enum MainTab: Hashable {
    case home
    case discover
}

struct FloatingTabBar: View {
    @Binding var selectedTab: MainTab
    var onAddTapped: () -> Void = {}

    private var selectionOffset: CGFloat {
        selectedTab == .home ? 0 : AppLayout.tabSegmentWidth
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            tabPillContent
                .frame(width: AppLayout.tabPillWidth, height: AppLayout.tabPillHeight)
                .modifier(TabPillGlassStyle())

            Spacer(minLength: 0)

            GlassCircleFABButton(action: onAddTapped)
        }
        .padding(.horizontal, AppLayout.tabBarHorizontalPadding)
        .padding(.top, AppLayout.tabBarVerticalPadding)
        .padding(.bottom, AppLayout.tabBarVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var tabPillContent: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.white)
                .frame(width: AppLayout.tabSegmentWidth, height: AppLayout.tabInnerHeight)
                .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
                .offset(x: AppLayout.tabPillInset + selectionOffset)
                .animation(.spring(response: 0.32, dampingFraction: 0.86), value: selectedTab)

            HStack(spacing: 0) {
                tabButton(tab: .home, title: "Home", icon: "house.fill")
                tabButton(tab: .discover, title: "Discover", icon: "person.2.fill")
            }
            .padding(AppLayout.tabPillInset)
        }
    }

    private func tabButton(tab: MainTab, title: String, icon: String) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .font(.system(size: AppLayout.tabIconSize, weight: .semibold))
                    .foregroundStyle(isSelected ? AppColors.green : AppColors.tabInactive)

                Text(title)
                    .font(AppTypography.tabLabel(selected: isSelected))
                    .foregroundStyle(isSelected ? AppColors.green : AppColors.tabInactive)
            }
            .frame(width: AppLayout.tabSegmentWidth, height: AppLayout.tabInnerHeight)
        }
        .buttonStyle(.plain)
    }
}

private struct TabPillGlassStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Capsule(style: .continuous))
        } else {
            content.background(.ultraThinMaterial, in: Capsule(style: .continuous))
        }
    }
}
