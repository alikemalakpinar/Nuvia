import SwiftUI

// MARK: - Nuvia Ethereal Color System
// "Ethereal Luxury" - High-Fashion, Editorial, Awwwards-Worthy

/// The Nuvia Ethereal Color Palette
/// Inspired by: Vogue Weddings, Apple Design Awards, Luxury Fashion Brands
extension Color {

    // MARK: - Foundation (Ethereal Whites)

    /// Primary background - Off-White / Warm Alabaster
    /// The canvas of elegance
    static let nuviaBackground = Color(hex: "FAFAF9")

    /// Pure surface - Absolute white for cards
    static let nuviaSurface = Color.white

    /// Elevated surface - Subtle warmth
    static let nuviaElevatedSurface = Color(hex: "FCFCFB")

    /// Tertiary surface - Soft cream for inputs
    static let nuviaTertiaryBackground = Color(hex: "F5F4F2")

    /// Muted surface - For disabled/secondary areas
    static let nuviaMutedSurface = Color(hex: "EDECE9")

    // MARK: - Brand Accents (The Signature)

    /// Champagne - Primary brand accent (replaces yellow gold)
    static let nuviaChampagne = Color(hex: "D4AF37").opacity(0.85)

    /// Rose Dust - Romantic accent
    static let nuviaRoseDust = Color(hex: "C9A9A6")

    /// Sage Green - Nature-inspired calm
    static let nuviaSage = Color(hex: "9CAF88")

    /// Blush - Soft feminine touch
    static let nuviaBlush = Color(hex: "E8D5D5")

    /// Wisteria - Dreamy purple
    static let nuviaWisteria = Color(hex: "B5A3C4")

    /// Dusty Blue - Something borrowed
    static let nuviaDustyBlue = Color(hex: "A3B5C4")

    /// Terracotta - Warm earth
    static let nuviaTerracotta = Color(hex: "C4A389")

    // MARK: - Text Colors (The Voice)

    /// Primary text - Rich Charcoal (not pure black)
    static let nuviaPrimaryText = Color(hex: "2C2C2C")

    /// Secondary text - Warm Gray
    static let nuviaSecondaryText = Color(hex: "6B6B6B")

    /// Tertiary text - Muted
    static let nuviaTertiaryText = Color(hex: "9A9A9A")

    /// Inverse text - For dark backgrounds
    static let nuviaInverseText = Color.white

    // MARK: - Action Colors (Fashion-Forward)

    /// Primary action - Charcoal (luxury fashion button style)
    static let nuviaPrimaryAction = Color(hex: "2C2C2C")

    /// Secondary action - Champagne stroke/fill
    static let nuviaSecondaryAction = Color(hex: "D4AF37")

    /// Destructive action - Soft Rose
    static let nuviaDestructiveAction = Color(hex: "C97A7A")

    // MARK: - Semantic Colors (Soft & Sophisticated)

    /// Success - Muted Sage
    static let nuviaSuccess = Color(hex: "8BAA7C")

    /// Warning - Warm Honey
    static let nuviaWarning = Color(hex: "D4A574")

    /// Error - Dusty Rose
    static let nuviaError = Color(hex: "C48B8B")

    /// Info - Soft Blue
    static let nuviaInfo = Color(hex: "8BA7C4")

    // MARK: - Category Colors (Wedding Palette)

    static let categoryVenue = Color(hex: "B5A3C4")      // Wisteria
    static let categoryPhoto = Color(hex: "A3B5C4")      // Dusty Blue
    static let categoryMusic = Color(hex: "C9A9A6")      // Rose Dust
    static let categoryFlowers = Color(hex: "9CAF88")    // Sage
    static let categoryDress = Color(hex: "E8D5D5")      // Blush
    static let categoryFood = Color(hex: "C4A389")       // Terracotta
    static let categoryInvitation = Color(hex: "D4AF37") // Champagne
    static let categoryDecor = Color(hex: "CFC5B8")      // Taupe

    // MARK: - Priority Colors

    static let priorityLow = Color(hex: "9CAF88")
    static let priorityMedium = Color(hex: "D4A574")
    static let priorityHigh = Color(hex: "C48B8B")
    static let priorityUrgent = Color(hex: "A86B6B")

    // MARK: - Status Colors

