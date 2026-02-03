import SwiftUI

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
    /// - Parameter theme: The theme to switch to
    /// - Returns: True if switch was successful, false if premium required
    @discardableResult
    public func setTheme(_ theme: NuviaTheme) -> Bool {
        if theme == .darkRomance && !isPremiumThemeUnlocked {
            return false
        }
        withAnimation(DesignTokens.Animation.smooth) {
            currentTheme = theme
        }
        HapticEngine.shared.selection()
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

    // MARK: - Color Palette

    public var colors: ThemeColors {
        switch self {
        case .lightLuxury: return LightLuxuryColors()
        case .darkRomance: return DarkRomanceColors()
        }
    }
}

// MARK: - Theme Colors Protocol

public protocol ThemeColors {
    // Foundation
    var background: Color { get }
    var surface: Color { get }
    var surfaceElevated: Color { get }
    var surfaceTertiary: Color { get }

    // Text
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textTertiary: Color { get }
    var textInverse: Color { get }

    // Brand
    var accent: Color { get }
    var accentSecondary: Color { get }
    var accentTertiary: Color { get }

    // Actions
    var buttonPrimary: Color { get }
    var buttonSecondary: Color { get }
    var buttonDestructive: Color { get }

    // Semantic
    var success: Color { get }
    var warning: Color { get }
    var error: Color { get }
    var info: Color { get }

    // Gradients
    var heroGradient: LinearGradient { get }
    var backgroundGradient: LinearGradient { get }
}

// MARK: - Light Luxury Theme (Default)
// Updated to "Editorial Elegance" specification

public struct LightLuxuryColors: ThemeColors {
    // Foundation - Editorial Elegance Spec
    public var background: Color { Color(hex: "FAFAF9") }      // Warm Alabaster
    public var surface: Color { Color(hex: "FFFFFF") }          // Pure White
    public var surfaceElevated: Color { Color(hex: "FCFCFB") }  // Slightly warm white
    public var surfaceTertiary: Color { Color(hex: "F5F4F2") }  // Subtle warmth

    // Text - Editorial Elegance Spec
    public var textPrimary: Color { Color(hex: "2A2A2A") }      // Rich charcoal
    public var textSecondary: Color { Color(hex: "6D6D6D") }    // Muted charcoal
    public var textTertiary: Color { Color(hex: "9A9A9A") }     // Light gray
    public var textInverse: Color { Color.white }

    // Brand - Editorial Elegance Spec
    public var accent: Color { Color(hex: "D4AF37") }           // Champagne Gold
    public var accentSecondary: Color { Color(hex: "E8D7D5") }  // Accent Rose
    public var accentTertiary: Color { Color(hex: "D5E8D7") }   // Accent Sage

    // Actions
    public var buttonPrimary: Color { Color(hex: "2A2A2A") }    // Dark for contrast
    public var buttonSecondary: Color { Color(hex: "D4AF37") }  // Gold
    public var buttonDestructive: Color { Color(hex: "C48B8B") }

    // Semantic - Muted, sophisticated
    public var success: Color { Color(hex: "8BAA7C") }          // Sage success
    public var warning: Color { Color(hex: "D4A574") }          // Warm amber
    public var error: Color { Color(hex: "C48B8B") }            // Dusty rose error
    public var info: Color { Color(hex: "8BA7C4") }             // Dusty blue

    // Gradients
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
// Updated to "Editorial Elegance" dark mode specification

public struct DarkRomanceColors: ThemeColors {
    // Foundation - Editorial Elegance Dark Spec
    public var background: Color { Color(hex: "1C1C1E") }       // iOS dark background
    public var surface: Color { Color(hex: "2C2C2E") }          // Elevated surface
    public var surfaceElevated: Color { Color(hex: "3A3A3C") }  // Modal/sheet
    public var surfaceTertiary: Color { Color(hex: "48484A") }  // Input backgrounds

    // Text - Editorial Elegance Dark Spec
    public var textPrimary: Color { Color(hex: "E5E5EA") }      // Primary text
    public var textSecondary: Color { Color(hex: "8E8E93") }    // Secondary text
    public var textTertiary: Color { Color(hex: "636366") }     // Tertiary text
    public var textInverse: Color { Color(hex: "1C1C1E") }

    // Brand - Rose Gold & Burgundy (darker tones)
    public var accent: Color { Color(hex: "D4AF37") }           // Gold (same)
    public var accentSecondary: Color { Color(hex: "8B4557") }  // Dark rose
    public var accentTertiary: Color { Color(hex: "4A5D4A") }   // Dark sage

    // Actions
    public var buttonPrimary: Color { Color(hex: "E5E5EA") }    // Light for contrast
    public var buttonSecondary: Color { Color(hex: "D4AF37") }  // Gold
    public var buttonDestructive: Color { Color(hex: "8B4557") }

    // Semantic - Darker tones
    public var success: Color { Color(hex: "5A7D5A") }
    public var warning: Color { Color(hex: "B8860B") }
    public var error: Color { Color(hex: "8B4557") }
    public var info: Color { Color(hex: "4A6B8A") }

