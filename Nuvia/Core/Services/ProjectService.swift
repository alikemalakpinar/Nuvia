import Foundation
import SwiftData
import SwiftUI

// MARK: - Project Provider Protocol
/// Protocol for accessing the current project - implemented by DataManager

public protocol ProjectProvider: AnyObject {
    var currentProject: WeddingProject? { get }
}

// MARK: - Project Service
/// Manages project lifecycle, tasks, shopping, journal, rooms, and files

@MainActor
public final class ProjectService: ObservableObject {
    private let modelContext: ModelContext
    private weak var projectProvider: ProjectProvider?

    init(modelContext: ModelContext, projectProvider: ProjectProvider) {
        self.modelContext = modelContext
        self.projectProvider = projectProvider
    }

    private var currentProject: WeddingProject? {
        projectProvider?.currentProject
    }

    // MARK: - Project Operations

    func updateProject(_ updates: (WeddingProject) -> Void) throws {
        guard let project = currentProject else { throw DataError.noProject }
        updates(project)
        project.updatedAt = Date()
        try modelContext.save()
    }

    // MARK: - Task Operations

    func addTask(
        title: String,
        description: String? = nil,
        category: TaskCategory = .other,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        assigneeId: UUID? = nil
    ) throws -> Task {
        guard let project = currentProject else { throw DataError.noProject }
        let task = Task(title: title, description: description, category: category, priority: priority, dueDate: dueDate)
        if let assigneeId = assigneeId {
            task.assignee = project.users.first { $0.id == assigneeId }
        }
        project.tasks.append(task)
        try modelContext.save()
        return task
    }

    func updateTask(_ task: Task, updates: (Task) -> Void) throws {
        updates(task)
        task.updatedAt = Date()
        try modelContext.save()
    }

    func completeTask(_ task: Task) throws {
        task.complete()
        try modelContext.save()
    }

    func deleteTask(_ task: Task) throws {
        guard let project = currentProject else { throw DataError.noProject }
        project.tasks.removeAll { $0.id == task.id }
        modelContext.delete(task)
        try modelContext.save()
    }

    func toggleChecklistItem(_ task: Task, itemId: UUID) throws {
        if let index = task.checklistItems.firstIndex(where: { $0.id == itemId }) {
            task.checklistItems[index].toggle()
            task.updatedAt = Date()
            try modelContext.save()
        }
    }

    func addChecklistItem(_ task: Task, text: String) throws {
        task.addChecklistItem(text)
        try modelContext.save()
    }

    func removeChecklistItem(_ task: Task, itemId: UUID) throws {
        task.checklistItems.removeAll { $0.id == itemId }
        task.updatedAt = Date()
        try modelContext.save()
    }

    // MARK: - Shopping Operations

    func addShoppingList(title: String, type: ShoppingListType, category: String? = nil) throws -> ShoppingList {
        guard let project = currentProject else { throw DataError.noProject }
        let list = ShoppingList(title: title, type: type, category: category)
        project.shoppingLists.append(list)
        try modelContext.save()
        return list
    }

    func deleteShoppingList(_ list: ShoppingList) throws {
        guard let project = currentProject else { throw DataError.noProject }
        // Delete all items in the list
        for item in list.items {
            modelContext.delete(item)
        }
        project.shoppingLists.removeAll { $0.id == list.id }
        modelContext.delete(list)
        try modelContext.save()
    }

    func addShoppingItem(
        to list: ShoppingList,
        name: String,
        quantity: Int = 1,
        estimatedPrice: Double? = nil,
        priority: TaskPriority = .medium,
        storeName: String? = nil,
        storeUrl: String? = nil
    ) throws -> ShoppingItem {
        let item = ShoppingItem(name: name, quantity: quantity, priority: priority, estimatedPrice: estimatedPrice)
        item.storeName = storeName
        item.storeUrl = storeUrl
        list.items.append(item)
        list.updatedAt = Date()
        try modelContext.save()
        return item
    }

    func markItemPurchased(_ item: ShoppingItem, actualPrice: Double? = nil) throws {
        item.markAsPurchased(actualPrice: actualPrice)
        try modelContext.save()
    }

    func deleteShoppingItem(_ item: ShoppingItem) throws {
        if let list = item.list {
            list.items.removeAll { $0.id == item.id }
            list.updatedAt = Date()
        }
        modelContext.delete(item)
        try modelContext.save()
    }

    // MARK: - Journal Operations

    func addJournalEntry(
        content: String,
        title: String? = nil,
        date: Date = Date(),
        mood: JournalMood? = nil,
        tags: [String] = []
    ) throws -> JournalEntry {
        guard let project = currentProject else { throw DataError.noProject }
        let entry = JournalEntry(content: content, date: date, mood: mood)
        entry.title = title
        for tag in tags { entry.addTag(tag) }
        project.journalEntries.append(entry)
        try modelContext.save()
        return entry
    }

