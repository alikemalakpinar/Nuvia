import SwiftUI

// MARK: - Design System Card
// Editorial card styles: Standard, Glass, Hero

/// Standard card with DS styling
public struct DSCard<Content: View>: View {
    let style: Style
    let padding: CGFloat
    let content: Content

    @Environment(\.colorScheme) var colorScheme

    public enum Style {
        case standard   // Pure white, soft shadow
        case glass      // UltraThinMaterial + border
        case hero       // Accent glow, elevated
        case compact    // Smaller padding, tertiary bg
    }

    public init(
        style: Style = .standard,
        padding: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding ?? (style == .hero ? DSSpacing.heroCardPadding : DSSpacing.cardPadding)
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(overlayView)
            .dsShadow(shadowLevel)
    }

    // MARK: - Style Properties

    private var cornerRadius: CGFloat {
        switch style {
        case .standard, .compact: return DSRadii.card
        case .glass: return DSRadii.xl
        case .hero: return DSRadii.cardHero
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .standard:
            DSColors.Adaptive.surface.resolve(for: colorScheme)
        case .glass:
            Color.clear.background(.ultraThinMaterial)
        case .hero:
            DSColors.Adaptive.surface.resolve(for: colorScheme)
        case .compact:
            DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme)
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch style {
        case .glass:
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        default:
            EmptyView()
        }
    }

    private var shadowLevel: DSShadow {
        switch style {
        case .standard: return .soft
        case .glass: return .whisper
        case .hero: return .medium
        case .compact: return .none
        }
    }
}

// MARK: - Hero Card with Accent

public struct DSHeroCard<Content: View>: View {
    let accentColor: Color
    let content: Content

    @Environment(\.colorScheme) var colorScheme

    public init(
        accent: Color = DSColors.Fallback.gold,
        @ViewBuilder content: () -> Content
    ) {
        self.accentColor = accent
        self.content = content()
    }

    public var body: some View {
        content
            .padding(DSSpacing.heroCardPadding)
            .background(
                ZStack {
                    DSColors.Adaptive.surface.resolve(for: colorScheme)
                    // Subtle accent gradient at top
                    VStack {
                        LinearGradient(
                            colors: [accentColor.opacity(0.06), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                        Spacer()
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.cardHero, style: .continuous))
            .dsShadow(.medium, colored: accentColor)
    }
}

// MARK: - Glass Card

public struct DSGlassCard<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(DSSpacing.cardPadding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.xl, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .dsShadow(.whisper)
    }
}

// MARK: - Interactive Card

public struct DSInteractiveCard<Content: View>: View {
    let content: Content
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme

    public init(
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button {
            DSHaptics.selection()
            action()
        } label: {
            content
                .padding(DSSpacing.cardPadding)
                .background(DSColors.Adaptive.surface.resolve(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: DSRadii.card, style: .continuous))
                .dsShadow(.soft)
        }
        .buttonStyle(DSButtonPressStyle(scale: 0.98))
    }
}

// MARK: - Metric Card

public struct DSMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    let color: Color

    @Environment(\.colorScheme) var colorScheme

    public init(
        icon: String,
        title: String,
        value: String,
        subtitle: String? = nil,
        color: Color = DSColors.Fallback.gold
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Text(title)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.Adaptive.textSecondary.resolve(for: colorScheme))
            }

            Text(value)
                .font(DSTypography.heading2)
                .foregroundColor(DSColors.Adaptive.textPrimary.resolve(for: colorScheme))

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.Adaptive.textTertiary.resolve(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Adaptive.surface.resolve(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.card, style: .continuous))
        .dsShadow(.whisper)
    }
}

// MARK: - Progress Card

public struct DSProgressCard: View {
    let title: String
    let value: String
    let progress: Double
    let color: Color

    @Environment(\.colorScheme) var colorScheme

    public init(
        title: String,
        value: String,
        progress: Double,
        color: Color = DSColors.Fallback.sage
    ) {
        self.title = title
        self.value = value
        self.progress = progress
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.Adaptive.textSecondary.resolve(for: colorScheme))

            Text(value)
                .font(DSTypography.heading3)
                .foregroundColor(DSColors.Adaptive.textPrimary.resolve(for: colorScheme))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DSRadii.progressBar)
                        .fill(DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: DSRadii.progressBar)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(min(progress, 1.0)), height: 6)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.cardPadding)
        .background(DSColors.Adaptive.surface.resolve(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.card, style: .continuous))
        .dsShadow(.whisper)
    }
}

// MARK: - Preview

#Preview("DS Cards") {
    ScrollView {
        VStack(spacing: DSSpacing.lg) {
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Standard Card")
                        .font(DSTypography.heading3)
                    Text("Pure white background with soft ethereal shadow.")
                        .font(DSTypography.body)
                        .foregroundColor(.secondary)
                }
            }

            DSCard(style: .glass) {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Glass Card")
                        .font(DSTypography.heading3)
                    Text("UltraThinMaterial with subtle border.")
                        .font(DSTypography.body)
                        .foregroundColor(.secondary)
                }
            }

            DSHeroCard(accent: .pink.opacity(0.8)) {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Hero Card")
                        .font(DSTypography.heading2)
                    Text("Elevated with accent glow effect.")
                        .font(DSTypography.body)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: DSSpacing.md) {
                DSMetricCard(
                    icon: "person.2.fill",
                    title: "Attending",
                    value: "127",
                    subtitle: "15 pending",
                    color: DSColors.Fallback.sage
                )

                DSProgressCard(
                    title: "Tasks",
                    value: "24/32",
                    progress: 0.75,
                    color: DSColors.Fallback.gold
                )
            }
        }
        .padding(DSSpacing.nuviaMargin)
    }
    .background(Color(hex: "FAFAF9"))
}
