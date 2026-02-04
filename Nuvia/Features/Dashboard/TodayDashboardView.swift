import SwiftUI
import SwiftData

// MARK: - Dashboard (Squire-Style Dark Theme)

struct TodayDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var showSettings = false
    @State private var showNotifications = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    // Colors
    private let bgColor = Color(hex: "121214")
    private let cardColor = Color(hex: "1C1C1E")
    private let accentColor = Color(hex: "D4AF37") // Gold
    private let textPrimary = Color.white
    private let textSecondary = Color(hex: "8E8E93")

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    headerSection

                    if let project = currentProject {
                        // Hero Card - Countdown
                        heroCard(project: project)

                        // Stats Grid
                        statsGrid(project: project)

                        // Next Task Card
                        nextTaskCard(project: project)

                        Spacer().frame(height: 100)
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(bgColor.ignoresSafeArea())
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showNotifications) { NotificationsInboxView() }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            if let project = currentProject {
                // Names
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.partnerName1)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(textPrimary)

                    HStack(spacing: 8) {
                        Text("&")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(accentColor)
                        Text(project.partnerName2)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(textPrimary)
                    }
                }
            } else {
                Text("Nuvia")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(textPrimary)
            }

            Spacer()

            // Profile Button
            Button {
                showSettings = true
            } label: {
                Circle()
                    .fill(cardColor)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(textSecondary)
                    )
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Hero Card

    private func heroCard(project: WeddingProject) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label
            Text("Düğüne kalan")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(bgColor.opacity(0.7))

            HStack(alignment: .bottom, spacing: 8) {
                // Big number
                Text("\(project.daysUntilWedding)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(bgColor)

                Text("gün")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(bgColor.opacity(0.7))
                    .padding(.bottom, 10)

                Spacer()

                // Progress badge
                HStack(spacing: 4) {
                    Text(formatProgress(project: project))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(bgColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 10)
            }

            // Date info
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                Text(project.weddingDate.formatted(.dateTime.day().month(.wide).year()))
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(bgColor.opacity(0.6))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        let guestProgress = totalGuests > 0 ? Double(attending) / Double(totalGuests) : 0

        return VStack(spacing: 12) {
            // Row 1: Tasks & Guests
            HStack(spacing: 12) {
                StatCard(
                    title: "Görevler",
                    subtitle: "Tamamlanan",
                    value: "\(Int(taskProgress * 100))%",
                    progress: taskProgress,
                    accentColor: Color(hex: "34C759") // Green
                )

                StatCard(
                    title: "Davetliler",
                    subtitle: "Katılıyor",
                    value: "\(attending)",
                    progress: guestProgress,
                    accentColor: Color(hex: "5E5CE6") // Purple
                )
            }

            // Row 2: Budget & Days
            HStack(spacing: 12) {
                StatCard(
                    title: "Bütçe",
                    subtitle: "Harcanan",
                    value: formatBudgetPercent(budgetProgress),
                    progress: budgetProgress,
                    accentColor: accentColor
                )

                StatCard(
                    title: "Hafta",
                    subtitle: "Düğüne kalan",
                    value: "\(project.daysUntilWedding / 7)",
                    progress: nil,
                    accentColor: Color(hex: "FF9F0A") // Orange
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

        return VStack(alignment: .leading, spacing: 12) {
            Text("Sıradaki görev")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(textSecondary)

            if let task = priorityTask {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(task.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textPrimary)
                            .lineLimit(2)

                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                Text(dueDate.formatted(.dateTime.day().month(.abbreviated)))
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(textSecondary)
                        }
                    }

                    Spacer()

                    // Complete button
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            task.status = TaskStatus.completed.rawValue
                        }
                        HapticManager.shared.success()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(bgColor)
                            .frame(width: 44, height: 44)
                            .background(accentColor)
                            .clipShape(Circle())
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "34C759"))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tüm görevler tamamlandı!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(textPrimary)
                        Text("Harika gidiyorsun")
                            .font(.system(size: 14))
                            .foregroundColor(textSecondary)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)

            Image(systemName: "heart.text.square")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(accentColor)

            Text("Düğün projenizi oluşturun")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textPrimary)

            Text("Planlamaya başlamak için bir proje ekleyin")
                .font(.system(size: 15))
                .foregroundColor(textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func formatProgress(project: WeddingProject) -> String {
        let completed = project.tasks.filter { $0.status == TaskStatus.completed.rawValue }.count
        let total = max(project.tasks.count, 1)
        return "\(Int(Double(completed) / Double(total) * 100))%"
    }

    private func formatBudgetPercent(_ value: Double) -> String {
        return "\(Int(value * 100))%"
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let subtitle: String
    let value: String
    let progress: Double?
    let accentColor: Color

    private let cardColor = Color(hex: "1C1C1E")
    private let textPrimary = Color.white
    private let textSecondary = Color(hex: "8E8E93")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(textPrimary)

            // Subtitle
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(textSecondary)

            Spacer()

            // Value
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(textPrimary)

            // Progress bar
            if let progress = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(accentColor)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Supporting Views

struct NotificationsInboxView: View {
    @Environment(\.dismiss) private var dismiss

    private let bgColor = Color(hex: "121214")
    private let cardColor = Color(hex: "1C1C1E")

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "bell.slash")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(Color(hex: "3A3A3C"))
                Text("Bildirim yok")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .padding(.top, 12)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .frame(width: 32, height: 32)
                            .background(cardColor)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(bgColor, for: .navigationBar)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    TodayDashboardView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
