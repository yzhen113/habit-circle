import SwiftUI

// MARK: - Step 1 · Name and description

struct CreateNameStep: View {
    @ObservedObject var viewModel: CreateCircleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 10) {
                CreateFieldLabel(title: "Group Name", requirement: "Required")
                CreatePillTextField(placeholder: "Name your circle", text: $viewModel.draft.groupName)
            }

            VStack(alignment: .leading, spacing: 10) {
                CreateFieldLabel(title: "Goal Name", requirement: "Required")
                CreatePillTextField(placeholder: "Name the habit", text: $viewModel.draft.goalName)
            }

            VStack(alignment: .leading, spacing: 10) {
                CreateFieldLabel(title: "Description", requirement: "Optional")
                CreatePillTextEditor(
                    placeholder: "Write a description for your Habit Circle...",
                    text: $viewModel.draft.details
                )
            }
        }
    }
}

// MARK: - Step 2 · Category

struct CreateCategoryStep: View {
    @ObservedObject var viewModel: CreateCircleViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(TaskCategory.createOptions, id: \.self) { category in
                CreateCategoryCard(
                    category: category,
                    isSelected: viewModel.draft.category == category
                ) {
                    viewModel.draft.category = category
                }
            }
        }
    }
}

// MARK: - Step 3 · Habit rules

struct CreateRulesStep: View {
    @ObservedObject var viewModel: CreateCircleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 12) {
                CreateFieldLabel(title: "Duration", requirement: "Required")

                FlowLayout(spacing: 10) {
                    ForEach(HabitDuration.allCases) { duration in
                        CreateSelectionChip(
                            title: duration.title,
                            isSelected: viewModel.draft.duration == duration
                        ) {
                            viewModel.draft.duration = duration
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                CreateFieldLabel(title: "Reminder Frequency", requirement: "Required")

                HStack(spacing: 12) {
                    CreateValueChip(title: viewModel.draft.reminderTimeText) {
                        viewModel.activeSheet = .reminderTime
                    }
                    CreateValueChip(title: viewModel.draft.repeatText) {
                        viewModel.activeSheet = .repeats
                    }
                }
            }

            Toggle(isOn: $viewModel.draft.photoVerification) {
                Text("Photo Verification Mode")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.black)
            }
            .tint(AppColors.green)
        }
    }
}

// MARK: - Step 4 · Join settings

struct CreateJoinSettingsStep: View {
    @ObservedObject var viewModel: CreateCircleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 12) {
                CreateFieldLabel(title: "Visibility", requirement: "Required")

                Button {
                    viewModel.activeSheet = .visibility
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: viewModel.draft.visibility.systemImage)
                            .font(.system(size: 17))
                            .foregroundStyle(AppColors.black)
                            .frame(width: 22)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.draft.visibility.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(AppColors.black)
                            Text(viewModel.draft.visibility.hint)
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.darkGray)
                        }

                        Spacer(minLength: 8)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(hex: 0x777C89))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .frame(minHeight: 64)
                    .background(
                        AppColors.lightGray,
                        in: RoundedRectangle(cornerRadius: CreateFormMetrics.fieldCornerRadius, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 14) {
                CreateFieldLabel(title: "Add Member", requirement: "Optional")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(Array(viewModel.draft.members.enumerated()), id: \.element.id) { index, member in
                            CreateMemberAvatar(member: member, index: index) {
                                viewModel.toggleInvite(member)
                            }
                        }

                        CreateAddMemberButton {
                            viewModel.addSuggestedMember()
                        }
                    }
                    .padding(.vertical, 2)
                }
                .scrollClipDisabled()
            }
        }
    }
}

// MARK: - Step 5 · Success

struct CreateSuccessStep: View {
    @ObservedObject var viewModel: CreateCircleViewModel

    private var category: TaskCategory { viewModel.draft.category ?? .routine }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 40)

            Image(category.circleAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 81, height: 81)
                .frame(width: 122, height: 122)
                .background(category.tintColor, in: Circle())
                .overlay {
                    Circle().strokeBorder(category.accentColor, lineWidth: 2)
                }

            VStack(spacing: 10) {
                Text("You've completed creating your Habit Circle!")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColors.black)

                Text("You will be able to view your Habit Circle on your Home Page.")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.darkGray)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: 300)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Wrapping row layout for the duration chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += rowWidth > 0 ? spacing + size.width : size.width
                rowHeight = max(rowHeight, size.height)
            }
        }

        return CGSize(width: maxWidth == .infinity ? rowWidth : maxWidth, height: totalHeight + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
