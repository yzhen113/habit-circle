import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @State private var previewCircle: DiscoverCircle?

    var body: some View {
        VStack(spacing: 0) {
            // Title + search stay put; chips scroll away with the cards.
            headerBlock

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    // Full-bleed chip row; tap empty padding beside pills to clear selection.
                    CategoryChipRow(
                        categories: viewModel.categories,
                        selectedCategoryID: viewModel.selectedCategoryID
                    ) { categoryID in
                        viewModel.selectCategory(categoryID)
                    }
                    .background {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.clearCategoryFilter()
                            }
                    }

                    if viewModel.filteredCircles.isEmpty {
                        discoverEmptyState
                            .padding(.top, 36)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.clearCategoryFilter()
                            }
                    } else {
                        ForEach(viewModel.filteredCircles) { circle in
                            DiscoverCircleCard(
                                circle: circle,
                                onJoin: { previewCircle = circle },
                                onToggleLike: {
                                    viewModel.toggleLike(circleID: circle.id)
                                }
                            )
                            .padding(.horizontal, AppLayout.horizontalPadding)
                        }
                    }
                }
                .padding(.bottom, AppLayout.homeScrollBottomInset)
                .frame(maxWidth: .infinity)
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
                // Match Home date title inset (tabBarHorizontalPadding).
                .padding(.horizontal, AppLayout.tabBarHorizontalPadding)

            DiscoverSearchBar(text: $viewModel.searchText)
                .padding(.horizontal, AppLayout.horizontalPadding)
        }
        .padding(.top, AppLayout.headerVerticalPadding)
        // Keeps scrolling chips/cards from sitting flush under the search.
        .padding(.bottom, 20)
        .background(AppColors.white)
    }

    private var discoverEmptyState: some View {
        let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return VStack(spacing: 8) {
            Text(query.isEmpty ? "No circles here" : "No matching circles")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.black)

            Text(
                query.isEmpty
                    ? "Try a different category or clear the filter."
                    : "Nothing matched “\(query)”. Try another title or description."
            )
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(AppColors.darkGray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppLayout.horizontalPadding)
    }
}

#Preview {
    DiscoverView(viewModel: DiscoverViewModel())
}
