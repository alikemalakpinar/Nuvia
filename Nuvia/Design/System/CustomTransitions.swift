import SwiftUI

// MARK: - Custom Transition Handler
// Award-winning navigation transitions using matchedGeometryEffect

// MARK: - Transition Namespace
struct TransitionNamespace {
    static let shared = Namespace().wrappedValue
}

// MARK: - Hero Transition Modifier
struct HeroTransitionModifier: ViewModifier {
    let id: String
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(id: id, in: namespace)
    }
}

extension View {
    func heroTransition(id: String, namespace: Namespace.ID) -> some View {
        self.modifier(HeroTransitionModifier(id: id, namespace: namespace))
    }
}

// MARK: - Slide Transition
struct SlideTransition: ViewModifier {
    let edge: Edge
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .offset(x: offsetX, y: offsetY)
            .opacity(isActive ? 1 : 0)
    }

    private var offsetX: CGFloat {
        guard !isActive else { return 0 }
        switch edge {
        case .leading: return -UIScreen.main.bounds.width
        case .trailing: return UIScreen.main.bounds.width
        default: return 0
        }
    }

    private var offsetY: CGFloat {
        guard !isActive else { return 0 }
        switch edge {
        case .top: return -UIScreen.main.bounds.height
        case .bottom: return UIScreen.main.bounds.height
        default: return 0
        }
    }
}

// MARK: - Scale Fade Transition
struct ScaleFadeTransition: ViewModifier {
    let isActive: Bool
    let scale: CGFloat

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1 : scale)
            .opacity(isActive ? 1 : 0)
    }
}

// MARK: - Morph Transition Container
struct MorphTransitionContainer<Content: View>: View {
    @Namespace private var namespace
    let content: (Namespace.ID) -> Content

    init(@ViewBuilder content: @escaping (Namespace.ID) -> Content) {
        self.content = content
    }

    var body: some View {
        content(namespace)
    }
}

// MARK: - Interactive Dismissal
struct InteractiveDismissModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    let threshold: CGFloat = 100

    func body(content: Content) -> some View {
        content
            .offset(y: max(0, dragOffset.height))
            .scaleEffect(scale)
            .opacity(opacity)
            .gesture(dismissGesture)
            .animation(DesignTokens.Animation.snappy, value: dragOffset)
    }

    private var scale: CGFloat {
        let progress = min(1, max(0, dragOffset.height / 400))
        return 1 - (progress * 0.1)
    }

    private var opacity: Double {
        let progress = min(1, max(0, dragOffset.height / 300))
        return 1 - (progress * 0.3)
    }

    private var dismissGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation
                    isDragging = true
                }
            }
            .onEnded { value in
                isDragging = false
                if value.translation.height > threshold {
                    HapticEngine.shared.impact(.medium)
                    withAnimation(DesignTokens.Animation.smooth) {
                        isPresented = false
                    }
                } else {
                    withAnimation(DesignTokens.Animation.bouncy) {
                        dragOffset = .zero
                    }
                }
            }
    }
}

extension View {
    func interactiveDismiss(isPresented: Binding<Bool>) -> some View {
        self.modifier(InteractiveDismissModifier(isPresented: isPresented))
    }
}

// MARK: - Card Expansion Transition
struct CardExpansionTransition: ViewModifier {
    let isExpanded: Bool
    let sourceFrame: CGRect

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .frame(
                    width: isExpanded ? geometry.size.width : sourceFrame.width,
                    height: isExpanded ? geometry.size.height : sourceFrame.height
                )
                .position(
                    x: isExpanded ? geometry.size.width / 2 : sourceFrame.midX,
                    y: isExpanded ? geometry.size.height / 2 : sourceFrame.midY
                )
                .clipShape(RoundedRectangle(
                    cornerRadius: isExpanded ? 0 : DesignTokens.Radius.lg,
                    style: .continuous
                ))
        }
    }
}

// MARK: - Staggered Animation Container
struct StaggeredAnimation<Content: View>: View {
    let count: Int
    let delay: Double
    let animation: Animation
    @ViewBuilder let content: (Int) -> Content

    @State private var appeared = false

    var body: some View {
        ForEach(0..<count, id: \.self) { index in
            content(index)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(
                    animation.delay(Double(index) * delay),
                    value: appeared
                )
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Parallax Effect
struct ParallaxEffect: GeometryEffect {
    var offset: CGFloat
    var multiplier: CGFloat

    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = offset * multiplier
        return ProjectionTransform(CGAffineTransform(translationX: 0, y: translation))
    }
}

extension View {
    func parallax(offset: CGFloat, multiplier: CGFloat = 0.5) -> some View {
        self.modifier(ParallaxEffect(offset: offset, multiplier: multiplier))
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.4),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = UIScreen.main.bounds.width
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}

// MARK: - Entrance Animations
enum EntranceAnimation {
    case fadeIn
    case slideUp
    case slideDown
    case slideLeft
    case slideRight
    case scale
    case bounce

    var offset: CGSize {
        switch self {
        case .slideUp: return CGSize(width: 0, height: 30)
        case .slideDown: return CGSize(width: 0, height: -30)
        case .slideLeft: return CGSize(width: 30, height: 0)
        case .slideRight: return CGSize(width: -30, height: 0)
        default: return .zero
        }
    }

    var initialScale: CGFloat {
        switch self {
        case .scale, .bounce: return 0.8
        default: return 1
        }
    }

    var animation: Animation {
        switch self {
        case .bounce: return DesignTokens.Animation.bouncy
        default: return DesignTokens.Animation.smooth
        }
    }
}

struct EntranceModifier: ViewModifier {
    let animation: EntranceAnimation
    let delay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(appeared ? .zero : animation.offset)
            .scaleEffect(appeared ? 1 : animation.initialScale)
            .animation(animation.animation.delay(delay), value: appeared)
            .onAppear {
                appeared = true
            }
    }
}

extension View {
    func entrance(_ animation: EntranceAnimation = .fadeIn, delay: Double = 0) -> some View {
        self.modifier(EntranceModifier(animation: animation, delay: delay))
    }
}

// MARK: - Blur Transition
struct BlurTransition: ViewModifier {
    let isActive: Bool
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .blur(radius: isActive ? 0 : radius)
            .opacity(isActive ? 1 : 0)
    }
}

extension View {
    func blurTransition(isActive: Bool, radius: CGFloat = 10) -> some View {
        self.modifier(BlurTransition(isActive: isActive, radius: radius))
    }
}

// MARK: - Rotation Transition
struct RotationTransition: ViewModifier {
    let isActive: Bool
    let angle: Angle
    let anchor: UnitPoint

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                isActive ? .zero : angle,
                axis: (x: 1, y: 0, z: 0),
                anchor: anchor,
                perspective: 0.3
            )
            .opacity(isActive ? 1 : 0)
    }
}

extension View {
    func rotationTransition(isActive: Bool, angle: Angle = .degrees(-90), anchor: UnitPoint = .top) -> some View {
        self.modifier(RotationTransition(isActive: isActive, angle: angle, anchor: anchor))
    }
}
