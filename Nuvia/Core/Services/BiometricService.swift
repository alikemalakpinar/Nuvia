import Foundation
import LocalAuthentication
import SwiftUI

/// Biyometrik (FaceID/TouchID) kimlik doğrulama servisi
/// Dosya kasası ve hassas veriler için
@MainActor
class BiometricService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var biometricType: BiometricType = .none
    @Published var error: String?

    enum BiometricType {
        case none
        case faceID
        case touchID

        var displayName: String {
            switch self {
            case .none: return "Yok"
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            }
        }

        var icon: String {
            switch self {
            case .none: return "lock.fill"
            case .faceID: return "faceid"
            case .touchID: return "touchid"
            }
        }
    }

    init() {
        checkBiometricType()
    }

    func checkBiometricType() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
            case .touchID:
                biometricType = .touchID
            default:
                biometricType = .none
            }
        } else {
            biometricType = .none
        }
    }

    func authenticate(reason: String = "Dosya kasanıza erişmek için kimliğinizi doğrulayın") async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "İptal"
        context.localizedFallbackTitle = "Şifre Kullan"

        var authError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            await MainActor.run {
                error = authError?.localizedDescription ?? "Biyometrik kimlik doğrulama kullanılamıyor"
                isAuthenticated = false
            }
            return false
        }

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            await MainActor.run {
                isAuthenticated = success
                error = success ? nil : "Kimlik doğrulama başarısız"
            }
            return success
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                isAuthenticated = false
            }
            return false
        }
    }

    func deauthenticate() {
        isAuthenticated = false
    }
}

// MARK: - Haptic Feedback Manager

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // Custom patterns
    func taskCompleted() {
        notification(.success)
    }

    func error() {
        notification(.error)
    }

    func warning() {
        notification(.warning)
    }

    func buttonTap() {
        impact(.light)
    }

    func dragStart() {
        impact(.medium)
    }

    func dragEnd() {
        impact(.rigid)
    }

    func seatingDrop() {
        impact(.heavy)
    }

    func seatConflict() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred(intensity: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.impactOccurred(intensity: 0.4)
        }
    }

    func countdown() {
        impact(.soft)
    }
}

// MARK: - Sound Manager

class SoundManager {
    static let shared = SoundManager()

    private init() {}

    func playCompletionSound() {
        // System sound for task completion
        AudioServicesPlaySystemSound(1001)
    }

    func playAlertSound() {
        AudioServicesPlaySystemSound(1005)
    }
}

import AudioToolbox
