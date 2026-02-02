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

    /// Glass overlay for glassmorphism
    static var nuviaGlassOverlay: Color {
        Color.white.opacity(0.06)
    }

    /// Glass border for glassmorphism
    static var nuviaGlassBorder: Color {
        Color.white.opacity(0.12)
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
