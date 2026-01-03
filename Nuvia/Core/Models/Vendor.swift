import Foundation
import SwiftData
import SwiftUI

/// Tedarikçi modeli
@Model
final class Vendor {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// Tedarikçi bilgileri
    var name: String
    var category: String
    var status: String // researching, selected, booked, cancelled

    /// İletişim
    var contactName: String?
    var phone: String?
    var email: String?
    var website: String?
    var instagram: String?

    /// Konum
    var address: String?
    var city: String?

    /// Fiyat
    var priceMin: Double?
    var priceMax: Double?
    var agreedPrice: Double?

    /// Notlar
    var notes: String?

    /// Değerlendirme (1-5)
    var rating: Int?

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.vendors)
    var project: WeddingProject?

    @Relationship
    var contractFile: FileAttachment?

    @Relationship(deleteRule: .cascade, inverse: \Expense.vendor)
    var payments: [Expense]

    @Relationship(inverse: \Task.linkedVendor)
    var linkedTasks: [Task]

    // MARK: - Hesaplanan Özellikler

    var vendorCategory: VendorCategory {
        get { VendorCategory(rawValue: category) ?? .other }
        set { category = newValue.rawValue }
    }

    var vendorStatus: VendorStatus {
        get { VendorStatus(rawValue: status) ?? .researching }
        set { status = newValue.rawValue }
    }

    var totalPaid: Double {
        payments.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    var remainingAmount: Double {
        guard let agreed = agreedPrice else { return 0 }
        return agreed - totalPaid
    }

    var priceRangeText: String {
        guard let min = priceMin, let max = priceMax else { return "Fiyat belirtilmedi" }
        return "\(Int(min).formatted()) - \(Int(max).formatted())"
    }

    // MARK: - Init

    init(
        name: String,
        category: VendorCategory,
        status: VendorStatus = .researching
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.name = name
        self.category = category.rawValue
        self.status = status.rawValue
        self.payments = []
        self.linkedTasks = []
    }
}

// MARK: - Tedarikçi Kategorisi

enum VendorCategory: String, CaseIterable, Codable {
    case venue = "mekan"
    case photoVideo = "foto_video"
    case music = "muzik"
    case flowers = "cicek"
    case invitation = "davetiye"
    case hair = "kuafor"
    case weddingDress = "gelinlik"
    case groomSuit = "damatlik"
    case cake = "pasta"
    case lighting = "isik_ses"
    case transport = "transfer"
    case catering = "yemek"
    case jewelry = "kuyumcu"
    case other = "diger"

    var displayName: String {
        switch self {
        case .venue: return "Mekan"
        case .photoVideo: return "Fotoğraf/Video"
        case .music: return "Müzik/DJ"
        case .flowers: return "Çiçek"
        case .invitation: return "Davetiye"
        case .hair: return "Kuaför"
        case .weddingDress: return "Gelinlik"
        case .groomSuit: return "Damatlık"
        case .cake: return "Pasta"
        case .lighting: return "Işık/Ses"
        case .transport: return "Transfer"
        case .catering: return "Yemek"
        case .jewelry: return "Kuyumcu"
        case .other: return "Diğer"
        }
    }

    var icon: String {
        switch self {
        case .venue: return "building.2.fill"
        case .photoVideo: return "camera.fill"
        case .music: return "music.note"
        case .flowers: return "leaf.fill"
        case .invitation: return "envelope.fill"
        case .hair: return "scissors"
        case .weddingDress: return "figure.stand.dress"
        case .groomSuit: return "figure.stand"
        case .cake: return "birthday.cake.fill"
        case .lighting: return "lightbulb.fill"
        case .transport: return "car.fill"
        case .catering: return "fork.knife"
        case .jewelry: return "diamond.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .venue: return .categoryVenue
        case .photoVideo: return .categoryPhoto
        case .music: return .categoryMusic
        case .flowers: return .categoryFlowers
        case .invitation: return .categoryInvitation
        case .hair: return .nuviaCopper
        case .weddingDress: return .categoryDress
        case .groomSuit: return .nuviaInfo
        case .cake: return .categoryFood
        case .lighting: return .nuviaWarning
        case .transport: return .nuviaSecondaryText
        case .catering: return .categoryFood
        case .jewelry: return .nuviaGoldFallback
        case .other: return .nuviaTertiaryText
        }
    }
}

// MARK: - Tedarikçi Durumu

enum VendorStatus: String, CaseIterable, Codable {
    case researching = "researching"
    case contacted = "contacted"
    case meeting = "meeting"
    case selected = "selected"
    case booked = "booked"
    case cancelled = "cancelled"

    var displayName: String {
        switch self {
        case .researching: return "Araştırılıyor"
        case .contacted: return "İletişime Geçildi"
        case .meeting: return "Görüşme Planlandı"
        case .selected: return "Seçildi"
        case .booked: return "Rezerve Edildi"
        case .cancelled: return "İptal"
        }
    }

    var icon: String {
        switch self {
        case .researching: return "magnifyingglass"
        case .contacted: return "phone.fill"
        case .meeting: return "calendar"
        case .selected: return "checkmark"
        case .booked: return "checkmark.seal.fill"
        case .cancelled: return "xmark"
        }
    }

    var color: Color {
        switch self {
        case .researching: return .statusPending
        case .contacted: return .nuviaInfo
        case .meeting: return .nuviaWarning
        case .selected: return .statusInProgress
        case .booked: return .statusCompleted
        case .cancelled: return .statusCancelled
        }
    }
}
