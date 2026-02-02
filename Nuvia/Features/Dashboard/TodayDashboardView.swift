import SwiftUI
import SwiftData

/// Bugün (Dashboard) ekranı
struct TodayDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var showNotifications = false
    @State private var showWeeklyBrief = false
    @State private var showSettings = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let project = currentProject {
                        CountdownCard(project: project)
                            .cardEntrance(delay: 0)

                        TodayTasksCard(project: project)
                            .cardEntrance(delay: 0.05)

                        QuickActionsGrid()
                            .cardEntrance(delay: 0.10)

                        UpcomingPaymentsCard(project: project)
                            .cardEntrance(delay: 0.15)

                        RSVPSummaryCard(project: project)
                            .cardEntrance(delay: 0.20)

                        if appState.appMode == .weddingAndHome {
                            UpcomingDeliveriesCard(project: project)
                                .cardEntrance(delay: 0.25)
                        }
                    } else {
                        NuviaEmptyState(
                            icon: "heart.slash",
                            title: "Proje bulunamadı",
                            message: "Lütfen bir düğün projesi oluşturun"
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Bugün")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showWeeklyBrief = true
                    } label: {
                        Image(systemName: "sparkles.rectangle.stack")
                            .foregroundColor(.nuviaGoldFallback)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showNotifications = true
                        } label: {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }
                }
            }
            .sheet(isPresented: $showWeeklyBrief) {
                WeeklyBriefView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsInboxView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Countdown Card

struct CountdownCard: View {
    let project: WeddingProject

    var body: some View {
        NuviaCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(project.partnerName1) & \(project.partnerName2)")
                            .font(NuviaTypography.title3())
                            .foregroundColor(.nuviaPrimaryText)

                        if let venue = project.venueName {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 12))
                                Text(venue)
                                    .font(NuviaTypography.caption())
                            }
                            .foregroundColor(.nuviaSecondaryText)
                        }
                    }

                    Spacer()

                    // Progress ring
                    NuviaProgressRing(
                        progress: min(1.0, Double(max(0, 365 - project.daysUntilWedding)) / 365),
                        size: 60,
                        lineWidth: 6,
                        showPercentage: false
                    )
                }

                Divider()
                    .background(Color.nuviaTertiaryText)

                HStack {
                    VStack {
                        Text("\(project.daysUntilWedding)")
                            .font(NuviaTypography.largeNumber())
                            .foregroundColor(.nuviaGoldFallback)
                        Text("gün kaldı")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Düğüne \(project.daysUntilWedding) gün kaldı")

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(project.weddingDate.formatted(date: .abbreviated, time: .omitted))
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)
                        if let time = project.weddingTime {
                            Text(time.formatted(date: .omitted, time: .shortened))
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Today's Tasks Card

struct TodayTasksCard: View {
    let project: WeddingProject

    private var todaysTasks: [Task] {
        let calendar = Calendar.current
        return project.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDateInToday(dueDate) && task.status != TaskStatus.completed.rawValue
        }.prefix(5).map { $0 }
    }

    private var overdueTasks: [Task] {
        project.tasks.filter { $0.isOverdue }.prefix(3).map { $0 }
    }

    var body: some View {
        NuviaCard {
            VStack(spacing: 16) {
                NuviaSectionHeader("Bugünün Görevleri", actionTitle: "Tümü") {
                    // Navigate to tasks
                }

                if todaysTasks.isEmpty && overdueTasks.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.nuviaSuccess)
                        Text("Bugün için görev yok!")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                    .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        // Overdue tasks first
                        ForEach(overdueTasks, id: \.id) { task in
                            TaskRowCompact(task: task, isOverdue: true)
                        }

                        // Today's tasks
                        ForEach(todaysTasks, id: \.id) { task in
                            TaskRowCompact(task: task, isOverdue: false)
                        }
                    }
                }
            }
        }
    }
}

