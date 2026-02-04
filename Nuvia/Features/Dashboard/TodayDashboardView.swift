import SwiftUI
import SwiftData

// MARK: - Premium Dashboard
// Magazine-style editorial dashboard with stunning animations

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
                ScrollOffsetReader()

                VStack(spacing: 0) {
                    if let project = currentProject {
                        // Hero Section with Parallax
                        heroSection(project: project)
                            .padding(.bottom, DSSpacing.xl)

                        // Main Content
                        VStack(spacing: DSSpacing.sectionSpacing) {
                            // Live Countdown Card
                            liveCountdownCard(project: project)
                                .cardEntrance(delay: 0.05)

                            // Today's Priority Task
                            todaysPriorityCard(project: project)
                                .cardEntrance(delay: 0.1)

                            // Stats Grid
                            statsGrid(project: project)
                                .cardEntrance(delay: 0.15)

                            // Quick Actions
                            quickActionsSection
                                .cardEntrance(delay: 0.2)

                            // Upcoming Timeline
                            upcomingTimeline(project: project)
                                .cardEntrance(delay: 0.25)
                        }
                        .padding(.horizontal, DSSpacing.nuviaMargin)
                    } else {
                        emptyStateView
                    }
                }
                .padding(.bottom, DSSpacing.scrollBottomInset)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
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

    // MARK: - Hero Section

    private func heroSection(project: WeddingProject) -> some View {
        let parallaxOffset = max(0, scrollOffset * 0.4)
        let opacity = 1 - min(1, scrollOffset / 300) * 0.3
        let scale = 1 - min(1, scrollOffset / 400) * 0.1

        return VStack(spacing: DSSpacing.md) {
            // Date
            Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(DSTypography.overline)
                .tracking(2)
                .foregroundColor(DSColors.textSecondary)
                .textCase(.uppercase)

            // Greeting
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: greetingEmoji)
                    .font(.system(size: 28))
                    .foregroundStyle(DSColors.heroGradient)

                Text(greeting)
                    .font(DSTypography.displaySmall)
                    .foregroundColor(DSColors.textPrimary)
            }

            // Couple Names with Heart
            HStack(spacing: DSSpacing.sm) {
                Text(project.partnerName1)
                    .font(DSTypography.heading3)
                    .foregroundColor(DSColors.textPrimary)

                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(DSColors.accentRose)

                Text(project.partnerName2)
                    .font(DSTypography.heading3)
                    .foregroundColor(DSColors.textPrimary)
            }
            .padding(.top, DSSpacing.xxs)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xl)
        .offset(y: -parallaxOffset)
        .opacity(opacity)
        .scaleEffect(scale)
    }

    // MARK: - Live Countdown Card

    private func liveCountdownCard(project: WeddingProject) -> some View {
        VStack(spacing: DSSpacing.lg) {
            // Countdown Arc
            CountdownArcView(
                daysRemaining: project.daysUntilWedding,
                totalDays: 365,
                weddingDate: project.weddingDate,
                size: 200,
                strokeWidth: 12
            )

            // Live Timer
            LiveCountdownView(weddingDate: project.weddingDate)
                .padding(.top, DSSpacing.sm)

            // Wedding Date
            HStack(spacing: DSSpacing.md) {
                Image(systemName: "calendar")
                    .foregroundColor(DSColors.primaryAction)

                Text(project.weddingDate.formatted(.dateTime.day().month(.wide).year()))
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)

                if let venue = project.venueName {
                    Text("•")
                        .foregroundColor(DSColors.textTertiary)

                    Image(systemName: "mappin")
                        .foregroundColor(DSColors.primaryAction)

                    Text(venue)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(DSSpacing.xl)
        .background(DSColors.surface)
        .cornerRadius(DSRadii.cardHero)
        .etherealShadow(.medium, colored: .nuviaChampagne)
    }

    // MARK: - Today's Priority Card

    private func todaysPriorityCard(project: WeddingProject) -> some View {
        let priorityTask = project.tasks
            .filter { $0.status != TaskStatus.completed.rawValue }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
            .first

        return VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Header
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(DSColors.primaryAction)

                Text("BUGÜNÜN ÖNCELİĞİ")
                    .font(DSTypography.overline)
                    .tracking(2)
                    .foregroundColor(DSColors.primaryAction)

                Spacer()
            }

            if let task = priorityTask {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    // Category Badge
                    HStack(spacing: DSSpacing.xs) {
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

                    // Task Title
                    Text(task.title)
                        .font(DSTypography.heading2)
                        .foregroundColor(DSColors.textPrimary)
                        .lineLimit(2)

                    // Description
                    if let desc = task.taskDescription, !desc.isEmpty {
                        Text(desc)
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                            .lineLimit(2)
                    }

                    // Complete Button
                    HStack {
                        Spacer()
                        Button {
                            task.status = TaskStatus.completed.rawValue
                            HapticManager.shared.success()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Tamamla")
                                    .font(DSTypography.buttonSmall)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(DSColors.heroGradient)
                            .cornerRadius(28)
                        }
                        .pressEffect()
                    }
                    .padding(.top, DSSpacing.sm)
                }
            } else {
                // All done state
                HStack(spacing: DSSpacing.md) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(DSColors.heroGradient)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Her Şey Tamam!")
                            .font(DSTypography.heading3)
                            .foregroundColor(DSColors.textPrimary)

                        Text("Bekleyen acil görev yok")
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(DSSpacing.cardPadding)
        .background(DSColors.surface)
        .cornerRadius(DSRadii.card)
        .etherealShadow(.soft)
    }

    // MARK: - Stats Grid

    private func statsGrid(project: WeddingProject) -> some View {
        let completedTasks = project.tasks.filter { $0.status == TaskStatus.completed.rawValue }.count
        let totalTasks = max(project.tasks.count, 1)
        let taskProgress = Double(completedTasks) / Double(totalTasks)

        let totalBudget = project.totalBudget
        let spentBudget = project.expenses.reduce(0) { $0 + $1.amount }
        let budgetProgress = totalBudget > 0 ? min(1.0, spentBudget / totalBudget) : 0

        let attending = project.guests.filter { $0.rsvp == .attending }.reduce(0) { $0 + 1 + $1.plusOneCount }
        let pending = project.guests.filter { $0.rsvp == .pending }.count
        let totalGuests = project.guests.count

        return VStack(spacing: DSSpacing.md) {
            // Row 1: Tasks & Budget
            HStack(spacing: DSSpacing.md) {
                // Tasks Progress
                StatCard(
                    icon: "checkmark.circle.fill",
                    iconColor: .nuviaSage,
                    title: "Görevler",
                    value: "\(completedTasks)/\(totalTasks)",
                    progress: taskProgress,
                    progressColor: .nuviaSage
                )

                // Budget Progress
                StatCard(
                    icon: "creditcard.fill",
                    iconColor: .nuviaChampagne,
                    title: "Bütçe",
                    value: formatCurrency(spentBudget, currency: project.currency),
                    subtitle: "/ \(formatCurrency(totalBudget, currency: project.currency))",
                    progress: budgetProgress,
                    progressColor: .nuviaChampagne
                )
            }

            // Row 2: Guests
            HStack(spacing: DSSpacing.md) {
                // Attending
                MiniStatCard(
                    icon: "person.fill.checkmark",
                    iconColor: .nuviaSage,
                    value: "\(attending)",
                    label: "Katılıyor"
                )

                // Pending
                MiniStatCard(
                    icon: "person.fill.questionmark",
                    iconColor: .nuviaWarning,
                    value: "\(pending)",
                    label: "Bekliyor"
                )

                // Total
                MiniStatCard(
                    icon: "person.2.fill",
                    iconColor: .nuviaInfo,
                    value: "\(totalGuests)",
                    label: "Toplam"
                )
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("HIZLI ERİŞİM")
                .font(DSTypography.overline)
                .tracking(2)
                .foregroundColor(DSColors.primaryAction)

            QuickActionsGrid()
        }
    }

    // MARK: - Upcoming Timeline

    private func upcomingTimeline(project: WeddingProject) -> some View {
        let upcomingTasks = project.tasks
            .filter { $0.status != TaskStatus.completed.rawValue && $0.dueDate != nil }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
            .prefix(4)
            .map { $0 }

        return VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("YAKLAŞAN GÖREVLER")
                .font(DSTypography.overline)
                .tracking(2)
                .foregroundColor(DSColors.primaryAction)

            if upcomingTasks.isEmpty {
                HStack(spacing: DSSpacing.md) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 24))
                        .foregroundColor(DSColors.success)

                    Text("Yaklaşan görev yok")
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DSSpacing.cardPadding)
                .background(DSColors.surface)
                .cornerRadius(DSRadii.card)
                .etherealShadow(.whisper)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(upcomingTasks.enumerated()), id: \.element.id) { index, task in
                        TimelineItem(
                            task: task,
                            isLast: index == upcomingTasks.count - 1
                        )
                    }
                }
                .padding(DSSpacing.md)
                .background(DSColors.surface)
                .cornerRadius(DSRadii.card)
                .etherealShadow(.soft)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()

            Image(systemName: "heart.text.square")
                .font(.system(size: 64))
                .foregroundStyle(DSColors.heroGradient)

            Text("Projeniz Yok")
                .font(DSTypography.heading1)
                .foregroundColor(DSColors.textPrimary)

            Text("Düğün planlamaya başlamak için\nbir proje oluşturun")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(DSSpacing.xl)
    }

    // MARK: - Helpers

    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let symbol = Currency(rawValue: currency)?.symbol ?? "₺"
        return "\(symbol)\(Int(amount).formatted())"
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var subtitle: String? = nil
    let progress: Double
    let progressColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(DSTypography.heading2)
                    .foregroundColor(DSColors.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textTertiary)
                }
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DSColors.surfaceTertiary)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)
        }
        .padding(DSSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .cornerRadius(DSRadii.card)
        .etherealShadow(.whisper)
    }
}

