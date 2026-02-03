import Foundation
import SwiftData

/// Ana düğün projesi modeli
@Model
final class WeddingProject {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Temel Bilgiler

    /// Çift adları
    var partnerName1: String
    var partnerName2: String

    /// Düğün tarihi ve saati
    var weddingDate: Date
    var weddingTime: Date?

    /// Mekan bilgileri
    var venueName: String?
    var venueAddress: String?
    var venueCity: String?
    var venueLatitude: Double?
    var venueLongitude: Double?

    /// Para birimi
    var currency: String // TRY, EUR, GBP, USD

    /// Tema seçimi
    var theme: String // minimal, floral, modern, luxury

    /// Uygulama modu
    var appMode: String // wedding, weddingHome, organizer

    /// Çocuk davetli toggle
    var allowChildren: Bool

    // MARK: - Bütçe

    var totalBudget: Double
    var spentAmount: Double

    // MARK: - İlişkiler

    @Relationship(deleteRule: .cascade)
    var users: [User]

    @Relationship(deleteRule: .cascade)
    var tasks: [Task]

    @Relationship(deleteRule: .cascade)
    var vendors: [Vendor]

    @Relationship(deleteRule: .cascade)
    var expenses: [Expense]

    @Relationship(deleteRule: .cascade)
    var guests: [Guest]

    @Relationship(deleteRule: .cascade)
    var tables: [SeatingTable]

    @Relationship(deleteRule: .cascade)
    var shoppingLists: [ShoppingList]

    @Relationship(deleteRule: .cascade)
    var journalEntries: [JournalEntry]

    @Relationship(deleteRule: .cascade)
    var files: [FileAttachment]

    @Relationship(deleteRule: .cascade)
    var notificationRules: [NotificationRule]

    @Relationship(deleteRule: .cascade)
    var rooms: [Room]

    // MARK: - Hesaplanan Özellikler

    var daysUntilWedding: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: weddingDate).day ?? 0
    }

    var remainingBudget: Double {
        totalBudget - spentAmount
    }

    var budgetProgress: Double {
        guard totalBudget > 0 else { return 0 }
        return spentAmount / totalBudget
    }

    var totalGuests: Int {
        guests.reduce(0) { $0 + 1 + ($1.plusOneCount) }
    }

    var confirmedGuests: Int {
        guests.filter { $0.rsvp == .attending }.reduce(0) { $0 + 1 + ($1.plusOneCount) }
    }

    var completedTasksCount: Int {
        tasks.filter { $0.taskStatus == .completed }.count
    }

    var pendingTasksCount: Int {
        tasks.filter { $0.taskStatus != .completed }.count
    }

    // MARK: - Init

    init(
        partnerName1: String,
        partnerName2: String,
        weddingDate: Date,
        currency: String = "TRY",
        theme: String = "minimal",
        appMode: String = "wedding",
        allowChildren: Bool = false,
        totalBudget: Double = 0
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.partnerName1 = partnerName1
        self.partnerName2 = partnerName2
        self.weddingDate = weddingDate
        self.currency = currency
        self.theme = theme
        self.appMode = appMode
        self.allowChildren = allowChildren
        self.totalBudget = totalBudget
        self.spentAmount = 0
        self.users = []
        self.tasks = []
        self.vendors = []
        self.expenses = []
        self.guests = []
        self.tables = []
        self.shoppingLists = []
        self.journalEntries = []
        self.files = []
        self.notificationRules = []
        self.rooms = []
    }
}

// MARK: - Tema Enum

enum ProjectTheme: String, CaseIterable, Codable {
    case minimal = "minimal"
    case floral = "floral"
    case modern = "modern"
    case luxury = "luxury"

    var displayName: String {
        switch self {
        case .minimal: return "Minimal"
        case .floral: return "Çiçekli"
        case .modern: return "Modern"
        case .luxury: return "Lüks"
        }
    }

    var iconName: String {
        switch self {
        case .minimal: return "square.grid.2x2"
        case .floral: return "leaf.fill"
        case .modern: return "diamond.fill"
        case .luxury: return "crown.fill"
        }
    }
}

// MARK: - Para Birimi Enum

enum Currency: String, CaseIterable, Codable {
    case TRY = "TRY"
    case EUR = "EUR"
    case GBP = "GBP"
    case USD = "USD"

    var symbol: String {
        switch self {
        case .TRY: return "₺"
        case .EUR: return "€"
        case .GBP: return "£"
        case .USD: return "$"
        }
    }

    var displayName: String {
        switch self {
        case .TRY: return "Türk Lirası (₺)"
        case .EUR: return "Euro (€)"
        case .GBP: return "İngiliz Sterlini (£)"
        case .USD: return "Amerikan Doları ($)"
        }
    }
}
