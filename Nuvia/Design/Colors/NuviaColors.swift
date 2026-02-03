import SwiftUI

/// Nuvia Renk Paleti
/// "Bridal White & Soft Luxury" - Ferah, Aydınlık ve Premium tasarım dili
extension Color {

    // MARK: - Primary Brand Colors

    /// Ana marka rengi - Antique Gold (Beyaz zeminde daha tok görünür)
    static let nuviaGold = Color("NuviaGold", bundle: nil)
    static let nuviaGoldFallback = Color(red: 0.75, green: 0.60, blue: 0.40) // Daha tok, antik altın

    /// Rose Gold accent - Düğün teması için
    static let nuviaRoseGold = Color(red: 0.72, green: 0.53, blue: 0.50) // #B8877F

    /// Bakır accent - Daha yumuşak ton
    static let nuviaCopper = Color(red: 0.65, green: 0.45, blue: 0.35) // Yumuşatılmış bakır

    /// Soft Navy - Aksanlarda kullanım için (eskiden zemin)
    static let nuviaMidnight = Color(red: 0.20, green: 0.25, blue: 0.35) // Yumuşak lacivert

    /// Warm Gray - Alt başlıklar ve ikonlar için
    static let nuviaCharcoal = Color(red: 0.35, green: 0.35, blue: 0.38) // Sıcak gri

    // MARK: - Semantic Colors (Pastel tonlara çekildi)

    /// Başarı rengi - Soft Sage Green
    static let nuviaSuccess = Color(red: 0.40, green: 0.70, blue: 0.55) // Yumuşak yeşil

    /// Uyarı rengi - Soft Amber
    static let nuviaWarning = Color(red: 0.90, green: 0.70, blue: 0.35) // Yumuşak amber

    /// Hata rengi - Soft Rose
    static let nuviaError = Color(red: 0.85, green: 0.45, blue: 0.45) // Yumuşak kırmızı

    /// Bilgi rengi - Soft Blue
    static let nuviaInfo = Color(red: 0.50, green: 0.65, blue: 0.85) // Yumuşak mavi

    // MARK: - Background Colors (FERAH & AYDINLIK)

    /// Ana arka plan - Porselen Beyazı / Warm Alabaster
    static var nuviaBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Çok yumuşak siyah
                : UIColor(red: 0.98, green: 0.98, blue: 0.97, alpha: 1.0) // #FAFAF8 Warm Alabaster
        })
    }

    /// Kart arka planı - Saf Beyaz
    static var nuviaCardBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.16, green: 0.16, blue: 0.17, alpha: 1.0)
                : UIColor.white // Saf beyaz kartlar
        })
    }

    /// Üçüncül arka plan - Çok hafif gri (input alanları için)
    static var nuviaTertiaryBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0)
                : UIColor(red: 0.96, green: 0.96, blue: 0.95, alpha: 1.0) // #F5F5F3
        })
    }

    // MARK: - Text Colors (Okunabilirlik için optimize edildi)

    /// Birincil metin - Koyu gri (siyah değil, daha yumuşak)
    static var nuviaPrimaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0) // #262629
        })
    }

    /// İkincil metin - Orta gri
    static var nuviaSecondaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.7, alpha: 1.0)
                : UIColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1.0) // #73737A
        })
    }

    /// Üçüncül metin - Açık gri
    static var nuviaTertiaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.5, alpha: 1.0)
                : UIColor(red: 0.60, green: 0.60, blue: 0.62, alpha: 1.0) // #99999E
        })
    }

    // MARK: - Category Colors (Düğün temasına uygun pastel tonlar)

    static let categoryVenue = Color(red: 0.60, green: 0.50, blue: 0.75)      // Soft Lavender
    static let categoryPhoto = Color(red: 0.45, green: 0.65, blue: 0.80)      // Dusty Blue
    static let categoryMusic = Color(red: 0.80, green: 0.50, blue: 0.60)      // Dusty Rose
    static let categoryFlowers = Color(red: 0.55, green: 0.72, blue: 0.60)    // Sage Green
    static let categoryDress = Color(red: 0.90, green: 0.75, blue: 0.78)      // Blush Pink
    static let categoryFood = Color(red: 0.85, green: 0.60, blue: 0.45)       // Terracotta
    static let categoryInvitation = Color(red: 0.70, green: 0.62, blue: 0.78) // Wisteria
    static let categoryDecor = Color(red: 0.78, green: 0.70, blue: 0.58)      // Champagne

    // MARK: - Priority Colors (Daha yumuşak tonlar)

    static let priorityLow = Color(red: 0.55, green: 0.72, blue: 0.60)    // Sage
    static let priorityMedium = Color(red: 0.90, green: 0.70, blue: 0.35) // Amber
    static let priorityHigh = Color(red: 0.85, green: 0.50, blue: 0.50)   // Coral

    // MARK: - Status Colors

    static let statusPending = Color(red: 0.55, green: 0.55, blue: 0.58)
    static let statusInProgress = Color(red: 0.50, green: 0.65, blue: 0.85)
    static let statusCompleted = Color(red: 0.40, green: 0.70, blue: 0.55)
    static let statusCancelled = Color(red: 0.60, green: 0.60, blue: 0.62)

    // MARK: - Gradient (Daha zarif, düğün temalı)

    /// Premium gradient - Rose Gold to Gold
    static var nuviaGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.80, green: 0.65, blue: 0.50), // Warm Gold
                Color(red: 0.72, green: 0.53, blue: 0.50)  // Rose Gold
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Subtle background gradient - Artık çok hafif
    static var nuviaBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.98, blue: 0.97),
                Color(red: 0.96, green: 0.95, blue: 0.94)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Soft overlay for subtle depth
    static var nuviaGlassOverlay: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.06)
                : UIColor.black.withAlphaComponent(0.02)
        })
    }

    /// Subtle border for cards
    static var nuviaGlassBorder: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.12)
                : UIColor.black.withAlphaComponent(0.06)
        })
    }
}

// MARK: - Shadow System

enum NuviaShadowLevel {
    case subtle, medium, elevated, floating

    var radius: CGFloat {
        switch self {
        case .subtle: return 8
        case .medium: return 16
        case .elevated: return 24
        case .floating: return 32
        }
    }

    var opacity: Double {
        switch self {
        case .subtle: return 0.08
        case .medium: return 0.12
        case .elevated: return 0.18
        case .floating: return 0.25
        }
    }

    var y: CGFloat {
        switch self {
        case .subtle: return 2
        case .medium: return 4
        case .elevated: return 8
        case .floating: return 12
        }
    }
}

extension View {
    func nuviaShadow(_ level: NuviaShadowLevel) -> some View {
        self.shadow(color: .black.opacity(level.opacity), radius: level.radius, y: level.y)
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.15),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: geo.size.width * phase)
                    .onAppear {
                        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                            phase = 1.6
                        }
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Card Entrance Animation

struct CardEntranceModifier: ViewModifier {
    let delay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : 30)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func cardEntrance(delay: Double = 0) -> some View {
        modifier(CardEntranceModifier(delay: delay))
    }
}

// MARK: - Interactive Press Effect

struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }
}

// MARK: - Seedable RNG for stable random positions

struct SeedableRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
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