// MARK: - Mini Stat Card

struct MiniStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)

            Text(value)
                .font(DSTypography.heading2)
                .foregroundColor(DSColors.textPrimary)

            Text(label)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DSSpacing.md)
        .background(DSColors.surface)
        .cornerRadius(DSRadii.card)
        .etherealShadow(.whisper)
    }
}

// MARK: - Timeline Item

struct TimelineItem: View {
    let task: Task
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            // Timeline dot and line
            VStack(spacing: 0) {
                Circle()
                    .fill(task.taskCategory.color)
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(DSColors.surfaceTertiary)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(DSTypography.bodyBold)
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: DSSpacing.xs) {
                    Text(task.taskCategory.displayName)
                        .font(DSTypography.caption)
                        .foregroundColor(task.taskCategory.color)

                    if let dueDate = task.dueDate {
                        Text("•")
                            .foregroundColor(DSColors.textTertiary)

                        Text(dueDate.formatted(.dateTime.month(.abbreviated).day()))
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.textTertiary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DSColors.textTertiary)
        }
        .padding(.vertical, DSSpacing.sm)
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
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            QuickActionItem(icon: "clock.badge.checkmark", title: "Akış", color: .nuviaWisteria) {
                showRunOfShow = true
            }
            QuickActionItem(icon: "person.2.badge.gearshape", title: "Tedarik", color: .nuviaDustyBlue) {
                showVendors = true
            }
            QuickActionItem(icon: "lock.doc", title: "Dosyalar", color: .nuviaTerracotta) {
                showFileVault = true
            }
            QuickActionItem(icon: "leaf.fill", title: "Zen", color: .nuviaSage) {
                showZenMode = true
            }
            QuickActionItem(icon: "music.note.list", title: "Müzik", color: .nuviaRoseDust) {
                showMusicVoting = true
            }
            QuickActionItem(icon: "photo.on.rectangle", title: "Foto", color: .nuviaChampagne) {
                showPhotoStream = true
            }
            QuickActionItem(icon: "person.badge.shield.checkmark", title: "Giriş", color: .nuviaInfo) {
                showCheckIn = true
            }
            QuickActionItem(icon: "heart.text.square", title: "Sonra", color: .nuviaBlush) {
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

// MARK: - Quick Action Item

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
                    .background(color.opacity(0.12))
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

// MARK: - Weekly Brief View

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
                        BriefSection(
                            icon: "checklist",
                            iconColor: .nuviaSage,
                            title: "Bu Haftanın Görevleri",
                            value: "5 görev",
                            description: "Mekan onayı ve catering menü seçimine odaklanın"
                        )

                        BriefSection(
                            icon: "creditcard.fill",
                            iconColor: .nuviaChampagne,
                            title: "Yaklaşan Ödemeler",
                            value: "₺25.000",
                            description: "Mekan depozitosu 3 gün içinde ödenmeli"
                        )

                        BriefSection(
                            icon: "person.2.fill",
                            iconColor: .nuviaRoseDust,
                            title: "RSVP Durumu",
                            value: "15 bekliyor",
                            description: "Yanıt vermeyen davetlilere hatırlatma gönderin"
                        )

                        BriefSection(
                            icon: "lightbulb.fill",
                            iconColor: .nuviaWisteria,
                            title: "İpucu",
                            value: nil,
                            description: "Tedarikçi toplantılarını karar son tarihinden en az 2 hafta önce planlayın"
                        )
                    }
                    .padding(.horizontal, DSSpacing.nuviaMargin)

                    Spacer(minLength: DSSpacing.xxl)
                }
            }
            .background(DSColors.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
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
    }
}

// MARK: - Notifications Inbox

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
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
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
