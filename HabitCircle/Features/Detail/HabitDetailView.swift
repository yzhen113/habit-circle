import SwiftUI

struct HabitDetailView: View {
    @StateObject var viewModel: HabitDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showChat = false

    init(task: TaskItem, isJoinLocked: Bool = false, onComplete: @escaping () -> Void = {}) {
        _viewModel = StateObject(
            wrappedValue: HabitDetailViewModel(task: task, isJoinLocked: isJoinLocked, onComplete: onComplete)
        )
    }

    init(viewModel: HabitDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            HabitInfoRow(viewModel: viewModel)
                            WeekdayStrip(viewModel: viewModel)
                            ProgressRing(viewModel: viewModel)
                            if viewModel.requiresPhoto {
                                PhotoHistorySection(
                                    images: viewModel.photoHistory,
                                    isBlurred: !viewModel.isCompleted
                                )
                            }
                        }
                        .padding(.horizontal, AppLayout.horizontalPadding)
                        .padding(.top, 20)
                        .padding(.bottom, 110)
                    }
                    .blur(radius: viewModel.isJoinLocked ? 9 : 0)
                    .allowsHitTesting(!viewModel.isJoinLocked)
                }

                if viewModel.isJoinLocked {
                    Color.white.opacity(0.25).ignoresSafeArea()
                    joinGate
                } else {
                    VStack {
                        Spacer()
                        ctaButton
                            .padding(.horizontal, AppLayout.horizontalPadding)
                            .padding(.bottom, 12)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showChat) {
                CircleChatView(viewModel: viewModel)
            }
        }
        // Attached to the stack so the same camera serves both detail and chat.
        .sheet(isPresented: $viewModel.showCamera, onDismiss: handleCameraDismiss) {
            PhotoVerificationCameraView(
                onCapture: { viewModel.stageCapturedPhoto($0) },
                onCancel: { viewModel.cancelPhotoVerification() }
            )
        }
    }

    /// A captured shot posts to the chat, then pulls the chat into view if the
    /// user started from the detail page.
    private func handleCameraDismiss() {
        guard let image = viewModel.takeCapturedPhoto() else { return }
        viewModel.postVerificationPhoto(image)
        if !showChat { showChat = true }
    }

    // MARK: - Header (gnb)

    private var header: some View {
        ZStack {
            Text(viewModel.circleName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.black)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.black)
                }

                Spacer()

                // A circle you haven't joined has no chat to open.
                if !viewModel.isJoinLocked {
                    Button {
                        showChat = true
                    } label: {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(AppColors.black)
                    }
                }
            }
        }
        .padding(.horizontal, AppLayout.horizontalPadding + 10)
        .padding(.vertical, 12)
    }

    // MARK: - Discover preview gate

    private var joinGate: some View {
        Button {
            viewModel.join()
        } label: {
            Label("Join to view", systemImage: "person.badge.plus")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(AppColors.black)
        .frame(width: 303, height: 44)
    }

    // MARK: - Bottom CTA

    private var ctaButton: some View {
        LiquidGlassCapsuleButton(
            title: viewModel.ctaTitle,
            icon: viewModel.ctaSystemImage,
            isDisabled: viewModel.isCompleted
        ) {
            if viewModel.requiresPhoto {
                viewModel.startPhotoVerification()
            } else {
                viewModel.completeWithoutPhoto()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.isCompleted)
    }
}

// MARK: - Habit info row

private struct HabitInfoRow: View {
    @ObservedObject var viewModel: HabitDetailViewModel

    var body: some View {
        // Spacing is per-gap rather than on the HStack so the 24pt before the
        // day badge is exact.
        HStack(alignment: .center, spacing: 0) {
            HabitCategoryIcon(
                icon: viewModel.icon,
                accentColor: viewModel.isCompleted ? viewModel.accentColor : AppColors.mediumGray
            )
            .frame(width: 48, height: 48)
            .padding(.trailing, 13)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(viewModel.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.black)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.darkGray)
                    Text("\(viewModel.memberCount)")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.darkGray)
                }

                HStack(spacing: 4) {
                    Text(viewModel.durationText)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.darkGray)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(AppColors.lightGray, in: Capsule())

                    if viewModel.requiresPhoto {
                        HStack(spacing: 4) {
                            Image(systemName: "camera")
                                .font(.system(size: 12))
                                .foregroundStyle(AppColors.darkGray)
                            Text(viewModel.frequencyText)
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.darkGray)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(AppColors.lightGray, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }

            Spacer(minLength: 24)

            VStack(spacing: 0) {
                Text("Day")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.darkGray)
                Text("\(viewModel.dayNumber)")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(viewModel.isCompleted ? viewModel.accentColor : AppColors.darkGray)
            }
            .frame(width: 42)
            .padding(7)
            .background(
                viewModel.isCompleted ? viewModel.tintColor : AppColors.lightGray,
                in: RoundedRectangle(cornerRadius: 15, style: .continuous)
            )
        }
    }
}

