import PhotosUI
import SwiftUI

/// One day cell in the habit's weekly completion strip.
struct HabitDayStatus: Identifiable {
    enum State {
        case completed
        case partial
        case today
        case upcoming
    }

    let id = UUID()
    let label: String
    var state: State
    /// Share of circle members who completed on this day (0...1).
    var completionFraction: Double
}

/// A single message in the circle group chat.
struct ChatMessage: Identifiable {
    enum Body: Equatable {
        case text(String)
        case image(String)
        case photo(UIImage)

        static func == (lhs: Body, rhs: Body) -> Bool {
            switch (lhs, rhs) {
            case (.text(let a), .text(let b)): return a == b
            case (.image(let a), .image(let b)): return a == b
            case (.photo, .photo): return true
            default: return false
            }
        }
    }

    let id = UUID()
    let isMine: Bool
    let body: Body
    /// Display name of the sender; nil for my own messages.
    var sender: String? = nil
}

/// A shot in the verification history: either a seeded asset from other
/// members, or one the user just captured.
enum VerificationPhoto {
    case asset(String)
    case captured(UIImage)
}

@MainActor
final class HabitDetailViewModel: ObservableObject {
    let title: String
    let circleName: String
    let habitDescription: String
    let categoryName: String
    let durationText: String
    let frequencyText: String
    let memberCount: Int
    let dayNumber: Int
    let requiresPhoto: Bool
    let icon: TaskIcon
    let accentColor: Color
    let tintColor: Color
    @Published var photoHistory: [VerificationPhoto]
    /// Roster order drives each member's avatar color, same as the create flow.
    let members: [String]

    @Published var weekdays: [HabitDayStatus]
    @Published var completedCount: Int
    @Published var isCompleted: Bool
    @Published var chatUnlocked: Bool
    @Published var messages: [ChatMessage]
    @Published var draft: String = ""
    @Published var pendingAttachment: ChatAttachment?
    @Published var showAttachmentMenu = false
    @Published var showCamera = false
    @Published var photoPickerItem: PhotosPickerItem?
    @Published var focusComposerOnAppear = false
    /// Set when the circle is opened as a Discover preview: everything is
    /// blurred behind a "Join to view" gate until the user joins.
    @Published var isJoinLocked = false

    /// True between opening the verification camera and posting (or cancelling).
    /// Backing out of the camera must not complete the habit.
    private(set) var awaitingVerification = false
    private var capturedPhoto: UIImage?

    var onComplete: () -> Void = {}

    var totalMembers: Int { memberCount }

    /// Circle name without emoji, for the ring caption.
    var displayCircleName: String {
        circleName
            .unicodeScalars
            .filter { !$0.properties.isEmojiPresentation && !$0.properties.isVariationSelector }
            .reduce(into: "") { $0.unicodeScalars.append($1) }
            .trimmed
    }
    var progressFraction: Double {
        guard totalMembers > 0 else { return 0 }
        return min(1, Double(completedCount) / Double(totalMembers))
    }

