import SwiftUI

// MARK: - Primary Button

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

    var body: some View {
        Button(action: action) {
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
                    ? Color.nuviaTertiaryText
                    : Color.nuviaGradient
            )
            .foregroundColor(.nuviaMidnight)
            .cornerRadius(16)
        }
        .disabled(isDisabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
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
        Button(action: action) {
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
            .background(Color.nuviaCardBackground)
            .foregroundColor(.nuviaGoldFallback)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.nuviaGoldFallback.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

// MARK: - Text Button

struct NuviaTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(NuviaTypography.smallButton())
                .foregroundColor(.nuviaGoldFallback)
        }
    }
}

// MARK: - Card

struct NuviaCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(Color.nuviaCardBackground)
            .cornerRadius(20)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaSecondaryText)

            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.nuviaSecondaryText)
                        .frame(width: 20)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(NuviaTypography.body())
                } else {
                    TextField(placeholder, text: $text)
                        .font(NuviaTypography.body())
                        .keyboardType(keyboardType)
                }
            }
            .padding(16)
            .background(Color.nuviaTertiaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.nuviaSecondaryText.opacity(0.2), lineWidth: 1)
            )
        }
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

            DatePicker(
                "",
                selection: $date,
                displayedComponents: displayedComponents
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .padding(12)
            .background(Color.nuviaTertiaryBackground)
            .cornerRadius(12)
        }
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
    }
}

// MARK: - Progress Ring

struct NuviaProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let showPercentage: Bool

    init(progress: Double, size: CGFloat = 80, lineWidth: CGFloat = 8, showPercentage: Bool = true) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.nuviaTertiaryBackground, lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    Color.nuviaGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Percentage text
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)
            }
        }
        .frame(width: size, height: size)
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
        .background(Color.nuviaCardBackground)
        .cornerRadius(24)
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
    }
}

// MARK: - Empty State

struct NuviaEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

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
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.nuviaSecondaryText)

            VStack(spacing: 8) {
                Text(title)
                    .font(NuviaTypography.title3())
                    .foregroundColor(.nuviaPrimaryText)

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
    }
}

// MARK: - Quick Action Button

struct NuviaQuickAction: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 56, height: 56)
                    .background(color.opacity(0.15))
                    .cornerRadius(16)

                Text(title)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaPrimaryText)
            }
        }
    }
}

// MARK: - Status Indicator

struct NuviaStatusIndicator: View {
    let status: TaskStatus

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: 10, height: 10)
    }
}

// MARK: - Preview

#Preview("Components") {
    ScrollView {
        VStack(spacing: 24) {
            NuviaPrimaryButton("Devam Et", icon: "arrow.right") {}

            NuviaSecondaryButton("İptal", icon: "xmark") {}

            NuviaCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kart Başlığı")
                        .font(NuviaTypography.title3())
                    Text("Kart içeriği burada yer alır.")
                        .font(NuviaTypography.body())
                }
            }

            NuviaProgressRing(progress: 0.65)

            NuviaCountdown(daysRemaining: 142, weddingDate: Date().addingTimeInterval(86400 * 142))

            HStack {
                NuviaTag("Nikah", color: .categoryVenue)
                NuviaTag("Yüksek", color: .priorityHigh)
                NuviaTag("Tamamlandı", color: .statusCompleted)
            }

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
