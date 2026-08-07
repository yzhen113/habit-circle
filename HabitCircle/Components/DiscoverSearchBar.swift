import SwiftUI

struct DiscoverSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppColors.darkGray)

            TextField("Search...", text: $text)
                .font(AppTypography.metadata())
                .foregroundStyle(AppColors.black)
        }
        .padding(.horizontal, 16)
        .frame(height: 36)
        .background(AppColors.lightGray, in: Capsule())
    }
}
