import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var previewCircle: DiscoverCircle?

    var body: some View {
        VStack(spacing: 0) {
            headerBlock

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(viewModel.filteredCircles) { circle in
                        DiscoverCircleCard(
                            circle: circle,
                            onJoin: { previewCircle = circle },
                            onToggleLike: {
                                viewModel.toggleLike(circleID: circle.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.bottom, AppLayout.homeScrollBottomInset)
            }
            .frame(maxHeight: .infinity)
        }
        .background(AppColors.white)
        .fullScreenCover(item: $previewCircle) { circle in
            HabitDetailView(task: circle.previewTask, isJoinLocked: true)
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Discover")
                .font(AppTypography.todayTitle())
                .foregroundStyle(AppColors.black)
                .padding(.top, 8)
                .padding(.horizontal, AppLayout.horizontalPadding)

            DiscoverSearchBar(text: $viewModel.searchText)
                .padding(.horizontal, AppLayout.horizontalPadding)

            // Runs full-width so pills scroll off the true screen edge (no 16px clip).
            CategoryChipRow(
                categories: viewModel.categories,
                selectedCategoryID: viewModel.selectedCategoryID
            ) { categoryID in
                viewModel.selectCategory(categoryID)
            }
        }
        .padding(.top, AppLayout.headerVerticalPadding)
        // Keeps cards from sliding right up against the pills as they scroll off.
        .padding(.bottom, 20)
        .background(AppColors.white)
    }
}

#Preview {
    DiscoverView()
}
