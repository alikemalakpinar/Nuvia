import SwiftUI

// MARK: - Design System Shadows
// Ethereal shadow system for depth and elevation

/// Shadow tokens for Nuvia Design System
public enum DSShadow: CaseIterable {
    case none
    case whisper    // Subtle hint of depth
    case soft       // Standard card shadow
    case medium     // Elevated cards
    case pronounced // Floating elements
    case dramatic   // Modals, overlays

    // MARK: - Properties

    public var color: Color {
        .black
    }

    public var opacity: Double {
        switch self {
        case .none: return 0
        case .whisper: return 0.02
        case .soft: return 0.04
        case .medium: return 0.06
        case .pronounced: return 0.08
        case .dramatic: return 0.12
        }
    }

    public var radius: CGFloat {
        switch self {
        case .none: return 0
        case .whisper: return 8
        case .soft: return 16
        case .medium: return 24
        case .pronounced: return 32
        case .dramatic: return 48
        }
    }

    public var y: CGFloat {
        switch self {
        case .none: return 0
        case .whisper: return 2
        case .soft: return 4
        case .medium: return 8
        case .pronounced: return 12
        case .dramatic: return 20
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply DS shadow with optional accent color
    public func dsShadow(_ level: DSShadow, colored: Color? = nil) -> some View {
        let shadowColor = colored ?? level.color

        return self
            // Primary shadow
            .shadow(
                color: shadowColor.opacity(level.opacity),
                radius: level.radius,
                x: 0,
                y: level.y
            )
            // Secondary diffuse shadow for ethereal effect
            .shadow(
                color: shadowColor.opacity(level.opacity * 0.5),
                radius: level.radius * 2,
                x: 0,
                y: level.y * 2
            )
    }

    /// Apply subtle card shadow
    public func cardShadow() -> some View {
        dsShadow(.soft)
    }

    /// Apply elevated card shadow
    public func elevatedShadow() -> some View {
        dsShadow(.medium)
    }

    /// Apply floating element shadow
    public func floatingShadow() -> some View {
        dsShadow(.pronounced)
    }
}

// MARK: - Elevation System (Alternative API)

public enum DSElevation {
    case flat       // No shadow
    case raised     // Cards, buttons
    case floating   // Modals, popovers
    case overlay    // Dialogs, sheets
    case navigation // App bars, tab bars

    public var shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat, opacity: Double) {
        switch self {
        case .flat:
            return (.clear, 0, 0, 0, 0)
        case .raised:
            return (.black, 8, 0, 2, 0.08)
        case .floating:
            return (.black, 16, 0, 4, 0.12)
        case .overlay:
            return (.black, 24, 0, 8, 0.16)
        case .navigation:
            return (.black, 4, 0, 1, 0.06)
        }
    }

    public func apply(to view: some View) -> some View {
        let s = shadow
        return view.shadow(color: s.color.opacity(s.opacity), radius: s.radius, x: s.x, y: s.y)
    }
}

extension View {
    /// Apply elevation shadow
    public func dsElevation(_ level: DSElevation) -> some View {
        level.apply(to: self)
    }
}
