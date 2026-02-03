import SwiftUI

// MARK: - Nuvia Ethereal Typography System
// "Editorial Elegance" - Magazine-quality type hierarchy

/// Typography tokens for the Nuvia Design System
/// Inspired by: Vogue, Harper's Bazaar, Apple Editorial
struct NuviaTypography {

    // MARK: - Font Families

    /// Display/Heading font - High-contrast Serif
    /// New York is Apple's native serif, perfect for editorial
    static let serifFamily = "New York"

    /// Body/UI font - Clean geometric sans
    static let sansFamily = "SF Pro Text"

    /// Display sans for large numbers
    static let displayFamily = "SF Pro Display"

    /// Monospace for data
    static let monoFamily = "SF Mono"

    // MARK: - Display Styles (Hero/Magazine)

    /// Magazine cover title - MASSIVE and emotive
    static func displayLarge() -> Font {
        .system(size: 56, weight: .bold, design: .serif)
    }

    /// Hero section title
    static func displayMedium() -> Font {
        .system(size: 44, weight: .bold, design: .serif)
    }

    /// Featured card title
    static func displaySmall() -> Font {
        .system(size: 34, weight: .semibold, design: .serif)
    }

    // MARK: - Heading Styles (Serif - Emotional)

    /// Page title - Primary heading
    static func heroTitle() -> Font {
        .system(size: 34, weight: .bold, design: .serif)
    }

    /// Section title
    static func title1() -> Font {
        .system(size: 28, weight: .semibold, design: .serif)
    }

    /// Subsection title
    static func title2() -> Font {
        .system(size: 22, weight: .semibold, design: .serif)
    }

    /// Card/Item title
    static func title3() -> Font {
        .system(size: 20, weight: .medium, design: .serif)
    }

    /// Small heading
    static func headline() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    // MARK: - Body Styles (Sans-Serif - Functional)

    /// Primary body text
    static func body() -> Font {
        .system(size: 17, weight: .regular, design: .default)
    }

    /// Emphasized body text
    static func bodyBold() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    /// Large body for important paragraphs
    static func bodyLarge() -> Font {
        .system(size: 19, weight: .regular, design: .default)
    }

    /// Secondary text
    static func callout() -> Font {
        .system(size: 16, weight: .regular, design: .default)
    }

    /// Footnote
    static func footnote() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }

    /// Caption
    static func caption() -> Font {
        .system(size: 12, weight: .medium, design: .default)
    }

    /// Micro text
    static func caption2() -> Font {
        .system(size: 11, weight: .regular, design: .default)
    }

    // MARK: - Special Styles

    /// Countdown number - Large and impactful
    static func countdown() -> Font {
        .system(size: 72, weight: .bold, design: .rounded)
    }

    /// Large statistic
    static func largeNumber() -> Font {
        .system(size: 48, weight: .bold, design: .rounded)
    }

    /// Medium statistic
    static func mediumNumber() -> Font {
        .system(size: 32, weight: .semibold, design: .rounded)
    }

    /// Small statistic
    static func smallNumber() -> Font {
        .system(size: 24, weight: .medium, design: .rounded)
    }

    /// Currency/Price
    static func currency() -> Font {
        .system(size: 24, weight: .medium, design: .monospaced)
    }

    /// Tag/Badge label
    static func tag() -> Font {
        .system(size: 12, weight: .semibold, design: .default)
    }

    /// Primary button
    static func button() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    /// Secondary/small button
    static func smallButton() -> Font {
        .system(size: 15, weight: .medium, design: .default)
    }

    /// Overline text (SMALL CAPS style)
    static func overline() -> Font {
        .system(size: 11, weight: .semibold, design: .default)
    }

    /// Quote/Testimonial - Italic serif
    static func quote() -> Font {
        .system(size: 20, weight: .regular, design: .serif)
    }

    // MARK: - Navigation Bar

    static func navTitle() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    static func navLargeTitle() -> Font {
        .system(size: 34, weight: .bold, design: .serif)
    }
}

// MARK: - Text Style Enum

enum NuviaTextStyle {
    // Display
    case displayLarge
    case displayMedium
    case displaySmall

    // Headings
    case heroTitle
    case title1
    case title2
    case title3
    case headline

    // Body
    case body
    case bodyBold
    case bodyLarge
    case callout
    case footnote
    case caption
    case caption2

    // Special
    case countdown
    case largeNumber
    case mediumNumber
    case smallNumber
    case currency
    case tag
    case button
    case smallButton
    case overline
    case quote

    var font: Font {
        switch self {
        case .displayLarge: return NuviaTypography.displayLarge()
        case .displayMedium: return NuviaTypography.displayMedium()
        case .displaySmall: return NuviaTypography.displaySmall()
        case .heroTitle: return NuviaTypography.heroTitle()
        case .title1: return NuviaTypography.title1()
        case .title2: return NuviaTypography.title2()
        case .title3: return NuviaTypography.title3()
        case .headline: return NuviaTypography.headline()
        case .body: return NuviaTypography.body()
        case .bodyBold: return NuviaTypography.bodyBold()
        case .bodyLarge: return NuviaTypography.bodyLarge()
        case .callout: return NuviaTypography.callout()
        case .footnote: return NuviaTypography.footnote()
        case .caption: return NuviaTypography.caption()
        case .caption2: return NuviaTypography.caption2()
        case .countdown: return NuviaTypography.countdown()
        case .largeNumber: return NuviaTypography.largeNumber()
        case .mediumNumber: return NuviaTypography.mediumNumber()
        case .smallNumber: return NuviaTypography.smallNumber()
        case .currency: return NuviaTypography.currency()
        case .tag: return NuviaTypography.tag()
        case .button: return NuviaTypography.button()
        case .smallButton: return NuviaTypography.smallButton()
        case .overline: return NuviaTypography.overline()
        case .quote: return NuviaTypography.quote()
        }
    }
}