    var canSend: Bool {
        pendingAttachment != nil || !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var needsPhotoToUnlock: Bool {
        requiresPhoto && !chatUnlocked
    }

    static let rosterNames = [
        "You", "Harry", "Zoe", "Bob", "Mia", "Leo", "Ada", "Nia",
        "Sam", "Ivy", "Theo", "Rae", "Jun", "Ola", "Kit", "Wes",
    ]

    /// Roster position of a sender, which selects their avatar color.
    func avatarColorIndex(for name: String?) -> Int? {
        guard let name else { return nil }
        if let index = members.firstIndex(of: name) { return index }
        // Guests who aren't on the roster still get a stable color.
        return HabitDetailViewModel.rosterNames.firstIndex(of: name)
    }

    func join() {
        withAnimation(.easeOut(duration: 0.35)) { isJoinLocked = false }
    }

    init(task: TaskItem, isJoinLocked: Bool = false, onComplete: @escaping () -> Void = {}) {
        self.isJoinLocked = isJoinLocked
        title = task.title
        circleName = task.circleName.isEmpty ? "\(task.title) Circle" : task.circleName
        habitDescription = task.detailDescription
        categoryName = task.category.displayName
        durationText = task.durationText
        frequencyText = task.frequencyText
        memberCount = max(task.participantCount, 1)
        dayNumber = task.dayNumber
        requiresPhoto = task.hasPhotoVerification
        icon = task.icon
        accentColor = task.accentColor
        tintColor = task.tintColor
        self.onComplete = onComplete

        let base = Int((Double(memberCount) * 0.7).rounded())
        let initialCompleted = min(max(base, 1), memberCount - 1)
        completedCount = initialCompleted
        isCompleted = task.isCompleted
        draft = ""
        pendingAttachment = nil
        showAttachmentMenu = false
        showCamera = false
        focusComposerOnAppear = false

        // The user's own shot is appended on verification, so it isn't seeded here.
        photoHistory = task.hasPhotoVerification
            ? [
                .asset("GymTreadmill"),
                .asset("GymClimbmill"),
                .asset("GymConsole"),
                .asset("GymPlanetConsole"),
                .asset("GymUConn"),
            ]
            : []

        members = Array(HabitDetailViewModel.rosterNames.prefix(max(task.participantCount, 1)))

        chatUnlocked = task.hasPhotoVerification ? task.isCompleted : true

        messages = [
            ChatMessage(isMine: false, body: .image("GymConsole"), sender: "Harry"),
            ChatMessage(isMine: false, body: .text("any song recs for the cardio session?"), sender: "Harry"),
            ChatMessage(isMine: false, body: .text("u can do this guys!"), sender: "Zoe"),
        ]

        let todayFraction = Double(initialCompleted) / Double(memberCount)
        weekdays = [
            HabitDayStatus(label: "Sat", state: .completed, completionFraction: 1),
            HabitDayStatus(label: "Sun", state: .partial, completionFraction: 0.575),
            HabitDayStatus(label: "Mon", state: .completed, completionFraction: 1),
            HabitDayStatus(label: "Tue", state: .today, completionFraction: todayFraction),
            HabitDayStatus(label: "Wed", state: .upcoming, completionFraction: 0),
            HabitDayStatus(label: "Thu", state: .upcoming, completionFraction: 0),
            HabitDayStatus(label: "Fri", state: .upcoming, completionFraction: 0),
        ]

        if task.isCompleted {
            syncTodayPillProgress()
        }
    }

    var ctaTitle: String {
        if isCompleted { return "Completed" }
        return requiresPhoto ? "Verify with Photo" : "Complete Habit"
    }

    var ctaSystemImage: String {
        if isCompleted { return "checkmark" }
        return requiresPhoto ? "camera" : "checkmark"
    }

    /// Non-photo habits complete instantly from the detail page.
    func completeWithoutPhoto() {
        guard !requiresPhoto else { return }
        finishCompletion(includePhotoMessage: false)
    }

    // MARK: - Photo verification

    /// Opens the verification camera over whichever screen is showing.
    func startPhotoVerification() {
        guard requiresPhoto, !isCompleted else { return }
        awaitingVerification = true
        showCamera = true
    }

    func cancelPhotoVerification() {
        awaitingVerification = false
        capturedPhoto = nil
    }

    func stageCapturedPhoto(_ image: UIImage) {
        capturedPhoto = image
    }

    /// Consumed by the presenting view once the camera sheet has dismissed.
    func takeCapturedPhoto() -> UIImage? {
        defer { capturedPhoto = nil }
        return capturedPhoto
    }

    /// Posts the verification shot to the circle chat and completes the habit.
    func postVerificationPhoto(_ image: UIImage) {
        let isVerifying = awaitingVerification || needsPhotoToUnlock
        awaitingVerification = false

        messages.append(ChatMessage(isMine: true, body: .photo(image)))

        withAnimation(.easeOut(duration: 0.25)) {
            chatUnlocked = true
        }

        if isVerifying {
            withAnimation(.easeOut(duration: 0.3)) {
                photoHistory.append(.captured(image))
            }
            finishCompletion(includePhotoMessage: false)
        }
    }

    /// Loads the picked library asset into the composer as a pending attachment.
    func loadPickedPhoto() async {
        guard let item = photoPickerItem else { return }
        photoPickerItem = nil

        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }

        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            attachImage(image)
        }
    }

    func toggleAttachmentMenu() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            showAttachmentMenu.toggle()
        }
    }

    func dismissAttachmentMenu() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            showAttachmentMenu = false
        }
    }

    /// Camera row in the chat attachment menu — reuses the verification camera.
    func openCameraFromChat() {
        dismissAttachmentMenu()
        awaitingVerification = needsPhotoToUnlock
        showCamera = true
    }

    func attachImage(_ image: UIImage, previewAssetName: String? = nil) {
        pendingAttachment = ChatAttachment(image: image, previewAssetName: previewAssetName)
    }

    func removePendingAttachment() {
        pendingAttachment = nil
    }

    func sendComposerMessage() {
        guard canSend else { return }

        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        let photo = pendingAttachment?.image
        let isVerificationPost = needsPhotoToUnlock && photo != nil

        if let photo {
            messages.append(ChatMessage(isMine: true, body: .photo(photo)))
        }

        if !trimmed.isEmpty {
            messages.append(ChatMessage(isMine: true, body: .text(trimmed)))
        }

        draft = ""
        pendingAttachment = nil
        showAttachmentMenu = false

        if isVerificationPost {
            finishCompletion(includePhotoMessage: false)
        }
    }

    private func finishCompletion(includePhotoMessage: Bool) {
        guard !isCompleted else { return }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
            isCompleted = true
            completedCount = min(completedCount + 1, memberCount)
            syncTodayPillProgress()
            if requiresPhoto {
                chatUnlocked = true
            }
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        onComplete()
    }

    func syncTodayPillProgress() {
        guard let index = weekdays.firstIndex(where: { $0.state == .today }) else { return }
        weekdays[index].completionFraction = progressFraction
    }
}
