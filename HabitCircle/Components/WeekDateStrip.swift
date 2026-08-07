import SwiftUI

struct DayCell: Identifiable {
    let offset: Int
    let weekday: String
    let dayNumber: Int
    var id: Int { offset }
}

/// A horizontal date strip that keeps the selected day locked to the center and
/// slides ("rotates") the surrounding days as the selection changes.
struct CenteredDateStrip: View {
    let days: [DayCell]
    let selectedOffset: Int
    var onSelect: (Int) -> Void = { _ in }

    private let visibleColumns: CGFloat = 7

    var body: some View {
        GeometryReader { geometry in
            let slotWidth = geometry.size.width / visibleColumns

            HStack(spacing: 0) {
                ForEach(days) { day in
                    dayColumn(day, isSelected: day.offset == selectedOffset)
                        .frame(width: slotWidth)
                        .contentShape(Rectangle())
                        .onTapGesture { onSelect(day.offset) }
                }
            }
            .offset(x: centeringOffset(slotWidth: slotWidth, containerWidth: geometry.size.width))
            .animation(.spring(response: 0.42, dampingFraction: 0.86), value: selectedOffset)
        }
        .frame(height: AppLayout.dateStripHeight)
        .clipped()
    }

    private func centeringOffset(slotWidth: CGFloat, containerWidth: CGFloat) -> CGFloat {
        guard let index = days.firstIndex(where: { $0.offset == selectedOffset }) else { return 0 }
        let slotCenter = CGFloat(index) * slotWidth + slotWidth / 2
        return containerWidth / 2 - slotCenter
    }

    private func dayColumn(_ day: DayCell, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            Text(day.weekday)
                .font(AppTypography.dayLabel())
                .foregroundStyle(weekdayColor(for: day, isSelected: isSelected))

            if isSelected {
                Text("\(day.dayNumber)")
                    .font(AppTypography.dateNumber())
                    .foregroundStyle(AppColors.black)
                    .frame(
                        width: AppLayout.selectedDateCapsuleWidth,
                        height: AppLayout.selectedDateCapsuleHeight
                    )
                    .background(AppColors.greenTint, in: Capsule())
            } else {
                Text("\(day.dayNumber)")
                    .font(AppTypography.dateNumber())
                    .foregroundStyle(AppColors.dateUnselected)
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.85), value: isSelected)
    }

    private func weekdayColor(for day: DayCell, isSelected: Bool) -> Color {
        if isSelected {
            return AppColors.black
        }
        if day.weekday == "Fri" || day.weekday == "Sat" || day.weekday == "Sun" {
            return AppColors.dateSecondary
        }
        return AppColors.dateUnselected
    }
}
