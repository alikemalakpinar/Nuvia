import SwiftUI

// MARK: - Template Category

enum TemplateCategory: String, CaseIterable {
    case all = "Tümü"
    case minimal = "Minimal"
    case floral = "Çiçekli"
    case elegant = "Şık"
    case modern = "Modern"
    case classic = "Klasik"
    case bohemian = "Bohem"

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .minimal: return "square"
        case .floral: return "leaf.fill"
        case .elegant: return "crown.fill"
        case .modern: return "square.split.diagonal"
        case .classic: return "seal.fill"
        case .bohemian: return "sparkles"
        }
    }
}

// MARK: - Invitation Template

struct InvitationTemplate: Identifiable {
    let id = UUID()
    let name: String
    let category: TemplateCategory
    let isPremium: Bool
    let backgroundColor: HexColor
    let accentColor: HexColor
    let textColor: HexColor
    let secondaryTextColor: HexColor
    let previewGradient: [Color]
    let elements: [StudioElement]

    // Preview colors for the gallery
    var previewColors: (primary: Color, secondary: Color, accent: Color) {
        (backgroundColor.color, accentColor.color, textColor.color)
    }
}

// MARK: - Template Library

struct TemplateLibrary {

    // MARK: - All Templates

    static let allTemplates: [InvitationTemplate] = [
        // MINIMAL
        pureWhite,
        softGray,
        cleanLines,

        // FLORAL
        roseGarden,
        wildflower,
        eucalyptus,

        // ELEGANT
        goldLuxury,
        blackTie,
        champagneDreams,

        // MODERN
        geometricBlush,
        boldContrast,
        neonGlow,

        // CLASSIC
        timelessIvory,
        vintageRomance,
        royalBlue,

        // BOHEMIAN
        desertSunset,
        terracottaDream,
        oceanBreeze
    ]

    // MARK: - Minimal Templates

    static let pureWhite = InvitationTemplate(
        name: "Saf Beyaz",
        category: .minimal,
        isPremium: false,
        backgroundColor: HexColor(hex: "FFFFFF"),
        accentColor: HexColor(hex: "2C2C2C"),
        textColor: HexColor(hex: "1A1A1A"),
        secondaryTextColor: HexColor(hex: "6B6B6B"),
        previewGradient: [Color(hex: "FFFFFF"), Color(hex: "F5F5F5")],
        elements: createMinimalElements(
            bgHex: "FFFFFF",
            textHex: "1A1A1A",
            accentHex: "D4AF37"
        )
    )

    static let softGray = InvitationTemplate(
        name: "Yumuşak Gri",
        category: .minimal,
        isPremium: false,
        backgroundColor: HexColor(hex: "F7F7F5"),
        accentColor: HexColor(hex: "9E9E9E"),
        textColor: HexColor(hex: "3D3D3D"),
        secondaryTextColor: HexColor(hex: "757575"),
        previewGradient: [Color(hex: "F7F7F5"), Color(hex: "E8E8E6")],
        elements: createMinimalElements(
            bgHex: "F7F7F5",
            textHex: "3D3D3D",
            accentHex: "9E9E9E"
        )
    )

    static let cleanLines = InvitationTemplate(
        name: "Temiz Çizgiler",
        category: .minimal,
        isPremium: true,
        backgroundColor: HexColor(hex: "FAFAFA"),
        accentColor: HexColor(hex: "000000"),
        textColor: HexColor(hex: "000000"),
        secondaryTextColor: HexColor(hex: "4A4A4A"),
        previewGradient: [Color(hex: "FAFAFA"), Color(hex: "EEEEEE")],
        elements: createMinimalElements(
            bgHex: "FAFAFA",
            textHex: "000000",
            accentHex: "000000"
        )
    )

    // MARK: - Floral Templates

    static let roseGarden = InvitationTemplate(
        name: "Gül Bahçesi",
        category: .floral,
        isPremium: false,
        backgroundColor: HexColor(hex: "FFF5F5"),
        accentColor: HexColor(hex: "E8B4B4"),
        textColor: HexColor(hex: "5C3D3D"),
        secondaryTextColor: HexColor(hex: "8B6B6B"),
        previewGradient: [Color(hex: "FFF5F5"), Color(hex: "FFE4E4")],
        elements: createFloralElements(
            bgHex: "FFF5F5",
            textHex: "5C3D3D",
            accentHex: "E8B4B4"
        )
    )

