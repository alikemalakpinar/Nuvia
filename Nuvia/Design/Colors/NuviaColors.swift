import SwiftUI

/// Nuvia Renk Paleti
/// Premium & Luxury his için Dark Mode + Champagne Gold accent
extension Color {

    // MARK: - Primary Brand Colors

    /// Ana marka rengi - Champagne Gold
    static let nuviaGold = Color("NuviaGold", bundle: nil)
    static let nuviaGoldFallback = Color(red: 0.96, green: 0.87, blue: 0.70) // #F5DEB3

    /// Bakır accent
    static let nuviaCopper = Color(red: 0.72, green: 0.45, blue: 0.20) // #B87333

    /// Derin gece mavisi - Dark mode zemin
    static let nuviaMidnight = Color(red: 0.07, green: 0.09, blue: 0.15) // #121727

    /// Kömür grisi - Alternatif zemin
    static let nuviaCharcoal = Color(red: 0.12, green: 0.13, blue: 0.18) // #1F212E

    // MARK: - Semantic Colors

    /// Başarı rengi
    static let nuviaSuccess = Color(red: 0.20, green: 0.78, blue: 0.55) // #34C78C

    /// Uyarı rengi
    static let nuviaWarning = Color(red: 1.0, green: 0.76, blue: 0.30) // #FFC24D

    /// Hata rengi
    static let nuviaError = Color(red: 0.96, green: 0.36, blue: 0.36) // #F55C5C

    /// Bilgi rengi
    static let nuviaInfo = Color(red: 0.40, green: 0.65, blue: 0.96) // #66A6F5

    // MARK: - Background Colors

    /// Ana arka plan
    static var nuviaBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0)
                : UIColor.systemBackground
        })
    }

    /// İkincil arka plan (kartlar için)
    static var nuviaCardBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.13, blue: 0.18, alpha: 1.0)
                : UIColor.secondarySystemBackground
        })
    }

    /// Üçüncül arka plan
    static var nuviaTertiaryBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.18, blue: 0.24, alpha: 1.0)
                : UIColor.tertiarySystemBackground
        })
    }

    // MARK: - Text Colors

    /// Birincil metin
    static var nuviaPrimaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor.label
        })
    }

    /// İkincil metin
    static var nuviaSecondaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.7, alpha: 1.0)
                : UIColor.secondaryLabel
        })
    }

    /// Üçüncül metin
    static var nuviaTertiaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.5, alpha: 1.0)
                : UIColor.tertiaryLabel
        })
    }

    // MARK: - Category Colors (Düğün kategorileri için)

    static let categoryVenue = Color(red: 0.55, green: 0.40, blue: 0.75)      // Mor
    static let categoryPhoto = Color(red: 0.30, green: 0.60, blue: 0.85)      // Mavi
    static let categoryMusic = Color(red: 0.85, green: 0.40, blue: 0.55)      // Pembe
    static let categoryFlowers = Color(red: 0.45, green: 0.75, blue: 0.55)    // Yeşil
    static let categoryDress = Color(red: 0.95, green: 0.70, blue: 0.75)      // Açık pembe
    static let categoryFood = Color(red: 0.95, green: 0.55, blue: 0.35)       // Turuncu
    static let categoryInvitation = Color(red: 0.65, green: 0.55, blue: 0.80) // Lavanta
    static let categoryDecor = Color(red: 0.75, green: 0.65, blue: 0.50)      // Bej

    // MARK: - Priority Colors

    static let priorityLow = Color(red: 0.45, green: 0.75, blue: 0.55)
    static let priorityMedium = Color(red: 1.0, green: 0.76, blue: 0.30)
    static let priorityHigh = Color(red: 0.96, green: 0.36, blue: 0.36)

    // MARK: - Status Colors

    static let statusPending = Color(red: 0.60, green: 0.60, blue: 0.65)
    static let statusInProgress = Color(red: 0.40, green: 0.65, blue: 0.96)
    static let statusCompleted = Color(red: 0.20, green: 0.78, blue: 0.55)
    static let statusCancelled = Color(red: 0.50, green: 0.50, blue: 0.55)

    // MARK: - Gradient

    /// Premium gradient
    static var nuviaGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.87, blue: 0.70),
                Color(red: 0.72, green: 0.45, blue: 0.20)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Subtle background gradient
    static var nuviaBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.09, blue: 0.15),
                Color(red: 0.10, green: 0.12, blue: 0.20)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Color Extensions

extension Color {
    /// Hex'ten renk oluştur
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