struct HabitCategoryIcon: View {
    let icon: TaskIcon
    let accentColor: Color

    private var assetName: String {
        switch icon {
        case .calendar: return "CircleRoutine"
        case .apple: return "CircleEating"
        case .dumbbell: return "CircleFitness"
        case .heart: return "CircleMisc"
        }
    }

    var body: some View {
        Group {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(accentColor)
            }
        }
    }
}

// MARK: - Weekday completion strip

private struct WeekdayStrip: View {
    @ObservedObject var viewModel: HabitDetailViewModel

    /// Figma: a 338-wide row centered in the column, space-between.
    private let rowWidth: CGFloat = 338

    var body: some View {
        VStack(spacing: 0) {
            TriangleMarker()
                .fill(viewModel.accentColor)
                .stroke(viewModel.accentColor, style: StrokeStyle(lineWidth: 4.4, lineJoin: .round))
                .frame(width: 12.75, height: 11.77)
                .frame(height: 16)

            HStack(spacing: 0) {
                ForEach(Array(viewModel.weekdays.enumerated()), id: \.element.id) { index, day in
                    VStack(spacing: 8) {
                        Text(day.label)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(day.state == .today ? AppColors.black : AppColors.dateUnselected)
                        DayPill(
                            day: day,
                            isCircleCompleted: viewModel.isCompleted,
                            accentColor: viewModel.accentColor,
                            tintColor: viewModel.tintColor
                        )
                    }

                    if index < viewModel.weekdays.count - 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
            .frame(width: rowWidth, height: 77)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Rounded-corner triangle above today's pill (web icon `triangle-marker`).
private struct TriangleMarker: Shape {
    func path(in rect: CGRect) -> Path {
        // Source viewBox is 13 x 12 with a 4.4 round-joined stroke.
        let sx = rect.width / 13
        let sy = rect.height / 12
        var path = Path()
        path.move(to: CGPoint(x: 2.2 * sx, y: 2.2 * sy))
        path.addLine(to: CGPoint(x: 10.8 * sx, y: 2.2 * sy))
        path.addLine(to: CGPoint(x: 6.5 * sx, y: 9.8 * sy))
        path.closeSubpath()
        return path
    }
}

/// Flat-topped fill inset from the pill's edge, with rounded bottom corners.
private struct PillFillShape: Shape {
    let bottomRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        Path(
            roundedRect: rect,
            cornerRadii: RectangleCornerRadii(
                topLeading: 2,
                bottomLeading: bottomRadius,
                bottomTrailing: bottomRadius,
                topTrailing: 2
            ),
            style: .continuous
        )
    }
}

private struct DayPill: View {
    let day: HabitDayStatus
    /// Whether *I* have completed today — only recolors today's pill.
    let isCircleCompleted: Bool
    let accentColor: Color
    let tintColor: Color

    private var state: HabitDayStatus.State { day.state }
    private var fraction: Double { min(max(day.completionFraction, 0), 1) }
    private var isToday: Bool { state == .today }
    private var isFull: Bool { fraction >= 1 }
    /// Past days stay grey in both states; only today picks up the accent.
    private var usesAccent: Bool { isCircleCompleted && isToday }

    // Figma 604:5476 / 1349:5566
    private var width: CGFloat { isToday ? 36 : 30 }
    private var height: CGFloat { isToday ? 52.8 : 44 }
    private var radius: CGFloat { isToday ? 18 : 15 }
    private var sideInset: CGFloat { isToday ? 4 : 2 }
    private var bottomInset: CGFloat { isToday ? 3.8 : 2 }
    private var innerHeight: CGFloat { isToday ? 45 : 40 }
    private var fillRadius: CGFloat { isToday ? 14 : 13 }
    private var minGlossFill: CGFloat { isToday ? 16 : 15 }
    private var topGlossInset: CGFloat { isToday ? 4.9 : 4 }

    private var fillHeight: CGFloat { CGFloat(fraction) * innerHeight }
    private var hasFillLayer: Bool { state == .partial || isToday }

    private var backgroundColor: Color {
        switch state {
        case .upcoming: return .clear
        case .completed: return AppColors.mediumGray
        case .partial: return AppColors.lightGray
        case .today: return usesAccent ? (isFull ? accentColor : tintColor) : AppColors.lightGray
        }
    }

    private var fillColor: Color {
        usesAccent ? accentColor : AppColors.mediumGray
    }

    /// Figma tints the part-fill gloss ~62% toward white from the accent.
    private var verticalGlossColor: Color {
        usesAccent ? accentColor.blended(toward: .white, amount: 0.62) : AppColors.lightGray
    }

    private var topGlossColor: Color {
        usesAccent ? tintColor : AppColors.lightGray
    }

    private var showsCheckmark: Bool {
        state == .completed || (hasFillLayer && isFull)
    }

    private var showsVerticalGloss: Bool {
        hasFillLayer && !isFull && fillHeight >= minGlossFill
    }

    /// Sits a few px below the fill's flat top.
    private var verticalGlossTop: CGFloat {
        height - bottomInset - fillHeight + 4
    }

    private var verticalGlossLeft: CGFloat { isToday ? 6.5 : 5.17 }
    private var verticalGlossWidth: CGFloat { isToday ? 4 : 3.6 }
    private var verticalGlossHeight: CGFloat { isToday ? 10 : 9 }

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(backgroundColor)

            if hasFillLayer {
                PillFillShape(bottomRadius: fillRadius)
                    .fill(fillColor)
                    .frame(height: fillHeight)
                    .padding(.horizontal, sideInset)
                    .padding(.bottom, bottomInset)
            }

            if state == .upcoming {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(AppColors.mediumGray, lineWidth: 1.5)
            }

            // Inset stroke rather than a border, so the fill and gloss offsets
            // above stay measured from the pill's outer edge.
            if usesAccent {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(accentColor, lineWidth: 1.5)
            }

            if showsCheckmark {
                Image(systemName: "checkmark")
                    .font(.system(size: 16.8, weight: .bold))
                    .foregroundStyle(AppColors.white)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(alignment: .top) {
            if showsCheckmark {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(topGlossColor)
                    .frame(width: 10, height: 4)
                    .offset(y: topGlossInset)
            }
        }
        .overlay(alignment: .topLeading) {
            if showsVerticalGloss {
                RoundedRectangle(cornerRadius: verticalGlossWidth / 2, style: .continuous)
                    .fill(verticalGlossColor)
                    .frame(width: verticalGlossWidth, height: verticalGlossHeight)
                    .offset(x: verticalGlossLeft, y: verticalGlossTop)
            }
        }
        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.4), value: fraction)
        .animation(.easeOut(duration: 0.4), value: usesAccent)
    }
}

// MARK: - Progress ring

private enum RingMetrics {
    /// Figma: 280 × 280.87, centerline radius 126.957, stroke 26.087.
    static let size: CGFloat = 280
    static let radius: CGFloat = 126.957
    static let lineWidth: CGFloat = 26.087
    /// Degrees the gloss trails the arc's leading tip.
    static let glossLag: Double = 2
    static let fadeShare: Double = 0.55
    static let fadeMaxDegrees: Double = 170
    static let duration: Double = 0.9
    /// Where the leading gloss starts dissolving and the faded tail starts
    /// closing up, so the ring seals itself instead of snapping shut at 1.
    static let closeFadeStart: Double = 0.88
    static let greyHead = Color(hex: 0x898989)
}

/// The animating layers. Conforming to `Animatable` on `fraction` rebuilds the
/// body every frame, so the sweep, tail fade, tip and gloss all step together —
/// the same thing the web prototype does from one requestAnimationFrame loop.
private struct RingArcLayers: View, Animatable {
    var fraction: Double
    let track: Color
    let head: Color
    let gloss: Color

    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }

    private var clamped: Double { min(max(fraction, 0), 1) }
    private var hasArc: Bool { clamped > 0.0001 }
    private var diameter: CGFloat { RingMetrics.radius * 2 }

    /// 0 until the ring nears completion, then ramps to 1 exactly at full.
    private var closeProgress: Double {
        let start = RingMetrics.closeFadeStart
        guard clamped > start else { return 0 }
        return min(1, (clamped - start) / (1 - start))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(track, lineWidth: RingMetrics.lineWidth)
                .frame(width: diameter, height: diameter)

            // Butt caps: a round cap at the start would bulge back past 12
            // o'clock into the opaque end of the mask. The tip circle rounds
            // off the head instead.
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(head, style: StrokeStyle(lineWidth: RingMetrics.lineWidth, lineCap: .butt))
                .frame(width: diameter, height: diameter)
                .rotationEffect(.degrees(-90))
                // The stroke straddles the centerline, so it paints half a
                // line-width outside its own frame. The mask has to cover the
                // full ring or it shears the arc's outer edge flat.
                .frame(width: RingMetrics.size, height: RingMetrics.size)
                .mask(tailFadeMask)

            // Stays at full strength all the way to 1: it rounds off the arc's
            // butt cap, and at 1 it lands on the arc's own start, invisible.
            Circle()
                .fill(head)
                .frame(width: RingMetrics.lineWidth, height: RingMetrics.lineWidth)
                .offset(y: -RingMetrics.radius)
                .rotationEffect(.degrees(360 * clamped))
                .opacity(hasArc ? 1 : 0)

            RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                .fill(gloss)
                .frame(width: 15, height: 5)
                .offset(y: -132.5)
                .rotationEffect(.degrees(360 * clamped - RingMetrics.glossLag))
                .opacity(hasArc ? 0.7 * (1 - closeProgress) : 0)
        }
        .frame(width: RingMetrics.size, height: RingMetrics.size)
    }

