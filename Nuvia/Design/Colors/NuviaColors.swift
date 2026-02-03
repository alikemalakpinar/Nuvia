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

public struct LightLuxuryColors: ThemeColors {
    // Foundation - Warm Alabaster
    public var background: Color { Color(hex: "FAFAF9") }
    public var surface: Color { Color.white }
    public var surfaceElevated: Color { Color(hex: "FCFCFB") }
    public var surfaceTertiary: Color { Color(hex: "F5F4F2") }

    // Text - Rich Charcoal
    public var textPrimary: Color { Color(hex: "2C2C2C") }
    public var textSecondary: Color { Color(hex: "6B6B6B") }
    public var textTertiary: Color { Color(hex: "9A9A9A") }
    public var textInverse: Color { Color.white }

    // Brand - Champagne & Rose
    public var accent: Color { Color(hex: "D4AF37") }
    public var accentSecondary: Color { Color(hex: "C9A9A6") }
    public var accentTertiary: Color { Color(hex: "9CAF88") }

    // Actions
    public var buttonPrimary: Color { Color(hex: "2C2C2C") }
    public var buttonSecondary: Color { Color(hex: "D4AF37") }
    public var buttonDestructive: Color { Color(hex: "C97A7A") }

    // Semantic
    public var success: Color { Color(hex: "8BAA7C") }
    public var warning: Color { Color(hex: "D4A574") }
    public var error: Color { Color(hex: "C48B8B") }
    public var info: Color { Color(hex: "8BA7C4") }

    // Gradients
    public var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "D4AF37").opacity(0.9), Color(hex: "C9A9A6")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "FAFAF9"), Color(hex: "F5F4F2")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Dark Romance Theme (Premium)

public struct DarkRomanceColors: ThemeColors {
    // Foundation - Deep Midnight
    public var background: Color { Color(hex: "0D0D0F") }
    public var surface: Color { Color(hex: "1A1A1E") }
    public var surfaceElevated: Color { Color(hex: "242428") }
    public var surfaceTertiary: Color { Color(hex: "2E2E34") }

    // Text - Ivory & Silver
    public var textPrimary: Color { Color(hex: "F5F5F3") }
    public var textSecondary: Color { Color(hex: "A8A8A8") }
    public var textTertiary: Color { Color(hex: "6B6B6B") }
    public var textInverse: Color { Color(hex: "0D0D0F") }

    // Brand - Rose Gold & Burgundy
    public var accent: Color { Color(hex: "B8860B") } // Deep Gold
    public var accentSecondary: Color { Color(hex: "8B4557") } // Burgundy
    public var accentTertiary: Color { Color(hex: "4A5D4A") } // Dark Sage

    // Actions
    public var buttonPrimary: Color { Color(hex: "F5F5F3") }
    public var buttonSecondary: Color { Color(hex: "B8860B") }
    public var buttonDestructive: Color { Color(hex: "8B4557") }

    // Semantic
    public var success: Color { Color(hex: "5A7D5A") }
    public var warning: Color { Color(hex: "B8860B") }
    public var error: Color { Color(hex: "8B4557") }
    public var info: Color { Color(hex: "4A6B8A") }

    // Gradients
    public var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "B8860B").opacity(0.9), Color(hex: "8B4557")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "0D0D0F"), Color(hex: "1A1A1E")],
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
    @MainActor
    public static var themed: ThemeColors {
        ThemeManager.shared.currentTheme.colors
    }
}

// MARK: - Legacy Compatibility (Mapped to Theme)

extension Color {
    // Foundation
    @MainActor public static var nuviaBackground: Color { themed.background }
    @MainActor public static var nuviaSurface: Color { themed.surface }
    @MainActor public static var nuviaElevatedSurface: Color { themed.surfaceElevated }
    @MainActor public static var nuviaTertiaryBackground: Color { themed.surfaceTertiary }

    // Text
    @MainActor public static var nuviaPrimaryText: Color { themed.textPrimary }
    @MainActor public static var nuviaSecondaryText: Color { themed.textSecondary }
    @MainActor public static var nuviaTertiaryText: Color { themed.textTertiary }
    @MainActor public static var nuviaInverseText: Color { themed.textInverse }

    // Brand
    @MainActor public static var nuviaChampagne: Color { themed.accent }
    @MainActor public static var nuviaRoseDust: Color { themed.accentSecondary }
    @MainActor public static var nuviaSage: Color { themed.accentTertiary }

    // Actions
    @MainActor public static var nuviaPrimaryAction: Color { themed.buttonPrimary }
    @MainActor public static var nuviaSecondaryAction: Color { themed.buttonSecondary }

    // Semantic
    @MainActor public static var nuviaSuccess: Color { themed.success }
    @MainActor public static var nuviaWarning: Color { themed.warning }
    @MainActor public static var nuviaError: Color { themed.error }
    @MainActor public static var nuviaInfo: Color { themed.info }

    // Gradient
    @MainActor public static var etherealGradient: LinearGradient { themed.heroGradient }

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

struct CardEntranceModifier: ViewModifier {
    let delay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : 40)
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.95)
            .onAppear {
                withAnimation(.etherealEntrance.delay(delay)) {
                    appeared = true
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
