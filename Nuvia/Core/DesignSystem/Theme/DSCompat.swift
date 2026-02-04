import SwiftUI

// MARK: - Design System Compatibility Layer
// Provides backward compatibility for legacy design token APIs
// This allows gradual migration from old tokens to new DS* tokens

// MARK: - Theme Manager
// Dual theme system: "Light Luxury" (Default) and "Dark Romance" (Premium)

/// Global theme manager singleton
@MainActor
@Observable
public final class ThemeManager {
    public static let shared = ThemeManager()

    /// Current active theme
    public var currentTheme: NuviaTheme = .lightLuxury

    /// Premium theme requires subscription
    public var isPremiumThemeUnlocked: Bool = false

    private init() {}

    /// Switch to a theme (checks premium status for Dark Romance)
    @discardableResult
    public func setTheme(_ theme: NuviaTheme) -> Bool {
        if theme == .darkRomance && !isPremiumThemeUnlocked {
            return false
        }
        withAnimation(DesignTokens.Animation.smooth) {
            currentTheme = theme
        }
        UISelectionFeedbackGenerator().selectionChanged()
        return true
    }

    /// Toggle between themes
    public func toggleTheme() {
        if currentTheme == .lightLuxury {
            _ = setTheme(.darkRomance)
        } else {
            _ = setTheme(.lightLuxury)
        }
    }
}

// MARK: - Nuvia Theme

public enum NuviaTheme: String, CaseIterable, Identifiable {
    case lightLuxury = "Light Luxury"
    case darkRomance = "Dark Romance"

    public var id: String { rawValue }

    public var isPremium: Bool {
        self == .darkRomance
    }

    public var colors: ThemeColors {
        switch self {
        case .lightLuxury: return LightLuxuryColors()
        case .darkRomance: return DarkRomanceColors()
        }
    }
}

// MARK: - Theme Colors Protocol

public protocol ThemeColors {
    var background: Color { get }
    var surface: Color { get }
    var surfaceElevated: Color { get }
    var surfaceTertiary: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textTertiary: Color { get }
    var textInverse: Color { get }
    var accent: Color { get }
    var accentSecondary: Color { get }
    var accentTertiary: Color { get }
    var buttonPrimary: Color { get }
    var buttonSecondary: Color { get }
    var buttonDestructive: Color { get }
    var success: Color { get }
    var warning: Color { get }
    var error: Color { get }
    var info: Color { get }
    var heroGradient: LinearGradient { get }
    var backgroundGradient: LinearGradient { get }
}

// MARK: - Light Luxury Theme (Default)

public struct LightLuxuryColors: ThemeColors {
    public var background: Color { Color(hex: "FAFAF9") }
    public var surface: Color { Color(hex: "FFFFFF") }
    public var surfaceElevated: Color { Color(hex: "FCFCFB") }
    public var surfaceTertiary: Color { Color(hex: "F5F4F2") }
    public var textPrimary: Color { Color(hex: "2A2A2A") }
    public var textSecondary: Color { Color(hex: "6D6D6D") }
    public var textTertiary: Color { Color(hex: "9A9A9A") }
    public var textInverse: Color { Color.white }
    public var accent: Color { Color(hex: "D4AF37") }
    public var accentSecondary: Color { Color(hex: "E8D7D5") }
    public var accentTertiary: Color { Color(hex: "D5E8D7") }
    public var buttonPrimary: Color { Color(hex: "2A2A2A") }
    public var buttonSecondary: Color { Color(hex: "D4AF37") }
    public var buttonDestructive: Color { Color(hex: "C48B8B") }
    public var success: Color { Color(hex: "8BAA7C") }
    public var warning: Color { Color(hex: "D4A574") }
    public var error: Color { Color(hex: "C48B8B") }
    public var info: Color { Color(hex: "8BA7C4") }

    public var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "D4AF37").opacity(0.9), Color(hex: "E8D7D5")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "FDFCFB"), Color(hex: "FAF9F7"), Color(hex: "FAFAF9")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Dark Romance Theme (Premium)

public struct DarkRomanceColors: ThemeColors {
    public var background: Color { Color(hex: "1C1C1E") }
    public var surface: Color { Color(hex: "2C2C2E") }
    public var surfaceElevated: Color { Color(hex: "3A3A3C") }
    public var surfaceTertiary: Color { Color(hex: "48484A") }
    public var textPrimary: Color { Color(hex: "E5E5EA") }
    public var textSecondary: Color { Color(hex: "8E8E93") }
    public var textTertiary: Color { Color(hex: "636366") }
    public var textInverse: Color { Color(hex: "1C1C1E") }
    public var accent: Color { Color(hex: "D4AF37") }
    public var accentSecondary: Color { Color(hex: "8B4557") }
    public var accentTertiary: Color { Color(hex: "4A5D4A") }
    public var buttonPrimary: Color { Color(hex: "E5E5EA") }
    public var buttonSecondary: Color { Color(hex: "D4AF37") }
    public var buttonDestructive: Color { Color(hex: "8B4557") }
    public var success: Color { Color(hex: "5A7D5A") }
    public var warning: Color { Color(hex: "B8860B") }
    public var error: Color { Color(hex: "8B4557") }
    public var info: Color { Color(hex: "4A6B8A") }

