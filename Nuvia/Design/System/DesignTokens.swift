import SwiftUI

// MARK: - Design Tokens (Single Source of Truth)
// No hardcoded values anywhere - all design flows from here

public enum DesignTokens {

    // MARK: - Spacing Scale (8pt Grid)
    public enum Spacing {
        public static let xxxs: CGFloat = 2
        public static let xxs: CGFloat = 4
        public static let xs: CGFloat = 8
        public static let sm: CGFloat = 12
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
        public static let xxxl: CGFloat = 64
        public static let huge: CGFloat = 96

        // MARK: - Semantic Spacing (Editorial Elegance)

        /// Standard horizontal padding for screens (24pt) - "Nuvia Margin"
        public static let nuviaMargin: CGFloat = 24

        /// Card internal padding (20pt)
        public static let cardPadding: CGFloat = 20

        /// Hero card padding (28pt)
        public static let heroCardPadding: CGFloat = 28

        /// Section spacing vertical (28pt)
        public static let sectionSpacing: CGFloat = 28

        /// List item spacing (12pt)
        public static let itemSpacing: CGFloat = 12

        /// Compact item spacing (8pt)
        public static let itemSpacingCompact: CGFloat = 8

        /// Icon-to-text spacing (10pt)
        public static let iconTextSpacing: CGFloat = 10

        /// Bottom safe area for scrollable content (120pt)
        public static let scrollBottomInset: CGFloat = 120
    }

    // MARK: - Corner Radius Scale
    public enum Radius {
        public static let none: CGFloat = 0
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 20
        public static let xxl: CGFloat = 24
        public static let xxxl: CGFloat = 28
        public static let full: CGFloat = 999

        // MARK: - Semantic Radius (Editorial Elegance)

        /// Input fields (8pt)
        public static let input: CGFloat = 8

        /// Standard cards (16pt)
        public static let card: CGFloat = 16

        /// Featured/Hero cards (24pt)
        public static let cardHero: CGFloat = 24

        /// Modals and sheets (24pt)
        public static let modal: CGFloat = 24

        /// Primary buttons (16pt)
        public static let button: CGFloat = 16

        /// Pill/capsule buttons (999pt)
        public static let pill: CGFloat = 999

        /// Progress bars (4pt)
        public static let progressBar: CGFloat = 4

        /// Tab bar indicator (3pt)
        public static let indicator: CGFloat = 3
    }

    // MARK: - Animation Timing
    public enum Animation {
        // Durations
        public static let instant: Double = 0.1
        public static let fast: Double = 0.2
        public static let normal: Double = 0.35
        public static let slow: Double = 0.5
        public static let dramatic: Double = 0.8

        // Springs
        public static let snappy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
        public static let smooth = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
        public static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
        public static let gentle = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.9, blendDuration: 0)

        // Easing
        public static let easeOut = SwiftUI.Animation.easeOut(duration: normal)
        public static let easeIn = SwiftUI.Animation.easeIn(duration: normal)
        public static let easeInOut = SwiftUI.Animation.easeInOut(duration: normal)
    }

    // MARK: - Elevation (Shadow Scale)
    public enum Elevation {
        case none
        case raised      // Cards, buttons
        case floating    // Modals, popovers
        case overlay     // Dialogs, sheets
        case navigation  // App bars

        public var shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            switch self {
            case .none:
                return (.clear, 0, 0, 0)
            case .raised:
                return (Color.black.opacity(0.08), 8, 0, 2)
            case .floating:
                return (Color.black.opacity(0.12), 16, 0, 4)
            case .overlay:
                return (Color.black.opacity(0.16), 24, 0, 8)
            case .navigation:
                return (Color.black.opacity(0.06), 4, 0, 1)
            }
        }
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

    // MARK: - Touch Targets
    public enum Touch {
        public static let minimum: CGFloat = 44  // Apple HIG minimum
        public static let comfortable: CGFloat = 48
        public static let large: CGFloat = 56
    }
}

// MARK: - Design System Colors (Semantic)

public struct DSColors {
    // Foundation
    public static let background = Color("nuviaBackground", bundle: nil)
    public static let surface = Color("nuviaSurface", bundle: nil)
    public static let surfaceElevated = Color("nuviaSurfaceElevated", bundle: nil)

    // Text Hierarchy
    public static let textPrimary = Color("nuviaPrimaryText", bundle: nil)
    public static let textSecondary = Color("nuviaSecondaryText", bundle: nil)
    public static let textTertiary = Color("nuviaTertiaryText", bundle: nil)
    public static let textInverse = Color.white

    // Brand Accents
    public static let accent = Color("nuviaChampagne", bundle: nil)
    public static let accentSecondary = Color("nuviaRoseDust", bundle: nil)
    public static let accentTertiary = Color("nuviaSage", bundle: nil)

    // Semantic
    public static let success = Color("nuviaSuccess", bundle: nil)
    public static let warning = Color("nuviaWarning", bundle: nil)
    public static let error = Color("nuviaError", bundle: nil)
    public static let info = Color("nuviaInfo", bundle: nil)

    // Interactive
    public static let buttonPrimary = Color("nuviaPrimaryAction", bundle: nil)
    public static let buttonSecondary = Color("nuviaSecondaryAction", bundle: nil)

    // Fallbacks (when asset catalog colors aren't available)
    public static let fallbackBackground = Color(hex: "FAFAF9")
    public static let fallbackSurface = Color(hex: "FFFFFF")
    public static let fallbackAccent = Color(hex: "D4AF37")
    public static let fallbackTextPrimary = Color(hex: "1A1A1A")
}

// Note: DSTypography is defined in Core/DesignSystem/Theme/DSTypography.swift

// MARK: - View Extensions for Design Tokens

extension View {

    /// Applies elevation shadow
    public func elevation(_ level: DesignTokens.Elevation) -> some View {
        let shadow = level.shadow
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    /// Standard card styling
    public func cardStyle(elevation: DesignTokens.Elevation = .raised) -> some View {
        self
            .background(DSColors.fallbackSurface)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
            .elevation(elevation)
    }

    /// Interactive press feedback
    public func pressable(scale: CGFloat = 0.97) -> some View {
        self.modifier(PressableModifier(scale: scale))
    }
}

// MARK: - Pressable Modifier

struct PressableModifier: ViewModifier {
    let scale: CGFloat
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(DesignTokens.Animation.snappy, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            HapticManager.shared.impact(.light)
                        }
                    }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// Note: HapticEngine and HapticManager are defined as typealiases in NuviaHaptics.swift
