import SwiftUI

struct DiscoverCircleCard: View {
    let circle: DiscoverCircle
    var onJoin: () -> Void = {}
    var onToggleLike: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                iconCircle

                VStack(alignment: .leading, spacing: 4) {
                    Text(circle.title)
                        .font(AppTypography.taskTitle())
                        .foregroundStyle(AppColors.black)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        Text(circle.duration)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(AppColors.darkGray)

                        Text("•")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(AppColors.darkGray)

                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.darkGray)

                        Text("\(circle.memberCount)")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(AppColors.darkGray)
                    }
                }

                Spacer(minLength: 0)
            }

            Text(circle.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppColors.darkGray)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center) {
                Button(action: onToggleLike) {
                    Image(systemName: circle.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(circle.isLiked ? AppColors.pink : AppColors.darkGray)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: onJoin) {
                    Text("Join")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(AppColors.white)
                        .frame(width: 108, height: 32)
                        .background(AppColors.black, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.lightGray, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var iconCircle: some View {
        Image(circle.iconAsset)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 64, height: 59)
    }
}
