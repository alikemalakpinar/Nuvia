import SwiftUI

// MARK: - Parallax Header
// Stretches when pulled down, blurs as it scrolls up

struct ParallaxHeader<Content: View, Background: View>: View {
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let scrollOffset: CGFloat
    @ViewBuilder let background: () -> Background
    @ViewBuilder let content: (CGFloat) -> Content

    // Computed properties
    private var stretchedHeight: CGFloat {
        if scrollOffset < 0 {
            // Pulling down - stretch the header
            return maxHeight - scrollOffset
        } else if scrollOffset > maxHeight - minHeight {
            // Scrolled past - use minimum height
            return minHeight
        } else {
            // Normal scrolling - shrink from max to min
            return maxHeight - scrollOffset
        }
    }

    private var blurAmount: CGFloat {
        // Start blurring after 50% scroll
        let threshold = (maxHeight - minHeight) * 0.5
        if scrollOffset > threshold {
            let blurProgress = (scrollOffset - threshold) / threshold
            return min(10, blurProgress * 10)
        }
        return 0
    }

    private var backgroundOpacity: CGFloat {
        // Fade out background as we scroll
        let fadeStart = (maxHeight - minHeight) * 0.3
        if scrollOffset > fadeStart {
            return max(0.3, 1 - ((scrollOffset - fadeStart) / (maxHeight - minHeight - fadeStart)))
        }
        return 1
    }

    private var progress: CGFloat {
        // 0 = fully expanded, 1 = fully collapsed
        min(1, max(0, scrollOffset / (maxHeight - minHeight)))
    }

    private var scale: CGFloat {
        if scrollOffset < 0 {
            // Stretching - scale up slightly
            return 1 + abs(scrollOffset) / maxHeight * 0.1
        }
        return 1
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                // Background (stretches and blurs)
                background()
                    .frame(width: proxy.size.width, height: stretchedHeight)
                    .scaleEffect(scale)
                    .blur(radius: blurAmount)
                    .opacity(backgroundOpacity)
                    .clipped()

                // Gradient overlay for text readability
                LinearGradient(
                    colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: stretchedHeight * 0.6)
                .frame(maxHeight: .infinity, alignment: .bottom)

                // Content
                content(progress)
                    .padding(.bottom, DesignTokens.Spacing.lg)
            }
            .frame(width: proxy.size.width, height: stretchedHeight)
            .offset(y: scrollOffset < 0 ? scrollOffset : 0)
        }
        .frame(height: maxHeight)
    }
}

// MARK: - Hero Header Content
struct HeroHeaderContent: View {
    let progress: CGFloat
    let title: String
    let subtitle: String?
    let date: String?

    private var titleOpacity: CGFloat {
        max(0, 1 - progress * 1.5)
    }

    private var titleScale: CGFloat {
        max(0.8, 1 - progress * 0.2)
    }

    private var titleOffset: CGFloat {
        progress * -30
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            // Date/Overline
            if let date = date {
                Text(date.uppercased())
                    .font(DSTypography.label(.small))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(titleOpacity)
            }

            // Main Title
            Text(title)
                .font(DSTypography.display(.medium))
                .foregroundColor(.white)
                .opacity(titleOpacity)
                .scaleEffect(titleScale, anchor: .bottomLeading)
                .offset(y: titleOffset)

            // Subtitle
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DSTypography.body(.regular))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(titleOpacity * 0.9)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Countdown Hero
struct CountdownHero: View {
    let daysRemaining: Int
    let weddingDate: Date
    let partnerNames: (String, String)
    let progress: CGFloat

    private var opacity: CGFloat {
        max(0, 1 - progress * 1.2)
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Days countdown
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(daysRemaining)")
                    .font(DSTypography.countdown)
                    .foregroundColor(.white)

                Text("days")
                    .font(DSTypography.heading(.h3))
                    .foregroundColor(.white.opacity(0.8))
            }
            .opacity(opacity)

            // Wedding date
            Text(weddingDate.formatted(date: .complete, time: .omitted))
                .font(DSTypography.body(.regular))
                .foregroundColor(.white.opacity(0.8))
                .opacity(opacity)

            // Partner names
            Text("\(partnerNames.0) & \(partnerNames.1)")
                .font(DSTypography.heading(.h2))
                .foregroundColor(.white)
                .opacity(opacity)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, DesignTokens.Spacing.lg)
    }
}

// MARK: - Editorial Card
struct EditorialCard<Content: View>: View {
    let scrollState: ScrollState
    let id: String
    @ViewBuilder let content: () -> Content

    @State private var appeared = false

    var body: some View {
        content()
            .cardStyle(elevation: .raised)
            .trackVisibility(id: id, in: "scroll")
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 30)
            .animation(DesignTokens.Animation.smooth.delay(0.1), value: appeared)
            .onChange(of: scrollState.visibleViews) { _, visible in
                if visible.contains(id) && !appeared {
                    appeared = true
                }
            }
    }
}

// MARK: - Featured Card (Large Editorial)
struct FeaturedCard: View {
    let title: String
    let subtitle: String
    let accentColor: Color
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(accentColor)
                    .frame(width: 56, height: 56)
                    .background(accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))

                // Text
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    Text(title)
                        .font(DSTypography.heading(.h4))
                        .foregroundColor(DSColors.fallbackTextPrimary)

                    Text(subtitle)
                        .font(DSTypography.body(.small))
                        .foregroundColor(DSColors.fallbackTextPrimary.opacity(0.6))
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DSColors.fallbackTextPrimary.opacity(0.3))
            }
            .padding(DesignTokens.Spacing.md)
            .background(DSColors.fallbackSurface)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
            .elevation(.raised)
        }
        .pressable()
    }
}

// MARK: - Section Header
struct EditorialSectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(DSTypography.label(.regular))
                .tracking(1.5)
                .foregroundColor(DSColors.fallbackTextPrimary.opacity(0.5))

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DSTypography.label(.regular))
                        .foregroundColor(DSColors.fallbackAccent)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.sm)
    }
}

// MARK: - Magazine Cover Style View
struct MagazineCoverView: View {
    let scrollOffset: CGFloat
    let image: Image?
    let title: String
    let date: Date

    private let maxHeight: CGFloat = 400
    private let minHeight: CGFloat = 100

    var body: some View {
        ParallaxHeader(
            minHeight: minHeight,
            maxHeight: maxHeight,
            scrollOffset: scrollOffset
        ) {
            // Background
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                // Default gradient background
                LinearGradient(
                    colors: [
                        Color(hex: "D4AF37").opacity(0.8),
                        Color(hex: "9CAF88").opacity(0.6),
                        Color(hex: "FAFAF9")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        } content: { progress in
            HeroHeaderContent(
                progress: progress,
                title: title,
                subtitle: nil,
                date: date.formatted(.dateTime.weekday(.wide).month(.wide).day())
            )
        }
    }
}
