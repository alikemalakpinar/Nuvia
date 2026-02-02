import SwiftUI
import SwiftData

/// Bütçe ana ekranı
struct BudgetHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var selectedView: BudgetViewMode = .overview
    @State private var showAddExpense = false
    @State private var showReports = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View mode picker
                Picker("Görünüm", selection: $selectedView) {
                    ForEach(BudgetViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if let project = currentProject {
                    switch selectedView {
                    case .overview:
                        BudgetOverviewView(project: project)
                    case .expenses:
                        ExpenseListView(project: project)
                    case .schedule:
                        PaymentScheduleView(project: project)
                    }
                } else {
                    NuviaEmptyState(
                        icon: "creditcard.trianglebadge.exclamationmark",
                        title: "Proje bulunamadı",
                        message: "Bütçe takibi için bir proje oluşturun"
                    )
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Bütçe")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showReports = true
                        } label: {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Button {
                            showAddExpense = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView()
            }
            .sheet(isPresented: $showReports) {
                BudgetReportsView()
            }
        }
    }
}

enum BudgetViewMode: String, CaseIterable {
    case overview = "Özet"
    case expenses = "Harcamalar"
    case schedule = "Takvim"
}

// MARK: - Budget Overview View

struct BudgetOverviewView: View {
    let project: WeddingProject

    private var currencySymbol: String {
        Currency(rawValue: project.currency)?.symbol ?? "₺"
    }

    private var categoryBreakdown: [(ExpenseCategory, Double)] {
        var breakdown: [ExpenseCategory: Double] = [:]
        for expense in project.expenses {
            breakdown[expense.expenseCategory, default: 0] += expense.amount
        }
        return breakdown.sorted { $0.value > $1.value }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Main budget card
                NuviaCard {
                    VStack(spacing: 20) {
                        // Progress ring
                        ZStack {
                            NuviaProgressRing(
                                progress: project.budgetProgress,
                                size: 120,
                                lineWidth: 12
                            )

                            VStack(spacing: 2) {
                                Text(currencySymbol)
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaSecondaryText)
                                Text("\(Int(project.spentAmount).formatted())")
                                    .font(NuviaTypography.mediumNumber())
                                    .foregroundColor(.nuviaPrimaryText)
                            }
                        }

                        // Stats row
                        HStack(spacing: 32) {
                            BudgetStatItem(
                                title: "Toplam Bütçe",
                                amount: project.totalBudget,
                                symbol: currencySymbol,
                                color: .nuviaPrimaryText
                            )

                            BudgetStatItem(
                                title: "Harcanan",
                                amount: project.spentAmount,
                                symbol: currencySymbol,
                                color: .nuviaWarning
                            )

                            BudgetStatItem(
                                title: "Kalan",
                                amount: project.remainingBudget,
                                symbol: currencySymbol,
                                color: project.remainingBudget >= 0 ? .nuviaSuccess : .nuviaError
                            )
                        }

                        // Warning if over budget
                        if project.spentAmount > project.totalBudget {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.nuviaError)
                                Text("Bütçe aşıldı! \(currencySymbol)\(Int(project.spentAmount - project.totalBudget).formatted()) fazla harcandı.")
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaError)
                            }
                            .padding(12)
                            .background(Color.nuviaError.opacity(0.15))
                            .cornerRadius(12)
                        }
                    }
                }

                // Category breakdown
                NuviaCard {
                    VStack(spacing: 16) {
                        NuviaSectionHeader("Kategori Dağılımı")

                        if categoryBreakdown.isEmpty {
                            Text("Henüz harcama yok")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                                .padding(.vertical, 8)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(categoryBreakdown.prefix(6), id: \.0) { category, amount in
                                    CategoryBreakdownRow(
                                        category: category,
                                        amount: amount,
                                        total: project.spentAmount,
                                        symbol: currencySymbol
                                    )
                                }
                            }
                        }
                    }
                }

                // Quick stats
                HStack(spacing: 16) {
                    QuickStatCard(
                        icon: "checkmark.circle.fill",
                        value: "\(project.expenses.filter { $0.isPaid }.count)",
                        label: "Ödenen",
                        color: .nuviaSuccess
                    )

                    QuickStatCard(
                        icon: "clock.fill",
                        value: "\(project.expenses.filter { !$0.isPaid }.count)",
                        label: "Bekleyen",
                        color: .nuviaWarning
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
}

struct BudgetStatItem: View {
    let title: String
    let amount: Double
    let symbol: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaSecondaryText)

            Text("\(symbol)\(Int(amount).formatted())")
                .font(NuviaTypography.bodyBold())
                .foregroundColor(color)
        }
    }
}

