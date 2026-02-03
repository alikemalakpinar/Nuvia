import SwiftUI

// MARK: - Motion Curves
// "Fluid Motion" system for Editorial Elegance animations

/// Animation presets for consistent motion throughout the app
public enum MotionCurves {

    // MARK: - Spring Presets

    /// Default spring - used for most interactions
    /// response: 0.5, dampingFraction: 0.8
    public static let `default` = Animation.spring(response: 0.5, dampingFraction: 0.8)

    /// Quick spring - for micro-interactions
    /// response: 0.3, dampingFraction: 0.7
    public static let quick = Animation.spring(response: 0.3, dampingFraction: 0.7)

    /// Bouncy spring - for playful feedback
    /// response: 0.4, dampingFraction: 0.6
    public static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)

    /// Gentle spring - for slow, elegant animations
    /// response: 0.6, dampingFraction: 0.9
    public static let gentle = Animation.spring(response: 0.6, dampingFraction: 0.9)

    /// Page transition spring - for navigation
    /// response: 0.7, dampingFraction: 0.85
    public static let pageTransition = Animation.spring(response: 0.7, dampingFraction: 0.85)

    /// Snappy spring - for instant feedback
    /// response: 0.25, dampingFraction: 0.75
    public static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.75)

    // MARK: - Easing Presets

    /// Standard ease out
    public static let easeOut = Animation.easeOut(duration: 0.35)

    /// Standard ease in
    public static let easeIn = Animation.easeIn(duration: 0.35)

    /// Standard ease in-out
    public static let easeInOut = Animation.easeInOut(duration: 0.35)

    /// Linear animation
    public static let linear = Animation.linear(duration: 0.35)

    // MARK: - Duration Presets

    public enum Duration {
        public static let instant: Double = 0.1
        public static let fast: Double = 0.2
        public static let normal: Double = 0.35
        public static let slow: Double = 0.5
        public static let dramatic: Double = 0.8
        public static let luxurious: Double = 1.2
    }

    // MARK: - Convenience Builders

    /// Spring with custom response
    public static func spring(response: Double) -> Animation {
        .spring(response: response, dampingFraction: 0.8)
    }

    /// Ease out with custom duration
    public static func easeOut(duration: Double) -> Animation {
        .easeOut(duration: duration)
    }

    /// Delayed animation
    public static func delayed(_ animation: Animation, by delay: Double) -> Animation {
        animation.delay(delay)
    }

    /// Repeating animation
    public static func repeating(_ animation: Animation, count: Int = .max, autoreverses: Bool = true) -> Animation {
        if count == .max {
            return animation.repeatForever(autoreverses: autoreverses)
        } else {
            return animation.repeatCount(count, autoreverses: autoreverses)
        }
    }
}

// MARK: - Stagger Configuration

/// Configuration for staggered animations
public struct StaggerConfig {
    public let baseDelay: Double
    public let staggerInterval: Double
    public let animation: Animation

    public init(
        baseDelay: Double = 0,
        staggerInterval: Double = 0.05,
        animation: Animation = MotionCurves.default
    ) {
        self.baseDelay = baseDelay
        self.staggerInterval = staggerInterval
        self.animation = animation
    }

    /// Calculate delay for item at index
    public func delay(for index: Int) -> Double {
        baseDelay + (Double(index) * staggerInterval)
    }

    /// Animation with stagger delay for index
    public func animation(for index: Int) -> Animation {
        animation.delay(delay(for: index))
    }

    // Presets
    public static let fast = StaggerConfig(staggerInterval: 0.03, animation: MotionCurves.quick)
    public static let normal = StaggerConfig(staggerInterval: 0.05, animation: MotionCurves.default)
    public static let slow = StaggerConfig(staggerInterval: 0.08, animation: MotionCurves.gentle)
    public static let cards = StaggerConfig(baseDelay: 0.1, staggerInterval: 0.05, animation: MotionCurves.pageTransition)
}

// MARK: - Animation Extensions

extension Animation {
    /// Apply stagger delay based on index
    public func staggered(index: Int, interval: Double = 0.05) -> Animation {
        self.delay(Double(index) * interval)
    }
}

// MARK: - View Animation Extensions

extension View {
    /// Apply motion curve animation
    public func motionAnimation<V: Equatable>(
        _ curve: Animation = MotionCurves.default,
        value: V
    ) -> some View {
        self.animation(curve, value: value)
    }

    /// Apply staggered entrance animation
    public func staggeredEntrance(
        index: Int,
        config: StaggerConfig = .normal,
        value: Bool
    ) -> some View {
        self.animation(config.animation(for: index), value: value)
    }
}
