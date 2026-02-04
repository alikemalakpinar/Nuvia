import Foundation
import SwiftData
import SwiftUI

// MARK: - Budget Service
/// Manages all expense, vendor, and budget-related operations

@MainActor
public final class BudgetService: ObservableObject {
    private let modelContext: ModelContext
    private weak var projectProvider: ProjectProvider?

    init(modelContext: ModelContext, projectProvider: ProjectProvider? = nil) {
        self.modelContext = modelContext
        self.projectProvider = projectProvider
    }

    /// Set the project provider (used for post-init wiring)
    func setProjectProvider(_ provider: ProjectProvider) {
        self.projectProvider = provider
    }

    private var currentProject: WeddingProject? {
        projectProvider?.currentProject
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
                title: "\(title) - \(L10n.Budget.installment) \(i + 1)/\(installmentCount)",
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

    // MARK: - Budget Analytics

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

    func getUpcomingPayments(days: Int = 7) -> [Expense] {
        guard let project = currentProject else { return [] }
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: now)!

        return project.expenses.filter { expense in
            !expense.isPaid && expense.date >= now && expense.date <= futureDate
        }.sorted { $0.date < $1.date }
    }

    func getOverduePayments() -> [Expense] {
        guard let project = currentProject else { return [] }
        return project.expenses.filter { $0.isOverdue }.sorted { $0.date < $1.date }
    }

    func getCategoryBreakdown() -> [(category: ExpenseCategory, amount: Double, percentage: Double)] {
        let summary = getBudgetSummary()
        guard summary.totalSpent > 0 else { return [] }

        return summary.byCategory.map { category, amount in
            (category: category, amount: amount, percentage: amount / summary.totalSpent)
        }.sorted { $0.amount > $1.amount }
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
        max(0, totalBudget - totalSpent)
    }

    var progress: Double {
        guard totalBudget > 0 else { return 0 }
        return min(1, totalSpent / totalBudget)
    }

    var isOverBudget: Bool {
        totalSpent > totalBudget
    }

    var overBudgetAmount: Double {
        max(0, totalSpent - totalBudget)
    }
}
