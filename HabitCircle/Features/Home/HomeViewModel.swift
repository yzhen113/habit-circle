import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedOffset: Int = 0
    @Published var tasksByOffset: [Int: [TaskItem]]

    /// Offset 0 == "today". Anchored to Thu Feb 12, 2026 (a real Thursday-the-12th)
    /// so weekday labels line up with the mock (Thu 12, week = Mon 9 … Sun 15).
    let baseDate: Date
    let offsets: [Int] = Array(-60...60)

    private let calendar = Calendar.current
    private let shortWeekdayFormatter: DateFormatter
    private let monthFormatter: DateFormatter

    init() {
        baseDate = HomeViewModel.makeBaseDate()
        tasksByOffset = HomeViewModel.makeTasksByOffset()

        shortWeekdayFormatter = DateFormatter()
        shortWeekdayFormatter.dateFormat = "EEE"
        monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
    }

    func selectDay(_ offset: Int) {
        guard offsets.contains(offset) else { return }
        selectedOffset = offset
    }

    func date(forOffset offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: baseDate) ?? baseDate
    }

    var dayCells: [DayCell] {
        offsets.map { offset in
            let date = date(forOffset: offset)
            return DayCell(
                offset: offset,
                weekday: shortWeekdayFormatter.string(from: date),
                dayNumber: calendar.component(.day, from: date)
            )
        }
    }

    /// e.g. "Feb 12"
    var headerTitle: String {
        let date = date(forOffset: selectedOffset)
        let day = calendar.component(.day, from: date)
        return "\(monthFormatter.string(from: date)) \(day)"
    }

    func tasks(for offset: Int) -> [TaskItem] {
        tasksByOffset[offset] ?? []
    }

    /// Changes when task order or completion state updates — drives list animations.
    func taskListToken(for offset: Int) -> String {
        (tasksByOffset[offset] ?? [])
            .map { "\($0.id.uuidString):\($0.isCompleted):\($0.sortOrder)" }
            .joined(separator: "|")
    }

    func taskBinding(offset: Int, taskID: UUID) -> Binding<TaskItem> {
        Binding(
            get: { [weak self] in
                self?.tasksByOffset[offset]?.first(where: { $0.id == taskID }) ?? .placeholder
            },
            set: { [weak self] newValue in
                guard let self else { return }
                if let index = self.tasksByOffset[offset]?.firstIndex(where: { $0.id == taskID }) {
                    self.tasksByOffset[offset]?[index] = newValue
                }
            }
        )
    }

    /// Drops a freshly created circle at the top of today's list.
    func addCreatedTask(_ task: TaskItem) {
        var newTask = task
        newTask.sortOrder = -1
        selectedOffset = 0

        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
            tasksByOffset[0, default: []].insert(newTask, at: 0)
        }
    }

    func markCompleted(offset: Int, taskID: UUID) {
        setCompleted(true, offset: offset, taskID: taskID)
    }

    /// Undo for an accidental swipe — returns the task to its original slot.
    func markIncomplete(offset: Int, taskID: UUID) {
        setCompleted(false, offset: offset, taskID: taskID)
    }

    private func setCompleted(_ isCompleted: Bool, offset: Int, taskID: UUID) {
        guard var dayTasks = tasksByOffset[offset],
              let index = dayTasks.firstIndex(where: { $0.id == taskID }),
              dayTasks[index].isCompleted != isCompleted else { return }

        dayTasks[index].isCompleted = isCompleted

        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
            tasksByOffset[offset] = dayTasks.sorted { lhs, rhs in
                if lhs.isCompleted != rhs.isCompleted {
                    return !lhs.isCompleted && rhs.isCompleted
                }
                return lhs.sortOrder < rhs.sortOrder
            }
        }
    }

    private static func makeBaseDate() -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 12
        return Calendar.current.date(from: components) ?? Date()
    }

    private static func makeTasksByOffset() -> [Int: [TaskItem]] {
        var result: [Int: [TaskItem]] = [:]

        // Wednesday (offset -1)
        result[-1] = [
            .make("Morning Run", reminder: "6:30AM", members: 8, category: .fitness, order: 0),
            .make("Meal Prep Lunches", reminder: "5:00PM", members: 12, category: .food, order: 1),
            .make("Read 20 Pages", reminder: "9:00PM", members: 1, category: .routine, order: 2),
            .make("Call Mom", reminder: "7:00PM", members: 1, category: .misc, order: 3),
        ]

        // Thursday (offset 0) — "today", 8 tasks.
        result[0] = [
            .make("Morning Stretch", reminder: "9:00AM", members: 1, category: .routine, order: 0),
            .make("45g Protein Goal", reminder: "1:00PM", members: 24, category: .food, order: 1),
            .make("30-min Cardio", reminder: "7:00AM", members: 10, category: .fitness, photo: true, order: 2,
                  circle: "Stairmasterers", description: "30 minutes of steady cardio a day. Snap a gym pic to keep the circle honest and cheering each other on.", duration: "1 month", day: 9),
            .make("Write My Journal", reminder: "10:00AM", members: 1, category: .misc, order: 3),
            .make("Push-up Set", reminder: "6:00PM", members: 5, category: .fitness, order: 4),
            .make("Evening Skincare", reminder: "8:30PM", members: 1, category: .misc, order: 5),
            .make("Hydration Check-in", reminder: "3:00PM", members: 6, category: .routine, order: 6),
            .make("Meditation Timer", reminder: "9:30PM", members: 3, category: .misc, order: 7),
        ]

        // Friday (offset +1)
        result[1] = [
            .make("Sunrise Yoga Flow", reminder: "8:00AM", members: 15, category: .fitness, order: 0),
            .make("No Sugar Day", reminder: "12:00PM", members: 30, category: .food, order: 1),
            .make("Plan The Weekend", reminder: "6:00PM", members: 1, category: .routine, order: 2),
            .make("Gratitude Journal", reminder: "10:00PM", members: 1, category: .misc, photo: true, order: 3),
        ]

        // Saturday (offset +2) and every other day stay empty -> empty state.
        return result
    }
}
