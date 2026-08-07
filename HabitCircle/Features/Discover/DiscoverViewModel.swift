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

    var filteredCircles: [DiscoverCircle] {
        circles.filter { circle in
            guard searchText.isEmpty else {
                return circle.title.localizedCaseInsensitiveContains(searchText)
                    || circle.description.localizedCaseInsensitiveContains(searchText)
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
}
