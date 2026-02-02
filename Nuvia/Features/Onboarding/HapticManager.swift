import UIKit

/// Centralized haptic feedback manager for consistent tactile responses throughout the app
final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Selection Feedback
    
    /// Provides light feedback for selection changes (e.g., tapping buttons, selecting items)
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Notification Feedback
    
    /// Provides success notification feedback
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Provides warning notification feedback
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Provides error notification feedback
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Impact Feedback
    
    /// Provides light impact feedback
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Provides medium impact feedback
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Provides heavy impact feedback
    func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Provides soft impact feedback (iOS 13+)
    func softImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    /// Provides rigid impact feedback (iOS 13+)
    func rigidImpact() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
}
