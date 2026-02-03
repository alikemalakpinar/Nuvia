import SwiftUI

// MARK: - Design System Theme
// Central theme configuration and environment

/// Nuvia Design System Theme
/// Provides centralized access to all design tokens
public struct DSTheme {

    // MARK: - Current Theme

    /// Light Luxury (default) or Dark Romance
    public enum Mode: String, CaseIterable {
        case lightLuxury = "Light Luxury"
        case darkRomance = "Dark Romance"

        public var isPremium: Bool {
            self == .darkRomance
        }
    }

    // MARK: - Animation Tokens

    public enum Animation {
        // Durations
        public static let instant: Double = 0.1
        public static let fast: Double = 0.2
        public static let normal: Double = 0.35
        public static let slow: Double = 0.5
        public static let dramatic: Double = 0.8

        // Springs - "Editorial Elegance" motion
        public static let snappy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        public static let smooth = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        public static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
        public static let gentle = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.9)
        public static let page = SwiftUI.Animation.spring(response: 0.7, dampingFraction: 0.85)

        // Default spring (used throughout app)
        public static let `default` = smooth

        // Easing
        public static let easeOut = SwiftUI.Animation.easeOut(duration: normal)
        public static let easeIn = SwiftUI.Animation.easeIn(duration: normal)
        public static let easeInOut = SwiftUI.Animation.easeInOut(duration: normal)
    }

    // MARK: - Touch Targets (Accessibility)

    public enum Touch {
        /// Minimum touch target (44pt - Apple HIG)
        public static let minimum: CGFloat = 44
        /// Comfortable touch target (48pt)
        public static let comfortable: CGFloat = 48
        /// Large touch target (56pt)
        public static let large: CGFloat = 56
    }

    // MARK: - Z-Index Layers

    public enum ZIndex {
        public static let background: Double = -1
        public static let content: Double = 0
        public static let raised: Double = 1
        public static let sticky: Double = 10
        public static let overlay: Double = 100
        public static let modal: Double = 1000
        public static let toast: Double = 10000
    }
}

// MARK: - Theme Environment

@MainActor
@Observable
public final class DSThemeManager {
    public static let shared = DSThemeManager()

    public var currentMode: DSTheme.Mode = .lightLuxury
    public var isPremiumUnlocked: Bool = false

    private init() {}

    @discardableResult
    public func setMode(_ mode: DSTheme.Mode) -> Bool {
        if mode == .darkRomance && !isPremiumUnlocked {
            return false
        }
        withAnimation(DSTheme.Animation.smooth) {
            currentMode = mode
        }
        return true
    }

    public func toggleMode() {
        if currentMode == .lightLuxury {
            _ = setMode(.darkRomance)
        } else {
            _ = setMode(.lightLuxury)
        }
    }
}

// MARK: - Environment Key

private struct DSThemeModeKey: EnvironmentKey {
    static let defaultValue: DSTheme.Mode = .lightLuxury
}

extension EnvironmentValues {
    public var dsThemeMode: DSTheme.Mode {
        get { self[DSThemeModeKey.self] }
        set { self[DSThemeModeKey.self] = newValue }
    }
}

// MARK: - Reduce Motion Support

private struct DSReduceMotionKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var dsReduceMotion: Bool {
        get { self[DSReduceMotionKey.self] }
        set { self[DSReduceMotionKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    /// Inject DS theme into view hierarchy
    public func dsTheme(_ mode: DSTheme.Mode = .lightLuxury) -> some View {
        self.environment(\.dsThemeMode, mode)
    }

    /// Apply animation respecting Reduce Motion preference
    public func dsAnimation<V: Equatable>(
        _ animation: SwiftUI.Animation = DSTheme.Animation.default,
        value: V
    ) -> some View {
        self.modifier(DSAnimationModifier(animation: animation, value: value))
    }
}

// MARK: - Reduce Motion Aware Animation

private struct DSAnimationModifier<V: Equatable>: ViewModifier {
    let animation: SwiftUI.Animation
    let value: V

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? .none : animation, value: value)
    }
}

// MARK: - Screen Container

/// Standard screen container with DS background
public struct DSScreenContainer<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack {
            DSColors.Adaptive.background.resolve(for: colorScheme)
                .ignoresSafeArea()

            content
        }
    }
}

// MARK: - Convenience Type Aliases

/// Shorthand for DS colors
public typealias DS = DSColors

/// Shorthand for typography
public typealias DSType = DSTypography

/// Shorthand for spacing
public typealias DSSpace = DSSpacing