struct TaskRowCompact: View {
    let task: Task
    let isOverdue: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.taskStatus.icon)
                .foregroundColor(isOverdue ? .nuviaError : task.taskStatus.color)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    NuviaTag(task.taskCategory.displayName, color: task.taskCategory.color, size: .small)

                    if isOverdue {
                        Text("Gecikmiş")
                            .font(NuviaTypography.caption2())
                            .foregroundColor(.nuviaError)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.nuviaTertiaryText)
                .font(.system(size: 14))
        }
        .padding(12)
        .background(Color.nuviaTertiaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Quick Actions Grid

struct QuickActionsGrid: View {
    @State private var showRunOfShow = false
    @State private var showFileVault = false
    @State private var showZenMode = false
    @State private var showMusicVoting = false
    @State private var showPhotoStream = false
    @State private var showCheckIn = false
    @State private var showPostWedding = false
    @State private var showVendors = false

    var body: some View {
        VStack(spacing: 12) {
            NuviaSectionHeader("Hızlı Erişim", actionTitle: nil) {}

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                NuviaQuickAction(icon: "clock.badge.checkmark", title: "Run of Show", color: .nuviaGoldFallback) {
                    showRunOfShow = true
                }
                NuviaQuickAction(icon: "person.2.badge.gearshape", title: "Tedarikçi", color: .nuviaInfo) {
                    showVendors = true
                }
                NuviaQuickAction(icon: "lock.doc", title: "Dosya Kasası", color: .nuviaWarning) {
                    showFileVault = true
                }
                NuviaQuickAction(icon: "leaf.fill", title: "Zen Modu", color: .nuviaSuccess) {
                    showZenMode = true
                }
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                NuviaQuickAction(icon: "music.note.list", title: "Müzik", color: .categoryMusic) {
                    showMusicVoting = true
                }
                NuviaQuickAction(icon: "photo.on.rectangle", title: "Fotoğraf", color: .categoryPhoto) {
                    showPhotoStream = true
                }
                NuviaQuickAction(icon: "person.badge.shield.checkmark", title: "Check-in", color: .categoryVenue) {
                    showCheckIn = true
                }
                NuviaQuickAction(icon: "heart.text.square", title: "Sonrası", color: .categoryDress) {
                    showPostWedding = true
                }
            }
        }
        .sheet(isPresented: $showRunOfShow) { WeddingDayRunOfShowView() }
        .sheet(isPresented: $showVendors) { VendorManagementView() }
        .sheet(isPresented: $showFileVault) { FileVaultView() }
        .sheet(isPresented: $showZenMode) { ZenModeView() }
        .sheet(isPresented: $showMusicVoting) { MusicVotingView() }
        .sheet(isPresented: $showPhotoStream) { LivePhotoStreamView() }
        .sheet(isPresented: $showCheckIn) { CheckInSystemView() }
        .sheet(isPresented: $showPostWedding) { PostWeddingView() }
    }
}

// MARK: - Upcoming Payments Card

struct UpcomingPaymentsCard: View {
    let project: WeddingProject

    private var upcomingPayments: [Expense] {
        project.expenses
            .filter { !$0.isPaid && $0.daysUntilDue <= 30 && $0.daysUntilDue >= 0 }
            .sorted { $0.date < $1.date }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        NuviaCard {
            VStack(spacing: 16) {
                NuviaSectionHeader("Yaklaşan Ödemeler", actionTitle: "Tümü") {}

                if upcomingPayments.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.nuviaSuccess)
                        Text("Yaklaşan ödeme yok")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                    .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(upcomingPayments, id: \.id) { expense in
                            PaymentRowCompact(expense: expense, currency: project.currency)
                        }
                    }
                }
            }
        }
    }
}

struct PaymentRowCompact: View {
    let expense: Expense
    let currency: String

    private var currencySymbol: String {
        Currency(rawValue: currency)?.symbol ?? "₺"
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.expenseCategory.icon)
                .foregroundColor(expense.expenseCategory.color)
                .font(.system(size: 20))
                .frame(width: 40, height: 40)
                .background(expense.expenseCategory.color.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)
                    .lineLimit(1)

