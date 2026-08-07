import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var discoverViewModel: DiscoverViewModel
    @State private var openedHabit: OpenedHabit?
    @State private var showSaved = false

    var body: some View {
        VStack(spacing: 8) {
            header

            CenteredDateStrip(
                days: viewModel.dayCells,
                selectedOffset: viewModel.selectedOffset
            ) { offset in
                withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                    viewModel.selectDay(offset)
                }
            }
            .padding(.horizontal, AppLayout.horizontalPadding)

            GeometryReader { pageGeometry in
                let tabBarInset = AppLayout.floatingTabBarHeight + pageGeometry.safeAreaInsets.bottom
                let bottomInset = tabBarInset + 24

                TabView(selection: daySelectionBinding) {
                    ForEach(viewModel.offsets, id: \.self) { offset in
                        dayContent(offset: offset, bottomInset: bottomInset, tabBarInset: tabBarInset)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .tag(offset)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .frame(maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
        }
        .padding(.top, AppLayout.headerVerticalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColors.white)
        .fullScreenCover(item: $openedHabit) { opened in
            HabitDetailView(task: opened.task) {
                viewModel.markCompleted(offset: opened.offset, taskID: opened.task.id)
            }
        }
        .fullScreenCover(isPresented: $showSaved) {
            SavedView(viewModel: discoverViewModel)
        }
    }

    private var daySelectionBinding: Binding<Int> {
        Binding(
            get: { viewModel.selectedOffset },
            set: { newValue in
                withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
                    viewModel.selectDay(newValue)
                }
            }
        )
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text(viewModel.headerTitle)
                .font(AppTypography.todayTitle())
                .foregroundStyle(AppColors.black)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.35), value: viewModel.selectedOffset)

            Spacer(minLength: 12)

            Button {
                showSaved = true
            } label: {
                // Always outline — fill state lives on Discover/Saved card hearts only.
                Image(systemName: "heart")
                    .font(.system(size: AppLayout.heartIconSize, weight: .regular))
                    .foregroundStyle(AppColors.dateUnselected)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppLayout.tabBarHorizontalPadding)
        .padding(.vertical, AppLayout.headerVerticalPadding)
    }

    @ViewBuilder
    private func dayContent(offset: Int, bottomInset: CGFloat, tabBarInset: CGFloat) -> some View {
        if viewModel.tasks(for: offset).isEmpty {
            // Centered in the space between the date strip and the tab bar.
            EmptyTasksView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, tabBarInset)
        } else {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppLayout.taskListSpacing) {
                    Text("My Tasks")
                        .font(AppTypography.sectionHeader())
                        .foregroundStyle(AppColors.myTasksLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: AppLayout.taskListSpacing) {
                        ForEach(viewModel.tasks(for: offset)) { task in
                            SwipeToCompleteRow(
                                task: viewModel.taskBinding(offset: offset, taskID: task.id),
                                onComplete: {
                                    viewModel.markCompleted(offset: offset, taskID: task.id)
                                },
                                onUndo: {
                                    viewModel.markIncomplete(offset: offset, taskID: task.id)
                                },
                                onOpen: {
                                    openedHabit = OpenedHabit(offset: offset, task: task)
                                }
                            )
                        }
                    }
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.88),
                        value: viewModel.taskListToken(for: offset)
                    )
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, bottomInset)
            }
            .scrollClipDisabled()
        }
    }
}

/// Identifies which task (and which day) is being opened in the detail sheet.
struct OpenedHabit: Identifiable {
    let offset: Int
    let task: TaskItem
    var id: UUID { task.id }
}

#Preview {
    HomeView(viewModel: HomeViewModel(), discoverViewModel: DiscoverViewModel())
}
