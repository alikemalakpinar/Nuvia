import SwiftUI

// MARK: - Lottie View
// Placeholder implementation using SwiftUI animations
// When lottie-ios is integrated, update this to use actual Lottie animations

/// A view that displays Lottie animations with graceful fallbacks
/// Currently uses SwiftUI-based placeholder animations
/// TODO: Integrate lottie-ios package and update to load actual .json files
public struct LottieView: View {
    let config: LottieConfig

    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var pulseEffect: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(slot: LottieSlot, loop: Bool? = nil, speed: Double? = nil, size: CGSize? = nil) {
        self.config = LottieConfig(slot: slot, loop: loop, speed: speed, size: size)
    }

    public init(config: LottieConfig) {
        self.config = config
    }

    public var body: some View {
        Group {
            // Check if actual Lottie file exists
            if animationFileExists {
                // TODO: Replace with actual Lottie implementation
                // LottieAnimationView(name: config.slot.filename)
                //     .playing(loopMode: config.loop ? .loop : .playOnce)
                //     .animationSpeed(config.speed)
                placeholderView
            } else {
                placeholderView
            }
        }
        .frame(width: config.size?.width, height: config.size?.height)
    }

    // MARK: - Animation File Check

    private var animationFileExists: Bool {
        // Check if .json file exists in bundle
        Bundle.main.url(forResource: config.slot.filename, withExtension: "json") != nil
    }

    // MARK: - Placeholder View

    @ViewBuilder
    private var placeholderView: some View {
        switch config.slot {
        case .anim_loading_general, .anim_loading_upload, .anim_loading_sync:
            loadingPlaceholder
        case .anim_task_completed, .anim_payment_success, .anim_rsvp_received:
            successPlaceholder
        case .anim_confetti:
            confettiPlaceholder
        case .anim_countdown_heart, .anim_countdown_rings:
            heartbeatPlaceholder
        case .anim_error_general, .anim_connection_lost:
            errorPlaceholder
        default:
            defaultPlaceholder
        }
    }

    // MARK: - Loading Placeholder

    private var loadingPlaceholder: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(config.slot.fallbackColor.opacity(0.2), lineWidth: 3)

