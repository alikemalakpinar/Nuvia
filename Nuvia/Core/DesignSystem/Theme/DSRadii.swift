import SwiftUI

// MARK: - Design System Corner Radii
// Consistent rounded corners across the app

/// Corner radius tokens for Nuvia Design System
public enum DSRadii {

    /// 0pt - No rounding (sharp corners)
    public static let none: CGFloat = 0

    /// 4pt - Extra small (badges, tiny elements)
    public static let xs: CGFloat = 4

    /// 8pt - Small (inputs, small buttons)
    public static let sm: CGFloat = 8

    /// 12pt - Medium (chips, tags)
    public static let md: CGFloat = 12

    /// 16pt - Large (cards, list items)
    public static let lg: CGFloat = 16

    /// 20pt - Extra large (featured cards)
    public static let xl: CGFloat = 20

    /// 24pt - 2XL (modals, sheets)
    public static let xxl: CGFloat = 24

    /// 28pt - Hero cards
    public static let hero: CGFloat = 28

    /// 32pt - 3XL
    public static let xxxl: CGFloat = 32

    /// 999pt - Full/Pill (capsule buttons)
    public static let pill: CGFloat = 999

    // MARK: - Semantic Radii

    /// Input fields (8pt)
    public static let input: CGFloat = sm

    /// Standard cards (16pt)
    public static let card: CGFloat = lg

    /// Hero/featured cards (28pt)
    public static let cardHero: CGFloat = hero

    /// Modal/sheet corners (24pt)
    public static let modal: CGFloat = xxl

    /// Primary buttons (16pt)
    public static let button: CGFloat = lg

    /// Pill buttons (999pt)
    public static let buttonPill: CGFloat = pill

    /// Icon containers (16pt)
    public static let iconContainer: CGFloat = lg

    /// Small icon containers (12pt)
    public static let iconContainerSmall: CGFloat = md

    /// Progress bars (4pt)
    public static let progressBar: CGFloat = xs

    /// Tab bar indicator (3pt)
    public static let indicator: CGFloat = 3
}

// MARK: - RoundedRectangle Presets

extension RoundedRectangle {
    /// Card shape with continuous corners
    public static var dsCard: RoundedRectangle {
        RoundedRectangle(cornerRadius: DSRadii.card, style: .continuous)
    }

    /// Hero card shape
    public static var dsHeroCard: RoundedRectangle {
        RoundedRectangle(cornerRadius: DSRadii.cardHero, style: .continuous)
    }

    /// Modal shape
    public static var dsModal: RoundedRectangle {
        RoundedRectangle(cornerRadius: DSRadii.modal, style: .continuous)
    }

    /// Button shape
    public static var dsButton: RoundedRectangle {
        RoundedRectangle(cornerRadius: DSRadii.button, style: .continuous)
    }

    /// Input field shape
    public static var dsInput: RoundedRectangle {
        RoundedRectangle(cornerRadius: DSRadii.input, style: .continuous)
    }
}

// MARK: - View Extension

extension View {
    /// Clip to card shape
    public func dsCardClip() -> some View {
        self.clipShape(RoundedRectangle.dsCard)
    }

    /// Clip to hero card shape
    public func dsHeroCardClip() -> some View {
        self.clipShape(RoundedRectangle.dsHeroCard)
    }

    /// Clip to button shape
    public func dsButtonClip() -> some View {
        self.clipShape(RoundedRectangle.dsButton)
    }
}
