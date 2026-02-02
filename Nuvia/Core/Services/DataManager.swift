import Foundation
import SwiftData
import SwiftUI

/// Merkezi veri yönetim servisi
/// Tüm CRUD operasyonları, iş mantığı ve veri bütünlüğü kontrollerini yönetir
@MainActor
class DataManager: ObservableObject {
    private let modelContext: ModelContext

    @Published var currentProject: WeddingProject?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Project Operations

    func loadProject(id: String) {
        let descriptor = FetchDescriptor<WeddingProject>(
            predicate: #Predicate { $0.id.uuidString == id }
        )
        currentProject = try? modelContext.fetch(descriptor).first
    }

    func updateProject(_ updates: (WeddingProject) -> Void) throws {
        guard let project = currentProject else { throw DataError.noProject }
        updates(project)
        project.updatedAt = Date()
        try modelContext.save()
    }

    func deleteProject() throws {
        guard let project = currentProject else { throw DataError.noProject }
        modelContext.delete(project)
        try modelContext.save()
        currentProject = nil
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

    // MARK: - Vendor Operations

    func addVendor(
        name: String,
        category: VendorCategory,
        contactName: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        priceMin: Double? = nil,
        priceMax: Double? = nil
    ) throws -> Vendor {
        guard let project = currentProject else { throw DataError.noProject }
        let vendor = Vendor(name: name, category: category)
        vendor.contactName = contactName
        vendor.phone = phone
        vendor.email = email
        vendor.priceMin = priceMin
        vendor.priceMax = priceMax
        project.vendors.append(vendor)
        try modelContext.save()
        return vendor
    }

    func updateVendor(_ vendor: Vendor, updates: (Vendor) -> Void) throws {
        updates(vendor)
        vendor.updatedAt = Date()
        try modelContext.save()
    }

    func deleteVendor(_ vendor: Vendor) throws {
        guard let project = currentProject else { throw DataError.noProject }
        project.vendors.removeAll { $0.id == vendor.id }
        modelContext.delete(vendor)
        try modelContext.save()
    }

    // MARK: - Expense Operations

    func addExpense(
        title: String,
        category: ExpenseCategory,
        amount: Double,
        date: Date = Date(),
        paymentType: PaymentType = .card,
        isPaid: Bool = false,
        vendorId: UUID? = nil
    ) throws -> Expense {
        guard let project = currentProject else { throw DataError.noProject }
        let expense = Expense(title: title, category: category, amount: amount, date: date, paymentType: paymentType, isPaid: isPaid)
        if let vendorId = vendorId {
            expense.vendor = project.vendors.first { $0.id == vendorId }
        }
        project.expenses.append(expense)
        project.spentAmount += amount
        try modelContext.save()
        return expense
    }

    func markExpenseAsPaid(_ expense: Expense) throws {
        expense.markAsPaid()
        try modelContext.save()
    }

    func deleteExpense(_ expense: Expense) throws {
        guard let project = currentProject else { throw DataError.noProject }
        project.spentAmount -= expense.amount
        project.expenses.removeAll { $0.id == expense.id }
        modelContext.delete(expense)
        try modelContext.save()
    }

    func createInstallmentPlan(
        title: String,
        category: ExpenseCategory,
        totalAmount: Double,
        installmentCount: Int,
        startDate: Date,
        vendorId: UUID? = nil
    ) throws -> [Expense] {
        guard let project = currentProject else { throw DataError.noProject }
        let perInstallment = totalAmount / Double(installmentCount)
        var expenses: [Expense] = []

        for i in 0..<installmentCount {
            let date = Calendar.current.date(byAdding: .month, value: i, to: startDate)!
            let expense = Expense(
                title: "\(title) - Taksit \(i + 1)/\(installmentCount)",
                category: category,
                amount: perInstallment,
                date: date,
                paymentType: .card,
                isPaid: false
            )
            expense.isInstallment = true
            expense.installmentCount = installmentCount
            expense.installmentNumber = i + 1
            if let vendorId = vendorId {
                expense.vendor = project.vendors.first { $0.id == vendorId }
            }
            project.expenses.append(expense)
            expenses.append(expense)
        }

        project.spentAmount += totalAmount
        try modelContext.save()
        return expenses
    }

    // MARK: - Guest Operations

    func addGuest(
        firstName: String,
        lastName: String,
        group: GuestGroup = .mutual,
        plusOneCount: Int = 0,
        phone: String? = nil,
        email: String? = nil,
        tags: [String] = [],
        notes: String? = nil
    ) throws -> Guest {
        guard let project = currentProject else { throw DataError.noProject }
        let guest = Guest(firstName: firstName, lastName: lastName, group: group, plusOneCount: plusOneCount)
        guest.phone = phone
        guest.email = email
        guest.notes = notes
        for tag in tags { guest.addTag(tag) }
        project.guests.append(guest)
        try modelContext.save()
        return guest
    }

    func updateGuestRSVP(_ guest: Guest, status: RSVPStatus) throws {
        guest.updateRSVP(status)
        try modelContext.save()
    }

    func bulkUpdateRSVP(guestIds: [UUID], status: RSVPStatus) throws {
        guard let project = currentProject else { throw DataError.noProject }
        for guest in project.guests where guestIds.contains(guest.id) {
            guest.updateRSVP(status)
        }
        try modelContext.save()
    }

    func deleteGuest(_ guest: Guest) throws {
        guard let project = currentProject else { throw DataError.noProject }
        // Remove seat assignment
        if let assignment = guest.seatAssignment {
            modelContext.delete(assignment)
        }
        project.guests.removeAll { $0.id == guest.id }
        modelContext.delete(guest)
        try modelContext.save()
    }

    func addGuestConflict(guest1Id: UUID, guest2Id: UUID) throws {
        guard let project = currentProject else { throw DataError.noProject }
        guard let guest1 = project.guests.first(where: { $0.id == guest1Id }),
              let guest2 = project.guests.first(where: { $0.id == guest2Id }) else {
            throw DataError.notFound
        }
        guest1.addConflict(with: guest2Id)
        guest2.addConflict(with: guest1Id)
        try modelContext.save()
    }

    // MARK: - Seating Operations

    func addTable(
        name: String,
        tableNumber: Int,
        capacity: Int = 10,
        layoutType: TableLayoutType = .round,
        positionX: Double = 0,
        positionY: Double = 0,
        isVIP: Bool = false
    ) throws -> SeatingTable {
        guard let project = currentProject else { throw DataError.noProject }
        let table = SeatingTable(name: name, tableNumber: tableNumber, capacity: capacity, layoutType: layoutType)
        table.positionX = positionX
        table.positionY = positionY
        if isVIP { table.tags.append("VIP") }
        project.tables.append(table)
        try modelContext.save()
        return table
    }

    func assignGuestToTable(guestId: UUID, tableId: UUID, seatNumber: Int? = nil) throws {
        guard let project = currentProject else { throw DataError.noProject }
        guard let guest = project.guests.first(where: { $0.id == guestId }),
              let table = project.tables.first(where: { $0.id == tableId }) else {
            throw DataError.notFound
        }

        // Check capacity
        guard table.canSeat(guest: guest) else {
            throw DataError.capacityExceeded
        }

        // Check conflicts
        if let conflict = table.hasConflict(with: guest) {
            throw DataError.seatingConflict(conflict.message)
        }

        // Remove existing assignment
        if let existing = guest.seatAssignment {
            modelContext.delete(existing)
        }

        let assignment = SeatAssignment(guest: guest, table: table, seatNumber: seatNumber)
        table.seatAssignments.append(assignment)
        modelContext.insert(assignment)
        try modelContext.save()
    }

    func removeGuestFromTable(guestId: UUID) throws {
        guard let project = currentProject else { throw DataError.noProject }
        guard let guest = project.guests.first(where: { $0.id == guestId }),
              let assignment = guest.seatAssignment else {
            throw DataError.notFound
        }
        modelContext.delete(assignment)
        try modelContext.save()
    }

    func autoAssignGuests() throws -> Int {
        guard let project = currentProject else { throw DataError.noProject }
        var assignedCount = 0
        let unassigned = project.guests.filter { $0.rsvp == .attending && $0.seatAssignment == nil }

        for guest in unassigned {
            for table in project.tables where table.canSeat(guest: guest) && table.hasConflict(with: guest) == nil {
                let assignment = SeatAssignment(guest: guest, table: table)
                table.seatAssignments.append(assignment)
                modelContext.insert(assignment)
                assignedCount += 1
                break
            }
        }

        try modelContext.save()
        return assignedCount
    }

    func detectAllConflicts() -> [SeatingConflict] {
        guard let project = currentProject else { return [] }
        var conflicts: [SeatingConflict] = []

        for table in project.tables {
            let guests = table.seatedGuests
            // Capacity check
            if table.occupiedSeats > table.capacity {
                if let firstGuest = guests.first {
                    conflicts.append(SeatingConflict(type: .capacityExceeded, guest1: firstGuest, guest2: nil, table: table))
                }
            }
            // Personal conflicts
            for i in 0..<guests.count {
                for j in (i+1)..<guests.count {
                    if guests[i].conflictWithGuestIds.contains(guests[j].id) {
                        conflicts.append(SeatingConflict(type: .personalConflict, guest1: guests[i], guest2: guests[j], table: table))
                    }
                }
                // Child at no-child event
                if project.allowChildren == false && guests[i].isChild {
                    conflicts.append(SeatingConflict(type: .noChildTable, guest1: guests[i], guest2: nil, table: table))
                }
            }
        }
        return conflicts
    }

    // MARK: - Shopping Operations

    func addShoppingList(title: String, type: ShoppingListType, category: String? = nil) throws -> ShoppingList {
        guard let project = currentProject else { throw DataError.noProject }
        let list = ShoppingList(title: title, type: type, category: category)
        project.shoppingLists.append(list)
        try modelContext.save()
        return list
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

    // MARK: - Analytics & Reporting

    func getBudgetSummary() -> BudgetSummary {
        guard let project = currentProject else {
            return BudgetSummary(totalBudget: 0, totalSpent: 0, totalPaid: 0, totalUnpaid: 0, byCategory: [:])
        }

        var byCategory: [ExpenseCategory: Double] = [:]
        var totalPaid: Double = 0
        var totalUnpaid: Double = 0

        for expense in project.expenses {
            byCategory[expense.expenseCategory, default: 0] += expense.amount
            if expense.isPaid {
                totalPaid += expense.amount
            } else {
                totalUnpaid += expense.amount
            }
        }

        return BudgetSummary(
            totalBudget: project.totalBudget,
            totalSpent: project.spentAmount,
            totalPaid: totalPaid,
            totalUnpaid: totalUnpaid,
            byCategory: byCategory
        )
    }

    func getGuestSummary() -> GuestSummary {
        guard let project = currentProject else {
            return GuestSummary(totalInvited: 0, totalHeadcount: 0, attending: 0, notAttending: 0, pending: 0, maybe: 0)
        }

        var attending = 0, notAttending = 0, pending = 0, maybe = 0
        let totalHeadcount = project.totalGuests

        for guest in project.guests {
            switch guest.rsvp {
            case .attending: attending += 1 + guest.plusOneCount
            case .notAttending: notAttending += 1
            case .pending: pending += 1
            case .maybe: maybe += 1
            }
        }

        return GuestSummary(
            totalInvited: project.guests.count,
            totalHeadcount: totalHeadcount,
            attending: attending,
            notAttending: notAttending,
            pending: pending,
            maybe: maybe
        )
    }

    func getSeatingPlanSummary() -> SeatingPlanSummary {
        guard let project = currentProject else {
            return SeatingPlanSummary(totalTables: 0, totalCapacity: 0, seatedGuests: 0, unseatedGuests: 0, conflicts: [])
        }

        let totalCapacity = project.tables.reduce(0) { $0 + $1.capacity }
        let seatedGuests = project.tables.reduce(0) { $0 + $1.occupiedSeats }
        let attendingGuests = project.guests.filter { $0.rsvp == .attending }.reduce(0) { $0 + 1 + $1.plusOneCount }
        let unseatedGuests = max(0, attendingGuests - seatedGuests)

        return SeatingPlanSummary(
            totalTables: project.tables.count,
            totalCapacity: totalCapacity,
            seatedGuests: seatedGuests,
            unseatedGuests: unseatedGuests,
            conflicts: detectAllConflicts()
        )
    }

    func getWeeklyBrief() -> WeeklyBrief {
        guard let project = currentProject else {
            return WeeklyBrief(tasksThisWeek: [], paymentsThisWeek: [], pendingRSVPCount: 0, upcomingDeliveries: [], overdueTasks: [])
        }

        let calendar = Calendar.current
        let now = Date()
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: now)!

        let tasksThisWeek = project.tasks.filter { task in
            guard let due = task.dueDate, task.status != TaskStatus.completed.rawValue else { return false }
            return due >= now && due <= weekEnd
        }

        let paymentsThisWeek = project.expenses.filter { expense in
            !expense.isPaid && expense.date >= now && expense.date <= weekEnd
        }

        let pendingRSVP = project.guests.filter { $0.rsvp == .pending }.count

        let overdueTasks = project.tasks.filter { $0.isOverdue }

        return WeeklyBrief(
            tasksThisWeek: tasksThisWeek,
            paymentsThisWeek: paymentsThisWeek,
            pendingRSVPCount: pendingRSVP,
            upcomingDeliveries: [],
            overdueTasks: overdueTasks
        )
    }

    // MARK: - Risk Detection

    func detectRisks() -> [RiskAlert] {
        guard let project = currentProject else { return [] }
        var risks: [RiskAlert] = []

        // Budget over
        if project.spentAmount > project.totalBudget && project.totalBudget > 0 {
            risks.append(RiskAlert(
                type: .budgetOverrun,
                title: "Bütçe Aşıldı",
                message: "Toplam harcama bütçeyi aştı. Harcamaları gözden geçirin.",
                severity: .high
            ))
        }

        // Budget 80% warning
        if project.budgetProgress > 0.8 && project.budgetProgress < 1.0 {
            risks.append(RiskAlert(
                type: .budgetWarning,
                title: "Bütçe Uyarısı",
                message: "Bütçenin %\(Int(project.budgetProgress * 100))'ı kullanıldı.",
                severity: .medium
            ))
        }

        // Overdue tasks
        let overdueCount = project.tasks.filter { $0.isOverdue }.count
        if overdueCount > 0 {
            risks.append(RiskAlert(
                type: .overdueTasks,
                title: "\(overdueCount) Gecikmiş Görev",
                message: "Tamamlanmamış görevleriniz var. Öncelikleri gözden geçirin.",
                severity: overdueCount > 5 ? .high : .medium
            ))
        }

        // Task pile-up (too many tasks same week)
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: Date())!
        let thisWeekTasks = project.tasks.filter { task in
            guard let due = task.dueDate, task.status != TaskStatus.completed.rawValue else { return false }
            return due <= weekEnd && due >= Date()
        }
        if thisWeekTasks.count > 10 {
            risks.append(RiskAlert(
                type: .taskPileUp,
                title: "Yoğun Hafta",
                message: "Bu hafta \(thisWeekTasks.count) görev var. Bazılarını ertelemeyi düşünün.",
                severity: .medium
            ))
        }

        // RSVP deadline approaching
        let pendingRSVP = project.guests.filter { $0.rsvp == .pending }.count
        if pendingRSVP > 0 && project.daysUntilWedding < 30 {
            risks.append(RiskAlert(
                type: .rsvpDeadline,
                title: "RSVP Acil",
                message: "\(pendingRSVP) kişi henüz yanıt vermedi ve düğüne \(project.daysUntilWedding) gün kaldı.",
                severity: .high
            ))
        }

        // Seating conflicts
        let conflicts = detectAllConflicts()
        if !conflicts.isEmpty {
            risks.append(RiskAlert(
                type: .seatingConflict,
                title: "\(conflicts.count) Oturma Çatışması",
                message: "Oturma planınızda çözülmesi gereken çatışmalar var.",
                severity: .medium
            ))
        }

        // Unpaid expenses overdue
        let overduePayments = project.expenses.filter { $0.isOverdue }
        if !overduePayments.isEmpty {
            let total = overduePayments.reduce(0) { $0 + $1.amount }
            let symbol = Currency(rawValue: project.currency)?.symbol ?? "₺"
            risks.append(RiskAlert(
                type: .overduePayments,
                title: "\(overduePayments.count) Gecikmiş Ödeme",
                message: "\(symbol)\(Int(total).formatted()) tutarında ödeme gecikmiş.",
                severity: .high
            ))
        }

        return risks.sorted { $0.severity.sortOrder < $1.severity.sortOrder }
    }
}