    // Gradients
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

// MARK: - Themed Color Extension

extension Color {
    /// Get current theme's color dynamically
    /// Using MainActor.assumeIsolated as this is only accessed from SwiftUI view bodies (main thread)
    nonisolated(unsafe) public static var themed: ThemeColors {
        MainActor.assumeIsolated {
            ThemeManager.shared.currentTheme.colors
        }
    }
}

// MARK: - Legacy Compatibility (Mapped to Theme)
// Using nonisolated(unsafe) since SwiftUI views always execute on main thread

extension Color {
    // Foundation
    nonisolated(unsafe) public static var nuviaBackground: Color { themed.background }
    nonisolated(unsafe) public static var nuviaSurface: Color { themed.surface }
    nonisolated(unsafe) public static var nuviaElevatedSurface: Color { themed.surfaceElevated }
    nonisolated(unsafe) public static var nuviaTertiaryBackground: Color { themed.surfaceTertiary }

    // Text
    nonisolated(unsafe) public static var nuviaPrimaryText: Color { themed.textPrimary }
    nonisolated(unsafe) public static var nuviaSecondaryText: Color { themed.textSecondary }
    nonisolated(unsafe) public static var nuviaTertiaryText: Color { themed.textTertiary }
    nonisolated(unsafe) public static var nuviaInverseText: Color { themed.textInverse }

    // Brand
    nonisolated(unsafe) public static var nuviaChampagne: Color { themed.accent }
    nonisolated(unsafe) public static var nuviaRoseDust: Color { themed.accentSecondary }
    nonisolated(unsafe) public static var nuviaSage: Color { themed.accentTertiary }

    // Actions
    nonisolated(unsafe) public static var nuviaPrimaryAction: Color { themed.buttonPrimary }
    nonisolated(unsafe) public static var nuviaSecondaryAction: Color { themed.buttonSecondary }

    // Semantic
    nonisolated(unsafe) public static var nuviaSuccess: Color { themed.success }
    nonisolated(unsafe) public static var nuviaWarning: Color { themed.warning }
    nonisolated(unsafe) public static var nuviaError: Color { themed.error }
    nonisolated(unsafe) public static var nuviaInfo: Color { themed.info }

    // Gradient
    nonisolated(unsafe) public static var etherealGradient: LinearGradient { themed.heroGradient }

    // Static gradient (non-MainActor)
    public static let nuviaGradient = LinearGradient(
        colors: [Color(hex: "D4AF37").opacity(0.9), Color(hex: "C9A9A6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Static fallbacks (non-MainActor) - Use these in SwiftData models
    public static let nuviaBlush = Color(hex: "E8D5D5")
    public static let nuviaWisteria = Color(hex: "B5A3C4")
    public static let nuviaDustyBlue = Color(hex: "A3B5C4")
    public static let nuviaTerracotta = Color(hex: "C4A389")
    public static let nuviaMutedSurface = Color(hex: "EDECE9")
    public static let nuviaCardBackground = Color(hex: "FFFFFF")

    // Non-MainActor semantic colors (for SwiftData models)
    public static let nuviaInfoStatic = Color(hex: "8BA7C4")
    public static let nuviaWarningStatic = Color(hex: "D4A574")
    public static let nuviaErrorStatic = Color(hex: "C48B8B")
    public static let nuviaSuccessStatic = Color(hex: "8BAA7C")
    public static let nuviaPrimaryTextStatic = Color(hex: "2C2C2C")
    public static let nuviaSecondaryTextStatic = Color(hex: "6B6B6B")
    public static let nuviaTertiaryTextStatic = Color(hex: "9A9A9A")
    public static let nuviaChampagneStatic = Color(hex: "D4AF37")

    // Legacy aliases
    public static let nuviaGoldFallback = Color(hex: "D4AF37")
    public static let nuviaMidnight = Color(hex: "2C2C2C")
    public static let nuviaCharcoal = Color(hex: "6B6B6B")
    public static let nuviaCopper = Color(hex: "C4A389")
    public static let nuviaRoseGold = Color(hex: "C9A9A6")
    public static let nuviaGold = Color(hex: "D4AF37")

    // Glass effect colors
    public static let nuviaGlassOverlay = Color.white.opacity(0.05)
    public static let nuviaGlassBorder = Color.white.opacity(0.1)

    // Category Colors (static)
    public static let categoryVenue = Color(hex: "B5A3C4")
    public static let categoryPhoto = Color(hex: "A3B5C4")
    public static let categoryMusic = Color(hex: "C9A9A6")
    public static let categoryFlowers = Color(hex: "9CAF88")
    public static let categoryDress = Color(hex: "E8D5D5")
    public static let categoryFood = Color(hex: "C4A389")
    public static let categoryInvitation = Color(hex: "D4AF37")
    public static let categoryDecor = Color(hex: "CFC5B8")

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

// MARK: - Shadow System

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
// Respects Reduce Motion accessibility setting

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

// MARK: - Seeded Random Number Generator

public struct SeedableRNG: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func next() -> UInt64 {
        // Linear congruential generator
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
