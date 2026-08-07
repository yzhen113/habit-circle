import SwiftUI

struct CategoryChipRow: View {
    let categories: [DiscoverCategory]
    let selectedCategoryID: String?
    var onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(categories) { category in
                    Button {
                        onSelect(category.id)
                    } label: {
                        Text(category.title)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(AppColors.black)
                            .padding(.vertical, 9)
                            .padding(.horizontal, 17)
                            .background(
                                selectedCategoryID == category.id
                                    ? AppColors.greenTint
                                    : AppColors.lightGray,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.leading, AppLayout.horizontalPadding)
        }
    }
}
