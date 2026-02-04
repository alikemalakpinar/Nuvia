import SwiftUI

// MARK: - Nuvia Ethereal Component Library
// "Editorial Excellence" - Awwwards-worthy UI components

// MARK: - Luxury Button (Fashion Brand Style)

/// Primary action button with charcoal background
/// Inspired by luxury fashion brand CTAs
struct NuviaPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    let style: ButtonStyle

    enum ButtonStyle {
        case filled      // Charcoal background
        case outlined    // Champagne border
        case ghost       // Text only
    }

    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .filled,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.shared.buttonTap()
            action()
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                    }
                    Text(title)
                        .font(NuviaTypography.button())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: style == .outlined ? 1.5 : 0)
            )
        }
        .pressEffect()
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1)
        .accessibilityLabel(title)
    }

    private var backgroundColor: Color {
        switch style {
        case .filled: return isDisabled ? .nuviaMutedSurface : .nuviaPrimaryAction
        case .outlined, .ghost: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .filled: return .nuviaInverseText
        case .outlined: return .nuviaPrimaryAction
        case .ghost: return .nuviaChampagneStatic
        }
    }

    private var borderColor: Color {
        style == .outlined ? .nuviaPrimaryAction : .clear
    }
}

// MARK: - Secondary Button

struct NuviaSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.shared.buttonTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(NuviaTypography.button())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.nuviaPrimaryText)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.nuviaPrimaryText.opacity(0.2), lineWidth: 1)
            )
        }
        .pressEffect()
        .accessibilityLabel(title)
    }
}

// MARK: - Text Button

struct NuviaTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.selection()
            action()
        } label: {
            Text(title)
                .font(NuviaTypography.smallButton())
                .foregroundColor(.nuviaChampagne)
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Editorial Card (Zero Stroke, Soft Shadow)

/// The signature card style - pure white, no borders, diffused shadow
struct EditorialCard<Content: View>: View {
    let content: Content
    let padding: CGFloat

    init(padding: CGFloat = 24, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.nuviaSurface)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .etherealShadow(.soft)
    }
}

// MARK: - Legacy Card Compatibility

struct NuviaCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        EditorialCard(padding: 20) {
            content
        }
    }
}

struct NuviaGlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        EditorialCard(padding: 24) {
            content
        }
    }
}

// MARK: - Hero Card (Featured Content)

struct HeroCard<Content: View>: View {
    let accentColor: Color
    let content: Content

    init(accent: Color = .nuviaChampagneStatic, @ViewBuilder content: () -> Content) {
        self.accentColor = accent
        self.content = content()
    }

    var body: some View {
        content
            .padding(28)
            .background(
                ZStack {
                    Color.nuviaSurface
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
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .etherealShadow(.medium, colored: accentColor)
    }
}

// Legacy support
struct NuviaHeroCard<Content: View>: View {
    let accentColor: Color
    let content: Content

    init(accent: Color = .nuviaChampagneStatic, @ViewBuilder content: () -> Content) {
        self.accentColor = accent
        self.content = content()
    }

    var body: some View {
        HeroCard(accent: accentColor) { content }
    }
}

// MARK: - Compact Card

struct NuviaCompactCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(Color.nuviaTertiaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Input Field (Minimal)

struct NuviaTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let isSecure: Bool
    let keyboardType: UIKeyboardType

    init(
        _ title: String,
        placeholder: String = "",
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(NuviaTypography.overline())
                .foregroundColor(.nuviaSecondaryText)
                .tracking(1)

            HStack(spacing: 14) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isFocused ? .nuviaChampagne : .nuviaTertiaryText)
                        .frame(width: 20)
                        .animation(.etherealSnap, value: isFocused)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(NuviaTypography.body())
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .font(NuviaTypography.body())
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                }
            }
            .padding(18)
            .background(Color.nuviaTertiaryBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isFocused ? Color.nuviaChampagne : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .animation(.etherealSnap, value: isFocused)
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Date Picker

struct NuviaDatePicker: View {
    let title: String
    @Binding var date: Date
    let displayedComponents: DatePicker.Components

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(NuviaTypography.overline())
                .foregroundColor(.nuviaSecondaryText)
                .tracking(1)

            DatePicker("", selection: $date, displayedComponents: displayedComponents)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(14)
                .background(Color.nuviaTertiaryBackground)
                .cornerRadius(14)
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Toggle

struct NuviaToggle: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    init(_ title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }
        }
        .tint(.nuviaChampagne)
        .onChange(of: isOn) { _, _ in
            HapticManager.shared.selection()
        }
    }
}

// MARK: - Progress Ring

struct NuviaProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let showPercentage: Bool
    let accentColor: Color
    @State private var animatedProgress: Double = 0

    init(
        progress: Double,
        size: CGFloat = 80,
        lineWidth: CGFloat = 6,
        showPercentage: Bool = true,
        accentColor: Color = .nuviaChampagneStatic
    ) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
        self.accentColor = accentColor
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.nuviaTertiaryBackground, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(min(animatedProgress, 1.0)))
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            if showPercentage {
                Text("\(Int(animatedProgress * 100))%")
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.etherealEntrance.delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.etherealSpring) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Countdown

struct NuviaCountdown: View {
    let daysRemaining: Int
    let weddingDate: Date