struct CategoryBreakdownRow: View {
    let category: ExpenseCategory
    let amount: Double
    let total: Double
    let symbol: String

    private var percentage: Double {
        guard total > 0 else { return 0 }
        return amount / total
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: category.icon)
                        .foregroundColor(category.color)
                        .frame(width: 24)

                    Text(category.displayName)
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaPrimaryText)
                }

                Spacer()

                Text("\(symbol)\(Int(amount).formatted())")
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.nuviaTertiaryBackground)
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(category.color)
                        .frame(width: geometry.size.width * CGFloat(percentage), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        NuviaCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                Text(value)
                    .font(NuviaTypography.mediumNumber())
                    .foregroundColor(.nuviaPrimaryText)

                Text(label)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Expense List View

struct ExpenseListView: View {
    let project: WeddingProject
    @State private var selectedCategory: ExpenseCategory?

    private var filteredExpenses: [Expense] {
        if let category = selectedCategory {
            return project.expenses.filter { $0.expenseCategory == category }
        }
        return project.expenses.sorted { $0.date > $1.date }
    }

    private var currencySymbol: String {
        Currency(rawValue: project.currency)?.symbol ?? "₺"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "Tümü", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }

                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.displayName,
                            isSelected: selectedCategory == category,
                            color: category.color
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            // Expense list
            if filteredExpenses.isEmpty {
                Spacer()
                NuviaEmptyState(
                    icon: "creditcard",
                    title: "Harcama yok",
                    message: "İlk harcamanızı ekleyin",
                    actionTitle: "Harcama Ekle"
                ) {}
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredExpenses, id: \.id) { expense in
                            ExpenseCard(expense: expense, symbol: currencySymbol)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct ExpenseCard: View {
    let expense: Expense
    let symbol: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: expense.expenseCategory.icon)
                .font(.system(size: 20))
                .foregroundColor(expense.expenseCategory.color)
                .frame(width: 44, height: 44)
                .background(expense.expenseCategory.color.opacity(0.15))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)

                    if expense.isInstallment, let count = expense.installmentCount {
                        Text("Taksit \(expense.installmentNumber ?? 1)/\(count)")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaInfo)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(symbol)\(Int(expense.amount).formatted())")
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)

                HStack(spacing: 4) {
                    Circle()
                        .fill(expense.isPaid ? Color.nuviaSuccess : Color.nuviaWarning)
                        .frame(width: 8, height: 8)
                    Text(expense.isPaid ? "Ödendi" : "Bekliyor")
                        .font(NuviaTypography.caption())
                        .foregroundColor(expense.isPaid ? .nuviaSuccess : .nuviaWarning)
                }
            }
        }
        .padding(16)
        .background(Color.nuviaCardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Payment Schedule View

struct PaymentScheduleView: View {
    let project: WeddingProject
    @State private var selectedDate = Date()

    private var upcomingPayments: [Expense] {
        project.expenses
            .filter { !$0.isPaid }
            .sorted { $0.date < $1.date }
    }

    private var currencySymbol: String {
        Currency(rawValue: project.currency)?.symbol ?? "₺"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Calendar
                DatePicker(
                    "Tarih",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.nuviaGoldFallback)
                .padding(.horizontal)

                // Upcoming payments
                NuviaCard {
                    VStack(spacing: 16) {
                        NuviaSectionHeader("Yaklaşan Ödemeler")

                        if upcomingPayments.isEmpty {
                            Text("Bekleyen ödeme yok")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                                .padding(.vertical, 8)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(upcomingPayments.prefix(5), id: \.id) { expense in
                                    PaymentScheduleRow(expense: expense, symbol: currencySymbol)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
}

struct PaymentScheduleRow: View {
    let expense: Expense
    let symbol: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .center, spacing: 2) {
                Text(expense.date.formatted(.dateTime.day()))
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)
                Text(expense.date.formatted(.dateTime.month(.abbreviated)))
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }
            .frame(width: 44)
            .padding(8)
            .background(Color.nuviaTertiaryBackground)
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)
                    .lineLimit(1)

                Text("\(expense.daysUntilDue) gün kaldı")
                    .font(NuviaTypography.caption())
                    .foregroundColor(expense.daysUntilDue <= 3 ? .nuviaWarning : .nuviaSecondaryText)
            }

            Spacer()

            Text("\(symbol)\(Int(expense.amount).formatted())")
                .font(NuviaTypography.bodyBold())
                .foregroundColor(.nuviaPrimaryText)
        }
    }
}