    static let statusPending = Color(hex: "9A9A9A")
    static let statusInProgress = Color(hex: "A3B5C4")
    static let statusCompleted = Color(hex: "8BAA7C")
    static let statusCancelled = Color(hex: "B5B5B5")

    // MARK: - Legacy Compatibility

    static var nuviaCardBackground: Color { nuviaSurface }
    static var nuviaGoldFallback: Color { nuviaChampagne }
    static var nuviaMidnight: Color { nuviaPrimaryText }
    static var nuviaCharcoal: Color { nuviaSecondaryText }
    static var nuviaCopper: Color { nuviaTerracotta }
    static var nuviaRoseGold: Color { nuviaRoseDust }
    static var nuviaGold: Color { nuviaChampagne }
    static var nuviaGlassOverlay: Color { Color.black.opacity(0.02) }
    static var nuviaGlassBorder: Color { Color.black.opacity(0.04) }

    // MARK: - Gradients (Ethereal)

    /// Hero gradient - Champagne to Rose
    static var etherealGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "D4AF37").opacity(0.9),
                Color(hex: "C9A9A6")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Subtle background gradient
    static var nuviaBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "FAFAF9"),
                Color(hex: "F5F4F2")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Premium mesh gradient for hero sections
    static var premiumMeshGradient: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(hex: "FDFCFB"),
                Color(hex: "F9F7F4"),
                Color(hex: "FBF9F7")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Legacy gradient compatibility
    static var nuviaGradient: LinearGradient { etherealGradient }
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

// MARK: - Ethereal Shadow System

/// Shadow tokens for depth and elevation
enum EtherealShadow {
    case none
    case whisper    // Barely visible, subtle lift
    case soft       // Default card shadow
    case medium     // Elevated cards
    case pronounced // Hero sections, floating elements
    case dramatic   // Modals, sheets

    var color: Color {
        Color.black
    }

    var opacity: Double {
        switch self {
        case .none: return 0
        case .whisper: return 0.02
        case .soft: return 0.04
        case .medium: return 0.06
        case .pronounced: return 0.08
        case .dramatic: return 0.12
        }
    }

    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .whisper: return 8
        case .soft: return 16
        case .medium: return 24
        case .pronounced: return 32
        case .dramatic: return 48
        }
    }

    var y: CGFloat {
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
    /// Apply ethereal shadow with optional secondary shadow for depth
    func etherealShadow(_ level: EtherealShadow, colored: Color? = nil) -> some View {
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

    /// Legacy shadow support
    func nuviaShadow(_ level: NuviaShadowLevel) -> some View {
        self.shadow(color: .black.opacity(level.opacity), radius: level.radius, y: level.y)
    }
}

// MARK: - Legacy Shadow Compatibility

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
        case .subtle: return 0.04
        case .medium: return 0.06
        case .elevated: return 0.08
        case .floating: return 0.10
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

// MARK: - Animation & Motion

/// Ethereal spring animation presets
extension Animation {
    /// Gentle, luxurious spring
    static var etherealSpring: Animation {
        .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1)
    }

    /// Quick, responsive spring
    static var etherealSnap: Animation {
        .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }

    /// Slow, dramatic entrance
    static var etherealEntrance: Animation {
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
    func cardEntrance(delay: Double = 0) -> some View {
        modifier(CardEntranceModifier(delay: delay))
    }
}

// MARK: - Press Effect

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

extension View {
    func pressEffect() -> some View {
        modifier(PressEffectModifier())
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
                            Color.white.opacity(0.2),
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

// MARK: - Parallax Header Effect

struct ParallaxHeaderModifier: ViewModifier {
    let minHeight: CGFloat
    let maxHeight: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let offset = geometry.frame(in: .global).minY
            let height = max(minHeight, maxHeight + offset)

            content
                .frame(width: geometry.size.width, height: height)
                .offset(y: offset > 0 ? -offset : 0)
        }
        .frame(height: maxHeight)
    }
}

extension View {
    func parallaxHeader(minHeight: CGFloat = 200, maxHeight: CGFloat = 350) -> some View {
        modifier(ParallaxHeaderModifier(minHeight: minHeight, maxHeight: maxHeight))
    }
}

// MARK: - Matched Geometry Namespace

/// Global namespace for matched geometry effects
enum NuviaNamespace {
    static let hero = "heroTransition"
    static let card = "cardTransition"
    static let detail = "detailTransition"
}

// MARK: - Seeded RNG

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