    var body: some View {
        VStack(spacing: 12) {
            Text("\(daysRemaining)")
                .font(NuviaTypography.countdown())
                .foregroundColor(.nuviaChampagne)
                .contentTransition(.numericText())

            Text("days until forever")
                .font(NuviaTypography.callout())
                .foregroundColor(.nuviaSecondaryText)
                .tracking(0.5)

            Text(weddingDate.formatted(date: .abbreviated, time: .omitted))
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaTertiaryText)
        }
        .padding(32)
        .background(Color.nuviaSurface)
        .cornerRadius(28)
        .etherealShadow(.medium, colored: .nuviaChampagne)
    }
}

// MARK: - Tag / Badge

struct NuviaTag: View {
    let text: String
    let color: Color
    let size: TagSize

    enum TagSize {
        case small, medium, large

        var font: Font {
            switch self {
            case .small: return NuviaTypography.caption2()
            case .medium: return NuviaTypography.tag()
            case .large: return NuviaTypography.caption()
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            case .large: return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            }
        }
    }

    init(_ text: String, color: Color = .nuviaChampagneStatic, size: TagSize = .medium) {
        self.text = text
        self.color = color
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(size.font)
            .foregroundColor(color)
            .padding(size.padding)
            .background(color.opacity(0.12))
            .cornerRadius(size == .large ? 12 : 8)
            .accessibilityLabel(text)
    }
}

// MARK: - Empty State

struct NuviaEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    @State private var floatOffset: CGFloat = 0

    init(
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

    var body: some View {
        VStack(spacing: 24) {
            // Floating icon with subtle glow
            ZStack {
                Circle()
                    .fill(Color.nuviaChampagne.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(.nuviaSecondaryText)
            }
            .offset(y: floatOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    floatOffset = -10
                }
            }

            VStack(spacing: 10) {
                Text(title)
                    .font(NuviaTypography.title2())
                    .foregroundColor(.nuviaPrimaryText)

                Text(message)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            if let actionTitle = actionTitle, let action = action {
                NuviaPrimaryButton(actionTitle, action: action)
                    .frame(width: 220)
            }
        }
        .padding(40)
    }
}

// MARK: - Section Header

struct NuviaSectionHeader: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(_ title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title)
                .font(NuviaTypography.title2())
                .foregroundColor(.nuviaPrimaryText)

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(NuviaTypography.smallButton())
                        .foregroundColor(.nuviaChampagne)
                }
            }
        }
    }
}

// MARK: - List Row

struct NuviaListRow<Leading: View, Trailing: View>: View {
    let leading: Leading
    let title: String
    let subtitle: String?
    let trailing: Trailing

    init(
        @ViewBuilder leading: () -> Leading,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.leading = leading()
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 16) {
            leading

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }

            Spacer()

            trailing
        }
        .padding(18)
        .background(Color.nuviaSurface)
        .cornerRadius(16)
        .etherealShadow(.whisper)
    }
}

// MARK: - Quick Action

struct NuviaQuickAction: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.selection()
            action()
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.nuviaChampagne)
                    .frame(width: 56, height: 56)
                    .background(Color.nuviaTertiaryBackground)
                    .cornerRadius(16)

                Text(title)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
                    .lineLimit(1)
            }
        }
        .pressEffect()
        .accessibilityLabel(title)
    }
}

// MARK: - Status Indicator

struct NuviaStatusIndicator: View {
    let status: TaskStatus
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            if status == .inProgress {
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

// MARK: - Filter Chip

struct NuviaFilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .nuviaChampagneStatic
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.selection()
            action()
        } label: {
            Text(title)
                .font(NuviaTypography.caption())
                .foregroundColor(isSelected ? .nuviaInverseText : .nuviaSecondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.nuviaPrimaryAction : Color.nuviaTertiaryBackground)
                .cornerRadius(20)
        }
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Skeleton Loading

struct NuviaSkeletonCard: View {
    let height: CGFloat

    init(height: CGFloat = 100) {
        self.height = height
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.nuviaTertiaryBackground)
            .frame(height: height)
            .shimmer()
    }
}

struct NuviaSkeletonRow: View {
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.nuviaTertiaryBackground)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.nuviaTertiaryBackground)
                    .frame(width: 140, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.nuviaTertiaryBackground)
                    .frame(width: 90, height: 10)
            }

            Spacer()
        }
        .padding(18)
        .shimmer()
    }
}

// MARK: - Divider

struct EtherealDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.nuviaTertiaryBackground)
            .frame(height: 1)
    }
}

// MARK: - Preview

#Preview("Ethereal Components") {
    ScrollView {
        VStack(spacing: 32) {
            NuviaPrimaryButton("Continue", icon: "arrow.right") {}

            NuviaPrimaryButton("Get Started", style: .outlined) {}

            NuviaSecondaryButton("Cancel", icon: "xmark") {}

            EditorialCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Editorial Card")
                        .font(NuviaTypography.title3())
                    Text("Pure white. Zero stroke. Diffused shadow. The signature of luxury.")
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }

            HeroCard(accent: .nuviaRoseDust) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hero Card")
                        .font(NuviaTypography.title2())
                    Text("For featured content with subtle accent glow.")
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }

            NuviaCountdown(daysRemaining: 127, weddingDate: Date().addingTimeInterval(86400 * 127))

            HStack(spacing: 12) {
                NuviaTag("Wedding", color: .nuviaChampagne)
                NuviaTag("Pending", color: .nuviaWarning)
                NuviaTag("Complete", color: .nuviaSuccess)
            }

            NuviaProgressRing(progress: 0.72, accentColor: .nuviaSage)

            NuviaEmptyState(
                icon: "heart",
                title: "Start Your Journey",
                message: "Add your first wedding task to begin planning the perfect day.",
                actionTitle: "Add Task"
            ) {}
        }
        .padding(24)
    }
    .background(Color.nuviaBackground)
}