    /// Dissolves the arc's tail into the track so the head stays full strength.
    @ViewBuilder
    private var tailFadeMask: some View {
        // The tail keeps dissolving all the way from a fully transparent start,
        // so its butt cap never shows as an edge. Instead of lifting it toward
        // opaque, the fade shortens as the ring closes until there is nothing
        // left to fade and the solid mask below takes over unnoticed.
        let end = min(RingMetrics.fadeMaxDegrees, 360 * clamped * RingMetrics.fadeShare)
            * (1 - closeProgress)

        if clamped >= 1 || end < 0.5 {
            Color.black
        } else {
            // The mask drops back to clear past the arc's head so the gradient's
            // 360°/0° seam lands on empty track instead of cutting the stroke.
            let head = min(clamped + 0.002, 1)
            AngularGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black.opacity(0.28), location: end * 0.3 / 360),
                    .init(color: .black.opacity(0.72), location: end * 0.62 / 360),
                    .init(color: .black, location: end / 360),
                    .init(color: .black, location: head),
                    .init(color: .clear, location: min(head + 0.001, 1)),
                    .init(color: .clear, location: 1),
                ],
                center: .center,
                startAngle: .degrees(-90),
                endAngle: .degrees(270)
            )
            .frame(width: RingMetrics.size, height: RingMetrics.size)
        }
    }
}