// MARK: - Data Error

enum DataError: LocalizedError {
    case noProject
    case notFound
    case capacityExceeded
    case seatingConflict(String)
    case saveFailed(Error)
    case exportFailed(String)
    case importFailed(String)

    var errorDescription: String? {
        switch self {
        case .noProject: return "Aktif proje bulunamadı"
        case .notFound: return "Kayıt bulunamadı"
        case .capacityExceeded: return "Masa kapasitesi aşıldı"
        case .seatingConflict(let msg): return msg
        case .saveFailed(let error): return "Kaydetme hatası: \(error.localizedDescription)"
        case .exportFailed(let msg): return "Dışa aktarma hatası: \(msg)"
        case .importFailed(let msg): return "İçe aktarma hatası: \(msg)"
        }
    }
}

// MARK: - Weekly Brief

struct WeeklyBrief {
    let tasksThisWeek: [Task]
    let paymentsThisWeek: [Expense]
    let pendingRSVPCount: Int
    let upcomingDeliveries: [Delivery]
    let overdueTasks: [Task]

    var totalPaymentAmount: Double {
        paymentsThisWeek.reduce(0) { $0 + $1.amount }
    }

    var taskCount: Int {
        tasksThisWeek.count
    }

    var hasOverdue: Bool {
        !overdueTasks.isEmpty
    }
}

// MARK: - Risk Alert

struct RiskAlert: Identifiable {
    let id = UUID()
    let type: RiskType
    let title: String
    let message: String
    let severity: RiskSeverity

    enum RiskType {
        case budgetOverrun
        case budgetWarning
        case overdueTasks
        case taskPileUp
        case rsvpDeadline
        case seatingConflict
        case overduePayments
    }

    enum RiskSeverity {
        case low, medium, high

        var color: Color {
            switch self {
            case .low: return .nuviaInfo
            case .medium: return .nuviaWarning
            case .high: return .nuviaError
            }
        }

        var icon: String {
            switch self {
            case .low: return "info.circle.fill"
            case .medium: return "exclamationmark.triangle.fill"
            case .high: return "exclamationmark.octagon.fill"
            }
        }

        var sortOrder: Int {
            switch self {
            case .high: return 0
            case .medium: return 1
            case .low: return 2
            }
        }
    }
}
