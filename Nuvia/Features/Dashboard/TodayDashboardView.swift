import SwiftUI
import SwiftData

// MARK: - Premium Award-Worthy Dashboard
// Dramatic, modern editorial design with stunning visuals

struct TodayDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var showNotifications = false
    @State private var showWeeklyBrief = false
    @State private var showSettings = false
    @State private var scrollOffset: CGFloat = 0
    @State private var appeared = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Dynamic gradient background
                    backgroundGradient
                        .ignoresSafeArea()

                    // Floating decorative elements
                    floatingElements
                        .ignoresSafeArea()

                    // Main content
                    ScrollView(showsIndicators: false) {
                        ScrollOffsetReader(coordinateSpace: "scroll")

                        if let project = currentProject {
                            VStack(spacing: 0) {
                                // Dramatic Hero
                                dramaticHero(project: project, screenHeight: geometry.size.height)

                                // Content cards
                                contentSection(project: project)
                                    .padding(.top, -60)
                            }
                        } else {
                            emptyStateView
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showWeeklyBrief) { WeeklyBriefView() }
            .sheet(isPresented: $showNotifications) { NotificationsInboxView() }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .onAppear {
                withAnimation(.easeOut(duration: 1)) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "FDF8F3"),
                    Color(hex: "F9F5F0"),
                    Color(hex: "FBF7F2")
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Warm accent blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "D4AF37").opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(x: 150, y: -100)
                .blur(radius: 60)

            // Rose accent blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "E8D7D5").opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: -100, y: 400)
                .blur(radius: 50)
        }
    }

    // MARK: - Floating Elements

    private var floatingElements: some View {
        ZStack {
            // Subtle floating shapes
            ForEach(0..<6, id: \.self) { index in
                FloatingShape(index: index)
            }
        }
        .opacity(appeared ? 0.4 : 0)
    }

    // MARK: - Dramatic Hero

    private func dramaticHero(project: WeddingProject, screenHeight: CGFloat) -> some View {
        let parallaxOffset = max(0, scrollOffset * 0.5)
        let scale = 1 - min(1, scrollOffset / 500) * 0.15
        let opacity = 1 - min(1, scrollOffset / 400) * 0.5

        return VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)

            // Large countdown number
            VStack(spacing: 8) {
                Text("\(project.daysUntilWedding)")
                    .font(.system(size: 140, weight: .thin, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "2A2A2A"),
                                Color(hex: "4A4A4A")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(hex: "D4AF37").opacity(0.2), radius: 30, x: 0, y: 10)

                Text("gün kaldı")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .tracking(8)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "8A8A8A"))
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: -parallaxOffset)

            Spacer()
                .frame(height: 32)

            // Couple names
            HStack(spacing: 16) {
                Text(project.partnerName1)
                    .font(.system(size: 24, weight: .light, design: .serif))

                // Elegant ampersand
                Text("&")
                    .font(.system(size: 28, weight: .ultraLight, design: .serif))
                    .foregroundColor(Color(hex: "D4AF37"))

                Text(project.partnerName2)
                    .font(.system(size: 24, weight: .light, design: .serif))
            }
            .foregroundColor(Color(hex: "3A3A3A"))
            .opacity(opacity)
            .offset(y: -parallaxOffset * 0.7)

            Spacer()
                .frame(height: 16)

            // Wedding date pill
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                Text(project.weddingDate.formatted(.dateTime.day().month(.wide).year()))
                    .font(.system(size: 14, weight: .medium))

                if let venue = project.venueName, !venue.isEmpty {
                    Circle()
                        .fill(Color(hex: "D4AF37"))
                        .frame(width: 4, height: 4)

                    Image(systemName: "mappin")
                        .font(.system(size: 12))
                    Text(venue)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                }
            }
            .foregroundColor(Color(hex: "6A6A6A"))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
            )
            .opacity(opacity)
            .offset(y: -parallaxOffset * 0.5)

            Spacer()
                .frame(height: 80)
        }
        .frame(height: screenHeight * 0.55)
    }

    // MARK: - Content Section

    private func contentSection(project: WeddingProject) -> some View {
        VStack(spacing: 20) {
            // Live countdown strip
            liveCountdownStrip(project: project)
                .cardEntrance(delay: 0)

            // Stats bento grid
            statsbentoGrid(project: project)
                .cardEntrance(delay: 0.1)

            // Priority task
            priorityTaskCard(project: project)
                .cardEntrance(delay: 0.15)

            // Quick actions
            quickActionsCard
                .cardEntrance(delay: 0.2)

            Spacer()
                .frame(height: 120)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Live Countdown Strip

    private func liveCountdownStrip(project: WeddingProject) -> some View {
        LiveCountdownStrip(weddingDate: project.weddingDate)
    }

    // MARK: - Stats Bento Grid

    private func statsbentoGrid(project: WeddingProject) -> some View {
        let completedTasks = project.tasks.filter { $0.status == TaskStatus.completed.rawValue }.count
        let totalTasks = max(project.tasks.count, 1)
        let taskProgress = Double(completedTasks) / Double(totalTasks)

        let totalBudget = project.totalBudget
        let spentBudget = project.expenses.reduce(0) { $0 + $1.amount }
        let budgetProgress = totalBudget > 0 ? min(1.0, spentBudget / totalBudget) : 0
        let remainingBudget = max(0, totalBudget - spentBudget)

        let attending = project.guests.filter { $0.rsvp == .attending }.reduce(0) { $0 + 1 + $1.plusOneCount }
        let totalGuests = project.guests.count

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Tasks - Large card
                BentoCard(
                    title: "Görevler",
                    value: "\(Int(taskProgress * 100))%",
                    subtitle: "\(completedTasks)/\(totalTasks) tamamlandı",
                    icon: "checkmark.circle.fill",
                    color: Color(hex: "8BAA7C"),
                    progress: taskProgress,
                    size: .large
                )

                VStack(spacing: 12) {
                    // Guests
                    BentoCard(
                        title: "Davetli",
                        value: "\(attending)",
                        subtitle: "katılıyor",
                        icon: "person.2.fill",
                        color: Color(hex: "9B8AA6"),
                        size: .small
                    )

                    // Total guests
                    BentoCard(
                        title: "Toplam",
                        value: "\(totalGuests)",
                        subtitle: "davetli",
                        icon: "person.3.fill",
                        color: Color(hex: "8BA7C4"),
                        size: .small
                    )
                }
            }

            // Budget - Full width
            BentoCard(
                title: "Bütçe",
                value: formatCurrency(remainingBudget, currency: project.currency),
                subtitle: "kalan • \(formatCurrency(spentBudget, currency: project.currency)) harcandı",
                icon: "creditcard.fill",
                color: Color(hex: "D4AF37"),
                progress: budgetProgress,
                size: .wide
            )
        }
    }

    // MARK: - Priority Task Card

    private func priorityTaskCard(project: WeddingProject) -> some View {
        let priorityTask = project.tasks
            .filter { $0.status != TaskStatus.completed.rawValue }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
            .first

        return VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Circle()
                    .fill(Color(hex: "D4AF37"))
                    .frame(width: 8, height: 8)

                Text("SONRAKİ ADIM")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(Color(hex: "D4AF37"))

                Spacer()

                if let task = priorityTask, let dueDate = task.dueDate {
                    Text(dueDate.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "9A9A9A"))
                }
            }

            if let task = priorityTask {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: "2A2A2A"))
                        .lineLimit(2)

                    if let desc = task.taskDescription, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "7A7A7A"))
                            .lineLimit(2)
                    }
                }

                HStack {
                    // Category
                    HStack(spacing: 6) {
                        Circle()
                            .fill(task.taskCategory.color)
                            .frame(width: 6, height: 6)
                        Text(task.taskCategory.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "7A7A7A"))
                    }

                    Spacer()

                    // Complete button
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            task.status = TaskStatus.completed.rawValue
                        }
                        HapticManager.shared.success()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Tamamla")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "D4AF37"), Color(hex: "C9A030")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "D4AF37").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .pressEffect()
                }
            } else {
                HStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "D4AF37"), Color(hex: "E8D7D5")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Harika gidiyorsun!")
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(Color(hex: "2A2A2A"))
                        Text("Şu an bekleyen görev yok")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "7A7A7A"))
                    }
                }
            }
        }
        .padding(20)
        .background(glassCard)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Quick Actions Card

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("HIZLI ERİŞİM")
                .font(.system(size: 11, weight: .semibold))
                .tracking(2)
                .foregroundColor(Color(hex: "9A9A9A"))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                QuickActionButton(icon: "calendar.badge.clock", title: "Takvim", color: Color(hex: "8BA7C4"))
                QuickActionButton(icon: "person.2.fill", title: "Tedarik", color: Color(hex: "9B8AA6"))
                QuickActionButton(icon: "photo.stack", title: "Galeri", color: Color(hex: "C4A08B"))
                QuickActionButton(icon: "list.clipboard", title: "Listeler", color: Color(hex: "8BAA7C"))
            }
        }
        .padding(20)
        .background(glassCard)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Glass Card Background

    private var glassCard: some View {
        ZStack {
            Color.white.opacity(0.7)

            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    Color.white.opacity(0.5),
                    Color.white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .background(.ultraThinMaterial)
        .shadow(color: .black.opacity(0.03), radius: 20, x: 0, y: 10)
        .shadow(color: .black.opacity(0.02), radius: 1, x: 0, y: 1)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.text.square")
                .font(.system(size: 80, weight: .ultraLight))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "D4AF37"), Color(hex: "E8D7D5")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Hayallerinize başlayın")
                .font(.system(size: 28, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "2A2A2A"))

            Text("İlk düğün projenizi oluşturun")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "7A7A7A"))

            Spacer()
        }
        .padding(40)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { showWeeklyBrief = true } label: {
                Image(systemName: "text.justify.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "5A5A5A"))
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                Button { showNotifications = true } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "5A5A5A"))
                }

                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "5A5A5A"))
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let symbol = Currency(rawValue: currency)?.symbol ?? "₺"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let formatted = formatter.string(from: NSNumber(value: Int(amount))) ?? "\(Int(amount))"
        return "\(symbol)\(formatted)"
    }
}

