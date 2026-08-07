import PhotosUI
import SwiftUI

/// ChatGPT-style composer: photo preview lives inside an expanded glass field above the text row.
struct ChatComposerBar: View {
    @ObservedObject var viewModel: HabitDetailViewModel
    @FocusState.Binding var inputFocused: Bool

    private let attachmentMenuWidth: CGFloat = 204
    private let attachmentThumbnailSize: CGFloat = 88
    private let composerCornerRadius: CGFloat = 26

    private var hasAttachment: Bool { viewModel.pendingAttachment != nil }

    var body: some View {
        composerCard
            .animation(.spring(response: 0.32, dampingFraction: 0.86), value: viewModel.showAttachmentMenu)
    }

    private var attachmentMenu: some View {
        VStack(spacing: 0) {
            attachmentRow(icon: "camera", title: "Camera") {
                viewModel.openCameraFromChat()
            }

            Divider().padding(.leading, 44)

            PhotosPicker(selection: $viewModel.photoPickerItem, matching: .images, photoLibrary: .shared()) {
                attachmentRowLabel(icon: "photo.on.rectangle", title: "Photos")
            }
            .onChange(of: viewModel.photoPickerItem) { _, newItem in
                if newItem != nil { viewModel.dismissAttachmentMenu() }
            }
        }
        .padding(.vertical, 4)
        .frame(width: attachmentMenuWidth, alignment: .leading)
        .background(glassPanel(in: RoundedRectangle(cornerRadius: 22, style: .continuous)))
    }

    private func attachmentRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            attachmentRowLabel(icon: icon, title: title)
        }
        .buttonStyle(.plain)
    }

    private func attachmentRowLabel(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColors.black)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppColors.black)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }

    private var composerCard: some View {
        ZStack(alignment: .bottomLeading) {
            HStack(alignment: .bottom, spacing: 10) {
                GlassComposerAddButton {
                    viewModel.toggleAttachmentMenu()
                }

                composerField
            }

            if viewModel.showAttachmentMenu {
                attachmentMenu
                    .offset(x: AppLayout.composerRowHeight + 10)
                    .transition(
                        .scale(scale: 0.9, anchor: .bottomLeading)
                            .combined(with: .opacity)
                    )
                    .zIndex(2)
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: viewModel.canSend)
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: hasAttachment)
    }

    private var composerField: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let attachment = viewModel.pendingAttachment {
                attachmentPreview(attachment)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            HStack(alignment: .bottom, spacing: 8) {
                TextField(
                    viewModel.needsPhotoToUnlock ? "Post photo to view the circle" : "Text the circle",
                    text: $viewModel.draft,
                    axis: .vertical
                )
                .font(.system(size: 17))
                .lineLimit(1...4)
                .focused($inputFocused)
                .allowsHitTesting(!viewModel.showAttachmentMenu)

                if viewModel.canSend {
                    Button {
                        viewModel.sendComposerMessage()
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppColors.white)
                            .frame(width: 32, height: 32)
                            .background(viewModel.accentColor, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(AppColors.mediumGray)
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 10)
            .padding(.vertical, 8)
            .frame(minHeight: AppLayout.composerRowHeight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if hasAttachment {
                glassPanel(in: RoundedRectangle(cornerRadius: composerCornerRadius, style: .continuous))
            } else {
                glassPanel(in: Capsule(style: .continuous))
            }
        }
    }

    private func attachmentPreview(_ attachment: ChatAttachment) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let asset = attachment.previewAssetName {
                    Image(asset)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(uiImage: attachment.image)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: attachmentThumbnailSize, height: attachmentThumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button {
                viewModel.removePendingAttachment()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.white)
                    .frame(width: 24, height: 24)
                    .background(.black.opacity(0.55), in: Circle())
            }
            .buttonStyle(.plain)
            .offset(x: 8, y: -8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func glassPanel<S: InsettableShape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            shape
                .fill(.clear)
                .glassEffect(.regular.interactive(), in: shape)
        } else {
            shape
                .fill(Color.white.opacity(0.55))
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape.strokeBorder(Color.white.opacity(0.85), lineWidth: 0.75)
                }
                .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
        }
    }
}
