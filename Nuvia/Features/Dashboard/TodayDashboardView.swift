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
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
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
                        .padding(.bottom, DesignTokens.Spacing.xl)

                    if let project = currentProject {
                        VStack(spacing: DesignTokens.Spacing.sectionSpacing) {
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
                        .padding(.horizontal, DesignTokens.Spacing.nuviaMargin)
                    } else {
                        NuviaEmptyState(
                            icon: "heart.slash",
                            title: "No Project Found",
                            message: "Create a wedding project to get started"
                        )
                        .padding(.horizontal, DesignTokens.Spacing.nuviaMargin)
                    }
                }
                .padding(.bottom, DesignTokens.Spacing.scrollBottomInset)
            }
            .background(
                Color.themed.backgroundGradient
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
                            .foregroundColor(.nuviaChampagne)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 20) {
                        Button {
                            showNotifications = true
                        } label: {
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .medium))
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

    // MARK: - Hero Header (Magazine Cover Style)

    private var heroHeader: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Date & Greeting
            VStack(spacing: DesignTokens.Spacing.xs) {
                Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(NuviaTypography.overline())
                    .tracking(2)
                    .foregroundColor(.nuviaSecondaryText)
                    .textCase(.uppercase)

                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: greetingEmoji)
                        .font(.system(size: 24))
                        .foregroundStyle(Color.etherealGradient)

                    Text(greeting)
                        .font(NuviaTypography.displaySmall())
                        .foregroundColor(.nuviaPrimaryText)
                }
            }
            .padding(.top, DesignTokens.Spacing.xl)

            // Couple Names (if available)
            if let project = currentProject {
                Text("\(project.partnerName1) & \(project.partnerName2)")
                    .font(NuviaTypography.title3())
                    .foregroundColor(.nuviaSecondaryText)
                    .padding(.top, DesignTokens.Spacing.xxs)
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
            Text("TODAY'S FOCUS")
                .font(NuviaTypography.overline())
                .tracking(2)
                .foregroundColor(.nuviaChampagne)

            if let task = priorityTask {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(task.taskCategory.color)
                            .frame(width: 8, height: 8)

                        Text(task.taskCategory.displayName)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)

                        Spacer()

                        if let dueDate = task.dueDate {
                            Text(dueDate.formatted(.dateTime.month(.abbreviated).day()))
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaTertiaryText)
                        }
                    }

                    Text(task.title)
                        .font(NuviaTypography.title2())
                        .foregroundColor(.nuviaPrimaryText)
                        .lineLimit(2)

                    if let desc = task.taskDescription, !desc.isEmpty {
                        Text(desc)
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
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
                                Text("Complete")
                                    .font(NuviaTypography.smallButton())
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.nuviaPrimaryAction)
                            .cornerRadius(24)
                        }
                        .pressEffect()
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(Color.nuviaSurface)
                .cornerRadius(24)
                .etherealShadow(.soft)
            } else {
                // All caught up state
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.etherealGradient)

                    Text("All Caught Up")
                        .font(NuviaTypography.title3())
                        .foregroundColor(.nuviaPrimaryText)

                    Text("No urgent tasks for today")
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(Color.nuviaSurface)
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
                    .font(NuviaTypography.countdown())
                    .foregroundStyle(Color.etherealGradient)

                Text("days to go")
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.nuviaTertiaryBackground)
                .frame(width: 1, height: 60)

            // Date
            VStack(spacing: 4) {
                Text(project.weddingDate.formatted(.dateTime.month(.abbreviated).day()))
                    .font(NuviaTypography.title1())
                    .foregroundColor(.nuviaPrimaryText)

                Text(project.weddingDate.formatted(.dateTime.year()))
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.nuviaTertiaryBackground)
                .frame(width: 1, height: 60)

            // Venue
            VStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.nuviaChampagne)

                Text(project.venueName ?? "Venue")
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color.nuviaSurface)
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
            Text("PROGRESS")
                .font(NuviaTypography.overline())
                .tracking(2)
                .foregroundColor(.nuviaChampagne)

            HStack(spacing: 16) {
                // Tasks Progress
                ProgressCard(
                    title: "Tasks",
                    value: "\(completedTasks)/\(totalTasks)",
                    progress: progress,
                    color: .nuviaSage
                )

                // Budget Progress
                ProgressCard(
                    title: "Budget",
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
            Text("QUICK ACCESS")
                .font(NuviaTypography.overline())
                .tracking(2)
                .foregroundColor(.nuviaChampagne)

            QuickActionsGrid()
        }
    }

    // MARK: - Metrics Section

    private func metricsSection(project: WeddingProject) -> some View {
        let attending = project.guests.filter { $0.rsvp == .attending }.reduce(0) { $0 + 1 + $1.plusOneCount }
        let pending = project.guests.filter { $0.rsvp == .pending }.count
        let totalGuests = project.guests.count

        return VStack(alignment: .leading, spacing: 20) {
            Text("AT A GLANCE")
                .font(NuviaTypography.overline())
                .tracking(2)
                .foregroundColor(.nuviaChampagne)

            HStack(spacing: 12) {
                // RSVP Card
                MetricCard(
                    icon: "person.2.fill",
                    title: "Attending",
                    value: "\(attending)",
                    subtitle: "\(pending) pending",
                    color: .nuviaSage
                )

                // Budget Card
                MetricCard(
                    icon: "creditcard.fill",
                    title: "Spent",
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
            Text("COMING UP")
                .font(NuviaTypography.overline())
                .tracking(2)
                .foregroundColor(.nuviaChampagne)

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
                            .foregroundColor(.nuviaSuccess)

                        Text("No upcoming deadlines")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.nuviaSurface)
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
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaSecondaryText)

            Text(value)
                .font(NuviaTypography.title3())
                .foregroundColor(.nuviaPrimaryText)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.nuviaTertiaryBackground)
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
        .background(Color.nuviaSurface)
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
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }

            Text(value)
                .font(NuviaTypography.title2())
                .foregroundColor(.nuviaPrimaryText)

            Text(subtitle)
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaTertiaryText)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.nuviaSurface)
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
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)
                    .lineLimit(1)

                Text(subtitle)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.nuviaTertiaryText)
        }
        .padding(16)
        .background(Color.nuviaSurface)
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
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
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
                VStack(spacing: DesignTokens.Spacing.xl) {
                    // Hero Header
                    VStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "newspaper.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.etherealGradient)

                        Text("Weekly Brief")
                            .font(NuviaTypography.displaySmall())
                            .foregroundColor(.nuviaPrimaryText)

                        Text(Date().formatted(.dateTime.month(.wide).day().year()))
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                    .padding(.top, DesignTokens.Spacing.xl)

                    VStack(spacing: DesignTokens.Spacing.cardPadding) {
                        // This week's summary
                        BriefSection(
                            icon: "checklist",
                            iconColor: .nuviaSage,
                            title: "This Week's Tasks",
                            value: "5 tasks",
                            description: "Focus on venue confirmation and catering menu selection"
                        )

                        BriefSection(
                            icon: "creditcard.fill",
                            iconColor: .nuviaChampagne,
                            title: "Upcoming Payments",
                            value: "₺25,000",
                            description: "Venue deposit due in 3 days"
                        )

                        BriefSection(
                            icon: "person.2.fill",
                            iconColor: .nuviaRoseDust,
                            title: "RSVP Update",
                            value: "15 pending",
                            description: "Send reminders to guests who haven't responded"
                        )

                        BriefSection(
                            icon: "lightbulb.fill",
                            iconColor: .nuviaWisteria,
                            title: "Pro Tip",
                            value: nil,
                            description: "Schedule vendor meetings at least 2 weeks before your decision deadline"
                        )
                    }
                    .padding(.horizontal, DesignTokens.Spacing.nuviaMargin)

                    Spacer(minLength: DesignTokens.Spacing.xxl)
                }
            }
            .background(
                Color.themed.backgroundGradient
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
                            .foregroundColor(.nuviaSecondaryText)
                            .frame(width: 32, height: 32)
                            .background(Color.nuviaSurface)
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
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: DesignTokens.Touch.comfortable, height: DesignTokens.Touch.comfortable)
                .background(iconColor.opacity(0.1))
                .cornerRadius(DesignTokens.Radius.md)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs + 2) {
                HStack {
                    Text(title)
                        .font(NuviaTypography.bodyBold())
                        .foregroundColor(.nuviaPrimaryText)

                    Spacer()

                    if let value = value {
                        Text(value)
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(iconColor)
                    }
                }

                Text(description)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .lineLimit(2)
            }
        }
        .padding(DesignTokens.Spacing.cardPadding)
        .background(Color.nuviaSurface)
        .cornerRadius(DesignTokens.Radius.xl)
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
                        .foregroundColor(.nuviaTertiaryText)

                    Text("All Caught Up")
                        .font(NuviaTypography.title2())
                        .foregroundColor(.nuviaPrimaryText)

                    Text("You have no new notifications")
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.nuviaBackground.ignoresSafeArea())
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.nuviaSecondaryText)
                            .frame(width: 32, height: 32)
                            .background(Color.nuviaSurface)
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