// MARK: - Floating Shape

struct FloatingShape: View {
    let index: Int
    @State private var offset: CGFloat = 0

    private var size: CGFloat {
        CGFloat([40, 60, 30, 50, 35, 45][index % 6])
    }

    private var initialX: CGFloat {
        CGFloat([-50, 200, 100, -100, 250, 50][index % 6])
    }

    private var initialY: CGFloat {
        CGFloat([100, 300, 500, 200, 600, 400][index % 6])
    }

    private var color: Color {
        [
            Color(hex: "D4AF37").opacity(0.15),
            Color(hex: "E8D7D5").opacity(0.2),
            Color(hex: "D5E8D7").opacity(0.15),
            Color(hex: "D4AF37").opacity(0.1),
            Color(hex: "E8D7D5").opacity(0.15),
            Color(hex: "8BA7C4").opacity(0.1)
        ][index % 6]
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: size / 3)
            .offset(x: initialX, y: initialY + offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 4...8))
                    .repeatForever(autoreverses: true)
                ) {
                    offset = CGFloat.random(in: -30...30)
                }
            }
    }
}

// MARK: - Live Countdown Strip

struct LiveCountdownStrip: View {
    let weddingDate: Date
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?

    private var days: Int { Int(timeRemaining / 86400) }
    private var hours: Int { Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600) }
    private var minutes: Int { Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60) }
    private var seconds: Int { Int(timeRemaining.truncatingRemainder(dividingBy: 60)) }

    var body: some View {
        HStack(spacing: 0) {
            CountdownUnit(value: days, label: "GÜN")
            Divider().frame(height: 30).opacity(0.3)
            CountdownUnit(value: hours, label: "SAAT")
            Divider().frame(height: 30).opacity(0.3)
            CountdownUnit(value: minutes, label: "DAKİKA")
            Divider().frame(height: 30).opacity(0.3)
            CountdownUnit(value: seconds, label: "SANİYE")
        }
        .padding(.vertical, 16)
        .background(
            ZStack {
                Color.white.opacity(0.8)
                LinearGradient(
                    colors: [Color(hex: "D4AF37").opacity(0.05), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: 10)
        .onAppear {
            updateTime()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in updateTime() }
        }
        .onDisappear { timer?.invalidate() }
    }

    private func updateTime() {
        timeRemaining = max(0, weddingDate.timeIntervalSinceNow)
    }
}

struct CountdownUnit: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%02d", value))
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(hex: "2A2A2A"))
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .tracking(1)
                .foregroundColor(Color(hex: "9A9A9A"))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Bento Card

