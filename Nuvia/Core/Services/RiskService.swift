import Foundation
import SwiftData
import SwiftUI

// MARK: - Risk Service
/// Detects and reports potential issues with wedding planning

@MainActor
public final class RiskService: ObservableObject {
    private weak var projectProvider: ProjectProvider?
    private let guestService: GuestService
    private let budgetService: BudgetService
    private let projectService: ProjectService

    init(
        projectProvider: ProjectProvider,
        guestService: GuestService,
        budgetService: BudgetService,
        projectService: ProjectService
    ) {
        self.projectProvider = projectProvider
        self.guestService = guestService
        self.budgetService = budgetService
        self.projectService = projectService
    }

    private var currentProject: WeddingProject? {
        projectProvider?.currentProject
    }

    // MARK: - Risk Detection

    func detectRisks() -> [RiskAlert] {
        guard let project = currentProject else { return [] }
        var risks: [RiskAlert] = []

        // Budget risks
        risks.append(contentsOf: detectBudgetRisks(project: project))

        // Task risks
        risks.append(contentsOf: detectTaskRisks(project: project))

        // RSVP risks
        risks.append(contentsOf: detectRSVPRisks(project: project))

        // Seating risks
        risks.append(contentsOf: detectSeatingRisks())

        // Payment risks
        risks.append(contentsOf: detectPaymentRisks(project: project))

        return risks.sorted { $0.severity.sortOrder < $1.severity.sortOrder }
    }

    // MARK: - Budget Risks

    private func detectBudgetRisks(project: WeddingProject) -> [RiskAlert] {
        var risks: [RiskAlert] = []

        // Budget overrun
        if project.spentAmount > project.totalBudget && project.totalBudget > 0 {
            risks.append(RiskAlert(
                type: .budgetOverrun,
                title: L10n.Risk.budgetOverrunTitle,
                message: L10n.Risk.budgetOverrunMessage,
                severity: .high
            ))
        }

        // Budget 80% warning
        if project.budgetProgress > 0.8 && project.budgetProgress < 1.0 {
            risks.append(RiskAlert(
                type: .budgetWarning,
                title: L10n.Risk.budgetWarningTitle,
                message: L10n.Risk.budgetWarningMessage(Int(project.budgetProgress * 100)),
                severity: .medium
            ))
        }

        return risks
    }

    // MARK: - Task Risks

    private func detectTaskRisks(project: WeddingProject) -> [RiskAlert] {
        var risks: [RiskAlert] = []

        // Overdue tasks
        let overdueTasks = projectService.getOverdueTasks()
        if !overdueTasks.isEmpty {
            risks.append(RiskAlert(
                type: .overdueTasks,
                title: L10n.Risk.overdueTasksTitle(overdueTasks.count),
                message: L10n.Risk.overdueTasksMessage,
                severity: overdueTasks.count > 5 ? .high : .medium
            ))
        }

        // Task pile-up
        let thisWeekTasks = projectService.getTasksThisWeek()
        if thisWeekTasks.count > 10 {
            risks.append(RiskAlert(
                type: .taskPileUp,
                title: L10n.Risk.taskPileUpTitle,
                message: L10n.Risk.taskPileUpMessage(thisWeekTasks.count),
                severity: .medium
            ))
        }

        return risks
    }

    // MARK: - RSVP Risks

    private func detectRSVPRisks(project: WeddingProject) -> [RiskAlert] {
        var risks: [RiskAlert] = []

        let pendingRSVP = project.guests.filter { $0.rsvp == .pending }.count
        if pendingRSVP > 0 && project.daysUntilWedding < 30 {
            risks.append(RiskAlert(
                type: .rsvpDeadline,
                title: L10n.Risk.rsvpUrgentTitle,
                message: L10n.Risk.rsvpUrgentMessage(pendingRSVP, project.daysUntilWedding),
                severity: .high
            ))
        }

        return risks
    }

    // MARK: - Seating Risks

    private func detectSeatingRisks() -> [RiskAlert] {
        var risks: [RiskAlert] = []

        let conflicts = guestService.detectAllConflicts()
        if !conflicts.isEmpty {
            risks.append(RiskAlert(
                type: .seatingConflict,
                title: L10n.Risk.seatingConflictTitle(conflicts.count),
                message: L10n.Risk.seatingConflictMessage,
                severity: .medium
            ))
        }

        return risks
    }

    // MARK: - Payment Risks

    private func detectPaymentRisks(project: WeddingProject) -> [RiskAlert] {
        var risks: [RiskAlert] = []

        let overduePayments = budgetService.getOverduePayments()
        if !overduePayments.isEmpty {
            let total = overduePayments.reduce(0) { $0 + $1.amount }
            let symbol = Currency(rawValue: project.currency)?.symbol ?? "₺"
            risks.append(RiskAlert(
                type: .overduePayments,
                title: L10n.Risk.overduePaymentsTitle(overduePayments.count),
                message: L10n.Risk.overduePaymentsMessage(symbol, Int(total)),
                severity: .high
            ))
        }

        return risks
    }

    // MARK: - Risk Prioritization

    func getHighPriorityRisks() -> [RiskAlert] {
        detectRisks().filter { $0.severity == .high }
    }

    func getMediumPriorityRisks() -> [RiskAlert] {
        detectRisks().filter { $0.severity == .medium }
    }

    func getRiskCount() -> (high: Int, medium: Int, low: Int) {
        let risks = detectRisks()
        return (
            high: risks.filter { $0.severity == .high }.count,
            medium: risks.filter { $0.severity == .medium }.count,
            low: risks.filter { $0.severity == .low }.count
        )
    }
}

// MARK: - L10n Extension for Risks

extension L10n {
    public enum Risk {
        public static let budgetOverrunTitle = "risk.budget.overrun.title".localized
        public static let budgetOverrunMessage = "risk.budget.overrun.message".localized
        public static let budgetWarningTitle = "risk.budget.warning.title".localized
        public static func budgetWarningMessage(_ percent: Int) -> String {
            String(format: "risk.budget.warning.message".localized, percent)
        }

        public static func overdueTasksTitle(_ count: Int) -> String {
            String(format: "risk.tasks.overdue.title".localized, count)
        }
        public static let overdueTasksMessage = "risk.tasks.overdue.message".localized

        public static let taskPileUpTitle = "risk.tasks.pileup.title".localized
        public static func taskPileUpMessage(_ count: Int) -> String {
            String(format: "risk.tasks.pileup.message".localized, count)
        }

        public static let rsvpUrgentTitle = "risk.rsvp.urgent.title".localized
        public static func rsvpUrgentMessage(_ pending: Int, _ days: Int) -> String {
            String(format: "risk.rsvp.urgent.message".localized, pending, days)
        }

        public static func seatingConflictTitle(_ count: Int) -> String {
            String(format: "risk.seating.conflict.title".localized, count)
        }
        public static let seatingConflictMessage = "risk.seating.conflict.message".localized

        public static func overduePaymentsTitle(_ count: Int) -> String {
            String(format: "risk.payments.overdue.title".localized, count)
        }
        public static func overduePaymentsMessage(_ symbol: String, _ amount: Int) -> String {
            String(format: "risk.payments.overdue.message".localized, symbol, amount)
        }
    }
}
