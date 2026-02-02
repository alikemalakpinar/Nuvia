import SwiftUI

// MARK: - Primary Button (Premium)

struct NuviaPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool

    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.shared.buttonTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .nuviaMidnight))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(NuviaTypography.button())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                isDisabled
                    ? AnyShapeStyle(Color.nuviaTertiaryText)
                    : AnyShapeStyle(Color.nuviaGradient)
            )
            .foregroundColor(.nuviaMidnight)
            .cornerRadius(16)
            .nuviaShadow(.medium)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .disabled(isDisabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Yükleniyor" : "")
    }
}

// MARK: - Secondary Button (Premium)

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
            .frame(height: 54)
            .background(Color.nuviaGlassOverlay)
            .foregroundColor(.nuviaGoldFallback)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.nuviaGoldFallback.opacity(0.4), lineWidth: 1)
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
                .foregroundColor(.nuviaGoldFallback)
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Card (Glassmorphism)

struct NuviaCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.nuviaCardBackground.opacity(0.7))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .nuviaShadow(.subtle)
    }
}

// MARK: - Glass Card (Full Glassmorphism)

struct NuviaGlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.thinMaterial)
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.nuviaCardBackground.opacity(0.4))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .nuviaShadow(.elevated)
    }
}

// MARK: - Hero Card (Featured/Elevated)

struct NuviaHeroCard<Content: View>: View {
    let accentColor: Color
    let content: Content

    init(accent: Color = .nuviaGoldFallback, @ViewBuilder content: () -> Content) {
        self.accentColor = accent
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.thinMaterial)
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.nuviaCardBackground.opacity(0.6))
                    // Subtle accent glow at top
                    VStack {
                        LinearGradient(
                            colors: [accentColor.opacity(0.08), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 60)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [accentColor.opacity(0.3), Color.white.opacity(0.08), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .nuviaShadow(.elevated)
    }
}

// MARK: - Compact Card (Inline/Minimal)

struct NuviaCompactCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .background(Color.nuviaTertiaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
            )
    }
}

// MARK: - Input Field

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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaSecondaryText)

            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isFocused ? .nuviaGoldFallback : .nuviaSecondaryText)
                        .frame(width: 20)
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
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
            .padding(16)
            .background(Color.nuviaTertiaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.nuviaGoldFallback.opacity(0.6) : Color.nuviaSecondaryText.opacity(0.2), lineWidth: isFocused ? 1.5 : 1)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Date Picker Field

struct NuviaDatePicker: View {
    let title: String
    @Binding var date: Date
    let displayedComponents: DatePicker.Components

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaSecondaryText)

            DatePicker("", selection: $date, displayedComponents: displayedComponents)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(12)
                .background(Color.nuviaTertiaryBackground)
                .cornerRadius(12)
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
        .tint(.nuviaGoldFallback)
        .onChange(of: isOn) { _, _ in
            HapticManager.shared.selection()
        }
    }
}

// MARK: - Progress Ring (Animated)