    public var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "D4AF37").opacity(0.85), Color(hex: "8B4557")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "1C1C1E"), Color(hex: "2C2C2E")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Theme Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: NuviaTheme = .lightLuxury
}

extension EnvironmentValues {
    public var theme: NuviaTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 44, 44, 44)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Legacy DesignTokens Namespace

public enum DesignTokens {

    // MARK: - Spacing (bridges to DSSpacing)
    public enum Spacing {
        public static let xxxs: CGFloat = DSSpacing.xxxs
        public static let xxs: CGFloat = DSSpacing.xxs
        public static let xs: CGFloat = DSSpacing.xs
        public static let sm: CGFloat = DSSpacing.sm
        public static let md: CGFloat = DSSpacing.md
        public static let lg: CGFloat = DSSpacing.lg
        public static let xl: CGFloat = DSSpacing.xl
        public static let xxl: CGFloat = DSSpacing.xxl
        public static let xxxl: CGFloat = DSSpacing.xxxl
        public static let huge: CGFloat = DSSpacing.huge

        // Semantic spacing
        public static let nuviaMargin: CGFloat = DSSpacing.nuviaMargin
        public static let cardPadding: CGFloat = DSSpacing.cardPadding
        public static let heroCardPadding: CGFloat = DSSpacing.heroCardPadding
        public static let sectionSpacing: CGFloat = DSSpacing.sectionSpacing
        public static let itemSpacing: CGFloat = DSSpacing.itemSpacing
        public static let itemSpacingCompact: CGFloat = DSSpacing.itemSpacingCompact
        public static let iconTextSpacing: CGFloat = DSSpacing.iconTextSpacing
        public static let scrollBottomInset: CGFloat = DSSpacing.scrollBottomInset
    }

    // MARK: - Radius (bridges to DSRadii)
    public enum Radius {
        public static let none: CGFloat = DSRadii.none
        public static let xs: CGFloat = DSRadii.xs
        public static let sm: CGFloat = DSRadii.sm
        public static let md: CGFloat = DSRadii.md
        public static let lg: CGFloat = DSRadii.lg
        public static let xl: CGFloat = DSRadii.xl
        public static let xxl: CGFloat = DSRadii.xxl
        public static let xxxl: CGFloat = DSRadii.hero
        public static let full: CGFloat = DSRadii.pill

        // Semantic radius
        public static let input: CGFloat = DSRadii.input
        public static let card: CGFloat = DSRadii.card
        public static let cardHero: CGFloat = DSRadii.cardHero
        public static let modal: CGFloat = DSRadii.modal
        public static let button: CGFloat = DSRadii.button
        public static let pill: CGFloat = DSRadii.pill
        public static let progressBar: CGFloat = DSRadii.progressBar
        public static let indicator: CGFloat = DSRadii.indicator
    }

    // MARK: - Animation
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

    // MARK: - Touch Targets
    public enum Touch {
        public static let minimum: CGFloat = 44
        public static let comfortable: CGFloat = 48
        public static let large: CGFloat = 56
    }

    // MARK: - Elevation
    public enum Elevation {
        case none
        case raised
        case floating
        case overlay
        case navigation

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

    // MARK: - Z-Index
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

// MARK: - Legacy NuviaTypography (bridges to DSTypography)

public struct NuviaTypography {

    // Display
    public static func displayLarge() -> Font { DSTypography.displayXL }
    public static func displayMedium() -> Font { DSTypography.display }
    public static func displaySmall() -> Font { DSTypography.displaySmall }

    // Headings
    public static func heroTitle() -> Font { DSTypography.heading1 }
    public static func title1() -> Font { DSTypography.heading1 }
    public static func title2() -> Font { DSTypography.heading2 }
    public static func title3() -> Font { DSTypography.heading3 }
    public static func headline() -> Font { DSTypography.heading4 }

    // Body
    public static func body() -> Font { DSTypography.body }
    public static func bodyBold() -> Font { DSTypography.bodyBold }
    public static func bodyLarge() -> Font { DSTypography.bodyLarge }
    public static func callout() -> Font { DSTypography.body }
    public static func footnote() -> Font { DSTypography.bodySmall }
    public static func caption() -> Font { DSTypography.caption }
    public static func caption2() -> Font { DSTypography.captionSmall }

