import SwiftUI
import SwiftData

// MARK: - Morning Briefing Dashboard
// Magazine cover style dashboard - "Awwwards Mobile Excellence"

struct TodayDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var showNotifications = false
    @State private var showWeeklyBrief = false
    @State private var showSettings = false
    @State private var scrollOffset: CGFloat = 0

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Günaydın"
        case 12..<17: return "İyi Öğlenler"
        case 17..<21: return "İyi Akşamlar"
        default: return "İyi Geceler"
        }
    }

    private var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "sunrise.fill"
        case 12..<17: return "sun.max.fill"
        case 17..<21: return "sunset.fill"
        default: return "moon.stars.fill"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Magazine-style Hero Header
                    heroHeader
                        .padding(.bottom, DSSpacing.xl)

                    if let project = currentProject {
                        VStack(spacing: DSSpacing.sectionSpacing) {
                            // Today's Focus - Featured Card
                            todaysFocusSection(project: project)
                                .cardEntrance(delay: 0.05)

                            // Countdown - Elegant Timeline
                            countdownSection(project: project)
                                .cardEntrance(delay: 0.1)

                            // Progress Overview
                            progressOverview(project: project)
                                .cardEntrance(delay: 0.15)

                            // Quick Actions - Minimal Grid
                            quickActionsSection
                                .cardEntrance(delay: 0.2)

                            // RSVP & Budget Summary
                            metricsSection(project: project)
                                .cardEntrance(delay: 0.25)

                            // Upcoming - Timeline Style
                            upcomingSection(project: project)
                                .cardEntrance(delay: 0.3)
                        }
                        .padding(.horizontal, DSSpacing.nuviaMargin)
                    } else {
                        NuviaEmptyState(
                            icon: "heart.slash",
                            title: "Proje Yok",
                            message: "İlk düğün projenizi oluşturun"
                        )
                        .padding(.horizontal, DSSpacing.nuviaMargin)
                    }
                }
                .padding(.bottom, DSSpacing.scrollBottomInset)
            }
            .background(
                DSColors.backgroundGradient
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showWeeklyBrief = true
                    } label: {
                        Image(systemName: "newspaper")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(DSColors.primaryAction)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 20) {
                        Button {
                            showNotifications = true
                        } label: {
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(DSColors.textSecondary)
                        }

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(DSColors.textSecondary)
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

    // MARK: - Hero Header (Magazine Cover Style)

    private var heroHeader: some View {
        VStack(spacing: DSSpacing.md) {
            // Date & Greeting
            VStack(spacing: DSSpacing.xs) {
                Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(DSTypography.overline)
                    .tracking(2)
                    .foregroundColor(DSColors.textSecondary)
                    .textCase(.uppercase)

                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: greetingEmoji)
                        .font(.system(size: 24))
                        .foregroundStyle(DSColors.heroGradient)

                    Text(greeting)
                        .font(DSTypography.displaySmall)
                        .foregroundColor(DSColors.textPrimary)
                }
            }
            .padding(.top, DSSpacing.xl)

            // Couple Names (if available)
            if let project = currentProject {
                Text("\(project.partnerName1) & \(project.partnerName2)")
                    .font(DSTypography.heading3)
                    .foregroundColor(DSColors.textSecondary)
                    .padding(.top, DSSpacing.xxs)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(greeting). \(currentProject?.partnerName1 ?? "") and \(currentProject?.partnerName2 ?? "")")
    }

    // MARK: - Today's Focus Section

    private func todaysFocusSection(project: WeddingProject) -> some View {
        let priorityTask = project.tasks
            .filter { $0.status != TaskStatus.completed.rawValue }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
            .first

        return VStack(alignment: .leading, spacing: 16) {
            Text("Bugünün Odağı")
                .font(DSTypography.overline)
                .tracking(2)
                .foregroundColor(DSColors.primaryAction)

            if let task = priorityTask {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(task.taskCategory.color)
                            .frame(width: 8, height: 8)

                        Text(task.taskCategory.displayName)
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.textSecondary)

                        Spacer()

                        if let dueDate = task.dueDate {
                            Text(dueDate.formatted(.dateTime.month(.abbreviated).day()))
                                .font(DSTypography.caption)
                                .foregroundColor(DSColors.textTertiary)
                        }
                    }

                    Text(task.title)
                        .font(DSTypography.heading2)
                        .foregroundColor(DSColors.textPrimary)
                        .lineLimit(2)

                    if let desc = task.taskDescription, !desc.isEmpty {
                        Text(desc)
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                            .lineLimit(2)
                    }

                    // Action Button
                    HStack {
                        Spacer()

                        Button {
                            // Mark as complete
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Tamamla")
                                    .font(DSTypography.buttonSmall)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(DSColors.primaryAction)
                            .cornerRadius(24)
                        }
                        .pressEffect()
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(DSColors.surface)
                .cornerRadius(24)
                .etherealShadow(.soft)
            } else {
                // All caught up state
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(DSColors.heroGradient)

                    Text("Her Şey Tamam!")
                        .font(DSTypography.heading3)
                        .foregroundColor(DSColors.textPrimary)

                    Text("Acil görev yok")
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(DSColors.surface)
                .cornerRadius(24)
                .etherealShadow(.soft)
            }
        }
    }

    // MARK: - Countdown Section (Elegant Timeline)

    private func countdownSection(project: WeddingProject) -> some View {
        HStack(spacing: 0) {
            // Days countdown
            VStack(spacing: 4) {
                Text("\(project.daysUntilWedding)")
                    .font(DSTypography.countdown)
                    .foregroundStyle(DSColors.heroGradient)

                Text("gün kaldı")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(DSColors.surfaceTertiary)
                .frame(width: 1, height: 60)

            // Date
            VStack(spacing: 4) {
                Text(project.weddingDate.formatted(.dateTime.month(.abbreviated).day()))
                    .font(DSTypography.heading1)
                    .foregroundColor(DSColors.textPrimary)

                Text(project.weddingDate.formatted(.dateTime.year()))
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(DSColors.surfaceTertiary)
                .frame(width: 1, height: 60)

            // Venue
            VStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DSColors.primaryAction)

                Text(project.venueName ?? "Venue")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(DSColors.surface)
        .cornerRadius(24)
        .etherealShadow(.whisper)
    }

    // MARK: - Progress Overview

    private func progressOverview(project: WeddingProject) -> some View {
        let completedTasks = project.tasks.filter { $0.status == TaskStatus.completed.rawValue }.count
        let totalTasks = max(project.tasks.count, 1)
        let progress = Double(completedTasks) / Double(totalTasks)

        let totalBudget = project.totalBudget
        let spentBudget = project.expenses.reduce(0) { $0 + $1.amount }
        let budgetProgress = totalBudget > 0 ? min(1.0, spentBudget / totalBudget) : 0

        return VStack(alignment: .leading, spacing: 20) {
            Text("İlerleme".uppercased())
                .font(DSTypography.overline)
                .tracking(2)
                .foregroundColor(DSColors.primaryAction)

            HStack(spacing: 16) {
                // Tasks Progress
                ProgressCard(
                    title: "Görevler",
                    value: "\(completedTasks)/\(totalTasks)",
                    progress: progress,
                    color: .nuviaSage
                )

                // Budget Progress
                ProgressCard(
                    title: "Bütçe",
                    value: "\(Int(budgetProgress * 100))%",
                    progress: budgetProgress,
                    color: .nuviaChampagne
                )
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        @State var showRunOfShow = false
        @State var showVendors = false
        @State var showFileVault = false
        @State var showZenMode = false

        return VStack(alignment: .leading, spacing: 20) {
            Text("Hızlı Erişim".uppercased())
                .font(DSTypography.overline)
                .tracking(2)
                .foregroundColor(DSColors.primaryAction)

            QuickActionsGrid()
        }
    }

    // MARK: - Metrics Section

    private func metricsSection(project: WeddingProject) -> some View {
        let attending = project.guests.filter { $0.rsvp == .attending }.reduce(0) { $0 + 1 + $1.plusOneCount }
        let pending = project.guests.filter { $0.rsvp == .pending }.count
        let totalGuests = project.guests.count

        return VStack(alignment: .leading, spacing: 20) {
            Text("Bir Bakışta".uppercased())
                .font(DSTypography.overline)
                .tracking(2)
                .foregroundColor(DSColors.primaryAction)

            HStack(spacing: 12) {
                // RSVP Card
                MetricCard(
                    icon: "person.2.fill",
                    title: "Katılıyor",
                    value: "\(attending)",
                    subtitle: "\(pending) \("bekliyor".lowercased())",
                    color: .nuviaSage
                )

                // Budget Card
                MetricCard(
                    icon: "creditcard.fill",
                    title: "Harcanan",
                    value: formatCurrency(project.expenses.reduce(0) { $0 + $1.amount }, currency: project.currency),
                    subtitle: "of \(formatCurrency(project.totalBudget, currency: project.currency))",
                    color: .nuviaChampagne
                )
            }
        }
    }

    // MARK: - Upcoming Section

    private func upcomingSection(project: WeddingProject) -> some View {
        let upcomingTasks = project.tasks
            .filter { $0.status != TaskStatus.completed.rawValue && $0.dueDate != nil }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
            .prefix(3)
            .map { $0 }

        let upcomingPayments = project.expenses
            .filter { !$0.isPaid && $0.daysUntilDue >= 0 }
            .sorted { $0.date < $1.date }
            .prefix(2)
            .map { $0 }

        return VStack(alignment: .leading, spacing: 20) {
            Text("Yaklaşanlar".uppercased())
                .font(DSTypography.overline)
                .tracking(2)
                .foregroundColor(DSColors.primaryAction)

            VStack(spacing: 12) {
                ForEach(upcomingTasks, id: \.id) { task in
                    UpcomingItem(
                        icon: task.taskCategory.icon,
                        title: task.title,
                        subtitle: task.dueDate?.formatted(.dateTime.month(.abbreviated).day()) ?? "",
                        color: task.taskCategory.color,
                        type: .task
                    )
                }

                ForEach(upcomingPayments, id: \.id) { expense in
                    UpcomingItem(
                        icon: "creditcard.fill",
                        title: expense.title,
                        subtitle: formatCurrency(expense.amount, currency: project.currency),
                        color: .nuviaWarning,
                        type: .payment
                    )
                }

                if upcomingTasks.isEmpty && upcomingPayments.isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 20))
                            .foregroundColor(DSColors.success)

                        Text("Yaklaşan son tarih yok")
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(DSColors.surface)
                    .cornerRadius(16)
                    .etherealShadow(.whisper)
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let symbol = Currency(rawValue: currency)?.symbol ?? "₺"
        return "\(symbol)\(Int(amount).formatted())"
    }
}

// MARK: - Progress Card

struct ProgressCard: View {
    let title: String
    let value: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)

            Text(value)
                .font(DSTypography.heading3)
                .foregroundColor(DSColors.textPrimary)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DSColors.surfaceTertiary)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .cornerRadius(20)
        .etherealShadow(.whisper)
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Text(title)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
            }

            Text(value)
                .font(DSTypography.heading2)
                .foregroundColor(DSColors.textPrimary)

            Text(subtitle)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textTertiary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .cornerRadius(20)
        .etherealShadow(.whisper)
    }
}

