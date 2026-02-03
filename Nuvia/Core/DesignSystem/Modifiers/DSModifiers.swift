import SwiftUI

// MARK: - Design System View Modifiers
// Common modifiers for consistent styling

// MARK: - Card Entrance Animation

public struct DSCardEntranceModifier: ViewModifier {
    let delay: Double
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    public func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 40))
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : (reduceMotion ? 1 : 0.95))
            .onAppear {
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(DSTheme.Animation.page.delay(delay)) {
                        appeared = true
                    }
                }
            }
    }
}

extension View {
    /// Card entrance animation with optional delay
    public func dsCardEntrance(delay: Double = 0) -> some View {
        modifier(DSCardEntranceModifier(delay: delay))
    }
}

// MARK: - Press Effect Modifier

public struct DSPressEffectModifier: ViewModifier {
    let scale: CGFloat
    @State private var isPressed = false

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(DSTheme.Animation.snappy, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            DSHaptics.impact(.light)
                        }
                    }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    /// Interactive press feedback with scale effect
    public func dsPressable(scale: CGFloat = 0.97) -> some View {
        modifier(DSPressEffectModifier(scale: scale))
    }
}

// MARK: - Shimmer Loading Effect

public struct DSShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    public func body(content: Content) -> some View {
        if reduceMotion {
            content.opacity(0.6)
        } else {
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
}

extension View {
    /// Shimmer loading effect
    public func dsShimmer() -> some View {
        modifier(DSShimmerModifier())
    }
}

// MARK: - Interactive Dismissal

public struct DSInteractiveDismissModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGSize = .zero
    let threshold: CGFloat

    public func body(content: Content) -> some View {
        content
            .offset(y: max(0, dragOffset.height))
            .scaleEffect(scale)
            .opacity(opacity)
            .gesture(dismissGesture)
            .animation(DSTheme.Animation.snappy, value: dragOffset)
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
                }
            }
            .onEnded { value in
                if value.translation.height > threshold {
                    DSHaptics.impact(.medium)
                    withAnimation(DSTheme.Animation.smooth) {
                        isPresented = false
                    }
                } else {
                    withAnimation(DSTheme.Animation.bouncy) {
                        dragOffset = .zero
                    }
                }
            }
    }
}

extension View {
    /// Interactive pull-to-dismiss gesture
    public func dsInteractiveDismiss(isPresented: Binding<Bool>, threshold: CGFloat = 100) -> some View {
        modifier(DSInteractiveDismissModifier(isPresented: isPresented, threshold: threshold))
    }
}

// MARK: - Parallax Effect

public struct DSParallaxModifier: ViewModifier {
    let offset: CGFloat
    let multiplier: CGFloat

    public func body(content: Content) -> some View {
        content
            .offset(y: offset * multiplier)
    }
}

extension View {
    /// Parallax scrolling effect
    public func dsParallax(offset: CGFloat, multiplier: CGFloat = 0.5) -> some View {
        modifier(DSParallaxModifier(offset: offset, multiplier: multiplier))
    }
}

// MARK: - Blur Transition

public struct DSBlurTransitionModifier: ViewModifier {
    let isActive: Bool
    let radius: CGFloat
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    public func body(content: Content) -> some View {
        content
            .blur(radius: (isActive || reduceMotion) ? 0 : radius)
            .opacity(isActive ? 1 : 0)
    }
}

extension View {
    /// Blur-in transition effect
    public func dsBlurTransition(isActive: Bool, radius: CGFloat = 10) -> some View {
        modifier(DSBlurTransitionModifier(isActive: isActive, radius: radius))
    }
}

// MARK: - Skeleton Loading View

public struct DSSkeletonCard: View {
    let height: CGFloat

    @Environment(\.colorScheme) var colorScheme

    public init(height: CGFloat = 100) {
        self.height = height
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: DSRadii.card, style: .continuous)
            .fill(DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme))
            .frame(height: height)
            .dsShimmer()
    }
}

public struct DSSkeletonRow: View {
    @Environment(\.colorScheme) var colorScheme

    public init() {}

    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            RoundedRectangle(cornerRadius: DSRadii.md)
                .fill(DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                RoundedRectangle(cornerRadius: DSRadii.xs)
                    .fill(DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme))
                    .frame(width: 140, height: 14)

                RoundedRectangle(cornerRadius: DSRadii.xs)
                    .fill(DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme))
                    .frame(width: 90, height: 10)
            }

            Spacer()
        }
        .padding(DSSpacing.md)
        .dsShimmer()
    }
}

// MARK: - Status Indicator

public struct DSStatusIndicator: View {
    let status: Status
    @State private var isGlowing = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    public enum Status {
        case pending
        case inProgress
        case completed
        case cancelled

        var color: Color {
            switch self {
            case .pending: return DSColors.Fallback.textSecondaryLight
            case .inProgress: return DSColors.Fallback.info
            case .completed: return DSColors.Fallback.success
            case .cancelled: return Color(hex: "B5B5B5")
            }
        }

        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            }
        }
    }

    public init(status: Status) {
        self.status = status
    }

    public var body: some View {
        ZStack {
            if status == .inProgress && !reduceMotion {
                Circle()
                    .fill(status.color.opacity(0.3))
                    .frame(width: 14, height: 14)
                    .scaleEffect(isGlowing ? 1.4 : 1.0)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            isGlowing = true
                        }
                    }
            }
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
        }
        .accessibilityLabel(status.displayName)
    }
}

// MARK: - Preview

#Preview("DS Modifiers") {
    ScrollView {
        VStack(spacing: DSSpacing.xl) {
            Text("Card Entrance")
                .font(DSTypography.heading3)
                .dsCardEntrance(delay: 0.1)

            DSCard {
                Text("Press me!")
                    .font(DSTypography.body)
            }
            .dsPressable()

            DSSkeletonCard(height: 80)

            DSSkeletonRow()

            HStack(spacing: DSSpacing.lg) {
                DSStatusIndicator(status: .pending)
                DSStatusIndicator(status: .inProgress)
                DSStatusIndicator(status: .completed)
                DSStatusIndicator(status: .cancelled)
            }
        }
        .padding(DSSpacing.nuviaMargin)
    }
    .background(Color(hex: "FAFAF9"))
}
