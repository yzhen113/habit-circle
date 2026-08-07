import SwiftUI

struct CircleChatView: View {
    @ObservedObject var viewModel: HabitDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var inputFocused: Bool

    private let headerHeight: CGFloat = 92

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.white.ignoresSafeArea()

            ZStack(alignment: .top) {
                ZStack {
                    messagesList

                    if !viewModel.chatUnlocked {
                        Color.white.opacity(0.25).ignoresSafeArea()
                        lockOverlay
                    }
                }

                header
                    .background {
                        BlurHeaderBackground()
                            .ignoresSafeArea(edges: .top)
                    }
            }

            ChatComposerBar(viewModel: viewModel, inputFocused: $inputFocused)
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.bottom, 10)
        }
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.focusComposerOnAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    inputFocused = true
                    viewModel.focusComposerOnAppear = false
                }
            }
        }
        .onChange(of: viewModel.photoPickerItem) { _, newItem in
            guard newItem != nil else { return }
            Task { await viewModel.loadPickedPhoto() }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.black)
            }

            HabitCategoryIcon(icon: viewModel.icon, accentColor: viewModel.accentColor)
                .frame(width: 44, height: 44)
                .padding(.leading, 5)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    Text(viewModel.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.black)
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.darkGray)
                    Text("\(viewModel.memberCount)")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.darkGray)
                }
                HStack(spacing: 6) {
                    Text(viewModel.durationText)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.darkGray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppColors.lightGray, in: Capsule())
                    if viewModel.requiresPhoto {
                        HStack(spacing: 4) {
                            Image(systemName: "camera")
                                .font(.system(size: 11))
                                .foregroundStyle(AppColors.darkGray)
                            Text(viewModel.frequencyText)
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.darkGray)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppColors.lightGray, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }

            Spacer(minLength: 8)

            VStack(spacing: 0) {
                Text("Day")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.darkGray)
                Text("\(viewModel.dayNumber)")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(viewModel.isCompleted ? viewModel.accentColor : AppColors.darkGray)
            }
            .frame(width: 42)
            .padding(7)
            .background(
                viewModel.isCompleted ? viewModel.tintColor : AppColors.lightGray,
                in: RoundedRectangle(cornerRadius: 15, style: .continuous)
            )
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Messages

    private var messagesList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: ChatBubbleMetrics.spacing) {
                ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                    ChatBubble(
                        message: message,
                        accentColor: viewModel.accentColor,
                        avatarColorIndex: viewModel.avatarColorIndex(for: message.sender),
                        showsAvatar: isLastInSenderCluster(at: index)
                    )
                }
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.top, headerHeight + 8)
            .padding(.bottom, 140)
        }
        .blur(radius: viewModel.chatUnlocked ? 0 : 9)
        .allowsHitTesting(viewModel.chatUnlocked)
    }

    private func isLastInSenderCluster(at index: Int) -> Bool {
        let messages = viewModel.messages
        guard index + 1 < messages.count else { return true }
        return !isSameSender(messages[index], messages[index + 1])
    }

    private func isSameSender(_ lhs: ChatMessage, _ rhs: ChatMessage) -> Bool {
        lhs.isMine == rhs.isMine && lhs.sender == rhs.sender
    }

    // MARK: - Lock overlay

    /// The locked thread's own way into the camera, so the only route to
    /// unlocking it isn't a trip back to the detail page.
    private var lockOverlay: some View {
        VStack(spacing: 8) {
            Text("Post to view")
                .font(.system(size: 14, weight: .semibold))
                .kerning(-0.35)
                .foregroundStyle(AppColors.black)

            Button {
                viewModel.openCameraFromChat()
            } label: {
                Label("Photo Verification", systemImage: "camera")
                    .font(.system(size: 15))
                    .kerning(-0.23)
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .tint(AppColors.black)
            .frame(width: 303, height: 44)
        }
        // Figma 1330:8814 sits the column just below the vertical midpoint.
        .padding(.top, 78)
    }
}

// MARK: - Bubble

private struct ChatBubble: View {
    let message: ChatMessage
    let accentColor: Color
    var avatarColorIndex: Int?
    var showsAvatar: Bool = true

    private let bubbleGray = Color(hex: 0xE9E9EB)

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if message.isMine {
                Spacer(minLength: 40)
                content
            } else {
                avatar
                content
                Spacer(minLength: 40)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch message.body {
        case .text(let text):
            ChatSpeechBubble(color: message.isMine ? accentColor : bubbleGray) {
                Text(text)
                    .foregroundStyle(message.isMine ? AppColors.white : AppColors.black.opacity(0.9))
            }
        case .image(let name):
            imageBubble {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
        case .photo(let uiImage):
            imageBubble {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
    }

    private func imageBubble<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(width: 190, height: 224)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    /// Only the last bubble in a sender's run shows the avatar; the others keep
    /// the slot so the bubbles stay left-aligned.
    private var avatar: some View {
        ChatMemberAvatar(name: message.sender, colorIndex: avatarColorIndex)
            .opacity(showsAvatar ? 1 : 0)
    }
}
