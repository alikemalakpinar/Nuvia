import SwiftUI
import UIKit

// MARK: - Nuvia Haptics
// Centralized haptic feedback system
// Provides semantic haptic patterns for different interactions

/// Haptic feedback manager with semantic patterns
@MainActor
public final class NuviaHaptics {
    public static let shared = NuviaHaptics()

    // Pre-created generators for better performance
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        selectionGenerator.prepare()
    }

    // MARK: - Basic Haptics

    /// Selection feedback - for picker changes, toggles, tab switches
    public func selection() {
        selectionGenerator.selectionChanged()
    }

    /// Impact feedback with style
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:  lightImpact.impactOccurred()
        case .medium: mediumImpact.impactOccurred()
        case .heavy:  heavyImpact.impactOccurred()
        case .rigid:  rigidImpact.impactOccurred()
        case .soft:   softImpact.impactOccurred()
        @unknown default: lightImpact.impactOccurred()
        }
    }

    /// Impact with intensity (0.0-1.0)
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat) {
        switch style {
        case .light:  lightImpact.impactOccurred(intensity: intensity)
        case .medium: mediumImpact.impactOccurred(intensity: intensity)
        case .heavy:  heavyImpact.impactOccurred(intensity: intensity)
        case .rigid:  rigidImpact.impactOccurred(intensity: intensity)
        case .soft:   softImpact.impactOccurred(intensity: intensity)
        @unknown default: lightImpact.impactOccurred(intensity: intensity)
        }
    }

    /// Notification feedback
    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }

    // MARK: - Semantic Haptics

    /// Tab switch - selection feedback
    public func tabSwitch() {
        selection()
    }

    /// Button tap - light impact
    public func buttonTap() {
        impact(.light)
    }

    /// Add action - medium impact
    public func addAction() {
        impact(.medium)
    }

    /// Delete action - rigid impact
    public func deleteAction() {
        impact(.rigid)
    }

    /// Task completed - success notification
    public func taskCompleted() {
        notification(.success)
    }

    /// Success feedback
    public func success() {
        notification(.success)
    }

    /// Warning feedback
    public func warning() {
        notification(.warning)
    }

    /// Error feedback
    public func error() {
        notification(.error)
    }

    /// Drag start - medium impact
    public func dragStart() {
        impact(.medium)
    }

    /// Drag end - light impact
    public func dragEnd() {
        impact(.light)
    }

    /// Drop - heavy impact
    public func drop() {
        impact(.heavy)
    }

    /// Seating drop - heavy impact (alias for drop)
    public func seatingDrop() {
        drop()
    }

    /// Seat conflict pattern (legacy compatibility)
    public func seatConflict() {
        conflict()
    }

    /// Slider tick - soft impact
    public func sliderTick() {
        impact(.soft, intensity: 0.5)
    }

    /// List item reorder bump
    public func reorderBump() {
        impact(.rigid, intensity: 0.6)
    }

    /// Pull to refresh threshold
    public func refreshThreshold() {
        impact(.medium, intensity: 0.8)
    }

    /// Long press trigger
    public func longPress() {
        impact(.heavy, intensity: 0.7)
    }

    /// Countdown tick
    public func countdownTick() {
        impact(.soft, intensity: 0.4)
    }

    // MARK: - Complex Patterns

    /// Double tap pattern
    public func doubleTap() {
        impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.impact(.light)
        }
    }

    /// Triple success pattern (for major achievements)
    public func majorSuccess() {
        notification(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.impact(.light, intensity: 0.6)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.impact(.soft, intensity: 0.4)
        }
    }

    /// Conflict/collision pattern (for seating conflicts, etc.)
    public func conflict() {
        impact(.rigid, intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.impact(.rigid, intensity: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.impact(.rigid, intensity: 0.4)
        }
    }

    /// Shake pattern (for error or denial)
    public func shake() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) { [weak self] in
                self?.impact(.rigid, intensity: 0.7)
            }
        }
    }

    /// Gentle pulse (for subtle attention)
    public func gentlePulse() {
        impact(.soft, intensity: 0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.impact(.soft, intensity: 0.2)
        }
    }
}

