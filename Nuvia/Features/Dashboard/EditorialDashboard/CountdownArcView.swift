import SwiftUI
import CoreGraphics

// MARK: - Countdown Arc View
// Beautiful CoreGraphics-based countdown ring for wedding countdown
// Features animated gradients, tick marks, and luxurious styling

struct CountdownArcView: View {
    let daysRemaining: Int
    let totalDays: Int
    let weddingDate: Date
    var size: CGFloat = 280
    var strokeWidth: CGFloat = 16

    @State private var animatedProgress: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -1

    private var progress: CGFloat {
        let elapsed = totalDays - daysRemaining
        return min(1, max(0, CGFloat(elapsed) / CGFloat(totalDays)))
    }

    var body: some View {
        ZStack {
            // Ambient glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.nuviaChampagne.opacity(0.15),
                            Color.nuviaChampagne.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.2, height: size * 1.2)
                .scaleEffect(pulseScale)

            // Background track
            ArcShape(startAngle: .degrees(-225), endAngle: .degrees(45), clockwise: false)
                .stroke(
                    Color.nuviaTertiaryBackground,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: size, height: size)

            // Tick marks
            TickMarksView(count: 60, size: size, strokeWidth: strokeWidth)

            // Progress arc with gradient
            ArcShape(startAngle: .degrees(-225), endAngle: progressEndAngle, clockwise: false)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.nuviaChampagne,
                            Color.nuviaRoseGold,
                            Color.nuviaSage.opacity(0.8),
                            Color.nuviaChampagne
                        ],
                        center: .center,
                        startAngle: .degrees(-225),
                        endAngle: .degrees(45)
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .shadow(color: Color.nuviaChampagne.opacity(0.4), radius: 8, x: 0, y: 0)

            // Shimmer effect on progress
            ArcShape(startAngle: .degrees(-225), endAngle: progressEndAngle, clockwise: false)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.5),
                            Color.white.opacity(0)
                        ],
                        startPoint: UnitPoint(x: shimmerOffset, y: 0),
                        endPoint: UnitPoint(x: shimmerOffset + 0.3, y: 1)
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth * 0.5, lineCap: .round)
                )
                .frame(width: size, height: size)

            // End cap indicator
            endCapIndicator

            // Center content
            centerContent
        }
        .onAppear {
            startAnimations()
        }
    }

    private var progressEndAngle: Angle {
        let totalAngle = 270.0 // From -225° to 45°
        let progressAngle = totalAngle * Double(animatedProgress)
        return .degrees(-225 + progressAngle)
    }

    private var endCapIndicator: some View {
        let angle = -225 + 270 * Double(animatedProgress)
        let radians = angle * .pi / 180
        let radius = size / 2

        let x = cos(radians) * radius
        let y = sin(radians) * radius

        return ZStack {
            // Outer glow
            Circle()
                .fill(Color.nuviaChampagne.opacity(0.3))
                .frame(width: strokeWidth * 2.5, height: strokeWidth * 2.5)
                .blur(radius: 4)

            // Inner circle
            Circle()
                .fill(Color.white)
                .frame(width: strokeWidth * 1.2, height: strokeWidth * 1.2)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: Color.nuviaChampagne.opacity(0.5), radius: 6, x: 0, y: 0)
        }
        .offset(x: x, y: y)
        .opacity(animatedProgress > 0.01 ? 1 : 0)
    }

    private var centerContent: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            // Days number
            Text("\(daysRemaining)")
                .font(DSTypography.countdown)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.nuviaPrimaryText, Color.nuviaPrimaryText.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .contentTransition(.numericText())

            // Label
            Text(daysRemaining == 1 ? "day" : "days")
                .font(DSTypography.heading3)
                .foregroundColor(.nuviaSecondaryText)

            // Wedding date
            Text(weddingDate.formatted(.dateTime.month(.wide).day()))
                .font(DSTypography.caption)
                .foregroundColor(.nuviaTertiaryText)
        }
    }

    private func startAnimations() {
        // Progress animation
        withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
            animatedProgress = progress
        }

        // Pulse animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }

        // Shimmer animation
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.5
        }
    }
}

// MARK: - Arc Shape

struct ArcShape: Shape {
    let startAngle: Angle
    var endAngle: Angle
    let clockwise: Bool

    var animatableData: Double {
        get { endAngle.degrees }
        set { endAngle = .degrees(newValue) }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: clockwise
        )
        return path
    }
}

// MARK: - Tick Marks View

struct TickMarksView: View {
    let count: Int
    let size: CGFloat
    let strokeWidth: CGFloat

    var body: some View {
        ForEach(0..<count, id: \.self) { index in
            let angle = tickAngle(for: index)
            if isTickVisible(at: angle) {
                TickMark(
                    angle: angle,
                    size: size,
                    strokeWidth: strokeWidth,
                    isMajor: index % 5 == 0
                )
            }
        }
    }

    private func tickAngle(for index: Int) -> Angle {
        let totalAngle = 270.0
        let anglePerTick = totalAngle / Double(count)
        return .degrees(-225 + anglePerTick * Double(index))
    }

    private func isTickVisible(at angle: Angle) -> Bool {
        let degrees = angle.degrees
        return degrees >= -225 && degrees <= 45
    }
}

struct TickMark: View {
    let angle: Angle
    let size: CGFloat
    let strokeWidth: CGFloat
    let isMajor: Bool

