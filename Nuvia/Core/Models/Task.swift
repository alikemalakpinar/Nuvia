import Foundation
import SwiftData
import SwiftUI

/// Görev modeli
@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// Görev bilgileri
    var title: String
    var taskDescription: String?

    /// Kategori etiketi
    var category: String // nikah, mekan, foto, gelinlik, davetiye, ev, diger

    /// Öncelik
    var priority: String // low, medium, high

    /// Tarihler
    var dueDate: Date?
    var dueTime: Date?
    var completedAt: Date?

    /// Durum
    var status: String // pending, inProgress, completed

    /// Alt görevler (checklist)
    var checklistItems: [ChecklistItem]

    /// Yorumlar
    var comments: [TaskComment]

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.tasks)
    var project: WeddingProject?

    @Relationship
    var assignee: User?

    @Relationship
    var linkedVendor: Vendor?

    @Relationship
    var linkedExpense: Expense?

    @Relationship
    var linkedShoppingList: ShoppingList?

    @Relationship(deleteRule: .cascade)
    var attachments: [FileAttachment]

    // MARK: - Hesaplanan Özellikler

    var taskStatus: TaskStatus {
        get { TaskStatus(rawValue: status) ?? .pending }
        set { status = newValue.rawValue }
    }

    var taskCategory: TaskCategory {
        get { TaskCategory(rawValue: category) ?? .other }
        set { category = newValue.rawValue }
    }

    var taskPriority: TaskPriority {
        get { TaskPriority(rawValue: priority) ?? .medium }
        set { priority = newValue.rawValue }
    }

    var isOverdue: Bool {
        guard let dueDate = dueDate, status != TaskStatus.completed.rawValue else { return false }
        return dueDate < Date()
    }

    var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day
    }

    var checklistProgress: Double {
        guard !checklistItems.isEmpty else { return 0 }
        let completed = checklistItems.filter { $0.isCompleted }.count
        return Double(completed) / Double(checklistItems.count)
    }

    // MARK: - Init

    init(
        title: String,
        description: String? = nil,
        category: TaskCategory = .other,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.title = title
        self.taskDescription = description
        self.category = category.rawValue
        self.priority = priority.rawValue
        self.dueDate = dueDate
        self.status = TaskStatus.pending.rawValue
        self.checklistItems = []
        self.comments = []
        self.attachments = []
    }

    // MARK: - Methods

    func complete() {
        status = TaskStatus.completed.rawValue
        completedAt = Date()
        updatedAt = Date()
    }

    func addChecklistItem(_ text: String) {
        let item = ChecklistItem(text: text)
        checklistItems.append(item)
        updatedAt = Date()
    }

    func addComment(_ text: String, by user: User) {
        let comment = TaskComment(text: text, authorId: user.id, authorName: user.name)
        comments.append(comment)
        updatedAt = Date()
    }
}

// MARK: - Görev Durumu

enum TaskStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case inProgress = "inProgress"
    case completed = "completed"

    var displayName: String {
        switch self {
        case .pending: return "Yapılacak"
        case .inProgress: return "Devam Ediyor"
        case .completed: return "Tamamlandı"
        }
    }

    var icon: String {
        switch self {
        case .pending: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .pending: return .statusPending
        case .inProgress: return .statusInProgress
        case .completed: return .statusCompleted
        }
    }
}

// MARK: - Görev Kategorisi

enum TaskCategory: String, CaseIterable, Codable {
    case venue = "mekan"
    case ceremony = "nikah"
    case photo = "foto"
    case music = "muzik"
    case dress = "gelinlik"
    case flowers = "cicek"
    case invitation = "davetiye"
    case catering = "yemek"
    case decor = "dekor"
    case home = "ev"
    case other = "diger"

    var displayName: String {
        switch self {
        case .venue: return "Mekan"
        case .ceremony: return "Nikah"
        case .photo: return "Fotoğraf/Video"
        case .music: return "Müzik"
        case .dress: return "Gelinlik/Damatlık"
        case .flowers: return "Çiçek"
        case .invitation: return "Davetiye"
        case .catering: return "Yemek"
        case .decor: return "Dekorasyon"
        case .home: return "Ev"
        case .other: return "Diğer"
        }
    }

    var icon: String {
        switch self {
        case .venue: return "building.2.fill"
        case .ceremony: return "heart.fill"
        case .photo: return "camera.fill"
        case .music: return "music.note"
        case .dress: return "tshirt.fill"
        case .flowers: return "leaf.fill"
        case .invitation: return "envelope.fill"
        case .catering: return "fork.knife"
        case .decor: return "sparkles"
        case .home: return "house.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }

    var color: Color {
        switch self {
        case .venue: return .categoryVenue
        case .ceremony: return .nuviaGoldFallback
        case .photo: return .categoryPhoto
        case .music: return .categoryMusic
        case .dress: return .categoryDress
        case .flowers: return .categoryFlowers
        case .invitation: return .categoryInvitation
        case .catering: return .categoryFood
        case .decor: return .categoryDecor
        case .home: return .nuviaInfoStatic
        case .other: return .nuviaSecondaryTextStatic
        }
    }
}

// MARK: - Görev Önceliği

enum TaskPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    var displayName: String {
        switch self {
        case .low: return "Düşük"
        case .medium: return "Orta"
        case .high: return "Yüksek"
        }
    }

    var icon: String {
        switch self {
        case .low: return "flag"
        case .medium: return "flag.fill"
        case .high: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .low: return .priorityLow
        case .medium: return .priorityMedium
        case .high: return .priorityHigh
        }
    }
}

// MARK: - Checklist Item

struct ChecklistItem: Codable, Identifiable, Hashable {
    var id: UUID
    var text: String
    var isCompleted: Bool
    var completedAt: Date?

    init(text: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.text = text
        self.isCompleted = isCompleted
    }

    mutating func toggle() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}

// MARK: - Task Comment

struct TaskComment: Codable, Identifiable {
    var id: UUID
    var text: String
    var authorId: UUID
    var authorName: String
    var createdAt: Date

    init(text: String, authorId: UUID, authorName: String) {
        self.id = UUID()
        self.text = text
        self.authorId = authorId
        self.authorName = authorName
        self.createdAt = Date()
    }
}
