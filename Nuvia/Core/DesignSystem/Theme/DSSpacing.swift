import SwiftUI

// MARK: - Design System Spacing
// 8pt grid system with semantic naming

/// Spacing tokens for Nuvia Design System
public enum DSSpacing {

    // MARK: - Base Scale (8pt Grid)

    /// 2pt - Micro spacing
    public static let xxxs: CGFloat = 2

    /// 4pt - Tiny spacing
    public static let xxs: CGFloat = 4

    /// 8pt - Extra small
    public static let xs: CGFloat = 8

    /// 12pt - Small
    public static let sm: CGFloat = 12

    /// 16pt - Medium (default)
    public static let md: CGFloat = 16

    /// 24pt - Large (Nuvia Margin)
    public static let lg: CGFloat = 24

    /// 32pt - Extra large
    public static let xl: CGFloat = 32

    /// 48pt - 2XL
    public static let xxl: CGFloat = 48

    /// 64pt - 3XL
    public static let xxxl: CGFloat = 64

    /// 96pt - Huge
    public static let huge: CGFloat = 96

    // MARK: - Semantic Spacing

    /// Standard horizontal padding for screens (24pt)
    public static let nuviaMargin: CGFloat = 24

    /// Card internal padding (20pt)
    public static let cardPadding: CGFloat = 20

    /// Hero card padding (28pt)
    public static let heroCardPadding: CGFloat = 28

    /// Section spacing (28pt)
    public static let sectionSpacing: CGFloat = 28

    /// Item spacing in lists (12pt)
    public static let itemSpacing: CGFloat = 12

    /// Compact item spacing (8pt)
    public static let itemSpacingCompact: CGFloat = 8

    /// Icon-to-text spacing (10pt)
    public static let iconTextSpacing: CGFloat = 10

    /// Button icon spacing (8pt)
    public static let buttonIconSpacing: CGFloat = 8

    /// Tab bar bottom padding (24pt)
    public static let tabBarBottomPadding: CGFloat = 24

    /// Bottom safe area for scrollable content (120pt)
    public static let scrollBottomInset: CGFloat = 120
}

// MARK: - EdgeInsets Presets

extension EdgeInsets {
    /// Standard horizontal padding
    public static var dsHorizontal: EdgeInsets {
        EdgeInsets(top: 0, leading: DSSpacing.nuviaMargin, bottom: 0, trailing: DSSpacing.nuviaMargin)
    }

    /// Card padding
    public static var dsCard: EdgeInsets {
        EdgeInsets(
            top: DSSpacing.cardPadding,
            leading: DSSpacing.cardPadding,
            bottom: DSSpacing.cardPadding,
            trailing: DSSpacing.cardPadding
        )
    }

    /// Hero card padding
    public static var dsHeroCard: EdgeInsets {
        EdgeInsets(
            top: DSSpacing.heroCardPadding,
            leading: DSSpacing.heroCardPadding,
            bottom: DSSpacing.heroCardPadding,
            trailing: DSSpacing.heroCardPadding
        )
    }

    /// Section padding
    public static var dsSection: EdgeInsets {
        EdgeInsets(
            top: DSSpacing.sectionSpacing,
            leading: DSSpacing.nuviaMargin,
            bottom: DSSpacing.sectionSpacing,
            trailing: DSSpacing.nuviaMargin
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply Nuvia standard horizontal margin
    public func nuviaMargin() -> some View {
        self.padding(.horizontal, DSSpacing.nuviaMargin)
    }

    /// Apply card internal padding
    public func cardPadding() -> some View {
        self.padding(DSSpacing.cardPadding)
    }

    /// Apply section spacing
    public func sectionSpacing() -> some View {
        self.padding(.vertical, DSSpacing.sectionSpacing)
    }
}
