import Foundation
import SwiftData
import SwiftUI

/// Teslimat modeli
@Model
final class Delivery {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// Sipariş bilgileri
    var orderNumber: String?
    var carrierName: String?
    var trackingNumber: String?
    var trackingUrl: String?

    /// Tarihler
    var orderDate: Date?
    var estimatedDeliveryDate: Date?
    var actualDeliveryDate: Date?

    /// Kurulum randevusu
    var installationDate: Date?
    var installationNotes: String?

    /// Durum
    var status: String // ordered, shipped, outForDelivery, delivered, installed

    /// Notlar
    var notes: String?

    // MARK: - İlişkiler

    @Relationship
    var linkedItem: ShoppingItem?

    // MARK: - Hesaplanan Özellikler

    var deliveryStatus: DeliveryStatus {
        get { DeliveryStatus(rawValue: status) ?? .ordered }
        set { status = newValue.rawValue }
    }

    var isDelivered: Bool {
        deliveryStatus == .delivered || deliveryStatus == .installed
    }

    var daysUntilDelivery: Int? {
        guard let eta = estimatedDeliveryDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: eta).day
    }

    var isLate: Bool {
        guard let eta = estimatedDeliveryDate, !isDelivered else { return false }
        return eta < Date()
    }

    // MARK: - Init

    init(
        orderNumber: String? = nil,
        carrierName: String? = nil,
        estimatedDeliveryDate: Date? = nil
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.orderNumber = orderNumber
        self.carrierName = carrierName
        self.estimatedDeliveryDate = estimatedDeliveryDate
        self.status = DeliveryStatus.ordered.rawValue
    }

    // MARK: - Methods

    func markAsDelivered() {
        status = DeliveryStatus.delivered.rawValue
        actualDeliveryDate = Date()
        updatedAt = Date()
    }

    func markAsInstalled() {
        status = DeliveryStatus.installed.rawValue
        updatedAt = Date()
    }
}

// MARK: - Teslimat Durumu

enum DeliveryStatus: String, CaseIterable, Codable {
    case ordered = "ordered"
    case shipped = "shipped"
    case outForDelivery = "outForDelivery"
    case delivered = "delivered"
    case installed = "installed"

    var displayName: String {
        switch self {
        case .ordered: return "Sipariş Verildi"
        case .shipped: return "Kargoya Verildi"
        case .outForDelivery: return "Dağıtımda"
        case .delivered: return "Teslim Edildi"
        case .installed: return "Kuruldu"
        }
    }

    var icon: String {
        switch self {
        case .ordered: return "bag.fill"
        case .shipped: return "shippingbox.fill"
        case .outForDelivery: return "truck.box.fill"
        case .delivered: return "checkmark.circle.fill"
        case .installed: return "wrench.and.screwdriver.fill"
        }
    }

    var color: Color {
        switch self {
        case .ordered: return .statusPending
        case .shipped: return .nuviaInfoStatic
        case .outForDelivery: return .nuviaWarningStatic
        case .delivered: return .statusCompleted
        case .installed: return .nuviaSuccessStatic
        }
    }
}
