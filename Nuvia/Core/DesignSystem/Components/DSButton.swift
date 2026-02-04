import SwiftUI

// MARK: - Design System Button
// Primary, Secondary, and Ghost button styles with haptics

/// Primary action button with DS styling
public struct DSButton: View {
    let title: String
    let icon: String?
    let style: Style
    let size: Size
    let isLoading: Bool
    let isDisabled: Bool
    let haptic: Bool
    let action: () -> Void

    // MARK: - Styles

    public enum Style {
        case primary    // Filled with primaryAction color
        case secondary  // Outlined with border
        case ghost      // Text only
        case gold       // Gold gradient fill

        var isPill: Bool {
            switch self {
            case .primary, .gold: return false
            case .secondary, .ghost: return false
            }
        }
    }

    public enum Size {
        case small   // 44pt height
        case medium  // 52pt height
        case large   // 56pt height

        var height: CGFloat {
            switch self {
            case .small: return 44
            case .medium: return 52
            case .large: return 56
            }
        }

        var font: Font {
            switch self {
            case .small: return DSTypography.buttonSmall
            case .medium, .large: return DSTypography.button
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 18
            }
        }
    }

    // MARK: - Init

    public init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        size: Size = .large,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        haptic: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.haptic = haptic
        self.action = action
    }

    // MARK: - Body

    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false

    public var body: some View {
        Button {
            if haptic {
                DSHaptics.impact(.light)
            }
            action()
        } label: {
            HStack(spacing: DSSpacing.buttonIconSpacing) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: size.iconSize, weight: .medium))
                    }
                    Text(title)
                        .font(size.font)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.button, style: .continuous)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1.5 : 0)
            )
        }
        .buttonStyle(DSButtonPressStyle(scale: 0.97))
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1)
        .accessibilityLabel(title)
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return isDisabled
                ? DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme)
                : DSColors.Fallback.textPrimaryLight
        case .secondary, .ghost:
            return .clear
        case .gold:
            return DSColors.Fallback.gold
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return DSColors.Adaptive.textPrimary.resolve(for: colorScheme)
        case .ghost:
            return DSColors.Fallback.gold
        case .gold:
            return .white
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary:
            return DSColors.Adaptive.textPrimary.resolve(for: colorScheme).opacity(0.2)
        default:
            return .clear
        }
    }
}

// MARK: - Button Press Style

public struct DSButtonPressStyle: ButtonStyle {
    let scale: CGFloat

    public init(scale: CGFloat = 0.97) {
        self.scale = scale
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(DSTheme.Animation.snappy, value: configuration.isPressed)
    }
}

// MARK: - Pill Button Variant

public struct DSPillButton: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    public init(
        _ title: String,
        icon: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button {
            DSHaptics.selection()
            action()
        } label: {
            HStack(spacing: DSSpacing.xxs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(DSTypography.caption)
            }
            .foregroundColor(
                isSelected
                    ? .white
                    : DSColors.Adaptive.textSecondary.resolve(for: colorScheme)
            )
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.xs)
            .background(
                isSelected
                    ? DSColors.Fallback.textPrimaryLight
                    : DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(DSButtonPressStyle(scale: 0.95))
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Icon Button

public struct DSIconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    public init(
        icon: String,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button {
            DSHaptics.selection()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(DSColors.Adaptive.textSecondary.resolve(for: colorScheme))
                .frame(width: size, height: size)
                .background(DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme))
                .clipShape(Circle())
        }
        .buttonStyle(DSButtonPressStyle(scale: 0.9))
        .accessibilityLabel(icon)
    }
}

// MARK: - Text Button

public struct DSTextButton: View {
    let title: String
    let color: Color?
    let action: () -> Void

    public init(
        _ title: String,
        color: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.action = action
    }

    public var body: some View {
        Button {
            DSHaptics.selection()
            action()
        } label: {
            Text(title)
                .font(DSTypography.buttonSmall)
                .foregroundColor(color ?? DSColors.Fallback.gold)
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Preview

#Preview("DS Buttons") {
    ScrollView {
        VStack(spacing: DSSpacing.lg) {
            DSButton("Continue", icon: "arrow.right") {}

            DSButton("Get Started", style: .gold) {}

            DSButton("Secondary Action", style: .secondary) {}

            DSButton("Learn More", style: .ghost) {}

            DSButton("Loading...", isLoading: true) {}

            DSButton("Disabled", isDisabled: true) {}

            HStack(spacing: DSSpacing.sm) {
                DSPillButton("All", isSelected: true) {}
                DSPillButton("Active", isSelected: false) {}
                DSPillButton("Completed", isSelected: false) {}
            }

            HStack(spacing: DSSpacing.md) {
                DSIconButton(icon: "xmark") {}
                DSIconButton(icon: "bell") {}
                DSIconButton(icon: "gearshape") {}
            }

            DSTextButton("Skip for now") {}
        }
        .padding(DSSpacing.nuviaMargin)
    }
    .background(Color(hex: "FAFAF9"))
}
