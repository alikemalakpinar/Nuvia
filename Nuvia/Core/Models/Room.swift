import Foundation
import SwiftData
import SwiftUI

/// Oda modeli (Ev Planlama için)
@Model
final class Room {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// Oda bilgileri
    var name: String
    var roomType: String
    var notes: String?

    /// Ölçüler (metre cinsinden)
    var width: Double?
    var length: Double?
    var height: Double?

    /// Kurulum durumu
    var setupProgress: Double // 0.0 - 1.0

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.rooms)
    var project: WeddingProject?

    @Relationship(deleteRule: .cascade, inverse: \InventoryItem.room)
    var inventoryItems: [InventoryItem]

    @Relationship
    var shoppingList: ShoppingList?

    // MARK: - Hesaplanan Özellikler

    var roomCategory: RoomType {
        get { RoomType(rawValue: roomType) ?? .other }
        set { roomType = newValue.rawValue }
    }

    var area: Double? {
        guard let w = width, let l = length else { return nil }
        return w * l
    }

    var formattedArea: String {
        guard let a = area else { return "Belirtilmedi" }
        return String(format: "%.1f m²", a)
    }

    var totalItemCount: Int {
        inventoryItems.count
    }

    var pendingItemCount: Int {
        inventoryItems.filter { !$0.isDelivered }.count
    }

    // MARK: - Init

    init(name: String, type: RoomType) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.name = name
        self.roomType = type.rawValue
        self.setupProgress = 0
        self.inventoryItems = []
    }
}

/// Demirbaş/Envanter öğesi modeli
@Model
final class InventoryItem {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    /// Ürün bilgileri
    var name: String
    var brand: String?
    var model: String?
    var serialNumber: String?

    /// Satın alma bilgileri
    var purchaseDate: Date?
    var purchasePrice: Double?
    var storeName: String?

    /// Garanti
    var warrantyEndDate: Date?
    var warrantyNotes: String?

    /// Teslimat durumu
    var isDelivered: Bool
    var isInstalled: Bool

    /// Notlar
    var notes: String?

    // MARK: - İlişkiler

    @Relationship
    var room: Room?

    @Relationship
    var receipt: FileAttachment?

    @Relationship
    var warrantyDocument: FileAttachment?

    // MARK: - Hesaplanan Özellikler

    var isWarrantyExpiring: Bool {
        guard let endDate = warrantyEndDate else { return false }
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return daysUntil <= 30 && daysUntil >= 0
    }

    var isWarrantyExpired: Bool {
        guard let endDate = warrantyEndDate else { return false }
        return endDate < Date()
    }

    var warrantyDaysRemaining: Int? {
        guard let endDate = warrantyEndDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: endDate).day
    }

    var formattedWarrantyStatus: String {
        guard let days = warrantyDaysRemaining else { return "Garanti yok" }
        if days < 0 {
            return "Garanti bitti"
        } else if days == 0 {
            return "Bugün bitiyor"
        } else if days <= 30 {
            return "\(days) gün kaldı"
        } else {
            let months = days / 30
            return "\(months) ay kaldı"
        }
    }

    // MARK: - Init

    init(
        name: String,
        brand: String? = nil,
        purchaseDate: Date? = nil,
        warrantyEndDate: Date? = nil
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.name = name
        self.brand = brand
        self.purchaseDate = purchaseDate
        self.warrantyEndDate = warrantyEndDate
        self.isDelivered = false
        self.isInstalled = false
    }

    // MARK: - Methods

    func markAsDelivered() {
        isDelivered = true
    }

    func markAsInstalled() {
        isInstalled = true
    }
}

// MARK: - Oda Tipi

enum RoomType: String, CaseIterable, Codable {
    case kitchen = "kitchen"
    case bathroom = "bathroom"
    case bedroom = "bedroom"
    case livingRoom = "livingRoom"
    case diningRoom = "diningRoom"
    case office = "office"
    case laundry = "laundry"
    case balcony = "balcony"
    case entrance = "entrance"
    case storage = "storage"
    case other = "other"

    var displayName: String {
        switch self {
        case .kitchen: return "Mutfak"
        case .bathroom: return "Banyo"
        case .bedroom: return "Yatak Odası"
        case .livingRoom: return "Salon"
        case .diningRoom: return "Yemek Odası"
        case .office: return "Çalışma Odası"
        case .laundry: return "Çamaşır Odası"
        case .balcony: return "Balkon"
        case .entrance: return "Antre"
        case .storage: return "Depo"
        case .other: return "Diğer"
        }
    }

    var icon: String {
        switch self {
        case .kitchen: return "fork.knife"
        case .bathroom: return "shower.fill"
        case .bedroom: return "bed.double.fill"
        case .livingRoom: return "sofa.fill"
        case .diningRoom: return "table.furniture.fill"
        case .office: return "desktopcomputer"
        case .laundry: return "washer.fill"
        case .balcony: return "sun.max.fill"
        case .entrance: return "door.left.hand.open"
        case .storage: return "archivebox.fill"
        case .other: return "square.dashed"
        }
    }

    var color: Color {
        switch self {
        case .kitchen: return .categoryFood
        case .bathroom: return .nuviaInfo
        case .bedroom: return .categoryDress
        case .livingRoom: return .nuviaGoldFallback
        case .diningRoom: return .categoryDecor
        case .office: return .nuviaSecondaryText
        case .laundry: return .categoryFlowers
        case .balcony: return .nuviaWarning
        case .entrance: return .nuviaCopper
        case .storage: return .nuviaTertiaryText
        case .other: return .nuviaTertiaryText
        }
    }
}
