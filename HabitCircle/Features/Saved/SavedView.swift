import SwiftUI

/// Hearted Discover circles — opened from the Home header heart.
struct SavedView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var previewCircle: DiscoverCircle?

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                if viewModel.likedCircles.isEmpty {
                    savedEmptyState
                        .padding(.top, 80)
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.likedCircles) { circle in
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
            }
            .frame(maxHeight: .infinity)
        }
        .background(AppColors.white)
        .fullScreenCover(item: $previewCircle) { circle in
            HabitDetailView(task: circle.previewTask, isJoinLocked: true)
        }
    }

    private var header: some View {
        HStack(spacing: 4) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.black)
            }
            .buttonStyle(.plain)

            Text("Saved")
                .font(AppTypography.todayTitle())
                .foregroundStyle(AppColors.black)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppLayout.tabBarHorizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .padding(.top, AppLayout.headerVerticalPadding)
    }

    private var savedEmptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart")
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(AppColors.mediumGray)

            Text("No saved circles yet")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.black)

            Text("Heart a circle on Discover and it will show up here.")
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
    SavedView(viewModel: DiscoverViewModel())
}