                Text("\(expense.daysUntilDue) gün sonra")
                    .font(NuviaTypography.caption())
                    .foregroundColor(expense.daysUntilDue <= 3 ? .nuviaWarning : .nuviaSecondaryText)
            }

            Spacer()

            Text("\(currencySymbol)\(Int(expense.amount).formatted())")
                .font(NuviaTypography.bodyBold())
                .foregroundColor(.nuviaPrimaryText)
        }
        .padding(12)
        .background(Color.nuviaTertiaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - RSVP Summary Card

struct RSVPSummaryCard: View {
    let project: WeddingProject

    private var attending: Int {
        project.guests.filter { $0.rsvp == .attending }.reduce(0) { $0 + 1 + $1.plusOneCount }
    }

    private var pending: Int {
        project.guests.filter { $0.rsvp == .pending }.count
    }

    private var notAttending: Int {
        project.guests.filter { $0.rsvp == .notAttending }.count
    }

    var body: some View {
        NuviaCard {
            VStack(spacing: 16) {
                NuviaSectionHeader("RSVP Özeti", actionTitle: "Detay") {}

                HStack(spacing: 24) {
                    RSVPStatItem(
                        count: attending,
                        label: "Geliyor",
                        color: .nuviaSuccess,
                        icon: "checkmark.circle.fill"
                    )

                    RSVPStatItem(
                        count: pending,
                        label: "Bekliyor",
                        color: .nuviaWarning,
                        icon: "questionmark.circle.fill"
                    )

                    RSVPStatItem(
                        count: notAttending,
                        label: "Gelmiyor",
                        color: .nuviaError,
                        icon: "xmark.circle.fill"
                    )
                }
            }
        }
    }
}

struct RSVPStatItem: View {
    let count: Int
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text("\(count)")
                    .font(NuviaTypography.mediumNumber())
                    .foregroundColor(.nuviaPrimaryText)
            }
            Text(label)
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Upcoming Deliveries Card

struct UpcomingDeliveriesCard: View {
    let project: WeddingProject

    var body: some View {
        NuviaCard {
            VStack(spacing: 16) {
                NuviaSectionHeader("Yaklaşan Teslimatlar", actionTitle: "Tümü") {}

                HStack {
                    Image(systemName: "shippingbox.fill")
                        .foregroundColor(.nuviaInfo)
                    Text("Henüz teslimat yok")
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Weekly Brief View

struct WeeklyBriefView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.nuviaGoldFallback)

                        Text("Bu Haftanın Özeti")
                            .font(NuviaTypography.title1())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("1 dakikalık planlama")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                    .padding(.top, 24)

                    // This week's tasks
                    NuviaCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checklist")
                                    .foregroundColor(.nuviaInfo)
                                Text("Bu Haftanın Görevleri")
                                    .font(NuviaTypography.bodyBold())
                            }

                            Text("5 görev tamamlanmayı bekliyor")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }

                    // This week's payments
                    NuviaCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "creditcard.fill")
                                    .foregroundColor(.nuviaSuccess)
                                Text("Bu Haftanın Ödemeleri")
                                    .font(NuviaTypography.bodyBold())
                            }

                            Text("₺25,000 ödeme yapılacak")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }

                    // Pending RSVPs
                    NuviaCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.categoryDress)
                                Text("Bekleyen RSVP'ler")
                                    .font(NuviaTypography.bodyBold())
                            }

                            Text("15 kişi henüz yanıt vermedi")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .background(Color.nuviaBackground)
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

// MARK: - Notifications Inbox

struct NotificationsInboxView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                NuviaEmptyState(
                    icon: "bell.slash",
                    title: "Bildirim yok",
                    message: "Yeni bildirimleriniz burada görünecek"
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.nuviaBackground)
            .navigationTitle("Bildirimler")
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

#Preview {
    TodayDashboardView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