struct BentoCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    var progress: Double? = nil
    let size: BentoSize

    enum BentoSize {
        case small, large, wide
    }

    var body: some View {
        VStack(alignment: .leading, spacing: size == .small ? 8 : 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: size == .small ? 14 : 16))
                    .foregroundColor(color)

                if size != .small {
                    Spacer()
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: size == .small ? 22 : 28, weight: .semibold))
                    .foregroundColor(Color(hex: "2A2A2A"))

                Text(subtitle)
                    .font(.system(size: size == .small ? 11 : 12))
                    .foregroundColor(Color(hex: "8A8A8A"))
                    .lineLimit(1)
            }

            if let progress = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color.opacity(0.15))

                        RoundedRectangle(cornerRadius: 3)
                            .fill(color)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 4)
            }

            if size != .small {
                Spacer(minLength: 0)
            }
        }
        .padding(size == .small ? 14 : 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: size == .small ? nil : (size == .large ? 160 : nil))
        .background(
            ZStack {
                Color.white.opacity(0.75)
                color.opacity(0.03)
            }
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: size == .small ? 18 : 22, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "6A6A6A"))
        }
        .pressEffect()
    }
}

// MARK: - Supporting Views

struct WeeklyBriefView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "newspaper")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color(hex: "D4AF37"))
                        .padding(.top, 40)

                    Text("Haftalık Özet")
                        .font(.system(size: 28, weight: .light, design: .serif))

                    Text("Yakında...")
                        .foregroundColor(Color(hex: "8A8A8A"))
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(hex: "FAFAF9"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "8A8A8A"))
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

struct NotificationsInboxView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "bell.slash")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(Color(hex: "CACACA"))
                Text("Bildirim yok")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "8A8A8A"))
                    .padding(.top, 12)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color(hex: "FAFAF9"))
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "8A8A8A"))
                            .frame(width: 32, height: 32)
                            .background(Color.white)
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
