import SwiftUI

// MARK: - Reduce Motion Support
// Environment-based guards for accessibility

/// Provides Reduce Motion awareness throughout the app
public struct ReduceMotionConfig {

    /// Whether system Reduce Motion is enabled
    public let isEnabled: Bool

    /// Fallback animation when motion is reduced
    public static let fallbackAnimation: Animation? = nil

    /// Instant animation for when some animation is needed
    public static let instantAnimation: Animation = .linear(duration: 0.1)

    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    /// Returns nil if reduce motion enabled, otherwise the provided animation
    public func safeAnimation(_ animation: Animation) -> Animation? {
        isEnabled ? nil : animation
    }

    /// Returns instant animation if reduce motion enabled, otherwise the provided animation
    public func gentleAnimation(_ animation: Animation) -> Animation {
        isEnabled ? Self.instantAnimation : animation
    }
}

// MARK: - View Modifier

/// Modifier that applies animation only if Reduce Motion is disabled
public struct ReduceMotionModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let animation: Animation
    let value: V
    let reducedAnimation: Animation?

    public init(
        animation: Animation,
        value: V,
        reducedAnimation: Animation? = nil
    ) {
        self.animation = animation
        self.value = value
        self.reducedAnimation = reducedAnimation
    }

    public func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? reducedAnimation : animation, value: value)
    }
}

extension View {
    /// Apply animation respecting Reduce Motion preference
    public func safeAnimation<V: Equatable>(
        _ animation: Animation,
        value: V,
        reduced: Animation? = nil
    ) -> some View {
        self.modifier(ReduceMotionModifier(
            animation: animation,
            value: value,
            reducedAnimation: reduced
        ))
    }

    /// Conditionally apply animation based on Reduce Motion
    public func reduceMotionAware<V: Equatable>(
        _ animation: Animation,
        fallback: Animation? = nil,
        value: V
    ) -> some View {
        self.modifier(ReduceMotionModifier(
            animation: animation,
            value: value,
            reducedAnimation: fallback
        ))
    }
}

// MARK: - Transition Support

/// Safe transition that respects Reduce Motion
public struct SafeTransition: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let transition: AnyTransition
    let reducedTransition: AnyTransition

    public init(
        transition: AnyTransition,
        reduced: AnyTransition = .opacity
    ) {
        self.transition = transition
        self.reducedTransition = reduced
    }

    public func body(content: Content) -> some View {
        content
            .transition(reduceMotion ? reducedTransition : transition)
    }
}

extension View {
    /// Apply transition respecting Reduce Motion
    public func safeTransition(
        _ transition: AnyTransition,
        reduced: AnyTransition = .opacity
    ) -> some View {
        self.modifier(SafeTransition(transition: transition, reduced: reduced))
    }
}

// MARK: - Common Safe Transitions

extension AnyTransition {
    /// Slide from bottom, falls back to opacity
    public static var safeSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }

    /// Scale with opacity, falls back to opacity
    public static var safeScale: AnyTransition {
        .scale.combined(with: .opacity)
    }

    /// Slide from leading, falls back to opacity
    public static var safeSlideLeading: AnyTransition {
        .move(edge: .leading).combined(with: .opacity)
    }
}

// MARK: - Entrance Animation

/// Entrance animation that respects Reduce Motion
public struct SafeEntranceModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    let animation: Animation
    let offset: CGFloat
    let scale: CGFloat

    public init(
        animation: Animation = MotionCurves.pageTransition,
        offset: CGFloat = 40,
        scale: CGFloat = 0.95
    ) {
        self.animation = animation
        self.offset = offset
        self.scale = scale
    }

    public func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : (reduceMotion ? 0 : offset))
            .scaleEffect(appeared ? 1 : (reduceMotion ? 1 : scale))
            .opacity(appeared ? 1 : 0)
            .onAppear {
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(animation) {
                        appeared = true
                    }
                }
            }
    }
}

extension View {
    /// Safe entrance animation
    public func safeEntrance(
        animation: Animation = MotionCurves.pageTransition,
        offset: CGFloat = 40,
        scale: CGFloat = 0.95
    ) -> some View {
        self.modifier(SafeEntranceModifier(
            animation: animation,
            offset: offset,
            scale: scale
        ))
    }

    /// Safe entrance with stagger delay
    public func safeEntrance(
        index: Int,
        config: StaggerConfig = .cards
    ) -> some View {
        self.modifier(SafeEntranceModifier(
            animation: config.animation(for: index),
            offset: 40,
            scale: 0.95
        ))
    }
}

// MARK: - Preview

#Preview("Reduce Motion Demo") {
    @Previewable @State var isVisible = false

    VStack(spacing: 20) {
        Button("Toggle") {
            withAnimation(MotionCurves.default) {
                isVisible.toggle()
            }
        }

        if isVisible {
            VStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.3))
                        .frame(height: 60)
                        .safeEntrance(index: index)
                }
            }
        }
    }
    .padding()
}
