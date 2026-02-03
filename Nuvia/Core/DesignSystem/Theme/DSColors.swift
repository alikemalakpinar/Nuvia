import SwiftUI

// MARK: - Design System Colors
// "Editorial Elegance" semantic color tokens
// Single source of truth - feature views NEVER use Color directly

/// Semantic color namespace for Nuvia Design System
/// All colors support light/dark mode automatically
public enum DSColors {

    // MARK: - Foundation

    /// Primary background color (#FAFAF9 light / #1C1C1E dark)
    public static var background: Color {
        Color("ds.background", bundle: nil)
    }

    /// Card/Surface color (#FFFFFF light / #2C2C2E dark)
    public static var surface: Color {
        Color("ds.surface", bundle: nil)
    }

    /// Elevated surface for modals/sheets
    public static var surfaceElevated: Color {
        Color("ds.surfaceElevated", bundle: nil)
    }

    /// Tertiary/muted background for inputs, chips
    public static var surfaceTertiary: Color {
        Color("ds.surfaceTertiary", bundle: nil)
    }

    // MARK: - Text Hierarchy

    /// Primary text color (#2A2A2A light / #E5E5EA dark)
    public static var textPrimary: Color {
        Color("ds.textPrimary", bundle: nil)
    }

    /// Secondary text color (#6D6D6D light / #8E8E93 dark)
    public static var textSecondary: Color {
        Color("ds.textSecondary", bundle: nil)
    }

    /// Tertiary/placeholder text
    public static var textTertiary: Color {
        Color("ds.textTertiary", bundle: nil)
    }

    /// Inverse text for dark backgrounds
    public static var textInverse: Color {
        Color.white
    }

    // MARK: - Brand Accents

    /// Primary gold accent (#D4AF37)
    public static var primaryAction: Color {
        Color("ds.primaryAction", bundle: nil)
    }

    /// Rose/blush accent (#E8D7D5 light / #8B4557 dark)
    public static var accentRose: Color {
        Color("ds.accentRose", bundle: nil)
    }

    /// Sage/green accent (#D5E8D7 light / #4A5D4A dark)
    public static var accentSage: Color {
        Color("ds.accentSage", bundle: nil)
    }

    // MARK: - Semantic States

    public static var success: Color {
        Color("ds.success", bundle: nil)
    }

    public static var warning: Color {
        Color("ds.warning", bundle: nil)
    }

    public static var error: Color {
        Color("ds.error", bundle: nil)
    }

    public static var info: Color {
        Color("ds.info", bundle: nil)
    }

    // MARK: - Interactive

    /// Primary button background (same as primaryAction)
    public static var buttonPrimary: Color {
        primaryAction
    }

    /// Secondary button (charcoal light / ivory dark)
    public static var buttonSecondary: Color {
        Color("ds.buttonSecondary", bundle: nil)
    }

    // MARK: - Gradients

    /// Hero gradient for featured content
    public static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [primaryAction.opacity(0.9), accentRose],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Subtle background gradient
    public static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [background, surfaceTertiary],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Hex Fallback Colors
// Used when Asset Catalog colors are not available
// These provide the exact spec values

extension DSColors {

    public enum Fallback {
        // Light mode
        public static let backgroundLight = Color(hex: "FAFAF9")
        public static let surfaceLight = Color(hex: "FFFFFF")
        public static let surfaceElevatedLight = Color(hex: "FCFCFB")
        public static let surfaceTertiaryLight = Color(hex: "F5F4F2")
        public static let textPrimaryLight = Color(hex: "2A2A2A")
        public static let textSecondaryLight = Color(hex: "6D6D6D")
        public static let textTertiaryLight = Color(hex: "9A9A9A")

        // Dark mode
        public static let backgroundDark = Color(hex: "1C1C1E")
        public static let surfaceDark = Color(hex: "2C2C2E")
        public static let surfaceElevatedDark = Color(hex: "3A3A3C")
        public static let surfaceTertiaryDark = Color(hex: "48484A")
        public static let textPrimaryDark = Color(hex: "E5E5EA")
        public static let textSecondaryDark = Color(hex: "8E8E93")
        public static let textTertiaryDark = Color(hex: "636366")

        // Brand (same in both modes)
        public static let gold = Color(hex: "D4AF37")
        public static let rose = Color(hex: "E8D7D5")
        public static let roseDark = Color(hex: "8B4557")
        public static let sage = Color(hex: "D5E8D7")
        public static let sageDark = Color(hex: "4A5D4A")

        // Semantic
        public static let success = Color(hex: "8BAA7C")
        public static let warning = Color(hex: "D4A574")
        public static let error = Color(hex: "C48B8B")
        public static let info = Color(hex: "8BA7C4")
    }
}

// MARK: - Adaptive Color Provider
// Returns correct color based on color scheme when Asset Catalog unavailable

public struct AdaptiveColor {
    let light: Color
    let dark: Color

    public func resolve(for scheme: ColorScheme) -> Color {
        scheme == .dark ? dark : light
    }
}

extension DSColors {

    /// Provides adaptive colors that work without Asset Catalog
    public enum Adaptive {
        public static let background = AdaptiveColor(
            light: Fallback.backgroundLight,
            dark: Fallback.backgroundDark
        )

        public static let surface = AdaptiveColor(
            light: Fallback.surfaceLight,
            dark: Fallback.surfaceDark
        )

        public static let surfaceElevated = AdaptiveColor(
            light: Fallback.surfaceElevatedLight,
            dark: Fallback.surfaceElevatedDark
        )

        public static let surfaceTertiary = AdaptiveColor(
            light: Fallback.surfaceTertiaryLight,
            dark: Fallback.surfaceTertiaryDark
        )

        public static let textPrimary = AdaptiveColor(
            light: Fallback.textPrimaryLight,
            dark: Fallback.textPrimaryDark
        )

        public static let textSecondary = AdaptiveColor(
            light: Fallback.textSecondaryLight,
            dark: Fallback.textSecondaryDark
        )

        public static let textTertiary = AdaptiveColor(
            light: Fallback.textTertiaryLight,
            dark: Fallback.textTertiaryDark
        )

        public static let accentRose = AdaptiveColor(
            light: Fallback.rose,
            dark: Fallback.roseDark
        )

        public static let accentSage = AdaptiveColor(
            light: Fallback.sage,
            dark: Fallback.sageDark
        )
    }
}

// MARK: - Environment-based Color Resolution

private struct DSColorSchemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme = .light
}

extension EnvironmentValues {
    var dsColorScheme: ColorScheme {
        get { self[DSColorSchemeKey.self] }
        set { self[DSColorSchemeKey.self] = newValue }
    }
}

// MARK: - View Extension for Adaptive Colors

extension View {
    /// Resolves adaptive DS colors based on current color scheme
    public func dsBackground() -> some View {
        self.modifier(DSBackgroundModifier())
    }
}

private struct DSBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(DSColors.Adaptive.background.resolve(for: colorScheme))
    }
}

// MARK: - Hex Color Initializer (if not already defined)

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
