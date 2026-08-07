import SwiftUI

private enum SwipeActionLayout {
    static let actionGap: CGFloat = 10
    static let edgeAlignPadding: CGFloat = 22
    /// Fraction of the row that must be revealed to commit the action.
    static let commitFraction: CGFloat = 0.52
    /// Past this, the icon stops centering and parks on the pill's open edge.
    static let edgeAlignFraction: CGFloat = 0.80
    static let maxRevealFraction: CGFloat = 0.92
    static let flickDistance: CGFloat = 220
}

struct SwipeActionBackground: View {
    let systemImage: String
    let accentColor: Color
    let tintColor: Color
    let pillWidth: CGFloat
    let rowHeight: CGFloat
    let isEdgeAligned: Bool
    /// Undo grows from the leading edge; complete grows from the trailing edge.
    let revealsFromLeading: Bool

    private var minDiameter: CGFloat {
        min(68, rowHeight - 20)
    }

    private var resolvedWidth: CGFloat {
        guard pillWidth > 4 else { return 0 }
        return max(pillWidth, minDiameter)
    }

    private var pillHeight: CGFloat {
        let expandStart = minDiameter
        let expandEnd = rowHeight * 0.72
        let progress = min(max((resolvedWidth - expandStart) / (expandEnd - expandStart), 0), 1)
        return minDiameter + (rowHeight - minDiameter) * progress
    }

    /// The icon trails the finger, so it pins to whichever edge is opening.
    private var iconAlignment: Alignment {
        guard isEdgeAligned else { return .center }
        return revealsFromLeading ? .trailing : .leading
    }

    private var iconPaddingEdge: Edge.Set {
        revealsFromLeading ? .trailing : .leading
    }

    private var anchor: Alignment {
        revealsFromLeading ? .leading : .trailing
    }

    var body: some View {
        HStack(spacing: 0) {
            if !revealsFromLeading { Spacer(minLength: 0) }

            ZStack(alignment: iconAlignment) {
                Capsule(style: .continuous)
                    .fill(tintColor)
                    .frame(width: resolvedWidth, height: pillHeight)

                if resolvedWidth > 10 {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(accentColor)
                        .padding(iconPaddingEdge, isEdgeAligned ? SwipeActionLayout.edgeAlignPadding : 0)
                        .frame(width: resolvedWidth, alignment: iconAlignment)
                }
            }
            .frame(width: resolvedWidth, height: rowHeight, alignment: anchor)

            if revealsFromLeading { Spacer(minLength: 0) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: anchor)
    }
}

struct SwipeToCompleteRow: View {
    @Binding var task: TaskItem
    let onComplete: () -> Void
    var onUndo: () -> Void = {}
    var onOpen: () -> Void = {}

    @State private var offset: CGFloat = 0
    /// nil until the drag's dominant axis is determined; true == horizontal swipe.
    @State private var isHorizontalDrag: Bool?
    /// Captured when the drag starts. Committing flips `task.isCompleted`, and
    /// reading it live would swing the pill to the other edge mid-animation.
    @State private var revealsFromLeading = false

    private var rowHeight: CGFloat {
        task.hasPhotoVerification ? AppLayout.taskCardPhotoHeight : AppLayout.taskCardHeight
    }

    var body: some View {
        GeometryReader { geometry in
            let rowWidth = geometry.size.width
            let pillWidth = max(0, abs(offset) - SwipeActionLayout.actionGap)
            let isEdgeAligned = pillWidth >= rowWidth * SwipeActionLayout.edgeAlignFraction

            ZStack {
                SwipeActionBackground(
                    systemImage: revealsFromLeading ? "arrow.uturn.backward" : "checkmark",
                    // Undo stays grey to match the completed card it pulls back
                    // from, the same way complete matches the pending card.
                    accentColor: revealsFromLeading ? AppColors.darkGray : task.accentColor,
                    tintColor: revealsFromLeading ? AppColors.lightGray : task.tintColor,
                    pillWidth: pillWidth,
                    rowHeight: rowHeight,
                    isEdgeAligned: isEdgeAligned,
                    revealsFromLeading: revealsFromLeading
                )

                TaskCardView(task: task)
                    .offset(x: offset)
                    .simultaneousGesture(dragGesture(rowWidth: rowWidth))
                    .onTapGesture {
                        guard offset == 0 else {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) { offset = 0 }
                            return
                        }
                        onOpen()
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: rowHeight)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.taskCardCornerRadius, style: .continuous))
    }

    private func dragGesture(rowWidth: CGFloat) -> some Gesture {
        let maxReveal = rowWidth * SwipeActionLayout.maxRevealFraction
        let limit = maxReveal + SwipeActionLayout.actionGap
        let commitThreshold = rowWidth * SwipeActionLayout.commitFraction

        return DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onChanged { value in
                // Lock the axis on the first meaningful movement. If the drag is
                // predominantly vertical, ignore it so the ScrollView can scroll.
                if isHorizontalDrag == nil {
                    isHorizontalDrag = abs(value.translation.width) > abs(value.translation.height)
                    revealsFromLeading = task.isCompleted
                }
                guard isHorizontalDrag == true else { return }

                // A done row only undoes (rightward); a pending row only
                // completes (leftward).
                offset = task.isCompleted
                    ? min(max(0, value.translation.width), limit)
                    : max(min(0, value.translation.width), -limit)
            }
            .onEnded { value in
                defer { isHorizontalDrag = nil }
                guard isHorizontalDrag == true else { return }

                let pillWidth = max(0, abs(offset) - SwipeActionLayout.actionGap)
                let predicted = value.predictedEndTranslation.width
                let flicked = task.isCompleted
                    ? predicted > SwipeActionLayout.flickDistance
                    : predicted < -SwipeActionLayout.flickDistance

                if pillWidth >= commitThreshold || flicked {
                    finishSwipe(limit: limit)
                } else {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        offset = 0
                    }
                }
            }
    }

    private func finishSwipe(limit: CGFloat) {
        let isUndo = task.isCompleted

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            offset = isUndo ? limit : -limit
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.9)) {
                offset = 0
                if isUndo {
                    onUndo()
                } else {
                    onComplete()
                }
            }
        }
    }
}
