import SwiftUI

struct DiscoverCircle: Identifiable, Equatable {
    let id: UUID
    let title: String
    let duration: String
    let memberCount: Int
    let description: String
    let iconAsset: String
    var isLiked: Bool

    init(
        id: UUID = UUID(),
        title: String,
        duration: String,
        memberCount: Int,
        description: String,
        iconAsset: String,
        isLiked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.duration = duration
        self.memberCount = memberCount
        self.description = description
        self.iconAsset = iconAsset
        self.isLiked = isLiked
    }

    var category: TaskCategory {
        switch iconAsset {
        case "CircleFitness": return .fitness
        case "CircleEating": return .food
        case "CircleRoutine": return .routine
        default: return .misc
        }
    }

    /// The circle rendered as a habit, for the locked Discover preview.
    var previewTask: TaskItem {
        .make(
            title,
            reminder: "7:00AM",
            members: memberCount,
            category: category,
            photo: true,
            order: 0,
            circle: title,
            description: description,
            duration: duration
        )
    }

    static let samples: [DiscoverCircle] = [
        DiscoverCircle(
            title: "Weight Training for Beginners",
            duration: "3 months",
            memberCount: 10,
            description: "Overcoming the fear of weights and empowered to get stronger in the gym!",
            iconAsset: "CircleFitness"
        ),
        DiscoverCircle(
            title: "Healthy Vegans",
            duration: "2 weeks",
            memberCount: 26,
            description: "Trying to find healthy, vegan meals that are tasty, inexpensive, and quick.",
            iconAsset: "CircleEating"
        ),
        DiscoverCircle(
            title: "Screen Time Under 4 Hours",
            duration: "6 months",
            memberCount: 82,
            description: "Too much doom scrolling. Let's keep each other accountable with no phone time.",
            iconAsset: "CircleRoutine"
        ),
    ]
}

struct DiscoverCategory: Identifiable, Hashable {
    let id: String
    let title: String

    static let all: [DiscoverCategory] = [
        DiscoverCategory(id: "physical", title: "Physical Health"),
        DiscoverCategory(id: "eating", title: "Healthy Eating"),
        DiscoverCategory(id: "routine", title: "Routine Building"),
        DiscoverCategory(id: "misc", title: "Miscellaneous"),
    ]
}