    var body: some View {
        let radians = angle.radians
        let outerRadius = size / 2 - strokeWidth / 2 - 4
        let innerRadius = outerRadius - (isMajor ? 8 : 4)

        let outerX = cos(radians) * outerRadius
        let outerY = sin(radians) * outerRadius
        let innerX = cos(radians) * innerRadius
        let innerY = sin(radians) * innerRadius

        Path { path in
            path.move(to: CGPoint(x: size/2 + innerX, y: size/2 + innerY))
            path.addLine(to: CGPoint(x: size/2 + outerX, y: size/2 + outerY))
        }
        .stroke(
            Color.nuviaTertiaryText.opacity(isMajor ? 0.4 : 0.2),
            style: StrokeStyle(lineWidth: isMajor ? 2 : 1, lineCap: .round)
        )
    }
}

// MARK: - Countdown Card

struct CountdownCard: View {
    let daysRemaining: Int
    let totalDays: Int
    let weddingDate: Date
    let partnerNames: (String, String)

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Header
            VStack(spacing: DesignTokens.Spacing.xxs) {
                Text("THE BIG DAY")
                    .font(DSTypography.overline)
                    .tracking(2)
                    .foregroundColor(.nuviaTertiaryText)

                Text("\(partnerNames.0) & \(partnerNames.1)")
                    .font(DSTypography.heading2)
                    .foregroundColor(.nuviaPrimaryText)
            }

            // Countdown arc
            CountdownArcView(
                daysRemaining: daysRemaining,
                totalDays: totalDays,
                weddingDate: weddingDate,
                size: 220,
                strokeWidth: 14
            )

            // Stats row
            HStack(spacing: DesignTokens.Spacing.xl) {
                CountdownStat(value: weeks, label: "Weeks")
                CountdownStat(value: months, label: "Months")
                CountdownStat(value: hours, label: "Hours")
            }

            // Progress message
            progressMessage
        }
        .padding(DesignTokens.Spacing.xl)
        .background(Color.nuviaSurface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.xl, style: .continuous))
        .elevation(DesignTokens.Elevation.floating)
    }

    private var weeks: Int {
        daysRemaining / 7
    }

    private var months: Int {
        daysRemaining / 30
    }

    private var hours: Int {
        daysRemaining * 24
    }

    private var progressMessage: some View {
        let percentage = min(100, max(0, Int(Double(totalDays - daysRemaining) / Double(totalDays) * 100)))

        VStack(spacing: DesignTokens.Spacing.xs) {
            Text("\(percentage)% of your planning journey complete")
                .font(DSTypography.bodySmall)
                .foregroundColor(.nuviaSecondaryText)
                .multilineTextAlignment(.center)

            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.nuviaTertiaryBackground)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(percentage) / 100)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, DesignTokens.Spacing.xl)
        }
    }
}

struct CountdownStat: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxs) {
            Text("\(value)")
                .font(DSTypography.heading2)
                .foregroundColor(.nuviaPrimaryText)
                .contentTransition(.numericText())

            Text(label)
                .font(DSTypography.caption)
                .foregroundColor(.nuviaTertiaryText)
        }
    }
}

// MARK: - Mini Countdown Badge

struct MiniCountdownBadge: View {
    let daysRemaining: Int

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            // Mini arc
            ZStack {
                Circle()
                    .stroke(Color.nuviaChampagne.opacity(0.2), lineWidth: 3)

                Circle()
                    .trim(from: 0, to: min(1, CGFloat(daysRemaining) / 365))
                    .stroke(
                        Color.nuviaChampagne,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 0) {
                Text("\(daysRemaining)")
                    .font(DSTypography.bodyBold)
                    .foregroundColor(.nuviaPrimaryText)

                Text("days")
                    .font(.system(size: 10))
                    .foregroundColor(.nuviaTertiaryText)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(
            Capsule()
                .fill(Color.nuviaSurface)
        )
        .elevation(DesignTokens.Elevation.raised)
    }
}

// MARK: - Live Countdown View (with seconds)

struct LiveCountdownView: View {
    let weddingDate: Date

    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?

    private var days: Int {
        Int(timeRemaining / 86400)
    }

    private var hours: Int {
        Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600)
    }

    private var minutes: Int {
        Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
    }

    private var seconds: Int {
        Int(timeRemaining.truncatingRemainder(dividingBy: 60))
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            TimeUnit(value: days, label: "Days")
            TimeSeparator()
            TimeUnit(value: hours, label: "Hours")
            TimeSeparator()
            TimeUnit(value: minutes, label: "Min")
            TimeSeparator()
            TimeUnit(value: seconds, label: "Sec")
        }
        .onAppear {
            updateTimeRemaining()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func updateTimeRemaining() {
        timeRemaining = max(0, weddingDate.timeIntervalSinceNow)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
}

struct TimeUnit: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxs) {
            Text(String(format: "%02d", value))
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.nuviaPrimaryText)
                .contentTransition(.numericText())

            Text(label)
                .font(DSTypography.captionSmall)
                .foregroundColor(.nuviaTertiaryText)
        }
    }
}

struct TimeSeparator: View {
    @State private var opacity: Double = 1

    var body: some View {
        Text(":")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.nuviaChampagne)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    opacity = 0.3
                }
            }
    }
}

// MARK: - Preview

#Preview("Countdown Arc") {
    let weddingDate = Calendar.current.date(byAdding: .day, value: 127, to: Date())!
    let totalDays = 365

    ScrollView {
        VStack(spacing: DesignTokens.Spacing.xl) {
            CountdownCard(
                daysRemaining: 127,
                totalDays: totalDays,
                weddingDate: weddingDate,
                partnerNames: ("Emma", "James")
            )

            HStack {
                MiniCountdownBadge(daysRemaining: 127)
                Spacer()
            }

            LiveCountdownView(weddingDate: weddingDate)
                .padding()
                .background(Color.nuviaSurface)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
                .elevation(DesignTokens.Elevation.raised)
        }
        .padding()
    }
    .background(Color.nuviaBackground)
}
