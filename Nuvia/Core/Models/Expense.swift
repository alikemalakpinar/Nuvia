import Foundation
import SwiftData
import SwiftUI

/// Harcama/Ödeme modeli
@Model
final class Expense {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// Harcama bilgileri
    var title: String
    var category: String
    var amount: Double
    var date: Date

    /// Ödeme tipi
    var paymentType: String // cash, card, transfer

    /// Ödeme durumu
    var isPaid: Bool
    var paidAt: Date?

    /// Taksit bilgileri
    var isInstallment: Bool
    var installmentCount: Int?
    var installmentNumber: Int? // Kaçıncı taksit

    /// Peşinat/kalan
    var isDeposit: Bool
    var depositNote: String?

    /// Notlar
    var notes: String?

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.expenses)
    var project: WeddingProject?

    @Relationship
    var vendor: Vendor?

    @Relationship
    var receipt: FileAttachment?

    @Relationship(inverse: \Task.linkedExpense)
    var linkedTask: Task?

    // MARK: - Hesaplanan Özellikler

    var expenseCategory: ExpenseCategory {
        get { ExpenseCategory(rawValue: category) ?? .other }
        set { category = newValue.rawValue }
    }

    var expensePaymentType: PaymentType {
        get { PaymentType(rawValue: paymentType) ?? .cash }
        set { paymentType = newValue.rawValue }
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = project?.currency == "TRY" ? "₺" :
                                    project?.currency == "EUR" ? "€" :
                                    project?.currency == "GBP" ? "£" : "$"
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    var isOverdue: Bool {
        !isPaid && date < Date()
    }

    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }

    // MARK: - Init

    init(
        title: String,
        category: ExpenseCategory,
        amount: Double,
        date: Date = Date(),
        paymentType: PaymentType = .cash,
        isPaid: Bool = false
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.title = title
        self.category = category.rawValue
        self.amount = amount
        self.date = date
        self.paymentType = paymentType.rawValue
        self.isPaid = isPaid
        self.isInstallment = false
        self.isDeposit = false
    }

    // MARK: - Methods

    func markAsPaid() {
        isPaid = true
        paidAt = Date()
        updatedAt = Date()
    }
}

// MARK: - Harcama Kategorisi

enum ExpenseCategory: String, CaseIterable, Codable {
    case venue = "mekan"
    case catering = "yemek"
    case photoVideo = "foto_video"
    case music = "muzik"
    case flowers = "cicek"
    case dress = "kiyafet"
    case invitation = "davetiye"
    case decor = "dekor"
    case jewelry = "taki"
    case hair = "kuafor"
    case transport = "ulasim"
    case honeymoon = "balay"
    case home = "ev"
    case other = "diger"

    var displayName: String {
        switch self {
        case .venue: return "Mekan"
        case .catering: return "Yemek/İkram"
        case .photoVideo: return "Fotoğraf/Video"
        case .music: return "Müzik/DJ"
        case .flowers: return "Çiçek"
        case .dress: return "Gelinlik/Damatlık"
        case .invitation: return "Davetiye"
        case .decor: return "Dekorasyon"
        case .jewelry: return "Takı/Altın"
        case .hair: return "Kuaför/Makyaj"
        case .transport: return "Ulaşım"
        case .honeymoon: return "Balayı"
        case .home: return "Ev Eşyası"
        case .other: return "Diğer"
        }
    }

    var icon: String {
        switch self {
        case .venue: return "building.2.fill"
        case .catering: return "fork.knife"
        case .photoVideo: return "camera.fill"
        case .music: return "music.note"
        case .flowers: return "leaf.fill"
        case .dress: return "tshirt.fill"
        case .invitation: return "envelope.fill"
        case .decor: return "sparkles"
        case .jewelry: return "diamond.fill"
        case .hair: return "scissors"
        case .transport: return "car.fill"
        case .honeymoon: return "airplane"
        case .home: return "house.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .venue: return .categoryVenue
        case .catering: return .categoryFood
        case .photoVideo: return .categoryPhoto
        case .music: return .categoryMusic
        case .flowers: return .categoryFlowers
        case .dress: return .categoryDress
        case .invitation: return .categoryInvitation
        case .decor: return .categoryDecor
        case .jewelry: return .nuviaGoldFallback
        case .hair: return .nuviaCopper
        case .transport: return .nuviaSecondaryText
        case .honeymoon: return .nuviaInfo
        case .home: return .nuviaSuccess
        case .other: return .nuviaTertiaryText
        }
    }
}

// MARK: - Ödeme Tipi

enum PaymentType: String, CaseIterable, Codable {
    case cash = "cash"
    case card = "card"
    case transfer = "transfer"
    case check = "check"

    var displayName: String {
        switch self {
        case .cash: return "Nakit"
        case .card: return "Kredi Kartı"
        case .transfer: return "Havale/EFT"
        case .check: return "Çek"
        }
    }

    var icon: String {
        switch self {
        case .cash: return "banknote.fill"
        case .card: return "creditcard.fill"
        case .transfer: return "arrow.left.arrow.right"
        case .check: return "doc.text.fill"
        }
    }
}

// MARK: - Budget Summary

struct BudgetSummary {
    let totalBudget: Double
    let totalSpent: Double
    let totalPaid: Double
    let totalUnpaid: Double
    let byCategory: [ExpenseCategory: Double]

    var remaining: Double {
        totalBudget - totalSpent
    }

    var progress: Double {
        guard totalBudget > 0 else { return 0 }
        return totalSpent / totalBudget
    }

    var isOverBudget: Bool {
        totalSpent > totalBudget
    }

    var overBudgetAmount: Double {
        max(0, totalSpent - totalBudget)
    }
}
