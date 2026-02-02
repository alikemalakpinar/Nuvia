import Foundation
import UserNotifications
import SwiftUI

/// Bildirim yönetim servisi
@MainActor
class NotificationManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []

    private let notificationCenter = UNUserNotificationCenter.current()

    init() {
        _Concurrency.Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Scheduling

    func scheduleTaskReminder(
        taskId: UUID,
        title: String,
        body: String,
        dueDate: Date,
        daysBefore: Int = 1
    ) async {
        guard isAuthorized else { return }

        let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: dueDate) ?? dueDate

        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Görev Hatırlatması"
        content.subtitle = title
        content.body = body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskId": taskId.uuidString, "type": "task"]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "task_\(taskId.uuidString)_\(daysBefore)",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    func schedulePaymentReminder(
        expenseId: UUID,
        title: String,
        amount: Double,
        currency: String,
        dueDate: Date,
        daysBefore: Int = 7
    ) async {
        guard isAuthorized else { return }

        let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: dueDate) ?? dueDate

        guard triggerDate > Date() else { return }

        let symbol = Currency(rawValue: currency)?.symbol ?? "₺"

        let content = UNMutableNotificationContent()
        content.title = "Ödeme Hatırlatması"
        content.subtitle = title
        content.body = "\(symbol)\(Int(amount).formatted()) tutarında ödeme \(daysBefore) gün sonra"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "PAYMENT_REMINDER"
        content.userInfo = ["expenseId": expenseId.uuidString, "type": "payment"]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "payment_\(expenseId.uuidString)_\(daysBefore)",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    func scheduleWeddingCountdown(
        projectId: UUID,
        weddingDate: Date,
        partnerNames: String
    ) async {
        guard isAuthorized else { return }

        let milestones = [30, 7, 1, 0] // Days before wedding

        for days in milestones {
            let triggerDate = Calendar.current.date(byAdding: .day, value: -days, to: weddingDate) ?? weddingDate

            guard triggerDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = days == 0 ? "Düğün Günü!" : "Geri Sayım"
            content.body = days == 0
                ? "Bugün \(partnerNames)'in özel günü! Mutluluklar!"
                : "Düğüne \(days) gün kaldı!"
            content.sound = .default
            content.categoryIdentifier = "WEDDING_COUNTDOWN"
            content.userInfo = ["projectId": projectId.uuidString, "type": "countdown"]

            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
            dateComponents.hour = 9 // Morning notification
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let request = UNNotificationRequest(
                identifier: "countdown_\(projectId.uuidString)_\(days)",
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch {
                print("Failed to schedule countdown notification: \(error)")
            }
        }
    }

    func scheduleRSVPReminder(
        projectId: UUID,
        pendingCount: Int,
        deadline: Date,
        daysBefore: Int = 10
    ) async {
        guard isAuthorized, pendingCount > 0 else { return }

        let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: deadline) ?? deadline

        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "RSVP Hatırlatması"
        content.body = "\(pendingCount) davetli henüz yanıt vermedi. RSVP kapanışına \(daysBefore) gün kaldı."
        content.sound = .default
        content.categoryIdentifier = "RSVP_REMINDER"
        content.userInfo = ["projectId": projectId.uuidString, "type": "rsvp"]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "rsvp_\(projectId.uuidString)_\(daysBefore)",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule RSVP notification: \(error)")
        }
    }

    func scheduleDeliveryReminder(
        deliveryId: UUID,
        itemName: String,
        deliveryDate: Date
    ) async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Teslimat Günü"
        content.body = "\(itemName) bugün teslim edilecek!"
        content.sound = .default
        content.categoryIdentifier = "DELIVERY_REMINDER"
        content.userInfo = ["deliveryId": deliveryId.uuidString, "type": "delivery"]

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: deliveryDate)
        dateComponents.hour = 8
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: "delivery_\(deliveryId.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule delivery notification: \(error)")
        }
    }

    func scheduleWarrantyReminder(
        itemId: UUID,
        itemName: String,
        expiryDate: Date,
        daysBefore: Int = 30
    ) async {
        guard isAuthorized else { return }

        let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: expiryDate) ?? expiryDate

        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Garanti Süresi Uyarısı"
        content.body = "\(itemName) garantisi \(daysBefore) gün içinde sona erecek."
        content.sound = .default
        content.categoryIdentifier = "WARRANTY_REMINDER"
        content.userInfo = ["itemId": itemId.uuidString, "type": "warranty"]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "warranty_\(itemId.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule warranty notification: \(error)")
        }
    }

    // MARK: - Management

    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications(for projectId: UUID) {
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { request in
                    guard let info = request.content.userInfo["projectId"] as? String else { return false }
                    return info == projectId.uuidString
                }
                .map { $0.identifier }

            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    func fetchPendingNotifications() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        await MainActor.run {
            pendingNotifications = requests
        }
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Notification Categories

    func setupNotificationCategories() {
        let taskActions = [
            UNNotificationAction(identifier: "COMPLETE_TASK", title: "Tamamlandı", options: []),
            UNNotificationAction(identifier: "SNOOZE_TASK", title: "Ertele", options: [])
        ]

        let paymentActions = [
            UNNotificationAction(identifier: "MARK_PAID", title: "Ödendi", options: []),
            UNNotificationAction(identifier: "VIEW_PAYMENT", title: "Görüntüle", options: [.foreground])
        ]

        let taskCategory = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: taskActions,
            intentIdentifiers: []
        )

        let paymentCategory = UNNotificationCategory(
            identifier: "PAYMENT_REMINDER",
            actions: paymentActions,
            intentIdentifiers: []
        )

        let countdownCategory = UNNotificationCategory(
            identifier: "WEDDING_COUNTDOWN",
            actions: [],
            intentIdentifiers: []
        )

        let rsvpCategory = UNNotificationCategory(
            identifier: "RSVP_REMINDER",
            actions: [],
            intentIdentifiers: []
        )

        let deliveryCategory = UNNotificationCategory(
            identifier: "DELIVERY_REMINDER",
            actions: [],
            intentIdentifiers: []
        )

        let warrantyCategory = UNNotificationCategory(
            identifier: "WARRANTY_REMINDER",
            actions: [],
            intentIdentifiers: []
        )

        notificationCenter.setNotificationCategories([
            taskCategory,
            paymentCategory,
            countdownCategory,
            rsvpCategory,
            deliveryCategory,
            warrantyCategory
        ])
    }
}