// MARK: - Upcoming Item

struct UpcomingItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let type: ItemType

    enum ItemType {
        case task, payment
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DSColors.textTertiary)
        }
        .padding(16)
        .background(DSColors.surface)
        .cornerRadius(16)
        .etherealShadow(.whisper)
    }
}

// MARK: - Quick Actions Grid (Redesigned)

struct QuickActionsGrid: View {
    @State private var showRunOfShow = false
    @State private var showFileVault = false
    @State private var showZenMode = false
    @State private var showMusicVoting = false
    @State private var showPhotoStream = false
    @State private var showCheckIn = false
    @State private var showPostWedding = false
    @State private var showVendors = false

    private let actions: [(icon: String, title: String, color: Color)] = [
        ("clock.badge.checkmark", "Timeline", .nuviaWisteria),
        ("person.2.badge.gearshape", "Vendors", .nuviaDustyBlue),
        ("lock.doc", "Files", .nuviaTerracotta),
        ("leaf.fill", "Zen Mode", .nuviaSage),
        ("music.note.list", "Music", .nuviaRoseDust),
        ("photo.on.rectangle", "Photos", .nuviaChampagne),
        ("person.badge.shield.checkmark", "Check-in", .nuviaInfo),
        ("heart.text.square", "Post-Wedding", .nuviaBlush)
    ]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            QuickActionItem(icon: "clock.badge.checkmark", title: "Timeline", color: .nuviaWisteria) {
                showRunOfShow = true
            }
            QuickActionItem(icon: "person.2.badge.gearshape", title: "Vendors", color: .nuviaDustyBlue) {
                showVendors = true
            }
            QuickActionItem(icon: "lock.doc", title: "Files", color: .nuviaTerracotta) {
                showFileVault = true
            }
            QuickActionItem(icon: "leaf.fill", title: "Zen", color: .nuviaSage) {
                showZenMode = true
            }
            QuickActionItem(icon: "music.note.list", title: "Music", color: .nuviaRoseDust) {
                showMusicVoting = true
            }
            QuickActionItem(icon: "photo.on.rectangle", title: "Photos", color: .nuviaChampagne) {
                showPhotoStream = true
            }
            QuickActionItem(icon: "person.badge.shield.checkmark", title: "Check-in", color: .nuviaInfo) {
                showCheckIn = true
            }
            QuickActionItem(icon: "heart.text.square", title: "After", color: .nuviaBlush) {
                showPostWedding = true
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

// MARK: - Quick Action Item (Minimal Style)

struct QuickActionItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 52, height: 52)
                    .background(color.opacity(0.1))
                    .cornerRadius(16)