// MARK: - Add Expense View

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var title = ""
    @State private var amount = ""
    @State private var category: ExpenseCategory = .other
    @State private var paymentType: PaymentType = .card
    @State private var date = Date()
    @State private var isPaid = false
    @State private var isInstallment = false
    @State private var installmentCount = 3
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Harcama Bilgileri") {
                    TextField("Başlık", text: $title)

                    HStack {
                        Text("₺")
                        TextField("Tutar", text: $amount)
                            .keyboardType(.decimalPad)
                    }

                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                }

                Section("Kategori") {
                    Picker("Kategori", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }

                Section("Ödeme") {
                    Picker("Ödeme Tipi", selection: $paymentType) {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }

                    Toggle("Ödendi", isOn: $isPaid)

                    Toggle("Taksitli", isOn: $isInstallment)

                    if isInstallment {
                        Stepper("Taksit Sayısı: \(installmentCount)", value: $installmentCount, in: 2...24)
                    }
                }

                Section("Not") {
                    TextField("Not (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Yeni Harcama")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        saveExpense()
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveExpense() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }),
              let amountValue = Double(amount) else {
            return
        }

        let expense = Expense(
            title: title,
            category: category,
            amount: amountValue,
            date: date,
            paymentType: paymentType,
            isPaid: isPaid
        )

        expense.isInstallment = isInstallment
        expense.installmentCount = isInstallment ? installmentCount : nil
        expense.installmentNumber = isInstallment ? 1 : nil
        expense.notes = notes.isEmpty ? nil : notes

        project.expenses.append(expense)
        project.spentAmount += amountValue

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save expense: \(error)")
        }
    }
}

// MARK: - Budget Reports View

