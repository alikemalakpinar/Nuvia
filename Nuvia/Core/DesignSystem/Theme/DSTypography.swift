import SwiftUI

// MARK: - Design System Typography
// "Vogue Scale" - Editorial typography hierarchy
// Headings: Playfair Display (fallback: system serif/New York)
// Body: Manrope (fallback: SF Pro)

/// Typography scale for Nuvia Design System
public enum DSTypography {

    // MARK: - Font Families

    private enum FontFamily {
        // Playfair Display - Editorial serif for headings
        static let serifRegular = "PlayfairDisplay-Regular"
        static let serifMedium = "PlayfairDisplay-Medium"
        static let serifSemiBold = "PlayfairDisplay-SemiBold"
        static let serifBold = "PlayfairDisplay-Bold"
        static let serifItalic = "PlayfairDisplay-Italic"

        // Manrope - Modern geometric sans for body
        static let sansRegular = "Manrope-Regular"
        static let sansMedium = "Manrope-Medium"
        static let sansSemiBold = "Manrope-SemiBold"
        static let sansBold = "Manrope-Bold"
        static let sansExtraBold = "Manrope-ExtraBold"
    }

    // MARK: - Display Scale (Hero/Magazine)
    // Uses Playfair Display - High contrast, dramatic

    /// DisplayXL: 56pt Bold Serif - Magazine cover headlines
    public static var displayXL: Font {
        customFont(FontFamily.serifBold, size: 56, fallback: .bold, design: .serif)
    }

    /// Display: 44pt Bold Serif - Hero sections
    public static var display: Font {
        customFont(FontFamily.serifBold, size: 44, fallback: .bold, design: .serif)
    }

    /// DisplaySmall: 34pt SemiBold Serif - Featured content
    public static var displaySmall: Font {
        customFont(FontFamily.serifSemiBold, size: 34, fallback: .semibold, design: .serif)
    }

    // MARK: - Heading Scale
    // H1-H2: Playfair (emotional), H3-H4: Manrope (functional)

    /// Heading1: 28pt Bold Serif - Page titles
    public static var heading1: Font {
        customFont(FontFamily.serifBold, size: 28, fallback: .bold, design: .serif)
    }

    /// Heading2: 24pt SemiBold Serif - Section titles
    public static var heading2: Font {
        customFont(FontFamily.serifSemiBold, size: 24, fallback: .semibold, design: .serif)
    }

    /// Heading3: 20pt SemiBold Sans - Subsections
    public static var heading3: Font {
        customFont(FontFamily.sansSemiBold, size: 20, fallback: .semibold, design: .default)
    }

    /// Heading4: 17pt SemiBold Sans - Card titles
    public static var heading4: Font {
        customFont(FontFamily.sansSemiBold, size: 17, fallback: .semibold, design: .default)
    }

    // MARK: - Body Scale
    // Uses Manrope - Clean, readable

    /// BodyLarge: 17pt Regular - Important paragraphs
    public static var bodyLarge: Font {
        customFont(FontFamily.sansRegular, size: 17, fallback: .regular, design: .default)
    }

    /// BodyBold: 15pt SemiBold - Emphasized body text
    public static var bodyBold: Font {
        customFont(FontFamily.sansSemiBold, size: 15, fallback: .semibold, design: .default)
    }

    /// Body: 15pt Regular - Standard body text
    public static var body: Font {
        customFont(FontFamily.sansRegular, size: 15, fallback: .regular, design: .default)
    }

    /// BodySmall: 13pt Regular - Secondary content
    public static var bodySmall: Font {
        customFont(FontFamily.sansRegular, size: 13, fallback: .regular, design: .default)
    }

    // MARK: - Caption Scale

    /// Caption: 12pt Medium - Labels, metadata
    public static var caption: Font {
        customFont(FontFamily.sansMedium, size: 12, fallback: .medium, design: .default)
    }

    /// CaptionSmall: 11pt Regular - Micro text
    public static var captionSmall: Font {
        customFont(FontFamily.sansRegular, size: 11, fallback: .regular, design: .default)
    }

    /// Overline: 11pt SemiBold - Section labels, SMALL CAPS style
    public static var overline: Font {
        customFont(FontFamily.sansSemiBold, size: 11, fallback: .semibold, design: .default)
    }

    // MARK: - Special Styles

    /// Countdown: 72pt ExtraBold Rounded - Large numbers
    public static var countdown: Font {
        customFont(FontFamily.sansExtraBold, size: 72, fallback: .heavy, design: .rounded)
    }

    /// NumberLarge: 48pt Bold Rounded - Statistics
    public static var numberLarge: Font {
        customFont(FontFamily.sansBold, size: 48, fallback: .bold, design: .rounded)
    }

    /// NumberMedium: 32pt SemiBold Rounded
    public static var numberMedium: Font {
        customFont(FontFamily.sansSemiBold, size: 32, fallback: .semibold, design: .rounded)
    }