private struct ProgressRing: View {
    @ObservedObject var viewModel: HabitDetailViewModel
    @State private var animatedFraction: Double = 0

    private var palette: (track: Color, head: Color, gloss: Color) {
        viewModel.isCompleted
            ? (viewModel.tintColor, viewModel.accentColor, viewModel.tintColor)
            : (AppColors.lightGray, RingMetrics.greyHead, AppColors.lightGray)
    }

    private var countColor: Color {
        viewModel.isCompleted ? viewModel.accentColor : AppColors.darkGray
    }

    private var fillAnimation: Animation {
        .timingCurve(0.2, 0.8, 0.2, 1, duration: RingMetrics.duration)
    }

    var body: some View {
        ZStack {
            RingArcLayers(
                fraction: animatedFraction,
                track: palette.track,
                head: palette.head,
                gloss: palette.gloss
            )

            VStack(spacing: 14.84) {
                Text("\(viewModel.completedCount)/\(viewModel.totalMembers)")
                    .font(AppTypography.diagonalFraction(size: 81, weight: .semibold))
                    .foregroundStyle(countColor)
                    .contentTransition(.numericText())
                    .frame(height: 60)

                (Text(viewModel.displayCircleName).foregroundColor(AppColors.black)
                    + Text(" have completed the habit today").foregroundColor(AppColors.darkGray))
                    .font(.system(size: 11.13))
                    .lineSpacing(3.7)
                    .multilineTextAlignment(.center)
                    .frame(width: 140.33)
            }
        }
        .frame(width: RingMetrics.size, height: RingMetrics.size)
        .frame(maxWidth: .infinity)
        .onAppear {
            animatedFraction = 0
            withAnimation(fillAnimation) { animatedFraction = viewModel.progressFraction }
        }
        .onChange(of: viewModel.progressFraction) { _, newValue in
            withAnimation(fillAnimation) { animatedFraction = newValue }
        }
    }
}

// MARK: - Photo verification history

private struct PhotoHistorySection: View {
    let images: [VerificationPhoto]
    var isBlurred: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Photo Verification History")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.darkGray)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.mediumGray)
            }

            // Bleeds past the page's horizontal padding so photos run to the
            // screen edge instead of stopping short of it.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(images.enumerated()), id: \.offset) { _, photo in
                        photoView(photo)
                            .scaledToFill()
                            .frame(width: 109, height: 151)
                            .blur(radius: isBlurred ? 7 : 0)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                }
                .padding(.trailing, AppLayout.horizontalPadding)
            }
            .animation(.easeOut(duration: 0.35), value: isBlurred)
            .padding(.trailing, -AppLayout.horizontalPadding)
        }
    }

    private func photoView(_ photo: VerificationPhoto) -> some View {
        Group {
            switch photo {
            case .asset(let name):
                Image(name).resizable()
            case .captured(let image):
                Image(uiImage: image).resizable()
            }
        }
    }
}

#Preview {
    HabitDetailView(
        task: .make("30-min Cardio", reminder: "7:00AM", members: 10, category: .fitness, photo: true, order: 0,
                    circle: "Stairmasterers", description: "30 minutes of steady cardio a day.", duration: "1 month", day: 9)
    )
}
