import SwiftUI

enum CreateCircleSheet: String, Identifiable {
    case reminderTime
    case repeats
    case visibility

    var id: String { rawValue }
}

@MainActor
final class CreateCircleViewModel: ObservableObject {
    /// Steps 1...4 collect input; step 5 is the success screen.
    static let inputStepCount = 4

    @Published var step: Int = 1
    @Published var draft = CircleDraft()
    @Published var activeSheet: CreateCircleSheet?
    @Published var didCopyLink = false

    var isSuccessStep: Bool { step > Self.inputStepCount }

    var progress: Double {
        Double(min(step, Self.inputStepCount)) / Double(Self.inputStepCount)
    }

    var headline: String {
        switch step {
        case 1: return "Name your Habit Circle"
        case 2: return "Category of Habit"
        case 3: return "Set the Habit Rules"
        default: return "Join Settings"
        }
    }

    var canAdvance: Bool {
        switch step {
        case 1:
            return !draft.groupName.trimmed.isEmpty && !draft.goalName.trimmed.isEmpty
        case 2:
            return draft.category != nil
        default:
            return true
        }
    }

    var primaryButtonTitle: String {
        isSuccessStep ? "Get Started" : "Next"
    }

    var isFirstStep: Bool { step == 1 }

    func goBack() {
        guard step > 1 else { return }
        withAnimation(.spring(response: 0.38, dampingFraction: 0.9)) {
            step -= 1
        }
    }

    func goNext() {
        guard canAdvance else { return }
        withAnimation(.spring(response: 0.38, dampingFraction: 0.9)) {
            step += 1
        }
    }

    func copyShareLink() {
        UIPasteboard.general.string = "https://habitcircle.app/join/\(UUID().uuidString.prefix(8))"
        withAnimation(.easeOut(duration: 0.2)) { didCopyLink = true }

        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            withAnimation(.easeOut(duration: 0.2)) { self.didCopyLink = false }
        }
    }

    func addSuggestedMember() {
        let taken = Set(draft.members.map(\.name))
        guard let next = CircleDraft.suggestedMembers.first(where: { !taken.contains($0) }) else { return }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            draft.members.append(CircleMember(name: next))
        }
    }

    func toggleInvite(_ member: CircleMember) {
        guard !member.isSelf,
              let index = draft.members.firstIndex(where: { $0.id == member.id }) else { return }
        withAnimation(.easeOut(duration: 0.18)) {
            draft.members[index].isInvited.toggle()
        }
    }

    /// Converts the finished draft into a home-screen task.
    func makeTask(sortOrder: Int) -> TaskItem {
        let category = draft.category ?? .routine
        let goal = draft.goalName.trimmed
        let group = draft.groupName.trimmed

        return TaskItem(
            title: goal.isEmpty ? group : goal,
            reminderText: "Reminder \(draft.reminderTimeText)",
            participantCount: max(draft.invitedCount, 1),
            category: category,
            accentColor: category.accentColor,
            tintColor: category.tintColor,
            icon: category.icon,
            hasPhotoVerification: draft.photoVerification,
            sortOrder: sortOrder,
            circleName: group.isEmpty ? goal : group,
            detailDescription: draft.details.trimmed,
            durationText: draft.duration == .custom ? "Custom" : draft.duration.title,
            frequencyText: draft.repeatRule == .daily ? "1/day" : draft.repeatText,
            dayNumber: 1
        )
    }
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
