import SwiftUI

/// How long the circle runs for.
enum HabitDuration: String, CaseIterable, Identifiable {
    case oneWeek = "1 week"
    case oneMonth = "1 month"
    case threeMonths = "3 months"
    case oneYear = "1 year"
    case custom = "Custom"

    var id: String { rawValue }
    var title: String { rawValue }
}

/// Reminder cadence chosen in the "Repeats" sheet.
enum RepeatRule: String, CaseIterable, Identifiable {
    case daily
    case weekly
    case monthly
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: return "Every Day"
        case .weekly: return "Every Week"
        case .monthly: return "Every Month"
        case .custom: return "Custom"
        }
    }
}

enum RepeatUnit: String, CaseIterable, Identifiable {
    case days
    case weeks
    case months

    var id: String { rawValue }
    var title: String { rawValue }
}

enum CircleVisibility: String, CaseIterable, Identifiable {
    case restricted
    case open

    var id: String { rawValue }

    var title: String {
        switch self {
        case .restricted: return "Restricted"
        case .open: return "Public"
        }
    }

    var hint: String {
        switch self {
        case .restricted: return "Only people with access can join the group"
        case .open: return "Anyone can find and join the group"
        }
    }

    var systemImage: String {
        switch self {
        case .restricted: return "lock.fill"
        case .open: return "globe"
        }
    }
}

/// A person on the invite roster for a new circle.
struct CircleMember: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var isInvited: Bool = true
    /// `true` for the circle creator, who can never be removed.
    var isSelf: Bool = false

    var initial: String { String(name.prefix(1)).uppercased() }
}

/// Everything the create-circle wizard collects before a `TaskItem` is made.
struct CircleDraft {
    var groupName: String = ""
    var goalName: String = ""
    var details: String = ""
    var category: TaskCategory?
    var duration: HabitDuration = .oneMonth
    var reminderTime: Date = CircleDraft.defaultReminderTime
    var repeatRule: RepeatRule = .daily
    var customInterval: Int = 2
    var customUnit: RepeatUnit = .days
    var visibility: CircleVisibility = .restricted
    var photoVerification: Bool = false
    var members: [CircleMember] = [
        CircleMember(name: "You", isSelf: true),
        CircleMember(name: "Harry"),
        CircleMember(name: "Zoe"),
        CircleMember(name: "Bob"),
    ]

    var invitedCount: Int {
        members.filter(\.isInvited).count
    }

    var reminderTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: reminderTime)
    }

    var repeatText: String {
        guard repeatRule == .custom else { return repeatRule.title }
        return "Every \(customInterval) \(customUnit.title)"
    }

    static let defaultReminderTime: Date = {
        var components = DateComponents()
        components.hour = 10
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()

    /// Names offered by the "Add" button on the join-settings step.
    static let suggestedMembers = ["Mia", "Leo", "Ada", "Nia"]
}

extension TaskCategory {
    /// The four cards on the "Category of Habit" step, in display order.
    static let createOptions: [TaskCategory] = [.fitness, .food, .routine, .misc]

    /// Longer label used only in the create flow (Figma 1330:8032).
    var createTitle: String {
        switch self {
        case .fitness: return "Physical Health"
        case .food: return "Healthy Eating"
        case .routine: return "Routine Building"
        case .misc: return "Miscellaneous"
        }
    }

    var circleAssetName: String {
        switch self {
        case .routine: return "CircleRoutine"
        case .food: return "CircleEating"
        case .fitness: return "CircleFitness"
        case .misc: return "CircleMisc"
        }
    }
}