    // Special
    public static func countdown() -> Font { DSTypography.countdown }
    public static func largeNumber() -> Font { DSTypography.numberLarge }
    public static func mediumNumber() -> Font { DSTypography.numberMedium }
    public static func smallNumber() -> Font { DSTypography.numberSmall }
    public static func currency() -> Font { DSTypography.currency }
    public static func tag() -> Font { DSTypography.caption }
    public static func button() -> Font { DSTypography.button }
    public static func smallButton() -> Font { DSTypography.buttonSmall }
    public static func overline() -> Font { DSTypography.overline }
    public static func quote() -> Font { DSTypography.quote }
    public static func navTitle() -> Font { DSTypography.navTitle }
    public static func navLargeTitle() -> Font { DSTypography.navLargeTitle }
}

// MARK: - Legacy Color Extensions (for backward compatibility)

extension Color {
    // Foundation colors
    public static var nuviaBackground: Color { DSColors.background }
    public static var nuviaSurface: Color { DSColors.surface }
    public static var nuviaElevatedSurface: Color { DSColors.surfaceElevated }
    public static var nuviaTertiaryBackground: Color { DSColors.surfaceTertiary }
    public static var nuviaCardBackground: Color { DSColors.surface }

    // Text colors
    public static var nuviaPrimaryText: Color { DSColors.textPrimary }
    public static var nuviaSecondaryText: Color { DSColors.textSecondary }
    public static var nuviaTertiaryText: Color { DSColors.textTertiary }
    public static var nuviaInverseText: Color { DSColors.textInverse }

    // Brand colors
    public static var nuviaChampagne: Color { DSColors.primaryAction }
    public static var nuviaPrimaryAction: Color { DSColors.primaryAction }
    public static var nuviaGoldFallback: Color { DSColors.Fallback.gold }

    // Semantic colors
    public static var nuviaSuccess: Color { DSColors.success }
    public static var nuviaWarning: Color { DSColors.warning }
    public static var nuviaError: Color { DSColors.error }
    public static var nuviaInfo: Color { DSColors.info }

    // Accent colors
    public static var nuviaSage: Color { DSColors.accentSage }
    public static var nuviaRoseDust: Color { DSColors.accentRose }
    public static var nuviaBlush: Color { DSColors.accentRose }

    // Additional decorative colors (keep as specific hex values)
    public static var nuviaWisteria: Color { Color(hex: "9B8AA6") }
    public static var nuviaDustyBlue: Color { Color(hex: "8BA7C4") }
    public static var nuviaTerracotta: Color { Color(hex: "C4A08B") }

    // Static variants (non-adaptive)
    public static var nuviaPrimaryTextStatic: Color { DSColors.Fallback.textPrimaryLight }
    public static var nuviaSecondaryTextStatic: Color { DSColors.Fallback.textSecondaryLight }
    public static var nuviaInfoStatic: Color { DSColors.Fallback.info }
    public static var nuviaSuccessStatic: Color { DSColors.Fallback.success }
    public static var nuviaWarningStatic: Color { DSColors.Fallback.warning }
    public static var nuviaErrorStatic: Color { DSColors.Fallback.error }

    // Category colors
    public static var categoryVenue: Color { Color(hex: "8BA7C4") }
    public static var categoryDress: Color { Color(hex: "E8D7D5") }
    public static var categoryMusic: Color { Color(hex: "9B8AA6") }
    public static var categoryFood: Color { Color(hex: "D4A574") }
    public static var categoryPhoto: Color { Color(hex: "D4AF37") }
    public static var categoryFlowers: Color { Color(hex: "8BAA7C") }

    // Gradients
    public static var nuviaGradient: LinearGradient {
        DSColors.heroGradient
    }

    public static var etherealGradient: LinearGradient {
        DSColors.heroGradient
    }
}

// MARK: - Themed Color Extension

extension Color {
    public struct themed {
        public static var backgroundGradient: LinearGradient {
            DSColors.backgroundGradient
        }
    }
}

// MARK: - Legacy View Extensions

extension View {
    /// Applies elevation shadow
    public func elevation(_ level: DesignTokens.Elevation) -> some View {
        let shadow = level.shadow
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    /// Legacy card styling
    public func cardStyle(elevation: DesignTokens.Elevation = .raised) -> some View {
        self
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.card, style: .continuous))
            .elevation(elevation)
    }