struct NuviaProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let showPercentage: Bool
    @State private var animatedProgress: Double = 0

    init(progress: Double, size: CGFloat = 80, lineWidth: CGFloat = 8, showPercentage: Bool = true) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.nuviaTertiaryBackground, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: CGFloat(min(animatedProgress, 1.0)))
                .stroke(
                    Color.nuviaGradient,
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
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Countdown Display

struct NuviaCountdown: View {
    let daysRemaining: Int
    let weddingDate: Date

    var body: some View {
        VStack(spacing: 8) {
            Text("\(daysRemaining)")
                .font(NuviaTypography.countdown())
                .foregroundColor(.nuviaGoldFallback)

            Text("gün kaldı")
                .font(NuviaTypography.callout())
                .foregroundColor(.nuviaSecondaryText)

            Text(weddingDate.formatted(date: .abbreviated, time: .omitted))
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaTertiaryText)
        }
        .padding(24)
        .background(
            ZStack {
                Color.nuviaCardBackground
                Color.nuviaGlassOverlay
            }
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.nuviaGlassBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Tag / Badge

struct NuviaTag: View {
    let text: String
    let color: Color
    let size: TagSize

    enum TagSize {
        case small, medium

        var font: Font {
            switch self {
            case .small: return NuviaTypography.caption2()
            case .medium: return NuviaTypography.tag()
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }

    init(_ text: String, color: Color = .nuviaGoldFallback, size: TagSize = .medium) {
        self.text = text
        self.color = color
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(size.font)
            .foregroundColor(color)
            .padding(size.padding)
            .background(color.opacity(0.15))
            .cornerRadius(8)
            .accessibilityLabel(text)
    }
}

// MARK: - Empty State (Enhanced with pulse animation)

struct NuviaEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    @State private var floatOffset: CGFloat = 0
    @State private var glowPulse = false

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
        VStack(spacing: 20) {
            ZStack {
                // Breathing glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.nuviaGoldFallback.opacity(0.1),
                                Color.nuviaGoldFallback.opacity(0.02),
                                Color.nuviaGoldFallback.opacity(0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(glowPulse ? 1.1 : 0.9)

                // Subtle ring
                Circle()
                    .stroke(Color.nuviaGoldFallback.opacity(0.08), lineWidth: 1)
                    .frame(width: 120, height: 120)

                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.nuviaSecondaryText.opacity(0.6), Color.nuviaSecondaryText.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .offset(y: floatOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    floatOffset = -8
                    glowPulse = true
                }
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(NuviaTypography.title3())
                    .foregroundColor(.nuviaPrimaryText)
                    .accessibilityAddTraits(.isHeader)

                Text(message)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                NuviaPrimaryButton(actionTitle, action: action)
                    .frame(width: 200)
            }
        }
        .padding(32)
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
        HStack {
            Text(title)
                .font(NuviaTypography.title3())
                .foregroundColor(.nuviaPrimaryText)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(NuviaTypography.smallButton())
                        .foregroundColor(.nuviaGoldFallback)
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
        .padding(16)
        .background(Color.nuviaCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.nuviaGlassBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Quick Action Button

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
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 52, height: 52)
                    .background(
                        ZStack {
                            color.opacity(0.12)
                            Color.white.opacity(0.03)
                        }
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.2), lineWidth: 0.5)
                    )

                Text(title)
                    .font(NuviaTypography.caption2())
                    .foregroundColor(.nuviaPrimaryText)
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
                    .frame(width: 16, height: 16)
                    .scaleEffect(isGlowing ? 1.3 : 1.0)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            isGlowing = true
                        }
                    }
            }
            Circle()
                .fill(status.color)
                .frame(width: 10, height: 10)
        }
        .accessibilityLabel(status.displayName)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .nuviaGoldFallback
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.selection()
            action()
        } label: {
            Text(title)
                .font(NuviaTypography.caption())
                .foregroundColor(isSelected ? .nuviaMidnight : .nuviaSecondaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.nuviaTertiaryBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color.opacity(0.5) : Color.nuviaGlassBorder, lineWidth: 0.5)
                )
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
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.nuviaTertiaryBackground)
            .frame(height: height)
            .shimmer()
    }
}

struct NuviaSkeletonRow: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.nuviaTertiaryBackground)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.nuviaTertiaryBackground)
                    .frame(width: 140, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.nuviaTertiaryBackground)
                    .frame(width: 90, height: 10)
            }

            Spacer()
        }
        .padding(16)
        .shimmer()
    }
}

// MARK: - Preview

#Preview("Components") {
    ScrollView {
        VStack(spacing: 24) {
            NuviaPrimaryButton("Devam Et", icon: "arrow.right") {}

            NuviaSecondaryButton("İptal", icon: "xmark") {}

            NuviaGlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Glass Kart")
                        .font(NuviaTypography.title3())
                    Text("Premium glassmorphism efektiyle.")
                        .font(NuviaTypography.body())
                }
            }

            NuviaCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kart Başlığı")
                        .font(NuviaTypography.title3())
                    Text("Kart içeriği burada yer alır.")
                        .font(NuviaTypography.body())
                }
            }

            NuviaProgressRing(progress: 0.65)

            HStack {
                NuviaTag("Nikah", color: .categoryVenue)
                NuviaTag("Yüksek", color: .priorityHigh)
                NuviaTag("Tamamlandı", color: .statusCompleted)
            }

            NuviaSkeletonCard()
            NuviaSkeletonRow()

            NuviaEmptyState(
                icon: "tray",
                title: "Henüz görev yok",
                message: "İlk görevinizi ekleyerek başlayın",
                actionTitle: "Görev Ekle"
            ) {}
        }
        .padding()
    }
    .background(Color.nuviaBackground)
}
