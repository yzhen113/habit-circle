import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @State private var showCreateCircle = false
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(viewModel: homeViewModel)
                case .discover:
                    DiscoverView()
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