    /// NumberSmall: 24pt Medium Rounded
    public static var numberSmall: Font {
        customFont(FontFamily.sansMedium, size: 24, fallback: .medium, design: .rounded)
    }

    /// Currency: 24pt SemiBold Monospace
    public static var currency: Font {
        customFont(FontFamily.sansSemiBold, size: 24, fallback: .semibold, design: .monospaced)
    }

    /// Button: 16pt SemiBold - Primary buttons
    public static var button: Font {
        customFont(FontFamily.sansSemiBold, size: 16, fallback: .semibold, design: .default)
    }

    /// ButtonSmall: 14pt Medium - Secondary buttons
    public static var buttonSmall: Font {
        customFont(FontFamily.sansMedium, size: 14, fallback: .medium, design: .default)
    }

    /// Quote: 20pt Italic Serif - Testimonials
    public static var quote: Font {
        customFont(FontFamily.serifItalic, size: 20, fallback: .regular, design: .serif)
    }

    /// NavTitle: 17pt SemiBold - Navigation bar
    public static var navTitle: Font {
        customFont(FontFamily.sansSemiBold, size: 17, fallback: .semibold, design: .default)
    }

    /// NavLargeTitle: 34pt Bold Serif - Large navigation title
    public static var navLargeTitle: Font {
        customFont(FontFamily.serifBold, size: 34, fallback: .bold, design: .serif)
    }

    // MARK: - Kerning Defaults

    public enum Kerning {
        public static let tight: CGFloat = -0.5
        public static let normal: CGFloat = 0
        public static let wide: CGFloat = 0.5
        public static let veryWide: CGFloat = 1.5
        public static let overline: CGFloat = 2.0
    }

    // MARK: - Line Height Multipliers

    public enum LineHeight {
        public static let tight: CGFloat = 1.1
        public static let normal: CGFloat = 1.4
        public static let relaxed: CGFloat = 1.6
        public static let loose: CGFloat = 1.8
    }

    // MARK: - Custom Font Resolution

    private static func customFont(
        _ name: String,
        size: CGFloat,
        fallback weight: Font.Weight,
        design: Font.Design
    ) -> Font {
        // Try custom font first
        if UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size)
        }
        // Fallback to system font with matching characteristics
        return .system(size: size, weight: weight, design: design)
    }
}

// MARK: - Text Style Enum (for convenience)

public enum DSTextStyle {
    // Display
    case displayXL
    case display
    case displaySmall

    // Headings
    case heading1
    case heading2
    case heading3
    case heading4

    // Body
    case bodyLarge
    case bodyBold
    case body
    case bodySmall

    // Caption
    case caption
    case captionSmall
    case overline

    // Special
    case countdown
    case numberLarge
    case numberMedium
    case numberSmall
    case currency
    case button
    case buttonSmall
    case quote

    public var font: Font {
        switch self {
        case .displayXL: return DSTypography.displayXL
        case .display: return DSTypography.display
        case .displaySmall: return DSTypography.displaySmall
        case .heading1: return DSTypography.heading1
        case .heading2: return DSTypography.heading2
        case .heading3: return DSTypography.heading3
        case .heading4: return DSTypography.heading4
        case .bodyLarge: return DSTypography.bodyLarge
        case .bodyBold: return DSTypography.bodyBold
        case .body: return DSTypography.body
        case .bodySmall: return DSTypography.bodySmall
        case .caption: return DSTypography.caption
        case .captionSmall: return DSTypography.captionSmall
        case .overline: return DSTypography.overline
        case .countdown: return DSTypography.countdown
        case .numberLarge: return DSTypography.numberLarge
        case .numberMedium: return DSTypography.numberMedium
        case .numberSmall: return DSTypography.numberSmall
        case .currency: return DSTypography.currency
        case .button: return DSTypography.button
        case .buttonSmall: return DSTypography.buttonSmall
        case .quote: return DSTypography.quote
        }
    }

    public var defaultKerning: CGFloat {
        switch self {
        case .displayXL, .display: return DSTypography.Kerning.tight
        case .displaySmall, .heading1: return -0.3
        case .overline: return DSTypography.Kerning.overline
        default: return DSTypography.Kerning.normal
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply DS typography style with optional kerning
    public func dsFont(_ style: DSTextStyle, kerning: CGFloat? = nil) -> some View {
        self
            .font(style.font)
            .tracking(kerning ?? style.defaultKerning)
    }
}

// MARK: - Text Extension

extension Text {
    /// Apply DS typography style
    public func dsStyle(_ style: DSTextStyle) -> Text {
        self.font(style.font)
    }

    /// Overline text with proper styling
    public func dsOverline() -> some View {
        self
            .font(DSTypography.overline)
            .tracking(DSTypography.Kerning.overline)
            .textCase(.uppercase)
    }
}
