import SwiftUI

enum TaskIcon: String, CaseIterable {
    case calendar
    case apple
    case dumbbell
    case heart
}

/// Maps the four habit categories to their icon + design-system colors.
/// calendar = routine, apple = food, dumbbell = fitness, heart = misc/personal care.
enum TaskCategory {
    case routine
    case food
    case fitness
    case misc

    var icon: TaskIcon {
        switch self {
        case .routine: return .calendar
        case .food: return .apple
        case .fitness: return .dumbbell
        case .misc: return .heart
        }
    }

    var accentColor: Color {
        switch self {
        case .routine: return AppColors.yellow
        case .food: return AppColors.green
        case .fitness: return AppColors.pink
        case .misc: return AppColors.purple
        }
    }

    var tintColor: Color {
        switch self {
        case .routine: return AppColors.yellowTint
        case .food: return AppColors.greenTint
        case .fitness: return AppColors.pinkTint
        case .misc: return AppColors.purpleTint
        }
    }

    var displayName: String {
        switch self {
        case .routine: return "Routine"
        case .food: return "Healthy Eating"
        case .fitness: return "Fitness"
        case .misc: return "Personal Care"
        }
    }
}

struct TaskItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var reminderText: String
    var participantCount: Int
    var category: TaskCategory
    var accentColor: Color
    var tintColor: Color
    var icon: TaskIcon
    var hasPhotoVerification: Bool
    var isCompleted: Bool
    var sortOrder: Int

    // Detail-page metadata
    var circleName: String
    var detailDescription: String
    var durationText: String
    var frequencyText: String
    var dayNumber: Int

    init(
        id: UUID = UUID(),
        title: String,
        reminderText: String,
        participantCount: Int,
        category: TaskCategory = .fitness,
        accentColor: Color,
        tintColor: Color,
        icon: TaskIcon,
        hasPhotoVerification: Bool = false,
        isCompleted: Bool = false,
        sortOrder: Int,
        circleName: String = "",
        detailDescription: String = "",
        durationText: String = "1 month",
        frequencyText: String = "1/day",
        dayNumber: Int = 9
    ) {
        self.id = id
        self.title = title
        self.reminderText = reminderText
        self.participantCount = participantCount
        self.category = category
        self.accentColor = accentColor
        self.tintColor = tintColor
        self.icon = icon
        self.hasPhotoVerification = hasPhotoVerification
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
        self.circleName = circleName
        self.detailDescription = detailDescription
        self.durationText = durationText
        self.frequencyText = frequencyText
        self.dayNumber = dayNumber
    }

    static func make(
        _ title: String,
        reminder: String,
        members: Int,
        category: TaskCategory,
        photo: Bool = false,
        order: Int,
        circle: String? = nil,
        description: String? = nil,
        duration: String = "1 month",
        day: Int = 9
    ) -> TaskItem {
        TaskItem(
            title: title,
            reminderText: "Reminder \(reminder)",
            participantCount: members,
            category: category,
            accentColor: category.accentColor,
            tintColor: category.tintColor,
            icon: category.icon,
            hasPhotoVerification: photo,
            sortOrder: order,
            circleName: circle ?? "\(title) Circle",
            detailDescription: description ?? TaskItem.defaultDescription(for: category),
            durationText: duration,
            frequencyText: "1/day",
            dayNumber: day
        )
    }

    private static func defaultDescription(for category: TaskCategory) -> String {
        switch category {
        case .routine: return "Build a consistent daily rhythm and stay accountable with your circle."
        case .food: return "Fuel your body with intention and share the wins with people who get it."
        case .fitness: return "Push your limits a little every day — stronger together than alone."
        case .misc: return "Small acts of self-care, done daily, add up to a healthier you."
        }
    }

    static let placeholder = TaskItem(
        title: "",
        reminderText: "",
        participantCount: 0,
        accentColor: AppColors.green,
        tintColor: AppColors.greenTint,
        icon: .calendar,
        sortOrder: 0
    )

    static let samples: [TaskItem] = [
        TaskItem(
            title: "Morning Stretch",
            reminderText: "Reminder 9:00AM",
            participantCount: 1,
            accentColor: AppColors.yellow,
            tintColor: AppColors.yellowTint,
            icon: .calendar,
            sortOrder: 0
        ),
        TaskItem(
            title: "45g Protein Goal",
            reminderText: "Reminder 1:00AM",
            participantCount: 24,
            accentColor: AppColors.green,
            tintColor: AppColors.greenTint,
            icon: .apple,
            sortOrder: 1
        ),
        TaskItem(
            title: "30-min Cardio",
            reminderText: "Reminder 7:00AM",
            participantCount: 10,
            accentColor: AppColors.pink,
            tintColor: AppColors.pinkTint,
            icon: .dumbbell,
            hasPhotoVerification: true,
            sortOrder: 2
        ),
        TaskItem(
            title: "Write My Journal",
            reminderText: "Reminder 10:00AM",
            participantCount: 1,
            accentColor: AppColors.purple,
            tintColor: AppColors.purpleTint,
            icon: .heart,
            sortOrder: 3
        ),
    ]
}