    func updateJournalEntry(_ entry: JournalEntry, updates: (JournalEntry) -> Void) throws {
        updates(entry)
        entry.updatedAt = Date()
        try modelContext.save()
    }

    func deleteJournalEntry(_ entry: JournalEntry) throws {
        guard let project = currentProject else { throw DataError.noProject }
        project.journalEntries.removeAll { $0.id == entry.id }
        modelContext.delete(entry)
        try modelContext.save()
    }

    // MARK: - Room Operations

    func addRoom(name: String, type: RoomType, width: Double? = nil, length: Double? = nil) throws -> Room {
        guard let project = currentProject else { throw DataError.noProject }
        let room = Room(name: name, type: type)
        room.width = width
        room.length = length
        project.rooms.append(room)
        try modelContext.save()
        return room
    }

    func updateRoom(_ room: Room, updates: (Room) -> Void) throws {
        updates(room)
        room.updatedAt = Date()
        try modelContext.save()
    }

    func deleteRoom(_ room: Room) throws {
        guard let project = currentProject else { throw DataError.noProject }
        // Delete all inventory items in the room
        for item in room.inventoryItems {
            modelContext.delete(item)
        }
        project.rooms.removeAll { $0.id == room.id }
        modelContext.delete(room)
        try modelContext.save()
    }

    func addInventoryItem(
        to room: Room,
        name: String,
        brand: String? = nil,
        purchasePrice: Double? = nil,
        warrantyEndDate: Date? = nil
    ) throws -> InventoryItem {
        let item = InventoryItem(name: name, brand: brand, purchaseDate: Date(), warrantyEndDate: warrantyEndDate)
        item.purchasePrice = purchasePrice
        room.inventoryItems.append(item)
        try modelContext.save()
        return item
    }

    func deleteInventoryItem(_ item: InventoryItem) throws {
        if let room = item.room {
            room.inventoryItems.removeAll { $0.id == item.id }
        }
        modelContext.delete(item)
        try modelContext.save()
    }

    // MARK: - File Operations

    func addFileAttachment(
        fileName: String,
        type: FileAttachmentType,
        localPath: String,
        mimeType: String? = nil,
        fileSize: Int64? = nil,
        requiresFaceID: Bool = false
    ) throws -> FileAttachment {
        guard let project = currentProject else { throw DataError.noProject }
        let file = FileAttachment(fileName: fileName, type: type, mimeType: mimeType, fileSize: fileSize)
        file.localPath = localPath
        file.requiresFaceID = requiresFaceID
        file.isEncrypted = type.requiresEncryption
        project.files.append(file)
        try modelContext.save()
        return file
    }

    func deleteFileAttachment(_ file: FileAttachment) throws {
        guard let project = currentProject else { throw DataError.noProject }
        // TODO: Delete actual file from disk
        project.files.removeAll { $0.id == file.id }
        modelContext.delete(file)
        try modelContext.save()
    }

    // MARK: - Task Analytics

    func getTasksThisWeek() -> [Task] {
        guard let project = currentProject else { return [] }
        let calendar = Calendar.current
        let now = Date()
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: now)!

        return project.tasks.filter { task in
            guard let due = task.dueDate, task.status != TaskStatus.completed.rawValue else { return false }
            return due >= now && due <= weekEnd
        }.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    func getOverdueTasks() -> [Task] {
        guard let project = currentProject else { return [] }
        return project.tasks.filter { $0.isOverdue }.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    func getTasksByCategory() -> [TaskCategory: [Task]] {
        guard let project = currentProject else { return [:] }
        return Dictionary(grouping: project.tasks, by: { $0.taskCategory })
    }

    func getTasksByPriority() -> [TaskPriority: [Task]] {
        guard let project = currentProject else { return [:] }
        return Dictionary(grouping: project.tasks, by: { $0.taskPriority })
    }

    func getTaskCompletionRate() -> Double {
        guard let project = currentProject, !project.tasks.isEmpty else { return 0 }
        let completed = project.tasks.filter { $0.status == TaskStatus.completed.rawValue }.count
        return Double(completed) / Double(project.tasks.count)
    }

    // MARK: - Weekly Brief

    func getWeeklyBrief(budgetService: BudgetService, guestService: GuestService) -> WeeklyBrief {
        guard let project = currentProject else {
            return WeeklyBrief(tasksThisWeek: [], paymentsThisWeek: [], pendingRSVPCount: 0, upcomingDeliveries: [], overdueTasks: [])
        }

        let tasksThisWeek = getTasksThisWeek()
        let paymentsThisWeek = budgetService.getUpcomingPayments(days: 7)
        let pendingRSVP = project.guests.filter { $0.rsvp == .pending }.count
        let overdueTasks = getOverdueTasks()

        return WeeklyBrief(
            tasksThisWeek: tasksThisWeek,
            paymentsThisWeek: paymentsThisWeek,
            pendingRSVPCount: pendingRSVP,
            upcomingDeliveries: [],
            overdueTasks: overdueTasks
        )
    }
}
