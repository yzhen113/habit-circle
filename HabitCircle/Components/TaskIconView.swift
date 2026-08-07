import SwiftUI

struct TaskIconView: View {
    let icon: TaskIcon
    let accentColor: Color
    var desaturated: Bool = false

    private var assetName: String? {
        switch icon {
        case .calendar: return "CircleRoutine"
        case .apple: return "CircleEating"
        case .dumbbell: return "CircleFitness"
        case .heart: return "CircleMisc"
        }
    }

    var body: some View {
        Group {
            if let assetName, UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .grayscale(desaturated ? 1 : 0)
                    .opacity(desaturated ? 0.45 : 1)
            } else {
                fallbackIcon
            }
        }
        .frame(width: 67, height: 67)
    }

    @ViewBuilder
    private var fallbackIcon: some View {
        let color = desaturated ? AppColors.mediumGray : accentColor
        switch icon {
        case .calendar:
            CalendarIcon(color: color)
        case .apple:
            AppleIcon(color: color)
        case .dumbbell:
            DumbbellIcon(color: color)
        case .heart:
            HeartIcon(color: color)
        }
    }
}

private struct CalendarIcon: View {
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color)
                .frame(width: 52, height: 54)
            Text("1")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .offset(y: 4)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(color.opacity(0.85))
                .frame(width: 52, height: 12)
                .offset(y: -24)
        }
    }
}

private struct AppleIcon: View {
    let color: Color

    var body: some View {
        Image(systemName: "apple.logo")
            .font(.system(size: 44, weight: .regular))
            .foregroundStyle(color)
    }
}

private struct DumbbellIcon: View {
    let color: Color

    var body: some View {
        Image(systemName: "dumbbell.fill")
            .font(.system(size: 40, weight: .semibold))
            .foregroundStyle(color)
            .rotationEffect(.degrees(-25))
    }
}

private struct HeartIcon: View {
    let color: Color

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 44, weight: .regular))
            .foregroundStyle(color)
    }
}
