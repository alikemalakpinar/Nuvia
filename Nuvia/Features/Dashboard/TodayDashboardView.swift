import SwiftUI
import SwiftData

// MARK: - Award-Worthy Dashboard

struct TodayDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var showSettings = false
    @State private var appeared = false
    @State private var countdownAnimated = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header with greeting
                headerSection
                    .offset(y: appeared ? 0 : -20)
                    .opacity(appeared ? 1 : 0)

                if let project = currentProject {
                    // Hero Card - Countdown with Ring
                    heroCard(project: project)
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)

                    // Live Countdown Strip
                    LiveCountdownStrip(weddingDate: project.weddingDate)
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)

                    // Stats Grid
                    statsGrid(project: project)
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)

                    // Next Task Card
                    nextTaskCard(project: project)
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appeared)

                    // Tip of the Day
                    tipOfTheDayCard
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: appeared)

                    Spacer().frame(height: 120)
                } else {
                    emptyState
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(DSColors.background.ignoresSafeArea())
        .sheet(isPresented: $showSettings) { SettingsView() }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    countdownAnimated = true
                }
            }
        }
    }

    // MARK: - Header with Greeting

    private var headerSection: some View {
        HStack(alignment: .top) {
            if let project = currentProject {
                VStack(alignment: .leading, spacing: 4) {
                    // Time-based greeting
                    Text(timeBasedGreeting)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)

                    // Partner names with heart
                    HStack(spacing: 8) {
                        Text(project.partnerName1)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(DSColors.textPrimary)

                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(DSColors.primaryAction)

                        Text(project.partnerName2)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(DSColors.textPrimary)
                    }
                }
            } else {
                Text("Nuvia")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
            }

            Spacer()

            // Profile Button
            Button {
                showSettings = true
                HapticManager.shared.buttonTap()
            } label: {
                ZStack {
                    Circle()
                        .fill(DSColors.surface)
                        .frame(width: 48, height: 48)
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

                    Image(systemName: "person.fill")
                        .font(.system(size: 18))
                        .foregroundColor(DSColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Time Based Greeting

    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Günaydın ☀️"
        case 12..<17: return "İyi günler 👋"
        case 17..<21: return "İyi akşamlar 🌆"
        default: return "İyi geceler 🌙"
        }
    }

    // MARK: - Hero Card with Ring

    private func heroCard(project: WeddingProject) -> some View {
        let taskProgress = calculateTaskProgress(project: project)
        let totalDays = max(1, Calendar.current.dateComponents([.day], from: project.createdAt, to: project.weddingDate).day ?? 365)
        let elapsedDays = max(0, Calendar.current.dateComponents([.day], from: project.createdAt, to: Date()).day ?? 0)
        let timeProgress = min(1.0, Double(elapsedDays) / Double(totalDays))

        return HStack(spacing: 20) {
            // Left: Text content
            VStack(alignment: .leading, spacing: 8) {
                Text("Düğüne Kalan")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                HStack(alignment: .bottom, spacing: 6) {
                    Text("\(project.daysUntilWedding)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())

                    Text("gün")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 10)
                }

                // Date & Venue
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(project.weddingDate.formatted(.dateTime.day().month(.abbreviated).year()))
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.7))

                if let venue = project.venueName, !venue.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                        Text(venue)
                            .font(.system(size: 13, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            // Right: Circular Progress Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 90, height: 90)

                // Progress ring
                Circle()
                    .trim(from: 0, to: countdownAnimated ? timeProgress : 0)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.2, dampingFraction: 0.8), value: countdownAnimated)

                // Center percentage
                VStack(spacing: 2) {
                    Text("\(Int(taskProgress * 100))%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("hazır")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(24)
        .background(
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        DSColors.primaryAction,
                        DSColors.primaryAction.opacity(0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Shimmer overlay
                ShimmerView()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: DSColors.primaryAction.opacity(0.3), radius: 20, x: 0, y: 10)
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
        let totalGuests = project.guests.count

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Görevler",
                    subtitle: "Tamamlanan",
                    value: "\(Int(taskProgress * 100))%",
                    progress: taskProgress,
                    accentColor: DSColors.success,
                    icon: "checkmark.circle.fill"
                )

                StatCard(
                    title: "Davetliler",
                    subtitle: "Katılıyor",
                    value: "\(attending)",
                    secondaryValue: "/\(totalGuests)",
                    progress: totalGuests > 0 ? Double(attending) / Double(totalGuests) : 0,
                    accentColor: DSColors.info,
                    icon: "person.2.fill"
                )
            }

            HStack(spacing: 12) {
                StatCard(
                    title: "Bütçe",
                    subtitle: "Harcanan",
                    value: "\(Int(budgetProgress * 100))%",
                    progress: budgetProgress,
                    accentColor: DSColors.primaryAction,
                    icon: "creditcard.fill"
                )

                StatCard(
                    title: "Hafta",
                    subtitle: "Kalan süre",
                    value: "\(project.daysUntilWedding / 7)",
                    secondaryValue: " hafta",
                    progress: nil,
                    accentColor: DSColors.warning,
                    icon: "calendar.badge.clock"
                )
            }
        }
    }

    // MARK: - Next Task Card

    private func nextTaskCard(project: WeddingProject) -> some View {
        let priorityTask = project.tasks
            .filter { $0.status != TaskStatus.completed.rawValue }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
            .first

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(DSColors.primaryAction)

                Text("SIRADAKİ GÖREV")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(DSColors.textSecondary)
            }

            if let task = priorityTask {
                HStack(alignment: .top, spacing: 16) {
                    // Task icon
                    Circle()
                        .fill(task.taskCategory.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: task.taskCategory.icon)
                                .font(.system(size: 18))
                                .foregroundColor(task.taskCategory.color)
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(task.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                            .lineLimit(2)

                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 11))
                                Text(formatDueDate(dueDate))
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(dueDateColor(dueDate))
                        }
                    }

                    Spacer()

                    // Complete button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            task.status = TaskStatus.completed.rawValue
                        }
                        HapticManager.shared.success()
                    } label: {
                        Circle()
                            .fill(DSColors.primaryAction)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: DSColors.primaryAction.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            } else {
                HStack(spacing: 14) {
                    Circle()
                        .fill(DSColors.success.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 20))
                                .foregroundColor(DSColors.success)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Harika gidiyorsun! 🎉")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                        Text("Tüm görevler tamamlandı")
                            .font(.system(size: 14))
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
            }
        }
        .padding(20)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }

    // MARK: - Tip of the Day

    private var tipOfTheDayCard: some View {
        let tips = [
            ("lightbulb.fill", "Tedarikçilerinizi en az 6 ay önceden ayırtın", DSColors.warning),
            ("camera.fill", "Fotoğrafçınızla çekim listesi hazırlayın", DSColors.info),
            ("gift.fill", "Hediye listesini erkenden paylaşın", DSColors.accentRose),
            ("person.2.fill", "Oturma planını 2 hafta önce tamamlayın", DSColors.success),
            ("doc.text.fill", "Davetiye metnini birlikte karar verin", DSColors.primaryAction)
        ]
        let tip = tips[Calendar.current.component(.day, from: Date()) % tips.count]

        return HStack(spacing: 14) {
            Circle()
                .fill(tip.2.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: tip.0)
                        .font(.system(size: 16))
                        .foregroundColor(tip.2)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("GÜNÜN İPUCU")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(DSColors.textTertiary)

                Text(tip.1)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 60)

            ZStack {
                Circle()
                    .fill(DSColors.primaryAction.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 50))
                    .foregroundColor(DSColors.primaryAction)
            }

            Text("Düğün projenizi oluşturun")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(DSColors.textPrimary)

            Text("Hayalinizdeki düğünü planlamaya başlayın")
                .font(.system(size: 15))
                .foregroundColor(DSColors.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func calculateTaskProgress(project: WeddingProject) -> Double {
        let completed = project.tasks.filter { $0.status == TaskStatus.completed.rawValue }.count
        let total = max(project.tasks.count, 1)
        return Double(completed) / Double(total)
    }

    private func formatDueDate(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 {
            return "\(abs(days)) gün gecikti"
        } else if days == 0 {
            return "Bugün"
        } else if days == 1 {
            return "Yarın"
        } else if days < 7 {
            return "\(days) gün kaldı"
        } else {
            return date.formatted(.dateTime.day().month(.abbreviated))
        }
    }

    private func dueDateColor(_ date: Date) -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 {
            return DSColors.error
        } else if days <= 3 {
            return DSColors.warning
        } else {
            return DSColors.textSecondary
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
        HStack(spacing: 8) {
            CountdownUnit(value: days, label: "GÜN", color: DSColors.primaryAction)
            CountdownDivider()
            CountdownUnit(value: hours, label: "SAAT", color: DSColors.info)
            CountdownDivider()
            CountdownUnit(value: minutes, label: "DAK", color: DSColors.success)
            CountdownDivider()
            CountdownUnit(value: seconds, label: "SAN", color: DSColors.warning)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .onAppear {
            updateTime()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateTime()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func updateTime() {
        timeRemaining = max(0, weddingDate.timeIntervalSinceNow)
    }
}

struct CountdownUnit: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%02d", value))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(DSColors.textPrimary)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: value)

            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.5)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CountdownDivider: View {
    var body: some View {
        Text(":")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(DSColors.textTertiary)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let subtitle: String
    let value: String
    var secondaryValue: String? = nil
    let progress: Double?
    let accentColor: Color
    let icon: String

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(accentColor)

            // Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(DSColors.textSecondary)
            }

            Spacer()

            // Value
            HStack(alignment: .bottom, spacing: 0) {
                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(DSColors.textPrimary)

                if let secondary = secondaryValue {
                    Text(secondary)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)
                        .padding(.bottom, 3)
                }
            }

            // Progress bar
            if let progress = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(accentColor.opacity(0.15))

                        RoundedRectangle(cornerRadius: 3)
                            .fill(accentColor)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 130)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.spring(response: 0.3), value: isPressed)
        .onTapGesture {
            isPressed = true
            HapticManager.shared.buttonTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

// MARK: - Shimmer Effect

struct ShimmerView: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        LinearGradient(
            colors: [
                .clear,
                .white.opacity(0.15),
                .clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .offset(x: phase * 400)
        .onAppear {
            withAnimation(
                .linear(duration: 2.5)
                .repeatForever(autoreverses: false)
            ) {
                phase = 1
            }
        }
    }
}

#Preview {
    TodayDashboardView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