    static let wildflower = InvitationTemplate(
        name: "Kır Çiçeği",
        category: .floral,
        isPremium: true,
        backgroundColor: HexColor(hex: "FFFBF0"),
        accentColor: HexColor(hex: "E6A87C"),
        textColor: HexColor(hex: "4A3728"),
        secondaryTextColor: HexColor(hex: "7D6454"),
        previewGradient: [Color(hex: "FFFBF0"), Color(hex: "FFF0DB")],
        elements: createFloralElements(
            bgHex: "FFFBF0",
            textHex: "4A3728",
            accentHex: "E6A87C"
        )
    )

    static let eucalyptus = InvitationTemplate(
        name: "Okaliptüs",
        category: .floral,
        isPremium: true,
        backgroundColor: HexColor(hex: "F5FAF7"),
        accentColor: HexColor(hex: "7BA08C"),
        textColor: HexColor(hex: "2D4A3E"),
        secondaryTextColor: HexColor(hex: "5A7A6A"),
        previewGradient: [Color(hex: "F5FAF7"), Color(hex: "E3F0E9")],
        elements: createFloralElements(
            bgHex: "F5FAF7",
            textHex: "2D4A3E",
            accentHex: "7BA08C"
        )
    )

    // MARK: - Elegant Templates

    static let goldLuxury = InvitationTemplate(
        name: "Altın Lüks",
        category: .elegant,
        isPremium: false,
        backgroundColor: HexColor(hex: "1A1A1A"),
        accentColor: HexColor(hex: "D4AF37"),
        textColor: HexColor(hex: "FFFFFF"),
        secondaryTextColor: HexColor(hex: "B8B8B8"),
        previewGradient: [Color(hex: "2A2A2A"), Color(hex: "1A1A1A")],
        elements: createElegantElements(
            bgHex: "1A1A1A",
            textHex: "FFFFFF",
            accentHex: "D4AF37"
        )
    )

    static let blackTie = InvitationTemplate(
        name: "Siyah Kravat",
        category: .elegant,
        isPremium: true,
        backgroundColor: HexColor(hex: "0D0D0D"),
        accentColor: HexColor(hex: "FFFFFF"),
        textColor: HexColor(hex: "FFFFFF"),
        secondaryTextColor: HexColor(hex: "A0A0A0"),
        previewGradient: [Color(hex: "1A1A1A"), Color(hex: "0D0D0D")],
        elements: createElegantElements(
            bgHex: "0D0D0D",
            textHex: "FFFFFF",
            accentHex: "C0C0C0"
        )
    )

    static let champagneDreams = InvitationTemplate(
        name: "Şampanya Rüyası",
        category: .elegant,
        isPremium: true,
        backgroundColor: HexColor(hex: "F9F6F0"),
        accentColor: HexColor(hex: "C9A961"),
        textColor: HexColor(hex: "3D3428"),
        secondaryTextColor: HexColor(hex: "6D6354"),
        previewGradient: [Color(hex: "F9F6F0"), Color(hex: "EDE8DD")],
        elements: createElegantElements(
            bgHex: "F9F6F0",
            textHex: "3D3428",
            accentHex: "C9A961"
        )
    )

    // MARK: - Modern Templates

    static let geometricBlush = InvitationTemplate(
        name: "Geometrik Pembe",
        category: .modern,
        isPremium: false,
        backgroundColor: HexColor(hex: "FDF2F4"),
        accentColor: HexColor(hex: "E8919A"),
        textColor: HexColor(hex: "2C2C2C"),
        secondaryTextColor: HexColor(hex: "6B6B6B"),
        previewGradient: [Color(hex: "FDF2F4"), Color(hex: "FCE4E8")],
        elements: createModernElements(
            bgHex: "FDF2F4",
            textHex: "2C2C2C",
            accentHex: "E8919A"
        )
    )

    static let boldContrast = InvitationTemplate(
        name: "Cesur Kontrast",
        category: .modern,
        isPremium: true,
        backgroundColor: HexColor(hex: "FFFFFF"),
        accentColor: HexColor(hex: "FF4444"),
        textColor: HexColor(hex: "000000"),
        secondaryTextColor: HexColor(hex: "666666"),
        previewGradient: [Color(hex: "FFFFFF"), Color(hex: "F0F0F0")],
        elements: createModernElements(
            bgHex: "FFFFFF",
            textHex: "000000",
            accentHex: "FF4444"
        )
    )

