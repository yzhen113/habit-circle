import SwiftUI

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var circles: [DiscoverCircle]
    @Published var categories = DiscoverCategory.all
    @Published var selectedCategoryID: String?
    @Published var searchText = ""

    init() {
        circles = DiscoverCircle.samples
    }

    /// Hearted circles for the Home → Saved list.
    var likedCircles: [DiscoverCircle] {
        circles.filter(\.isLiked)
    }

    var filteredCircles: [DiscoverCircle] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return circles.filter { circle in
            // While searching, match title + description across all categories.
            if !query.isEmpty {
                return circle.title.localizedCaseInsensitiveContains(query)
                    || circle.description.localizedCaseInsensitiveContains(query)
            }
            if let selectedCategoryID, circle.filterCategoryID != selectedCategoryID {
                return false
            }
            return true
        }
    }

    func toggleLike(circleID: UUID) {
        guard let index = circles.firstIndex(where: { $0.id == circleID }) else { return }
        circles[index].isLiked.toggle()
    }

    func selectCategory(_ categoryID: String?) {
        selectedCategoryID = categoryID == selectedCategoryID ? nil : categoryID
    }

    func clearCategoryFilter() {
        selectedCategoryID = nil
    }
}
