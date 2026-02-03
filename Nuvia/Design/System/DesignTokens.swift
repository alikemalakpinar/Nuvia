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
    }

    // MARK: - Corner Radius Scale
    public enum Radius {
        public static let none: CGFloat = 0
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
        public static let full: CGFloat = 9999
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

// MARK: - Design System Typography

public struct DSTypography {

    // Display (Hero text, large numbers)
    public static func display(_ size: DisplaySize) -> Font {
        switch size {
        case .large:  return .system(size: 56, weight: .bold, design: .serif)
        case .medium: return .system(size: 44, weight: .bold, design: .serif)
        case .small:  return .system(size: 34, weight: .bold, design: .serif)
        }
    }

    // Headings
    public static func heading(_ level: HeadingLevel) -> Font {
        switch level {
        case .h1: return .system(size: 28, weight: .bold, design: .serif)
        case .h2: return .system(size: 24, weight: .semibold, design: .serif)
        case .h3: return .system(size: 20, weight: .semibold, design: .default)
        case .h4: return .system(size: 17, weight: .semibold, design: .default)
        }
    }

    // Body
    public static func body(_ variant: BodyVariant = .regular) -> Font {
        switch variant {
        case .large:   return .system(size: 17, weight: .regular, design: .default)
        case .regular: return .system(size: 15, weight: .regular, design: .default)
        case .small:   return .system(size: 13, weight: .regular, design: .default)
        case .bold:    return .system(size: 15, weight: .semibold, design: .default)
        }
    }

    // Utility
    public static func label(_ size: LabelSize = .regular) -> Font {
        switch size {
        case .large:   return .system(size: 14, weight: .medium, design: .default)
        case .regular: return .system(size: 12, weight: .medium, design: .default)
        case .small:   return .system(size: 10, weight: .semibold, design: .default)
        }
    }

    // Special
    public static let countdown = Font.system(size: 72, weight: .thin, design: .rounded)
    public static let overline = Font.system(size: 11, weight: .semibold, design: .default)
    public static let button = Font.system(size: 16, weight: .semibold, design: .default)
    public static let caption = Font.system(size: 12, weight: .regular, design: .default)

    // Enums
    public enum DisplaySize { case large, medium, small }
    public enum HeadingLevel { case h1, h2, h3, h4 }
    public enum BodyVariant { case large, regular, small, bold }
    public enum LabelSize { case large, regular, small }
}

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
                            HapticEngine.shared.impact(.light)
                        }
                    }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Haptic Engine (Centralized)

public final class HapticEngine {
    public static let shared = HapticEngine()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        selection.prepare()
    }

    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:  lightImpact.impactOccurred()
        case .medium: mediumImpact.impactOccurred()
        case .heavy:  heavyImpact.impactOccurred()
        case .rigid:  rigidImpact.impactOccurred()
        case .soft:   softImpact.impactOccurred()
        @unknown default: lightImpact.impactOccurred()
        }
    }

    public func selection() {
        selection.selectionChanged()
    }

    public func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notification.notificationOccurred(type)
    }
}