    static let neonGlow = InvitationTemplate(
        name: "Neon Parıltı",
        category: .modern,
        isPremium: true,
        backgroundColor: HexColor(hex: "0F0F1A"),
        accentColor: HexColor(hex: "00D9FF"),
        textColor: HexColor(hex: "FFFFFF"),
        secondaryTextColor: HexColor(hex: "8888AA"),
        previewGradient: [Color(hex: "1A1A2E"), Color(hex: "0F0F1A")],
        elements: createModernElements(
            bgHex: "0F0F1A",
            textHex: "FFFFFF",
            accentHex: "00D9FF"
        )
    )

    // MARK: - Classic Templates

    static let timelessIvory = InvitationTemplate(
        name: "Zamansız Fildişi",
        category: .classic,
        isPremium: false,
        backgroundColor: HexColor(hex: "FFFEF5"),
        accentColor: HexColor(hex: "8B7355"),
        textColor: HexColor(hex: "3C3022"),
        secondaryTextColor: HexColor(hex: "6B5D4D"),
        previewGradient: [Color(hex: "FFFEF5"), Color(hex: "FFF8E7")],
        elements: createClassicElements(
            bgHex: "FFFEF5",
            textHex: "3C3022",
            accentHex: "8B7355"
        )
    )

    static let vintageRomance = InvitationTemplate(
        name: "Vintage Romantik",
        category: .classic,
        isPremium: true,
        backgroundColor: HexColor(hex: "FBF7F4"),
        accentColor: HexColor(hex: "B08968"),
        textColor: HexColor(hex: "5C4033"),
        secondaryTextColor: HexColor(hex: "8B7355"),
        previewGradient: [Color(hex: "FBF7F4"), Color(hex: "F5EDE6")],
        elements: createClassicElements(
            bgHex: "FBF7F4",
            textHex: "5C4033",
            accentHex: "B08968"
        )
    )

    static let royalBlue = InvitationTemplate(
        name: "Kraliyet Mavisi",
        category: .classic,
        isPremium: true,
        backgroundColor: HexColor(hex: "0A1628"),
        accentColor: HexColor(hex: "C9A961"),
        textColor: HexColor(hex: "FFFFFF"),
        secondaryTextColor: HexColor(hex: "A0B0C0"),
        previewGradient: [Color(hex: "142850"), Color(hex: "0A1628")],
        elements: createClassicElements(
            bgHex: "0A1628",
            textHex: "FFFFFF",
            accentHex: "C9A961"
        )
    )

    // MARK: - Bohemian Templates

    static let desertSunset = InvitationTemplate(
        name: "Çöl Günbatımı",
        category: .bohemian,
        isPremium: false,
        backgroundColor: HexColor(hex: "FDF8F3"),
        accentColor: HexColor(hex: "C4704F"),
        textColor: HexColor(hex: "3D2E27"),
        secondaryTextColor: HexColor(hex: "7A6459"),
        previewGradient: [Color(hex: "FDF8F3"), Color(hex: "FBEEE3")],
        elements: createBohemianElements(
            bgHex: "FDF8F3",
            textHex: "3D2E27",
            accentHex: "C4704F"
        )
    )

    static let terracottaDream = InvitationTemplate(
        name: "Terrakota Rüyası",
        category: .bohemian,
        isPremium: true,
        backgroundColor: HexColor(hex: "F5EDE4"),
        accentColor: HexColor(hex: "C67B5C"),
        textColor: HexColor(hex: "4A3830"),
        secondaryTextColor: HexColor(hex: "7A6458"),
        previewGradient: [Color(hex: "F5EDE4"), Color(hex: "EBE0D3")],
        elements: createBohemianElements(
            bgHex: "F5EDE4",
            textHex: "4A3830",
            accentHex: "C67B5C"
        )
    )

    static let oceanBreeze = InvitationTemplate(
        name: "Okyanus Esintisi",
        category: .bohemian,
        isPremium: true,
        backgroundColor: HexColor(hex: "F0F7F9"),
        accentColor: HexColor(hex: "5B9AA0"),
        textColor: HexColor(hex: "2A4A4F"),
        secondaryTextColor: HexColor(hex: "5A7A80"),
        previewGradient: [Color(hex: "F0F7F9"), Color(hex: "E0EEF2")],
        elements: createBohemianElements(
            bgHex: "F0F7F9",
            textHex: "2A4A4F",
            accentHex: "5B9AA0"
        )
    )

