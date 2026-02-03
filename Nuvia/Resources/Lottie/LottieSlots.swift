import SwiftUI

// MARK: - Lottie Animation Slots
// Predefined slots for Lottie animations throughout the app
// When .json files are added, update LottieView to load them

/// Defines all animation slots used in the app
/// Each slot maps to a specific .json file (when available)
public enum LottieSlot: String, CaseIterable, Identifiable {
    // MARK: - Onboarding
    case anim_splash_logo = "anim_splash_logo"
    case anim_onboarding_welcome = "anim_onboarding_welcome"
    case anim_onboarding_planning = "anim_onboarding_planning"
    case anim_onboarding_collaborate = "anim_onboarding_collaborate"
    case anim_onboarding_complete = "anim_onboarding_complete"

    // MARK: - Empty States
    case anim_empty_inbox = "anim_empty_inbox"
    case anim_empty_tasks = "anim_empty_tasks"
    case anim_empty_guests = "anim_empty_guests"
    case anim_empty_budget = "anim_empty_budget"
    case anim_empty_timeline = "anim_empty_timeline"

    // MARK: - Success / Completion
    case anim_task_completed = "anim_task_completed"
    case anim_payment_success = "anim_payment_success"
    case anim_rsvp_received = "anim_rsvp_received"
    case anim_confetti = "anim_confetti"

    // MARK: - Loading / Processing
    case anim_loading_general = "anim_loading_general"
    case anim_loading_upload = "anim_loading_upload"
    case anim_loading_sync = "anim_loading_sync"

    // MARK: - Countdown / Calendar
    case anim_countdown_heart = "anim_countdown_heart"
    case anim_countdown_rings = "anim_countdown_rings"

    // MARK: - Error States
    case anim_error_general = "anim_error_general"
    case anim_connection_lost = "anim_connection_lost"

    public var id: String { rawValue }

    /// Filename for the animation (without extension)
    public var filename: String { rawValue }

    /// Whether this animation should loop by default
    public var shouldLoop: Bool {
        switch self {
        case .anim_loading_general, .anim_loading_upload, .anim_loading_sync,
             .anim_countdown_heart, .anim_countdown_rings:
            return true
        case .anim_confetti, .anim_task_completed, .anim_payment_success,
             .anim_rsvp_received, .anim_onboarding_complete:
            return false
        default:
            return true
        }
    }

    /// Default speed multiplier
    public var defaultSpeed: Double {
        switch self {
        case .anim_loading_general, .anim_loading_upload, .anim_loading_sync:
            return 1.2
        case .anim_confetti:
            return 1.0
        case .anim_task_completed:
            return 1.3
        default:
            return 1.0
        }
    }

    /// Fallback SF Symbol when animation file is not available
    public var fallbackSymbol: String {
        switch self {
        case .anim_splash_logo, .anim_countdown_rings:
            return "heart.fill"
        case .anim_onboarding_welcome:
            return "sparkles"
        case .anim_onboarding_planning:
            return "calendar"
        case .anim_onboarding_collaborate:
            return "person.2.fill"
        case .anim_onboarding_complete:
            return "checkmark.circle.fill"
        case .anim_empty_inbox:
            return "tray"
        case .anim_empty_tasks:
            return "checklist"
        case .anim_empty_guests:
            return "person.3"
        case .anim_empty_budget:
            return "creditcard"
        case .anim_empty_timeline:
            return "calendar.badge.clock"
        case .anim_task_completed:
            return "checkmark.circle.fill"
        case .anim_payment_success:
            return "checkmark.seal.fill"
        case .anim_rsvp_received:
            return "envelope.open.fill"
        case .anim_confetti:
            return "party.popper.fill"
        case .anim_loading_general, .anim_loading_upload, .anim_loading_sync:
            return "arrow.2.circlepath"
        case .anim_countdown_heart:
            return "heart.fill"
        case .anim_error_general:
            return "exclamationmark.triangle.fill"
        case .anim_connection_lost:
            return "wifi.slash"
        }
    }

    /// Fallback color for the symbol
    public var fallbackColor: Color {
        switch self {
        case .anim_task_completed, .anim_payment_success, .anim_rsvp_received:
            return Color(hex: "8BAA7C") // Success green
        case .anim_error_general, .anim_connection_lost:
            return Color(hex: "C48B8B") // Error red
        case .anim_confetti, .anim_countdown_heart, .anim_countdown_rings:
            return Color(hex: "D4AF37") // Gold
        case .anim_loading_general, .anim_loading_upload, .anim_loading_sync:
            return Color(hex: "6D6D6D") // Secondary text
        default:
            return Color(hex: "D4AF37") // Gold
        }
    }
}

// MARK: - Animation Configuration

/// Configuration for Lottie animation playback
public struct LottieConfig {
    public let slot: LottieSlot
    public let loop: Bool
    public let speed: Double
    public let size: CGSize?

    public init(
        slot: LottieSlot,
        loop: Bool? = nil,
        speed: Double? = nil,
        size: CGSize? = nil
    ) {
        self.slot = slot
        self.loop = loop ?? slot.shouldLoop
        self.speed = speed ?? slot.defaultSpeed
        self.size = size
    }

    // Convenience initializers
    public static func splash() -> LottieConfig {
        LottieConfig(slot: .anim_splash_logo, size: CGSize(width: 200, height: 200))
    }

    public static func loading() -> LottieConfig {
        LottieConfig(slot: .anim_loading_general, size: CGSize(width: 100, height: 100))
    }

    public static func taskCompleted() -> LottieConfig {
        LottieConfig(slot: .anim_task_completed, loop: false, size: CGSize(width: 80, height: 80))
    }

    public static func emptyState(_ type: EmptyStateType) -> LottieConfig {
        LottieConfig(slot: type.slot, size: CGSize(width: 150, height: 150))
    }

    public enum EmptyStateType {
        case inbox, tasks, guests, budget, timeline

        var slot: LottieSlot {
            switch self {
            case .inbox: return .anim_empty_inbox
            case .tasks: return .anim_empty_tasks
            case .guests: return .anim_empty_guests
            case .budget: return .anim_empty_budget
            case .timeline: return .anim_empty_timeline
            }
        }
    }
}