struct BudgetReportsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState
    @State private var selectedPeriod: ReportPeriod = .all
    @State private var showShareSheet = false
    @State private var exportData: Data?
    @State private var exportFileName: String = ""

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    enum ReportPeriod: String, CaseIterable {
        case week = "Bu Hafta"
        case month = "Bu Ay"
        case all = "Tümü"
    }

    private var filteredExpenses: [Expense] {
        guard let project = currentProject else { return [] }
        let now = Date()
        switch selectedPeriod {
        case .week:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            return project.expenses.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
            return project.expenses.filter { $0.date >= monthAgo }
        case .all:
            return project.expenses
        }
    }

    private var categoryTotals: [(category: ExpenseCategory, total: Double)] {
        var dict: [ExpenseCategory: Double] = [:]
        for expense in filteredExpenses {
            dict[expense.expenseCategory, default: 0] += expense.amount
        }
        return dict.map { ($0.key, $0.value) }.sorted { $0.total > $1.total }
    }

    private var totalSpent: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    private var monthlyTrend: [(month: String, amount: Double)] {
        guard let project = currentProject else { return [] }
        let calendar = Calendar.current
        var dict: [String: Double] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "tr_TR")
        for expense in project.expenses {
            let key = formatter.string(from: expense.date)
            dict[key, default: 0] += expense.amount
        }
        // Sort by date order - get last 6 months
        let now = Date()
        var result: [(String, Double)] = []
        for i in (0..<6).reversed() {
            if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                let key = formatter.string(from: date)
                result.append((key, dict[key] ?? 0))
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period picker
                    Picker("Dönem", selection: $selectedPeriod) {
                        ForEach(ReportPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Summary card
                    if let project = currentProject {
                        let symbol = Currency(rawValue: project.currency)?.symbol ?? "₺"

                        NuviaHeroCard(accent: .nuviaGoldFallback) {
                            VStack(spacing: 12) {
                                Text("Bütçe Özeti")
                                    .font(NuviaTypography.headline())
                                    .foregroundColor(.nuviaPrimaryText)

                                HStack(spacing: 24) {
                                    VStack(spacing: 4) {
                                        Text("\(symbol)\(Int(project.totalBudget).formatted())")
                                            .font(NuviaTypography.title3())
                                            .foregroundColor(.nuviaPrimaryText)
                                        Text("Toplam")
                                            .font(NuviaTypography.caption())
                                            .foregroundColor(.nuviaSecondaryText)
                                    }
                                    VStack(spacing: 4) {
                                        Text("\(symbol)\(Int(totalSpent).formatted())")
                                            .font(NuviaTypography.title3())
                                            .foregroundColor(.nuviaWarning)
                                        Text("Harcanan")
                                            .font(NuviaTypography.caption())
                                            .foregroundColor(.nuviaSecondaryText)
                                    }
                                    VStack(spacing: 4) {
                                        Text("\(symbol)\(Int(project.remainingBudget).formatted())")
                                            .font(NuviaTypography.title3())
                                            .foregroundColor(project.remainingBudget >= 0 ? .nuviaSuccess : .nuviaError)
                                        Text("Kalan")
                                            .font(NuviaTypography.caption())
                                            .foregroundColor(.nuviaSecondaryText)
                                    }
                                }

                                // Progress bar
                                let progress = project.totalBudget > 0 ? min(project.spentAmount / project.totalBudget, 1.0) : 0
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.nuviaTertiaryBackground)
                                            .frame(height: 8)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(progress > 0.9 ? Color.nuviaError : Color.nuviaGoldFallback)
                                            .frame(width: geo.size.width * progress, height: 8)
                                    }
                                }
                                .frame(height: 8)

                                Text("%\(Int(progress * 100)) kullanıldı")
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaTertiaryText)
                            }
                        }

                        // Category breakdown
                        NuviaCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Kategori Dağılımı")
                                    .font(NuviaTypography.headline())
                                    .foregroundColor(.nuviaPrimaryText)

                                if categoryTotals.isEmpty {
                                    Text("Henüz harcama yok")
                                        .font(NuviaTypography.body())
                                        .foregroundColor(.nuviaSecondaryText)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 20)
                                } else {
                                    ForEach(categoryTotals, id: \.category) { item in
                                        HStack(spacing: 12) {
                                            Image(systemName: item.category.icon)
                                                .font(.system(size: 16))
                                                .foregroundColor(item.category.color)
                                                .frame(width: 24)

                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack {
                                                    Text(item.category.displayName)
                                                        .font(NuviaTypography.subheadline())
                                                        .foregroundColor(.nuviaPrimaryText)
                                                    Spacer()
                                                    Text("\(symbol)\(Int(item.total).formatted())")
                                                        .font(NuviaTypography.subheadline())
                                                        .foregroundColor(.nuviaPrimaryText)
                                                }

                                                let pct = totalSpent > 0 ? item.total / totalSpent : 0
                                                GeometryReader { geo in
                                                    ZStack(alignment: .leading) {
                                                        RoundedRectangle(cornerRadius: 2)
                                                            .fill(Color.nuviaTertiaryBackground)
                                                            .frame(height: 4)
                                                        RoundedRectangle(cornerRadius: 2)
                                                            .fill(item.category.color)
                                                            .frame(width: geo.size.width * pct, height: 4)
                                                    }
                                                }
                                                .frame(height: 4)

                                                Text("%\(Int(pct * 100))")
                                                    .font(NuviaTypography.caption2())
                                                    .foregroundColor(.nuviaTertiaryText)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Monthly trend
                        NuviaCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Aylık Trend")
                                    .font(NuviaTypography.headline())
                                    .foregroundColor(.nuviaPrimaryText)

                                let maxAmount = monthlyTrend.map(\.amount).max() ?? 1

                                HStack(alignment: .bottom, spacing: 8) {
                                    ForEach(monthlyTrend, id: \.month) { item in
                                        VStack(spacing: 4) {
                                            if item.amount > 0 {
                                                Text("\(symbol)\(Int(item.amount / 1000))K")
                                                    .font(NuviaTypography.caption2())
                                                    .foregroundColor(.nuviaSecondaryText)
                                            }

                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.nuviaGoldFallback.opacity(item.amount > 0 ? 0.8 : 0.15))
                                                .frame(height: max(4, CGFloat(item.amount / maxAmount) * 100))

                                            Text(item.month)
                                                .font(NuviaTypography.caption2())
                                                .foregroundColor(.nuviaTertiaryText)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .frame(height: 140)
                            }
                        }

                        // Payment status
                        NuviaCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Ödeme Durumu")
                                    .font(NuviaTypography.headline())
                                    .foregroundColor(.nuviaPrimaryText)

                                let paid = filteredExpenses.filter(\.isPaid).reduce(0) { $0 + $1.amount }
                                let unpaid = totalSpent - paid
                                let overdue = filteredExpenses.filter(\.isOverdue).reduce(0) { $0 + $1.amount }

                                HStack(spacing: 16) {
                                    PaymentStatCard(title: "Ödenen", amount: "\(symbol)\(Int(paid).formatted())", color: .nuviaSuccess)
                                    PaymentStatCard(title: "Bekleyen", amount: "\(symbol)\(Int(unpaid).formatted())", color: .nuviaWarning)
                                    PaymentStatCard(title: "Geciken", amount: "\(symbol)\(Int(overdue).formatted())", color: .nuviaError)
                                }
                            }
                        }

                        // Export buttons
                        NuviaCard {
                            VStack(spacing: 12) {
                                Text("Dışa Aktar")
                                    .font(NuviaTypography.headline())
                                    .foregroundColor(.nuviaPrimaryText)

                                HStack(spacing: 12) {
                                    Button {
                                        if let data = ExportService.generateBudgetPDF(project: project) {
                                            ExportService.shareFile(data: data, fileName: "butce-raporu.pdf")
                                        }
                                    } label: {
                                        Label("PDF", systemImage: "doc.fill")
                                            .font(NuviaTypography.subheadline())
                                            .foregroundColor(.nuviaPrimaryText)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.nuviaTertiaryBackground)
                                            .cornerRadius(10)
                                    }

                                    Button {
                                        let csv = ExportService.generateBudgetCSV(project: project)
                                        ExportService.shareText(text: csv, fileName: "butce-raporu.csv")
                                    } label: {
                                        Label("CSV", systemImage: "tablecells")
                                            .font(NuviaTypography.subheadline())
                                            .foregroundColor(.nuviaPrimaryText)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.nuviaTertiaryBackground)
                                            .cornerRadius(10)
                                    }

                                    Button {
                                        if let json = ExportService.generateProjectJSON(project: project) {
                                            ExportService.shareText(text: json, fileName: "proje-veri.json")
                                        }
                                    } label: {
                                        Label("JSON", systemImage: "curlybraces")
                                            .font(NuviaTypography.subheadline())
                                            .foregroundColor(.nuviaPrimaryText)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.nuviaTertiaryBackground)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Raporlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.nuviaGoldFallback)
                }
            }
        }
    }
}

struct PaymentStatCard: View {
    let title: String
    let amount: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle().fill(color).frame(width: 10, height: 10)
                )
            Text(amount)
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaPrimaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(NuviaTypography.caption2())
                .foregroundColor(.nuviaSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.nuviaTertiaryBackground)
        .cornerRadius(10)
    }
}

#Preview {
    BudgetHomeView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
