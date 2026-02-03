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

// MARK: - Design System Typography
// Custom Fonts: Playfair Display (serif) + Manrope (sans-serif)

public struct DSTypography {

    // MARK: - Font Family Names
    public struct FontFamily {
        // Playfair Display - Elegant editorial serif for headers
        public static let serifRegular = "PlayfairDisplay-Regular"
        public static let serifMedium = "PlayfairDisplay-Medium"
        public static let serifSemiBold = "PlayfairDisplay-SemiBold"
        public static let serifBold = "PlayfairDisplay-Bold"
        public static let serifBlack = "PlayfairDisplay-Black"
        public static let serifItalic = "PlayfairDisplay-Italic"
        public static let serifBoldItalic = "PlayfairDisplay-BoldItalic"

        // Manrope - Modern geometric sans for body
        public static let sansLight = "Manrope-Light"
        public static let sansRegular = "Manrope-Regular"
        public static let sansMedium = "Manrope-Medium"
        public static let sansSemiBold = "Manrope-SemiBold"
        public static let sansBold = "Manrope-Bold"
        public static let sansExtraBold = "Manrope-ExtraBold"
    }

    // MARK: - Display Styles (Hero/Magazine)
    // Uses Playfair Display - High contrast, dramatic serif

    public static func display(_ size: DisplaySize) -> Font {
        switch size {
        case .large:
            return customFont(FontFamily.serifBold, size: 56, fallbackWeight: .bold, design: .serif)
        case .medium:
            return customFont(FontFamily.serifBold, size: 44, fallbackWeight: .bold, design: .serif)
        case .small:
            return customFont(FontFamily.serifSemiBold, size: 34, fallbackWeight: .semibold, design: .serif)
        }
    }

    // MARK: - Headings
    // H1-H2: Playfair Display (emotional)
    // H3-H4: Manrope (functional)

    public static func heading(_ level: HeadingLevel) -> Font {
        switch level {
        case .h1:
            return customFont(FontFamily.serifBold, size: 28, fallbackWeight: .bold, design: .serif)
        case .h2:
            return customFont(FontFamily.serifSemiBold, size: 24, fallbackWeight: .semibold, design: .serif)
        case .h3:
            return customFont(FontFamily.sansSemiBold, size: 20, fallbackWeight: .semibold, design: .default)
        case .h4:
            return customFont(FontFamily.sansSemiBold, size: 17, fallbackWeight: .semibold, design: .default)
        }
    }

    // MARK: - Body Styles
    // Uses Manrope - Clean, readable sans-serif

    public static func body(_ variant: BodyVariant = .regular) -> Font {
        switch variant {
        case .large:
            return customFont(FontFamily.sansRegular, size: 17, fallbackWeight: .regular, design: .default)
        case .regular:
            return customFont(FontFamily.sansRegular, size: 15, fallbackWeight: .regular, design: .default)
        case .small:
            return customFont(FontFamily.sansRegular, size: 13, fallbackWeight: .regular, design: .default)
        case .bold:
            return customFont(FontFamily.sansSemiBold, size: 15, fallbackWeight: .semibold, design: .default)
        }
    }

    // MARK: - Label/Utility Styles
    // Uses Manrope - Compact, clear

    public static func label(_ size: LabelSize = .regular) -> Font {
        switch size {
        case .large:
            return customFont(FontFamily.sansMedium, size: 14, fallbackWeight: .medium, design: .default)
        case .regular:
            return customFont(FontFamily.sansMedium, size: 12, fallbackWeight: .medium, design: .default)
        case .small:
            return customFont(FontFamily.sansSemiBold, size: 10, fallbackWeight: .semibold, design: .default)
        }
    }

    // MARK: - Special Styles

    /// Large countdown numbers - Uses Manrope ExtraBold
    public static var countdown: Font {
        customFont(FontFamily.sansExtraBold, size: 72, fallbackWeight: .heavy, design: .rounded)
    }

    /// Overline/Eyebrow text
    public static var overline: Font {
        customFont(FontFamily.sansSemiBold, size: 11, fallbackWeight: .semibold, design: .default)
    }

    /// Button text
    public static var button: Font {
        customFont(FontFamily.sansSemiBold, size: 16, fallbackWeight: .semibold, design: .default)
    }

    /// Caption text
    public static var caption: Font {
        customFont(FontFamily.sansRegular, size: 12, fallbackWeight: .regular, design: .default)
    }

    /// Quote/Testimonial - Playfair Italic
    public static var quote: Font {
        customFont(FontFamily.serifItalic, size: 20, fallbackWeight: .regular, design: .serif)
    }

    /// Currency/Price display
    public static var currency: Font {
        customFont(FontFamily.sansSemiBold, size: 24, fallbackWeight: .semibold, design: .monospaced)
    }

    /// Navigation title
    public static var navTitle: Font {
        customFont(FontFamily.sansSemiBold, size: 17, fallbackWeight: .semibold, design: .default)
    }

    /// Large navigation title
    public static var navLargeTitle: Font {
        customFont(FontFamily.serifBold, size: 34, fallbackWeight: .bold, design: .serif)
    }

    // MARK: - Enums

    public enum DisplaySize { case large, medium, small }
    public enum HeadingLevel { case h1, h2, h3, h4 }
    public enum BodyVariant { case large, regular, small, bold }
    public enum LabelSize { case large, regular, small }

    // MARK: - Custom Font Helper

    /// Creates a custom font with system fallback
    private static func customFont(
        _ name: String,
        size: CGFloat,
        fallbackWeight: Font.Weight,
        design: Font.Design
    ) -> Font {
        // Try custom font first
        if let _ = UIFont(name: name, size: size) {
            return Font.custom(name, size: size)
        }
        // Fallback to system font
        return .system(size: size, weight: fallbackWeight, design: design)
    }
}

// MARK: - Font Registration Helper

public enum FontRegistration {
    /// Call this in AppDelegate or App init to register custom fonts
    public static func registerCustomFonts() {
        let fontNames = [
            // Playfair Display
            "PlayfairDisplay-Regular",
            "PlayfairDisplay-Medium",
            "PlayfairDisplay-SemiBold",
            "PlayfairDisplay-Bold",
            "PlayfairDisplay-Black",
            "PlayfairDisplay-Italic",
            "PlayfairDisplay-BoldItalic",
            // Manrope
            "Manrope-Light",
            "Manrope-Regular",
            "Manrope-Medium",
            "Manrope-SemiBold",
            "Manrope-Bold",
            "Manrope-ExtraBold"
        ]

        for fontName in fontNames {
            if let url = Bundle.main.url(forResource: fontName, withExtension: "ttf") {
                registerFont(from: url)
            } else if let url = Bundle.main.url(forResource: fontName, withExtension: "otf") {
                registerFont(from: url)
            }
        }
    }

    private static func registerFont(from url: URL) {
        guard let fontDataProvider = CGDataProvider(url: url as CFURL),
              let font = CGFont(fontDataProvider) else {
            return
        }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }

    /// Debug helper to list all available fonts
    public static func printAvailableFonts() {
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  - \(name)")
            }
        }
    }
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
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        selectionGenerator.prepare()
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
        selectionGenerator.selectionChanged()
    }

    public func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notification.notificationOccurred(type)
    }
}
