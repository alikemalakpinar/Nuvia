import Foundation
import SwiftData
import SwiftUI

/// Alışveriş Listesi modeli
@Model
final class ShoppingList {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// Liste bilgileri
    var title: String
    var listType: String // wedding, home
    var category: String?
    var notes: String?

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.shoppingLists)
    var project: WeddingProject?

    @Relationship(deleteRule: .cascade, inverse: \ShoppingItem.list)
    var items: [ShoppingItem]

    @Relationship(inverse: \Task.linkedShoppingList)
    var linkedTask: Task?

    // MARK: - Hesaplanan Özellikler

    var shoppingListType: ShoppingListType {
        get { ShoppingListType(rawValue: listType) ?? .wedding }
        set { listType = newValue.rawValue }
    }

    var totalItems: Int {
        items.count
    }

    var completedItems: Int {
        items.filter { $0.itemStatus == .purchased }.count
    }

    var progress: Double {
        guard totalItems > 0 else { return 0 }
        return Double(completedItems) / Double(totalItems)
    }

    var estimatedTotal: Double {
        items.reduce(0) { $0 + ($1.estimatedPrice ?? 0) * Double($1.quantity) }
    }

    var actualTotal: Double {
        items.reduce(0) { $0 + ($1.actualPrice ?? 0) * Double($1.quantity) }
    }

    var pendingItems: [ShoppingItem] {
        items.filter { $0.itemStatus == .toBuy }
    }

    // MARK: - Init

    init(title: String, type: ShoppingListType, category: String? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.title = title
        self.listType = type.rawValue
        self.category = category
        self.items = []
    }
}

/// Alışveriş Ürünü modeli
@Model
final class ShoppingItem {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// Ürün bilgileri
    var name: String
    var quantity: Int
    var unit: String? // adet, kg, lt, paket

    /// Öncelik
    var priority: String // low, medium, high

    /// Fiyat
    var estimatedPrice: Double?
    var actualPrice: Double?

    /// Nereden alınacak
    var storeName: String?
    var storeUrl: String?

    /// Barkod (opsiyonel)
    var barcode: String?

    /// Durum
    var status: String // toBuy, inCart, purchased, returned

    /// Notlar
    var notes: String?

    // MARK: - İlişkiler

    @Relationship
    var list: ShoppingList?

    @Relationship
    var assignee: User?

    @Relationship(deleteRule: .cascade, inverse: \Delivery.linkedItem)
    var delivery: Delivery?

    // MARK: - Hesaplanan Özellikler

    var itemPriority: TaskPriority {
        get { TaskPriority(rawValue: priority) ?? .medium }
        set { priority = newValue.rawValue }
    }

    var itemStatus: ShoppingItemStatus {
        get { ShoppingItemStatus(rawValue: status) ?? .toBuy }
        set { status = newValue.rawValue }
    }

    var totalEstimatedPrice: Double {
        (estimatedPrice ?? 0) * Double(quantity)
    }

    var totalActualPrice: Double {
        (actualPrice ?? 0) * Double(quantity)
    }

    var priceDifference: Double {
        totalActualPrice - totalEstimatedPrice
    }

    // MARK: - Init

    init(
        name: String,
        quantity: Int = 1,
        priority: TaskPriority = .medium,
        estimatedPrice: Double? = nil
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.name = name
        self.quantity = quantity
        self.priority = priority.rawValue
        self.estimatedPrice = estimatedPrice
        self.status = ShoppingItemStatus.toBuy.rawValue
    }

    // MARK: - Methods

    func markAsPurchased(actualPrice: Double? = nil) {
        status = ShoppingItemStatus.purchased.rawValue
        if let price = actualPrice {
            self.actualPrice = price
        }
        updatedAt = Date()
    }
}

// MARK: - Liste Tipi

enum ShoppingListType: String, CaseIterable, Codable {
    case wedding = "wedding"
    case home = "home"

    var displayName: String {
        switch self {
        case .wedding: return "Düğün"
        case .home: return "Ev"
        }
    }

    var icon: String {
        switch self {
        case .wedding: return "heart.fill"
        case .home: return "house.fill"
        }
    }

    var color: Color {
        switch self {
        case .wedding: return .nuviaGoldFallback
        case .home: return .nuviaInfoStatic
        }
    }
}

// MARK: - Ürün Durumu

enum ShoppingItemStatus: String, CaseIterable, Codable {
    case toBuy = "toBuy"
    case inCart = "inCart"
    case purchased = "purchased"
    case returned = "returned"

    var displayName: String {
        switch self {
        case .toBuy: return "Alınacak"
        case .inCart: return "Sepette"
        case .purchased: return "Alındı"
        case .returned: return "İade"
        }
    }

    var icon: String {
        switch self {
        case .toBuy: return "cart"
        case .inCart: return "cart.fill"
        case .purchased: return "checkmark.circle.fill"
        case .returned: return "arrow.uturn.left"
        }
    }

    var color: Color {
        switch self {
        case .toBuy: return .statusPending
        case .inCart: return .nuviaWarningStatic
        case .purchased: return .statusCompleted
        case .returned: return .nuviaErrorStatic
        }
    }
}

// MARK: - Yaygın Liste Kategorileri

enum WeddingListCategory: String, CaseIterable {
    case dressAccessories = "Gelinlik Aksesuarları"
    case engagementBohca = "Nişan/Bohça"
    case civilDocuments = "Nikah Evrakları"
    case gifts = "Hediyelik"
    case tableDecor = "Masa Süsleri"

    var icon: String {
        switch self {
        case .dressAccessories: return "sparkles"
        case .engagementBohca: return "gift.fill"
        case .civilDocuments: return "doc.text.fill"
        case .gifts: return "giftcard.fill"
        case .tableDecor: return "sparkle"
        }
    }
}

enum HomeListCategory: String, CaseIterable {
    case kitchen = "Mutfak"
    case bathroom = "Banyo"
    case bedroom = "Yatak Odası"
    case livingRoom = "Salon"
    case electronics = "Elektronik"
    case cleaning = "Temizlik"

    var icon: String {
        switch self {
        case .kitchen: return "fork.knife"
        case .bathroom: return "shower.fill"
        case .bedroom: return "bed.double.fill"
        case .livingRoom: return "sofa.fill"
        case .electronics: return "tv.fill"
        case .cleaning: return "bubbles.and.sparkles.fill"
        }
    }
}
