import Foundation
import SwiftData
import SwiftUI

/// Bildirim kuralı modeli
@Model
final class NotificationRule {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    /// Kural bilgileri
    var triggerType: String // task, payment, rsvp, delivery, warranty, weddingDay
    var title: String
    var body: String?

    /// Tetikleme zamanları (gün olarak offset)
    var offsets: [Int] // örn: [7, 1, 0] = 7 gün önce, 1 gün önce, aynı gün

    /// Aktif mi?
    var isEnabled: Bool

    /// Son tetikleme
    var lastTriggeredAt: Date?

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.notificationRules)
    var project: WeddingProject?

    // MARK: - Hesaplanan Özellikler

    var notificationType: NotificationTriggerType {
        get { NotificationTriggerType(rawValue: triggerType) ?? .task }
        set { triggerType = newValue.rawValue }
    }

    // MARK: - Init

    init(
        type: NotificationTriggerType,
        title: String,
        offsets: [Int] = [1, 0]
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.triggerType = type.rawValue
        self.title = title
        self.offsets = offsets
        self.isEnabled = true
    }
}

// MARK: - Bildirim Tetikleme Türü

enum NotificationTriggerType: String, CaseIterable, Codable {
    case task = "task"
    case payment = "payment"
    case rsvp = "rsvp"
    case delivery = "delivery"
    case warranty = "warranty"
    case weddingDay = "weddingDay"

    var displayName: String {
        switch self {
        case .task: return "Görev"
        case .payment: return "Ödeme"
        case .rsvp: return "RSVP"
        case .delivery: return "Teslimat"
        case .warranty: return "Garanti"
        case .weddingDay: return "Düğün Günü"
        }
    }

    var defaultOffsets: [Int] {
        switch self {
        case .task: return [1, 0]          // 1 gün önce, aynı gün
        case .payment: return [7, 1]       // 7 gün önce, 1 gün önce
        case .rsvp: return [10, 3]         // 10 gün önce, 3 gün önce
        case .delivery: return [0]         // Aynı gün
        case .warranty: return [30]        // 30 gün önce
        case .weddingDay: return [30, 7, 1, 0] // 30, 7, 1 gün önce ve aynı gün
        }
    }

    var icon: String {
        switch self {
        case .task: return "checklist"
        case .payment: return "creditcard.fill"
        case .rsvp: return "person.2.fill"
        case .delivery: return "shippingbox.fill"
        case .warranty: return "shield.fill"
        case .weddingDay: return "heart.fill"
        }
    }
}

// MARK: - Scheduled Notification

struct ScheduledNotification: Identifiable {
    let id: UUID
    let title: String
    let body: String
    let scheduledDate: Date
    let type: NotificationTriggerType
    let relatedItemId: UUID?

    var isUpcoming: Bool {
        scheduledDate > Date()
    }

    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: scheduledDate).day ?? 0
    }
}

// MARK: - Default Rules Factory

struct DefaultNotificationRules {
    static func createDefaults() -> [NotificationRule] {
        return [
            NotificationRule(
                type: .task,
                title: "Görev Hatırlatma",
                offsets: [1, 0]
            ),
            NotificationRule(
                type: .payment,
                title: "Ödeme Hatırlatma",
                offsets: [7, 1]
            ),
            NotificationRule(
                type: .rsvp,
                title: "RSVP Kapanış Hatırlatma",
                offsets: [10, 3]
            ),
            NotificationRule(
                type: .delivery,
                title: "Teslimat Bildirimi",
                offsets: [0]
            ),
            NotificationRule(
                type: .warranty,
                title: "Garanti Süresi Uyarısı",
                offsets: [30]
            ),
            NotificationRule(
                type: .weddingDay,
                title: "Düğün Geri Sayımı",
                offsets: [30, 7, 1, 0]
            )
        ]
    }
}
