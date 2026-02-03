import SwiftUI

// MARK: - Parallax Hero Header
// Magazine-style hero with parallax scroll effect and countdown

struct ParallaxHeroView: View {
    let greeting: String
    let greetingIcon: String
    let partnerName1: String
    let partnerName2: String
    let weddingDate: Date
    let scrollOffset: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Parallax calculations
    private var parallaxOffset: CGFloat {
        guard !reduceMotion else { return 0 }
        return max(0, scrollOffset * 0.4)
    }

    private var headerOpacity: Double {
        guard !reduceMotion else { return 1 }
        let progress = min(1, max(0, scrollOffset / 200))
        return 1 - (progress * 0.3)
    }

    private var headerScale: CGFloat {
        guard !reduceMotion else { return 1 }
        let progress = min(1, max(0, scrollOffset / 300))
        return 1 - (progress * 0.1)
    }

    private var blurAmount: CGFloat {
        guard !reduceMotion else { return 0 }
        return min(10, max(0, scrollOffset / 30))
    }

    // Countdown
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let wedding = calendar.startOfDay(for: weddingDate)
        return max(0, calendar.dateComponents([.day], from: today, to: wedding).day ?? 0)
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Date & Greeting
            greetingSection
                .offset(y: -parallaxOffset)
                .opacity(headerOpacity)
                .scaleEffect(headerScale)

            // Countdown Display
            countdownDisplay
                .offset(y: -parallaxOffset * 0.6)
                .opacity(headerOpacity)

            // Couple Names
            coupleNames
                .offset(y: -parallaxOffset * 0.3)
                .opacity(headerOpacity)
        }
        .padding(.top, DesignTokens.Spacing.xl)
        .padding(.bottom, DesignTokens.Spacing.xxl)
        .blur(radius: blurAmount)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(greeting). \(daysRemaining) days until \(partnerName1) and \(partnerName2)'s wedding")
    }

    // MARK: - Greeting Section

    private var greetingSection: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            // Overline date
            Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(NuviaTypography.overline())
                .tracking(DSTypography.Kerning.overline)
                .foregroundColor(.nuviaSecondaryText)
                .textCase(.uppercase)

            // Greeting with icon
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: greetingIcon)
                    .font(.system(size: 28))
                    .foregroundStyle(Color.etherealGradient)

                Text(greeting)
                    .font(NuviaTypography.displaySmall())
                    .foregroundColor(.nuviaPrimaryText)
            }
        }
    }

    // MARK: - Countdown Display

    private var countdownDisplay: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            // Large number
            Text("\(daysRemaining)")
                .font(NuviaTypography.countdown())
                .foregroundStyle(Color.etherealGradient)
                .contentTransition(.numericText())

            // Days label
            Text("DAYS")
                .font(NuviaTypography.overline())
                .tracking(DSTypography.Kerning.overline)
                .foregroundColor(.nuviaSecondaryText)
        }
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Couple Names

    private var coupleNames: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Text(partnerName1)
                .font(NuviaTypography.title2())
                .foregroundColor(.nuviaPrimaryText)

            Image(systemName: "heart.fill")
                .font(.system(size: 12))
                .foregroundColor(.nuviaRoseDust)

            Text(partnerName2)
                .font(NuviaTypography.title2())
                .foregroundColor(.nuviaPrimaryText)
        }
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Scroll Offset Reader

struct ScrollOffsetReader: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: -geometry.frame(in: .named("scroll")).origin.y
                )
        }
        .frame(height: 0)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        ParallaxHeroView(
            greeting: "Good Morning",
            greetingIcon: "sunrise.fill",
            partnerName1: "Emma",
            partnerName2: "James",
            weddingDate: Date().addingTimeInterval(86400 * 127),
            scrollOffset: 0
        )
    }
    .background(Color(hex: "FAFAF9"))
}