// MARK: - View Modifiers

struct NuviaHeadingStyle: ViewModifier {
    let level: HeadingLevel

    enum HeadingLevel {
        case display, hero, title1, title2, title3
    }

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(.nuviaPrimaryText)
            .tracking(tracking)
    }

    private var font: Font {
        switch level {
        case .display: return NuviaTypography.displayMedium()
        case .hero: return NuviaTypography.heroTitle()
        case .title1: return NuviaTypography.title1()
        case .title2: return NuviaTypography.title2()
        case .title3: return NuviaTypography.title3()
        }
    }

    private var tracking: CGFloat {
        switch level {
        case .display: return -0.5
        case .hero: return -0.3
        case .title1: return -0.2
        case .title2, .title3: return 0
        }
    }
}

struct NuviaBodyStyle: ViewModifier {
    let weight: BodyWeight

    enum BodyWeight {
        case regular, bold, large
    }

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(.nuviaPrimaryText)
            .lineSpacing(4)
    }

    private var font: Font {
        switch weight {
        case .regular: return NuviaTypography.body()
        case .bold: return NuviaTypography.bodyBold()
        case .large: return NuviaTypography.bodyLarge()
        }
    }
}

// MARK: - View Extensions

extension View {
    func nuviaHeading(_ level: NuviaHeadingStyle.HeadingLevel) -> some View {
        modifier(NuviaHeadingStyle(level: level))
    }

    func nuviaBody(_ weight: NuviaBodyStyle.BodyWeight = .regular) -> some View {
        modifier(NuviaBodyStyle(weight: weight))
    }

    /// Apply editorial text styling
    func editorialText() -> some View {
        self
            .foregroundColor(.nuviaPrimaryText)
            .lineSpacing(6)
    }
}

// MARK: - Text Extensions

extension Text {
    func nuviaStyle(_ style: NuviaTextStyle) -> Text {
        self.font(style.font)
    }

    /// Small caps styling for overline text
    func overlineStyle() -> Text {
        self
            .font(NuviaTypography.overline())
            .tracking(1.5)
    }

    /// Quote/testimonial styling
    func quoteStyle() -> some View {
        self
            .font(NuviaTypography.quote())
            .italic()
            .foregroundColor(.nuviaSecondaryText)
            .lineSpacing(8)
    }
}

// MARK: - Label Styles

/// Ethereal label style for editorial look
struct EtherealLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon
                .font(.system(size: 16, weight: .medium))
            configuration.title
                .font(NuviaTypography.body())
        }
    }
}

extension LabelStyle where Self == EtherealLabelStyle {
    static var ethereal: EtherealLabelStyle { EtherealLabelStyle() }
}

// MARK: - Preview

#Preview("Typography System") {
    ScrollView {
        VStack(alignment: .leading, spacing: 32) {
            Group {
                Text("Display Styles")
                    .overlineStyle()
                    .foregroundColor(.nuviaSecondaryText)

                Text("The Big Day")
                    .font(NuviaTypography.displayLarge())
                    .foregroundColor(.nuviaPrimaryText)

                Text("Your Wedding Journey")
                    .font(NuviaTypography.displayMedium())
                    .foregroundColor(.nuviaPrimaryText)

                Text("Featured Moments")
                    .font(NuviaTypography.displaySmall())
                    .foregroundColor(.nuviaPrimaryText)
            }

            Divider()

            Group {
                Text("HEADING STYLES")
                    .overlineStyle()
                    .foregroundColor(.nuviaSecondaryText)

                Text("Hero Title")
                    .font(NuviaTypography.heroTitle())

                Text("Title 1 - Page Title")
                    .font(NuviaTypography.title1())

                Text("Title 2 - Section")
                    .font(NuviaTypography.title2())

                Text("Title 3 - Card Title")
                    .font(NuviaTypography.title3())
            }

            Divider()

            Group {
                Text("BODY STYLES")
                    .overlineStyle()
                    .foregroundColor(.nuviaSecondaryText)

                Text("Body Large - For important introductory paragraphs that need extra emphasis and readability.")
                    .font(NuviaTypography.bodyLarge())

                Text("Body Regular - The standard text style for most content throughout the application.")
                    .font(NuviaTypography.body())

                Text("Callout - Secondary information")
                    .font(NuviaTypography.callout())
                    .foregroundColor(.nuviaSecondaryText)

                Text("Caption - Metadata and labels")
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaTertiaryText)
            }

            Divider()

            Group {
                Text("SPECIAL STYLES")
                    .overlineStyle()
                    .foregroundColor(.nuviaSecondaryText)

                Text("127")
                    .font(NuviaTypography.countdown())
                    .foregroundColor(.nuviaChampagne)

                Text("$45,000")
                    .font(NuviaTypography.currency())
                    .foregroundColor(.nuviaPrimaryText)

                Text("\"Love is composed of a single soul inhabiting two bodies.\"")
                    .quoteStyle()
            }
        }
        .padding(24)
    }
    .background(Color.nuviaBackground)
}