    /// Interactive press feedback
    public func pressable(scale: CGFloat = 0.97) -> some View {
        self.modifier(PressableModifier(scale: scale))
    }
}

// MARK: - Pressable Modifier

private struct PressableModifier: ViewModifier {
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

// MARK: - Ethereal Shadow System

public enum EtherealShadow {
    case none, whisper, soft, medium, pronounced, dramatic

    public var color: Color { .black }

    public var opacity: Double {
        switch self {
        case .none: return 0
        case .whisper: return 0.02
        case .soft: return 0.04
        case .medium: return 0.06
        case .pronounced: return 0.08
        case .dramatic: return 0.12
        }
    }

    public var radius: CGFloat {
        switch self {
        case .none: return 0
        case .whisper: return 8
        case .soft: return 16
        case .medium: return 24
        case .pronounced: return 32
        case .dramatic: return 48
        }
    }

    public var y: CGFloat {
        switch self {
        case .none: return 0
        case .whisper: return 2
        case .soft: return 4
        case .medium: return 8
        case .pronounced: return 12
        case .dramatic: return 20
        }
    }
}

extension View {
    public func etherealShadow(_ level: EtherealShadow, colored: Color? = nil) -> some View {
        self
            .shadow(
                color: (colored ?? level.color).opacity(level.opacity),
                radius: level.radius,
                x: 0,
                y: level.y
            )
            .shadow(
                color: (colored ?? level.color).opacity(level.opacity * 0.5),
                radius: level.radius * 2,
                x: 0,
                y: level.y * 2
            )
    }
}

// MARK: - Nuvia Shadow System

public enum NuviaShadow {
    case none, subtle, medium, elevated

    public var color: Color { .black }

    public var opacity: Double {
        switch self {
        case .none: return 0
        case .subtle: return 0.05
        case .medium: return 0.1
        case .elevated: return 0.15
        }
    }

    public var radius: CGFloat {
        switch self {
        case .none: return 0
        case .subtle: return 8
        case .medium: return 16
        case .elevated: return 24
        }
    }

    public var y: CGFloat {
        switch self {
        case .none: return 0
        case .subtle: return 2
        case .medium: return 6
        case .elevated: return 10
        }
    }
}

extension View {
    public func nuviaShadow(_ level: NuviaShadow) -> some View {
        self.shadow(
            color: level.color.opacity(level.opacity),
            radius: level.radius,
            x: 0,
            y: level.y
        )
    }
}

// MARK: - Animation Presets

extension Animation {
    public static var etherealSpring: Animation {
        .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1)
    }

    public static var etherealSnap: Animation {
        .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }

    public static var etherealEntrance: Animation {
        .spring(response: 0.7, dampingFraction: 0.85, blendDuration: 0.2)
    }
}

// MARK: - Card Entrance Animation

struct CardEntranceModifier: ViewModifier {
    let delay: Double
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 40))
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : (reduceMotion ? 1 : 0.95))
            .onAppear {
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(.etherealEntrance.delay(delay)) {
                        appeared = true
                    }
                }
            }
    }
}

extension View {
    public func cardEntrance(delay: Double = 0) -> some View {
        modifier(CardEntranceModifier(delay: delay))
    }

    public func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }
}

struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(.etherealSnap, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Seeded Random Number Generator

public struct SeedableRNG: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// MARK: - Additional Legacy Color Aliases

extension Color {
    // More static color aliases from NuviaColors
    public static let nuviaMutedSurface = Color(hex: "EDECE9")
    public static let nuviaBlush = Color(hex: "E8D5D5")
    public static let nuviaMidnight = Color(hex: "2C2C2C")
    public static let nuviaCharcoal = Color(hex: "6B6B6B")
    public static let nuviaCopper = Color(hex: "C4A389")
    public static let nuviaRoseGold = Color(hex: "C9A9A6")
    public static let nuviaGold = Color(hex: "D4AF37")
    public static let nuviaChampagneStatic = Color(hex: "D4AF37")

    // Glass effect colors
    public static let nuviaGlassOverlay = Color.white.opacity(0.05)
    public static let nuviaGlassBorder = Color.white.opacity(0.1)

    // Priority Colors
    public static let priorityLow = Color(hex: "9CAF88")
    public static let priorityMedium = Color(hex: "D4A574")
    public static let priorityHigh = Color(hex: "C48B8B")
    public static let priorityUrgent = Color(hex: "A86B6B")

    // Status Colors
    public static let statusPending = Color(hex: "9A9A9A")
    public static let statusInProgress = Color(hex: "A3B5C4")
    public static let statusCompleted = Color(hex: "8BAA7C")
    public static let statusCancelled = Color(hex: "B5B5B5")

    // Category Colors
    public static let categoryInvitation = Color(hex: "D4AF37")
    public static let categoryDecor = Color(hex: "CFC5B8")
}
