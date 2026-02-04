import Foundation
import SwiftData
import SwiftUI

// MARK: - Project Provider Protocol
/// Protocol for accessing the current project - defined here to ensure compilation

@MainActor
protocol ProjectProvider: AnyObject {
    var currentProject: WeddingProject? { get }
}

/// Central Data Manager - Coordinator Pattern
/// This class only handles app-level coordination.
/// All CRUD operations are delegated to specialized services.
@MainActor
class DataManager: ObservableObject, ProjectProvider {
    let modelContext: ModelContext

    // MARK: - Services
    let budgetService: BudgetService
    let guestService: GuestService
    let projectService: ProjectService
    let riskService: RiskService

    // MARK: - Published State
    @Published var currentProject: WeddingProject?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Initialize services without a provider initially
        let budget = BudgetService(modelContext: modelContext)
        let guest = GuestService(modelContext: modelContext)
        let project = ProjectService(modelContext: modelContext)

        self.budgetService = budget
        self.guestService = guest
        self.projectService = project

        // Risk service needs other services
        self.riskService = RiskService(
            guestService: guest,
            budgetService: budget,
            projectService: project
        )

        // Wire up services with self as the project provider
        // Must be done after all properties are initialized
        wireUpServices()
    }

    /// Wire up services with self as the project provider
    private func wireUpServices() {
        budgetService.setProjectProvider(self)
        guestService.setProjectProvider(self)
        projectService.setProjectProvider(self)
        riskService.setProjectProvider(self)
    }

    // MARK: - Project Loading

    func loadProject(id: String) {
        let descriptor = FetchDescriptor<WeddingProject>(
            predicate: #Predicate { $0.id.uuidString == id }
        )
        currentProject = try? modelContext.fetch(descriptor).first
    }

    func loadFirstProject() {
        let descriptor = FetchDescriptor<WeddingProject>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        currentProject = try? modelContext.fetch(descriptor).first
    }

    // MARK: - Project Lifecycle

    func createProject(
        partnerName1: String,
        partnerName2: String,
        weddingDate: Date,
        totalBudget: Double = 0,
        currency: String = "TRY"
    ) throws -> WeddingProject {
        let project = WeddingProject(
            partnerName1: partnerName1,
            partnerName2: partnerName2,
            weddingDate: weddingDate
        )
        project.totalBudget = totalBudget
        project.currency = currency
        modelContext.insert(project)
        try modelContext.save()
        currentProject = project
        return project
    }

    func deleteProject() throws {
        guard let project = currentProject else { throw DataError.noProject }
        modelContext.delete(project)
        try modelContext.save()
        currentProject = nil
    }

    // MARK: - High-Level Summaries (Aggregated from Services)

    func getWeeklyBrief() -> WeeklyBrief {
        return projectService.getWeeklyBrief(budgetService: budgetService, guestService: guestService)
    }

    func getBudgetSummary() -> BudgetSummary {
        return budgetService.getBudgetSummary()
    }

    func getGuestSummary() -> GuestSummary {
        return guestService.getGuestSummary()
    }

    func getSeatingPlanSummary() -> SeatingPlanSummary {
        return guestService.getSeatingPlanSummary()
    }

    func detectRisks() -> [RiskAlert] {
        return riskService.detectRisks()
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
        case .noProject: return L10n.Error.noProject
        case .notFound: return L10n.Error.notFound
        case .capacityExceeded: return L10n.Error.capacityExceeded
        case .seatingConflict(let msg): return msg
        case .saveFailed(let error): return "\(L10n.Error.saveFailed): \(error.localizedDescription)"
        case .exportFailed(let msg): return "\(L10n.Error.exportFailed): \(msg)"
        case .importFailed(let msg): return "\(L10n.Error.importFailed): \(msg)"
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

        @MainActor
        var color: Color {
            switch self {
            case .low: return DSColors.info
            case .medium: return DSColors.warning
            case .high: return DSColors.error
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

// MARK: - L10n Extension for Errors

extension L10n {
    public enum Error {
        public static let noProject = "error.noProject".localized
        public static let notFound = "error.notFound".localized
        public static let capacityExceeded = "error.capacityExceeded".localized
        public static let saveFailed = "error.saveFailed".localized
        public static let exportFailed = "error.exportFailed".localized
        public static let importFailed = "error.importFailed".localized
    }
}
