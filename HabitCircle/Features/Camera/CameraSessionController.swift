import AVFoundation
import SwiftUI

/// Wraps an `AVCaptureSession` for the photo-verification viewfinder.
/// Falls back to a stand-in image on Simulator (and anywhere without a camera)
/// so the prototype flow stays walkable.
@MainActor
final class CameraSessionController: NSObject, ObservableObject {
    /// Stand-in shot used when no capture device is available.
    static let fallbackAssetName = "GymStairmaster"

    @Published private(set) var isReady = false
    @Published private(set) var isAuthorized = false
    @Published private(set) var hasCaptureDevice = false

    let session = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.habitcircle.camera.session")
    private var isConfigured = false
    private var captureHandler: ((UIImage?) -> Void)?

    var usesFallbackImage: Bool { !hasCaptureDevice || !isAuthorized }

    // MARK: - Lifecycle

    func start() async {
        isAuthorized = await Self.requestAccess()

        guard isAuthorized else {
            markReadyAfterWarmUp()
            return
        }

        configureIfNeeded()

        guard hasCaptureDevice else {
            markReadyAfterWarmUp()
            return
        }

        sessionQueue.async { [session] in
            if !session.isRunning { session.startRunning() }
        }
        markReadyAfterWarmUp()
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
        isReady = false
    }

    /// Brief warm-up so the viewfinder fades in instead of popping (matches the
    /// 620ms "camera waking" beat in the web prototype).
    private func markReadyAfterWarmUp() {
        Task {
            try? await Task.sleep(nanoseconds: 620_000_000)
            withAnimation(.easeOut(duration: 0.25)) { self.isReady = true }
        }
    }

    private static func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    private func configureIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            hasCaptureDevice = false
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }

        session.commitConfiguration()
        hasCaptureDevice = session.inputs.isEmpty == false
    }

    // MARK: - Capture

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard !usesFallbackImage else {
            completion(UIImage(named: Self.fallbackAssetName))
            return
        }

        captureHandler = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraSessionController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let image = photo.fileDataRepresentation().flatMap(UIImage.init(data:))
        Task { @MainActor in
            let handler = self.captureHandler
            self.captureHandler = nil
            handler?(image ?? UIImage(named: Self.fallbackAssetName))
        }
    }
}

/// Hosts the live `AVCaptureVideoPreviewLayer`.
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            // swiftlint:disable:next force_cast
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