    // MARK: - Element Factory Methods

    private static func createMinimalElements(bgHex: String, textHex: String, accentHex: String) -> [StudioElement] {
        [
            // Names
            .text(
                id: UUID(),
                content: "İSİM & İSİM",
                color: HexColor(hex: textHex),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 36,
                    fontWeight: .light,
                    letterSpacing: 4,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: -80), zIndex: 3)
            ),
            // Line divider
            .shape(
                id: UUID(),
                type: .line,
                fillColor: HexColor(hex: accentHex),
                strokeColor: nil,
                strokeWidth: 0,
                transform: StudioTransform(offset: CGSize(width: 0, height: 0), scale: 0.5, zIndex: 2)
            ),
            // Date
            .text(
                id: UUID(),
                content: "1 Ocak 2026",
                color: HexColor(hex: textHex, opacity: 0.7),
                style: StudioTextStyle(
                    fontFamily: "Helvetica Neue",
                    fontSize: 14,
                    fontWeight: .regular,
                    letterSpacing: 3,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: 60), zIndex: 1)
            )
        ]
    }

    private static func createFloralElements(bgHex: String, textHex: String, accentHex: String) -> [StudioElement] {
        [
            // Decorative top shape
            .shape(
                id: UUID(),
                type: .heart,
                fillColor: HexColor(hex: accentHex, opacity: 0.3),
                strokeColor: nil,
                strokeWidth: 0,
                transform: StudioTransform(offset: CGSize(width: 0, height: -180), scale: 0.5, zIndex: 0)
            ),
            // Names
            .text(
                id: UUID(),
                content: "İSİM\n&\nİSİM",
                color: HexColor(hex: textHex),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 32,
                    fontWeight: .regular,
                    letterSpacing: 2,
                    lineHeight: 1.3,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: -40), zIndex: 3)
            ),
            // Date
            .text(
                id: UUID(),
                content: "1 Ocak 2026",
                color: HexColor(hex: textHex, opacity: 0.8),
                style: StudioTextStyle(
                    fontFamily: "Helvetica Neue",
                    fontSize: 13,
                    fontWeight: .medium,
                    letterSpacing: 2,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: 80), zIndex: 2)
            ),
            // Venue
            .text(
                id: UUID(),
                content: "Mekan Adı",
                color: HexColor(hex: accentHex),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 12,
                    fontWeight: .regular,
                    letterSpacing: 1,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: 110), zIndex: 1)
            )
        ]
    }

    private static func createElegantElements(bgHex: String, textHex: String, accentHex: String) -> [StudioElement] {
        [
            // Top decorative element
            .shape(
                id: UUID(),
                type: .diamond,
                fillColor: HexColor(hex: accentHex),
                strokeColor: nil,
                strokeWidth: 0,
                transform: StudioTransform(offset: CGSize(width: 0, height: -200), scale: 0.3, zIndex: 0)
            ),
            // Names
            .text(
                id: UUID(),
                content: "İSİM\n♦\nİSİM",
                color: HexColor(hex: textHex),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 38,
                    fontWeight: .bold,
                    letterSpacing: 6,
                    lineHeight: 1.2,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: -40), zIndex: 3)
            ),
            // Date with elegant styling
            .text(
                id: UUID(),
                content: "BİR OCAK İKİ BİN YİRMİ ALTI",
                color: HexColor(hex: accentHex),
                style: StudioTextStyle(
                    fontFamily: "Helvetica Neue",
                    fontSize: 11,
                    fontWeight: .medium,
                    letterSpacing: 4,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: 100), zIndex: 2)
            ),
            // Bottom decorative
            .shape(
                id: UUID(),
                type: .diamond,
                fillColor: HexColor(hex: accentHex),
                strokeColor: nil,
                strokeWidth: 0,
                transform: StudioTransform(offset: CGSize(width: 0, height: 200), scale: 0.3, zIndex: 0)
            )
        ]
    }

    private static func createModernElements(bgHex: String, textHex: String, accentHex: String) -> [StudioElement] {
        [
            // Geometric accent shape
            .shape(
                id: UUID(),
                type: .rectangle,
                fillColor: HexColor(hex: accentHex, opacity: 0.2),
                strokeColor: nil,
                strokeWidth: 0,
                transform: StudioTransform(offset: CGSize(width: -100, height: -150), scale: 0.8, rotation: .degrees(45), zIndex: 0)
            ),
            // Names - bold modern style
            .text(
                id: UUID(),
                content: "İSİM\n+\nİSİM",
                color: HexColor(hex: textHex),
                style: StudioTextStyle(
                    fontFamily: "Helvetica Neue",
                    fontSize: 42,
                    fontWeight: .bold,
                    letterSpacing: 0,
                    lineHeight: 1.1,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: -20), zIndex: 3)
            ),
            // Date
            .text(
                id: UUID(),
                content: "01.01.2026",
                color: HexColor(hex: accentHex),
                style: StudioTextStyle(
                    fontFamily: "Helvetica Neue",
                    fontSize: 18,
                    fontWeight: .bold,
                    letterSpacing: 2,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: 100), zIndex: 2)
            )
        ]
    }

    private static func createClassicElements(bgHex: String, textHex: String, accentHex: String) -> [StudioElement] {
        [
            // Ornamental top
            .shape(
                id: UUID(),
                type: .star,
                fillColor: HexColor(hex: accentHex, opacity: 0.5),
                strokeColor: nil,
                strokeWidth: 0,
                transform: StudioTransform(offset: CGSize(width: 0, height: -200), scale: 0.4, zIndex: 0)
            ),
            // "Evleniyoruz" text
            .text(
                id: UUID(),
                content: "Evleniyoruz",
                color: HexColor(hex: accentHex),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 14,
                    fontWeight: .regular,
                    letterSpacing: 3,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: -120), zIndex: 1)
            ),
            // Names
            .text(
                id: UUID(),
                content: "İsim & İsim",
                color: HexColor(hex: textHex),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 36,
                    fontWeight: .semiBold,
                    letterSpacing: 2,
                    lineHeight: 1.3,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: -40), zIndex: 3)
            ),
            // Date
            .text(
                id: UUID(),
                content: "1 Ocak 2026 • Saat 14:00",
                color: HexColor(hex: textHex, opacity: 0.7),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 13,
                    fontWeight: .regular,
                    letterSpacing: 1,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: 60), zIndex: 2)
            ),
            // Venue
            .text(
                id: UUID(),
                content: "Mekan Adı, Şehir",
                color: HexColor(hex: textHex, opacity: 0.6),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 12,
                    fontWeight: .regular,
                    letterSpacing: 1,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: 90), zIndex: 1)
            )
        ]
    }

    private static func createBohemianElements(bgHex: String, textHex: String, accentHex: String) -> [StudioElement] {
        [
            // Sun/moon shape
            .shape(
                id: UUID(),
                type: .circle,
                fillColor: HexColor(hex: accentHex, opacity: 0.2),
                strokeColor: HexColor(hex: accentHex),
                strokeWidth: 1,
                transform: StudioTransform(offset: CGSize(width: 0, height: -180), scale: 0.6, zIndex: 0)
            ),
            // Names - handwritten style
            .text(
                id: UUID(),
                content: "İsim\n&\nİsim",
                color: HexColor(hex: textHex),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 34,
                    fontWeight: .regular,
                    letterSpacing: 1,
                    lineHeight: 1.2,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: -30), zIndex: 3)
            ),
            // "together forever"
            .text(
                id: UUID(),
                content: "sonsuza dek birlikte",
                color: HexColor(hex: accentHex),
                style: StudioTextStyle(
                    fontFamily: "Georgia",
                    fontSize: 12,
                    fontWeight: .regular,
                    letterSpacing: 2,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: 60), zIndex: 2)
            ),
            // Date
            .text(
                id: UUID(),
                content: "01 • 01 • 2026",
                color: HexColor(hex: textHex, opacity: 0.8),
                style: StudioTextStyle(
                    fontFamily: "Helvetica Neue",
                    fontSize: 14,
                    fontWeight: .medium,
                    letterSpacing: 3,
                    lineHeight: 1.4,
                    alignment: .center
                ),
                transform: StudioTransform(offset: CGSize(width: 0, height: 100), zIndex: 1)
            )
        ]
    }

    // MARK: - Filter by Category

    static func templates(for category: TemplateCategory) -> [InvitationTemplate] {
        if category == .all {
            return allTemplates
        }
        return allTemplates.filter { $0.category == category }
    }
}
