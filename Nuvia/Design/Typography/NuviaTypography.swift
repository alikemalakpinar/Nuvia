import SwiftUI

/// Nuvia Tipografi Sistemi
/// 1 Serif başlık + 1 Modern sans gövde
struct NuviaTypography {

    // MARK: - Font Names

    /// Başlık fontu - Serif (Playfair Display benzeri)
    /// Sistem fontu kullanılıyor, custom font entegre edilebilir
    static let headingFontName = "Georgia"

    /// Gövde fontu - Modern sans
    static let bodyFontName = "SF Pro Text"

    // MARK: - Heading Styles

    /// Büyük başlık (Hero)
    static func heroTitle() -> Font {
        .custom(headingFontName, size: 34, relativeTo: .largeTitle)
    }

    /// Sayfa başlığı
    static func title1() -> Font {
        .custom(headingFontName, size: 28, relativeTo: .title)
    }

    /// Alt başlık
    static func title2() -> Font {
        .custom(headingFontName, size: 22, relativeTo: .title2)
    }

    /// Küçük başlık
    static func title3() -> Font {
        .custom(headingFontName, size: 20, relativeTo: .title3)
    }

    // MARK: - Body Styles

    /// Ana gövde metni
    static func body() -> Font {
        .system(size: 17, weight: .regular, design: .default)
    }

    /// Kalın gövde
    static func bodyBold() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    /// Alt yazı
    static func callout() -> Font {
        .system(size: 16, weight: .regular, design: .default)
    }

    /// Dipnot
    static func footnote() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }

    /// Küçük metin
    static func caption() -> Font {
        .system(size: 12, weight: .regular, design: .default)
    }

    /// Çok küçük metin
    static func caption2() -> Font {
        .system(size: 11, weight: .regular, design: .default)
    }

    // MARK: - Special Styles

    /// Geri sayım sayısı
    static func countdown() -> Font {
        .system(size: 56, weight: .bold, design: .rounded)
    }

    /// Büyük rakam
    static func largeNumber() -> Font {
        .system(size: 44, weight: .bold, design: .rounded)
    }

    /// Orta rakam
    static func mediumNumber() -> Font {
        .system(size: 32, weight: .semibold, design: .rounded)
    }

    /// Para birimi
    static func currency() -> Font {
        .system(size: 24, weight: .medium, design: .monospaced)
    }

    /// Etiket
    static func tag() -> Font {
        .system(size: 12, weight: .medium, design: .default)
    }

    /// Buton metni
    static func button() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    /// Küçük buton
    static func smallButton() -> Font {
        .system(size: 15, weight: .medium, design: .default)
    }
}

// MARK: - View Modifiers

struct NuviaHeadingStyle: ViewModifier {
    let level: HeadingLevel

    enum HeadingLevel {
        case hero, title1, title2, title3
    }

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(.nuviaPrimaryText)
    }

    private var font: Font {
        switch level {
        case .hero: return NuviaTypography.heroTitle()
        case .title1: return NuviaTypography.title1()
        case .title2: return NuviaTypography.title2()
        case .title3: return NuviaTypography.title3()
        }
    }
}

struct NuviaBodyStyle: ViewModifier {
    let weight: BodyWeight

    enum BodyWeight {
        case regular, bold
    }

    func body(content: Content) -> some View {
        content
            .font(weight == .bold ? NuviaTypography.bodyBold() : NuviaTypography.body())
            .foregroundColor(.nuviaPrimaryText)
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
}

// MARK: - Text Styles

extension Text {
    func nuviaStyle(_ style: NuviaTextStyle) -> Text {
        self.font(style.font)
    }
}

enum NuviaTextStyle {
    case heroTitle
    case title1
    case title2
    case title3
    case body
    case bodyBold
    case callout
    case footnote
    case caption
    case caption2
    case countdown
    case largeNumber
    case currency
    case tag
    case button

    var font: Font {
        switch self {
        case .heroTitle: return NuviaTypography.heroTitle()
        case .title1: return NuviaTypography.title1()
        case .title2: return NuviaTypography.title2()
        case .title3: return NuviaTypography.title3()
        case .body: return NuviaTypography.body()
        case .bodyBold: return NuviaTypography.bodyBold()
        case .callout: return NuviaTypography.callout()
        case .footnote: return NuviaTypography.footnote()
        case .caption: return NuviaTypography.caption()
        case .caption2: return NuviaTypography.caption2()
        case .countdown: return NuviaTypography.countdown()
        case .largeNumber: return NuviaTypography.largeNumber()
        case .currency: return NuviaTypography.currency()
        case .tag: return NuviaTypography.tag()
        case .button: return NuviaTypography.button()
        }
    }
}
