import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @State private var showCreateCircle = false
    @StateObject private var homeViewModel = HomeViewModel()
    /// Shared so Discover likes stay in sync with the Home → Saved list.
    @StateObject private var discoverViewModel = DiscoverViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        viewModel: homeViewModel,
                        discoverViewModel: discoverViewModel
                    )
                case .discover:
                    DiscoverView(viewModel: discoverViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            FloatingTabBar(selectedTab: $selectedTab) {
                showCreateCircle = true
            }
            .background(Color.clear)
        }
        .background(AppColors.white.ignoresSafeArea())
        .persistentSystemOverlays(.hidden)
        .fullScreenCover(isPresented: $showCreateCircle) {
            CreateCircleView { task in
                selectedTab = .home
                homeViewModel.addCreatedTask(task)
            }
        }
    }
}

#Preview {
    MainTabView()
}
