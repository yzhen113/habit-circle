import PhotosUI
import SwiftUI

/// Photo-verification camera sheet (Figma 1330:7493 / 1330:7617).
/// Presented over the habit detail or chat; capturing posts straight to the circle.
struct PhotoVerificationCameraView: View {
    var onCapture: (UIImage) -> Void
    var onCancel: () -> Void

    @StateObject private var camera = CameraSessionController()
    @Environment(\.dismiss) private var dismiss
    @State private var isShutterPressed = false
    @State private var libraryItem: PhotosPickerItem?

    private let viewfinderCornerRadius: CGFloat = 15
    private let shutterSize: CGFloat = 70

    var body: some View {
        VStack(spacing: 0) {
            header

            viewfinder
                .padding(.horizontal, 24)
                .padding(.top, 24)

            Spacer(minLength: 16)

            shutterButton

            PhotosPicker(selection: $libraryItem, matching: .images, photoLibrary: .shared()) {
                Text("or choose from your library")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.black.opacity(0.5))
                    .underline()
            }
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.white)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .task { await camera.start() }
        .onDisappear { camera.stop() }
        .onChange(of: libraryItem) { _, newItem in
            guard let newItem else { return }
            Task { await loadFromLibrary(newItem) }
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Photo verification")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.black)

            HStack {
                Button {
                    onCancel()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(AppColors.black)
                        .frame(width: 32, height: 32, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    // MARK: - Viewfinder

    private var viewfinder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: viewfinderCornerRadius, style: .continuous)
                .fill(Color.black)

            // Color.clear keeps `scaledToFill` from widening the layout.
            Color.clear
                .overlay {
                    if camera.usesFallbackImage {
                        Image(CameraSessionController.fallbackAssetName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        CameraPreviewView(session: camera.session)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: viewfinderCornerRadius, style: .continuous))
                .opacity(camera.isReady ? 1 : 0)

            ScanningFrame()
                .stroke(Color(hex: 0x757575), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .padding(2)
        }
        .aspectRatio(354 / 515.62, contentMode: .fit)
    }

    // MARK: - Shutter

    private var shutterButton: some View {
        Button(action: capture) {
            ZStack {
                Circle()
                    .fill(AppColors.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 4)

                Circle()
                    .fill(Color(hex: 0xD9D9D9))
                    .frame(width: shutterSize - 6, height: shutterSize - 6)

                Circle()
                    .fill(AppColors.white)
                    .frame(width: shutterSize - 12, height: shutterSize - 12)
                    .opacity(isShutterPressed ? 0 : 1)
            }
            .frame(width: shutterSize, height: shutterSize)
        }
        .buttonStyle(.plain)
        .disabled(!camera.isReady)
        .opacity(camera.isReady ? 1 : 0.5)
        .animation(.easeOut(duration: 0.12), value: isShutterPressed)
    }

    private func capture() {
        withAnimation { isShutterPressed = true }

        camera.capturePhoto { image in
            guard let image else {
                isShutterPressed = false
                return
            }
            finish(with: image)
        }
    }

    private func loadFromLibrary(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        finish(with: image)
    }

    private func finish(with image: UIImage) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onCapture(image)
        dismiss()
    }
}

/// Four corner brackets that frame the shot (Figma "Scanning" 1330:7610).
struct ScanningFrame: Shape {
    var cornerLength: CGFloat = 44
    var cornerRadius: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length = min(cornerLength, min(rect.width, rect.height) / 2)
        let radius = min(cornerRadius, length)

        // Top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        // Top-right
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        // Bottom-right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))

        // Bottom-left
        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - radius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))

        return path
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            PhotoVerificationCameraView(onCapture: { _ in }, onCancel: {})
        }
}
