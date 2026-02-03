import SwiftUI

// MARK: - Design System Empty State
// Editorial empty state with floating animation

/// Empty state view with DS styling
public struct DSEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    @State private var floatOffset: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    public init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DSSpacing.lg) {
            // Floating icon with subtle glow
            iconView
                .offset(y: floatOffset)
                .onAppear {
                    guard !reduceMotion else { return }
                    withAnimation(
                        .easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                    ) {
                        floatOffset = -10
                    }
                }

            // Text content
            VStack(spacing: DSSpacing.xs) {
                Text(title)
                    .font(DSTypography.heading2)
                    .foregroundColor(DSColors.Adaptive.textPrimary.resolve(for: colorScheme))

                Text(message)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.Adaptive.textSecondary.resolve(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Optional action button
            if let actionTitle = actionTitle, let action = action {
                DSButton(actionTitle, action: action)
                    .frame(width: 220)
            }
        }
        .padding(DSSpacing.xxl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(DSColors.Fallback.gold.opacity(0.08))
                .frame(width: 120, height: 120)

            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundColor(DSColors.Adaptive.textSecondary.resolve(for: colorScheme))
        }
    }
}

// MARK: - Compact Empty State

public struct DSEmptyStateCompact: View {
    let icon: String
    let title: String
    let message: String?

    @Environment(\.colorScheme) var colorScheme

    public init(
        icon: String,
        title: String,
        message: String? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(DSColors.Adaptive.textTertiary.resolve(for: colorScheme))

            Text(title)
                .font(DSTypography.heading4)
                .foregroundColor(DSColors.Adaptive.textPrimary.resolve(for: colorScheme))

            if let message = message {
                Text(message)
                    .font(DSTypography.bodySmall)
                    .foregroundColor(DSColors.Adaptive.textSecondary.resolve(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DSSpacing.lg)
    }
}

// MARK: - Section Header

public struct DSSectionHeader: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?

    @Environment(\.colorScheme) var colorScheme

    public init(
        _ title: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title)
                .font(DSTypography.heading2)
                .foregroundColor(DSColors.Adaptive.textPrimary.resolve(for: colorScheme))

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                Button(action: {
                    DSHaptics.selection()
                    action()
                }) {
                    Text(actionTitle)
                        .font(DSTypography.buttonSmall)
                        .foregroundColor(DSColors.Fallback.gold)
                }
            }
        }
    }
}

// MARK: - Overline Label

public struct DSOverline: View {
    let text: String
    let color: Color?

    @Environment(\.colorScheme) var colorScheme

    public init(_ text: String, color: Color? = nil) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(text.uppercased())
            .font(DSTypography.overline)
            .tracking(DSTypography.Kerning.overline)
            .foregroundColor(color ?? DSColors.Fallback.gold)
    }
}

// MARK: - Divider

public struct DSDivider: View {
    @Environment(\.colorScheme) var colorScheme

    public init() {}

    public var body: some View {
        Rectangle()
            .fill(DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme))
            .frame(height: 1)
    }
}

// MARK: - Tag/Badge

public struct DSTag: View {
    let text: String
    let color: Color
    let size: Size

    public enum Size {
        case small
        case medium
        case large

        var font: Font {
            switch self {
            case .small: return DSTypography.captionSmall
            case .medium: return DSTypography.caption
            case .large: return DSTypography.caption
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            case .large: return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            }
        }

        var radius: CGFloat {
            switch self {
            case .small, .medium: return DSRadii.sm
            case .large: return DSRadii.md
            }
        }
    }

    public init(
        _ text: String,
        color: Color = DSColors.Fallback.gold,
        size: Size = .medium
    ) {
        self.text = text
        self.color = color
        self.size = size
    }

    public var body: some View {
        Text(text)
            .font(size.font)
            .foregroundColor(color)
            .padding(size.padding)
            .background(color.opacity(0.12))
            .cornerRadius(size.radius)
            .accessibilityLabel(text)
    }
}

// MARK: - Preview

#Preview("DS Empty States") {
    ScrollView {
        VStack(spacing: DSSpacing.xxl) {
            DSEmptyState(
                icon: "heart.slash",
                title: "Start Your Journey",
                message: "Add your first wedding task to begin planning the perfect day.",
                actionTitle: "Add Task"
            ) {}

            DSDivider()

            DSEmptyStateCompact(
                icon: "calendar.badge.checkmark",
                title: "All Caught Up",
                message: "No upcoming deadlines"
            )

            DSDivider()

            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSSectionHeader("Quick Access", actionTitle: "See All") {}

                DSOverline("Coming Up")

                HStack(spacing: DSSpacing.xs) {
                    DSTag("Wedding", color: DSColors.Fallback.gold)
                    DSTag("Pending", color: DSColors.Fallback.warning, size: .small)
                    DSTag("Complete", color: DSColors.Fallback.success, size: .large)
                }
            }
            .padding(.horizontal, DSSpacing.nuviaMargin)
        }
        .padding(.vertical, DSSpacing.xl)
    }
    .background(Color(hex: "FAFAF9"))
}