            // Animated arc
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    config.slot.fallbackColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(rotationAngle))
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                .linear(duration: 1.0 / config.speed)
                .repeatForever(autoreverses: false)
            ) {
                rotationAngle = 360
            }
        }
    }

    // MARK: - Success Placeholder

    private var successPlaceholder: some View {
        ZStack {
            Circle()
                .fill(config.slot.fallbackColor.opacity(0.15))
                .scaleEffect(scaleEffect)

            Image(systemName: config.slot.fallbackSymbol)
                .font(.system(size: (config.size?.width ?? 80) * 0.4, weight: .medium))
                .foregroundColor(config.slot.fallbackColor)
                .scaleEffect(isAnimating ? 1.0 : 0.5)
        }
        .onAppear {
            guard !reduceMotion else {
                isAnimating = true
                return
            }
            withAnimation(MotionCurves.bouncy) {
                isAnimating = true
            }
            // Subtle pulse after appear
            withAnimation(MotionCurves.gentle.delay(0.3)) {
                scaleEffect = 1.1
            }
            withAnimation(MotionCurves.gentle.delay(0.5)) {
                scaleEffect = 1.0
            }
        }
    }

    // MARK: - Confetti Placeholder

    private var confettiPlaceholder: some View {
        ZStack {
            ForEach(0..<8) { index in
                Circle()
                    .fill(confettiColor(for: index))
                    .frame(width: 8, height: 8)
                    .offset(confettiOffset(for: index, isAnimating: isAnimating))
                    .opacity(isAnimating ? 0 : 1)
            }

            Image(systemName: "party.popper.fill")
                .font(.system(size: (config.size?.width ?? 80) * 0.3, weight: .medium))
                .foregroundColor(config.slot.fallbackColor)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }

    private func confettiColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(hex: "D4AF37"), // Gold
            Color(hex: "E8D7D5"), // Rose
            Color(hex: "D5E8D7"), // Sage
            Color(hex: "8BA7C4"), // Blue
        ]
        return colors[index % colors.count]
    }

    private func confettiOffset(for index: Int, isAnimating: Bool) -> CGSize {
        let baseRadius: CGFloat = isAnimating ? 60 : 0
        let angle = Double(index) * (360 / 8) * .pi / 180
        return CGSize(
            width: cos(angle) * baseRadius,
            height: sin(angle) * baseRadius - (isAnimating ? 20 : 0)
        )
    }

    // MARK: - Heartbeat Placeholder

    private var heartbeatPlaceholder: some View {
        ZStack {
            // Pulsing background
            Circle()
                .fill(config.slot.fallbackColor.opacity(0.1))
                .scaleEffect(pulseEffect)

            Image(systemName: config.slot.fallbackSymbol)
                .font(.system(size: (config.size?.width ?? 80) * 0.4, weight: .medium))
                .foregroundColor(config.slot.fallbackColor)
                .scaleEffect(pulseEffect)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                .easeInOut(duration: 0.8 / config.speed)
                .repeatForever(autoreverses: true)
            ) {
                pulseEffect = 1.15
            }
        }
    }

    // MARK: - Error Placeholder

    private var errorPlaceholder: some View {
        ZStack {
            Circle()
                .fill(config.slot.fallbackColor.opacity(0.1))

            Image(systemName: config.slot.fallbackSymbol)
                .font(.system(size: (config.size?.width ?? 80) * 0.4, weight: .medium))
                .foregroundColor(config.slot.fallbackColor)
                .offset(x: isAnimating ? 0 : -2)
        }
        .onAppear {
            guard !reduceMotion else { return }
            // Shake effect
            withAnimation(
                .easeInOut(duration: 0.08)
                .repeatCount(3, autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }

    // MARK: - Default Placeholder

    private var defaultPlaceholder: some View {
        ZStack {
            // Floating animation
            Circle()
                .fill(config.slot.fallbackColor.opacity(0.08))
                .scaleEffect(isAnimating ? 1.05 : 1.0)

            Image(systemName: config.slot.fallbackSymbol)
                .font(.system(size: (config.size?.width ?? 80) * 0.35, weight: .light))
                .foregroundColor(config.slot.fallbackColor)
                .offset(y: isAnimating ? -5 : 0)
        }
        .onAppear {
            guard !reduceMotion && config.loop else { return }
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Convenience Constructors

extension LottieView {
    /// Loading spinner
    public static func loading(size: CGFloat = 60) -> LottieView {
        LottieView(slot: .anim_loading_general, size: CGSize(width: size, height: size))
    }

    /// Task completion animation
    public static func taskComplete() -> LottieView {
        LottieView(config: .taskCompleted())
    }

    /// Empty state animation
    public static func emptyState(_ type: LottieConfig.EmptyStateType) -> LottieView {
        LottieView(config: .emptyState(type))
    }

    /// Splash logo animation
    public static func splash() -> LottieView {
        LottieView(config: .splash())
    }
}

// MARK: - Preview

#Preview("Lottie Placeholders") {
    ScrollView {
        VStack(spacing: 40) {
            Group {
                Text("Loading")
                    .font(.headline)
                LottieView.loading()
            }

            Group {
                Text("Task Complete")
                    .font(.headline)
                LottieView.taskComplete()
            }

            Group {
                Text("Empty Tasks")
                    .font(.headline)
                LottieView.emptyState(.tasks)
            }

            Group {
                Text("Countdown Heart")
                    .font(.headline)
                LottieView(slot: .anim_countdown_heart, size: CGSize(width: 100, height: 100))
            }

            Group {
                Text("Confetti")
                    .font(.headline)
                LottieView(slot: .anim_confetti, size: CGSize(width: 120, height: 120))
            }

            Group {
                Text("Error")
                    .font(.headline)
                LottieView(slot: .anim_error_general, size: CGSize(width: 80, height: 80))
            }
        }
        .padding(40)
    }
}