// MARK: - View Modifier for Haptic Feedback

public struct HapticFeedbackModifier: ViewModifier {
    let trigger: HapticTrigger
    @Binding var value: Bool

    public func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, newValue in
                if newValue {
                    _Concurrency.Task { @MainActor in
                        trigger.fire()
                    }
                }
            }
    }
}

public enum HapticTrigger {
    case selection
    case lightImpact
    case mediumImpact
    case heavyImpact
    case success
    case warning
    case error
    case buttonTap
    case taskComplete
    case addAction
    case tabSwitch

    @MainActor
    func fire() {
        let haptics = NuviaHaptics.shared
        switch self {
        case .selection: haptics.selection()
        case .lightImpact: haptics.impact(.light)
        case .mediumImpact: haptics.impact(.medium)
        case .heavyImpact: haptics.impact(.heavy)
        case .success: haptics.success()
        case .warning: haptics.warning()
        case .error: haptics.error()
        case .buttonTap: haptics.buttonTap()
        case .taskComplete: haptics.taskCompleted()
        case .addAction: haptics.addAction()
        case .tabSwitch: haptics.tabSwitch()
        }
    }
}

extension View {
    /// Add haptic feedback when a value changes to true
    public func hapticFeedback(_ trigger: HapticTrigger, on value: Binding<Bool>) -> some View {
        self.modifier(HapticFeedbackModifier(trigger: trigger, value: value))
    }

    /// Convenience for button haptic
    public func buttonHaptic() -> some View {
        self.simultaneousGesture(TapGesture().onEnded { _ in
            _Concurrency.Task { @MainActor in
                NuviaHaptics.shared.buttonTap()
            }
        })
    }
}

// MARK: - Haptic Button Style

/// Button style that includes haptic feedback
public struct HapticButtonStyle: ButtonStyle {
    let hapticType: HapticTrigger
    let scale: CGFloat

    public init(haptic: HapticTrigger = .buttonTap, scale: CGFloat = 0.97) {
        self.hapticType = haptic
        self.scale = scale
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(MotionCurves.snappy, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    _Concurrency.Task { @MainActor in
                        hapticType.fire()
                    }
                }
            }
    }
}

extension ButtonStyle where Self == HapticButtonStyle {
    public static var haptic: HapticButtonStyle { HapticButtonStyle() }
    public static func haptic(_ type: HapticTrigger) -> HapticButtonStyle {
        HapticButtonStyle(haptic: type)
    }
}

// MARK: - Static Convenience Methods (for DSHaptics compatibility)

extension NuviaHaptics {
    /// Static selection feedback
    public static func selection() {
        _Concurrency.Task { @MainActor in shared.selection() }
    }

    /// Static impact feedback
    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        _Concurrency.Task { @MainActor in shared.impact(style) }
    }

    /// Static notification feedback
    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        _Concurrency.Task { @MainActor in shared.notification(type) }
    }

    /// Static success feedback
    public static func success() {
        _Concurrency.Task { @MainActor in shared.success() }
    }

    /// Static warning feedback
    public static func warning() {
        _Concurrency.Task { @MainActor in shared.warning() }
    }

    /// Static error feedback
    public static func error() {
        _Concurrency.Task { @MainActor in shared.error() }
    }

    /// Static button tap feedback
    public static func buttonTap() {
        _Concurrency.Task { @MainActor in shared.buttonTap() }
    }

    /// Static task completed feedback
    public static func taskCompleted() {
        _Concurrency.Task { @MainActor in shared.taskCompleted() }
    }
}

// MARK: - Compatibility Aliases

/// Alias for HapticManager compatibility
public typealias HapticManager = NuviaHaptics

/// Alias for HapticEngine compatibility
public typealias HapticEngine = NuviaHaptics

/// Alias for DSHaptics compatibility (Design System)
public typealias DSHaptics = NuviaHaptics
