import SwiftUI
import SwiftData

// MARK: - Dashboard (Squire-Style Layout + Nuvia Theme)

struct TodayDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var showSettings = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    headerSection

                    if let project = currentProject {
                        // Hero Card - Countdown
                        heroCard(project: project)

                        // Stats Grid (2 columns)
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
            .background(DSColors.background.ignoresSafeArea())
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            if let project = currentProject {
                // Names - stacked like reference
                VStack(alignment: .leading, spacing: 0) {
                    Text(project.partnerName1)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(DSColors.textPrimary)

                    Text(project.partnerName2)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
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
            } label: {
                Circle()
                    .fill(DSColors.surface)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DSColors.textSecondary)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Hero Card (Gold)

    private func heroCard(project: WeddingProject) -> some View {
        let taskProgress = calculateTaskProgress(project: project)

        return VStack(alignment: .leading, spacing: 12) {
            // Label
            Text("Düğüne kalan")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            HStack(alignment: .bottom) {
                // Big number
                Text("\(project.daysUntilWedding)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("gün")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 14)

                Spacer()

                // Progress badge with bar
                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(Int(taskProgress * 100))%")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DSColors.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    // Mini progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.3))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: geo.size.width * taskProgress)
                        }
                    }
                    .frame(width: 60, height: 4)
                }
                .padding(.bottom, 14)
            }

            // Date & Venue
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 13))
                Text(project.weddingDate.formatted(.dateTime.day().month(.wide).year()))
                    .font(.system(size: 14, weight: .medium))

                if let venue = project.venueName, !venue.isEmpty {
                    Text("•")
                    Text(venue)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                }
            }
            .foregroundColor(.white.opacity(0.7))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.primaryAction) // Gold
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

        return VStack(spacing: 12) {
            // Row 1
            HStack(spacing: 12) {
                StatCard(
                    title: "Görevler",
                    subtitle: "Tamamlanan",
                    value: "\(Int(taskProgress * 100))%",
                    progress: taskProgress,
                    accentColor: DSColors.success
                )

                StatCard(
                    title: "Davetliler",
                    subtitle: "Katılıyor",
                    value: "\(attending)/\(totalGuests)",
                    progress: totalGuests > 0 ? Double(attending) / Double(totalGuests) : 0,
                    accentColor: DSColors.info
                )
            }

            // Row 2
            HStack(spacing: 12) {
                StatCard(
                    title: "Bütçe",
                    subtitle: "Harcanan",
                    value: "\(Int(budgetProgress * 100))%",
                    progress: budgetProgress,
                    accentColor: DSColors.primaryAction
                )

                StatCard(
                    title: "Hafta",
                    subtitle: "Düğüne kalan",
                    value: "\(project.daysUntilWedding / 7)",
                    progress: nil,
                    accentColor: DSColors.warning
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
                .foregroundColor(DSColors.textSecondary)

            if let task = priorityTask {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(task.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                            .lineLimit(2)

                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                Text(dueDate.formatted(.dateTime.day().month(.abbreviated)))
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(DSColors.textSecondary)
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
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(DSColors.primaryAction)
                            .clipShape(Circle())
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 28))
                        .foregroundColor(DSColors.success)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tüm görevler tamamlandı!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                        Text("Harika gidiyorsun")
                            .font(.system(size: 14))
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)

            Image(systemName: "heart.text.square")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(DSColors.primaryAction)

            Text("Düğün projenizi oluşturun")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)

            Text("Planlamaya başlamak için bir proje ekleyin")
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
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let subtitle: String
    let value: String
    let progress: Double?
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)

            // Subtitle
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(DSColors.textSecondary)

            Spacer()

            // Value
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(DSColors.textPrimary)

            // Progress bar
            if let progress = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(accentColor.opacity(0.2))
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
        .frame(height: 130)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    TodayDashboardView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
