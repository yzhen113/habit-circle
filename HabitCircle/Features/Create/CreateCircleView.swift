import SwiftUI

/// Five-screen wizard for creating a Habit Circle (Figma 1330:7742).
struct CreateCircleView: View {
    @StateObject private var viewModel: CreateCircleViewModel
    @Environment(\.dismiss) private var dismiss

    /// Called with the finished habit when the user taps "Get Started".
    private let onFinish: (TaskItem) -> Void

    init(onFinish: @escaping (TaskItem) -> Void) {
        _viewModel = StateObject(wrappedValue: CreateCircleViewModel())
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            AppColors.white.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        if !viewModel.isSuccessStep {
                            Text(viewModel.headline)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(AppColors.black)
                        }

                        stepContent
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 160)
                }
                .scrollDismissesKeyboard(.interactively)
            }

            VStack {
                Spacer()
                footer
            }
        }
        .sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .reminderTime:
                ReminderTimeSheet(time: $viewModel.draft.reminderTime) {
                    viewModel.activeSheet = nil
                }
            case .repeats:
                RepeatsSheet(
                    rule: $viewModel.draft.repeatRule,
                    interval: $viewModel.draft.customInterval,
                    unit: $viewModel.draft.customUnit
                ) {
                    viewModel.activeSheet = nil
                }
            case .visibility:
                VisibilitySheet(visibility: $viewModel.draft.visibility) {
                    viewModel.activeSheet = nil
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Text("Create Habit Circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.black)

                HStack {
                    Button {
                        if viewModel.isFirstStep {
                            dismiss()
                        } else {
                            viewModel.goBack()
                        }
                    } label: {
                        Image(systemName: viewModel.isFirstStep ? "xmark" : "chevron.left")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(AppColors.black)
                            .frame(width: 32, height: 32, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
            .padding(.horizontal, 20)

            progressBar
                .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(AppColors.lightGray)
                Capsule()
                    .fill(AppColors.green)
                    .frame(width: geometry.size.width * viewModel.progress)
            }
        }
        .frame(height: 8)
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: viewModel.progress)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case 1:
            CreateNameStep(viewModel: viewModel)
                .transition(stepTransition)
        case 2:
            CreateCategoryStep(viewModel: viewModel)
                .transition(stepTransition)
        case 3:
            CreateRulesStep(viewModel: viewModel)
                .transition(stepTransition)
        case 4:
            CreateJoinSettingsStep(viewModel: viewModel)
                .transition(stepTransition)
        default:
            CreateSuccessStep(viewModel: viewModel)
                .transition(.opacity)
        }
    }

    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        )
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 12) {
            CreatePrimaryButton(
                title: viewModel.primaryButtonTitle,
                isDisabled: !viewModel.canAdvance
            ) {
                if viewModel.isSuccessStep {
                    onFinish(viewModel.makeTask(sortOrder: 0))
                    dismiss()
                } else {
                    viewModel.goNext()
                }
            }

            if viewModel.isSuccessStep {
                CreateSecondaryButton(title: viewModel.didCopyLink ? "Link Copied" : "Share Link") {
                    viewModel.copyShareLink()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .background {
            LinearGradient(
                colors: [AppColors.white.opacity(0), AppColors.white, AppColors.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 190)
            .allowsHitTesting(false)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.9), value: viewModel.isSuccessStep)
    }
}

#Preview {
    CreateCircleView { _ in }
}