                Text(title)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                    .lineLimit(1)
            }
        }
        .pressEffect()
    }
}

// MARK: - Weekly Brief View (Redesigned)

struct WeeklyBriefView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.xl) {
                    // Hero Header
                    VStack(spacing: DSSpacing.md) {
                        Image(systemName: "newspaper.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(DSColors.heroGradient)

                        Text("Haftalık Özet")
                            .font(DSTypography.displaySmall)
                            .foregroundColor(DSColors.textPrimary)

                        Text(Date().formatted(.dateTime.month(.wide).day().year()))
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                    }
                    .padding(.top, DSSpacing.xl)

                    VStack(spacing: DSSpacing.cardPadding) {
                        // This week's summary
                        BriefSection(
                            icon: "checklist",
                            iconColor: .nuviaSage,
                            title: "Bu Haftanın Görevleri",
                            value: "5 tasks",
                            description: "Focus on venue confirmation and catering menu selection"
                        )

                        BriefSection(
                            icon: "creditcard.fill",
                            iconColor: .nuviaChampagne,
                            title: "Yaklaşan Ödemeler",
                            value: "₺25,000",
                            description: "Venue deposit due in 3 days"
                        )

                        BriefSection(
                            icon: "person.2.fill",
                            iconColor: .nuviaRoseDust,
                            title: "RSVP Durumu",
                            value: "15 pending",
                            description: "Send reminders to guests who haven't responded"
                        )

                        BriefSection(
                            icon: "lightbulb.fill",
                            iconColor: .nuviaWisteria,
                            title: "İpucu",
                            value: nil,
                            description: "Schedule vendor meetings at least 2 weeks before your decision deadline"
                        )
                    }
                    .padding(.horizontal, DSSpacing.nuviaMargin)

                    Spacer(minLength: DSSpacing.xxl)
                }
            }
            .background(
                DSColors.backgroundGradient
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DSColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(DSColors.surface)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// MARK: - Brief Section

struct BriefSection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String?
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 48, height: 48)
                .background(iconColor.opacity(0.1))
                .cornerRadius(DSRadii.md)

            VStack(alignment: .leading, spacing: DSSpacing.xxs + 2) {
                HStack {
                    Text(title)
                        .font(DSTypography.bodyBold)
                        .foregroundColor(DSColors.textPrimary)

                    Spacer()

                    if let value = value {
                        Text(value)
                            .font(DSTypography.bodyBold)
                            .foregroundColor(iconColor)
                    }
                }

                Text(description)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.surface)
        .cornerRadius(DSRadii.xl)
        .etherealShadow(.whisper)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(value ?? ""). \(description)")
    }
}

// MARK: - Notifications Inbox (Redesigned)

struct NotificationsInboxView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 48))
                        .foregroundColor(DSColors.textTertiary)

                    Text("Her Şey Tamam!")
                        .font(DSTypography.heading2)
                        .foregroundColor(DSColors.textPrimary)

                    Text("Yeni bildirim yok")
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColors.background.ignoresSafeArea())
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DSColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(DSColors.surface)
                            .clipShape(Circle())
                    }
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
