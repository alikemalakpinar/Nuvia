import SwiftUI
import SwiftData

// MARK: - Premium Plan View

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var selectedView: TimelineViewMode = .timeline
    @State private var selectedFilter: TaskCategory?
    @State private var showAddTask = false
    @State private var showVendors = false
    @State private var appeared = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                headerSection
                    .offset(y: appeared ? 0 : -20)
                    .opacity(appeared ? 1 : 0)

                if let project = currentProject {
                    // Progress Overview
                    progressCard(project: project)
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)

                    // View Mode Selector
                    viewModeSelector
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: appeared)

                    // Filter Chips
                    filterChips
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)

                    // Content
                    Group {
                        switch selectedView {
                        case .timeline:
                            timelineContent(project: project)
                        case .board:
                            boardContent(project: project)
                        case .calendar:
                            calendarContent(project: project)
                        }
                    }
                    .offset(y: appeared ? 0 : 30)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: appeared)

                    Spacer().frame(height: 120)
                } else {
                    emptyState
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(DSColors.background.ignoresSafeArea())
        .sheet(isPresented: $showAddTask) { AddTaskView() }
        .sheet(isPresented: $showVendors) { VendorManagementView() }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Plan")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)

                Text("Düğün hazırlıkları")
                    .font(.system(size: 15))
                    .foregroundColor(DSColors.textSecondary)
            }

            Spacer()

            HStack(spacing: 12) {
                // Vendors button
                Button {
                    showVendors = true
                    HapticManager.shared.buttonTap()
                } label: {
                    Circle()
                        .fill(DSColors.surface)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 16))
                                .foregroundColor(DSColors.textSecondary)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }

                // Add button
                Button {
                    showAddTask = true
                    HapticManager.shared.buttonTap()
                } label: {
                    Circle()
                        .fill(DSColors.primaryAction)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: DSColors.primaryAction.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
    }

    // MARK: - Progress Card

    private func progressCard(project: WeddingProject) -> some View {
        let completed = project.tasks.filter { $0.status == TaskStatus.completed.rawValue }.count
        let inProgress = project.tasks.filter { $0.status == TaskStatus.inProgress.rawValue }.count
        let pending = project.tasks.filter { $0.status == TaskStatus.pending.rawValue }.count
        let total = max(project.tasks.count, 1)
        let progress = Double(completed) / Double(total)

        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("İlerleme Durumu")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)

                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(Int(progress * 100))")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(DSColors.textPrimary)

                        Text("%")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DSColors.textSecondary)
                            .padding(.bottom, 6)
                    }
                }

                Spacer()

                // Mini stats
                HStack(spacing: 20) {
                    MiniStat(value: pending, label: "Bekleyen", color: DSColors.warning)
                    MiniStat(value: inProgress, label: "Devam", color: DSColors.info)
                    MiniStat(value: completed, label: "Bitti", color: DSColors.success)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DSColors.primaryAction.opacity(0.15))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [DSColors.primaryAction, DSColors.primaryAction.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }

    // MARK: - View Mode Selector

    private var viewModeSelector: some View {
        HStack(spacing: 8) {
            ForEach(TimelineViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedView = mode
                    }
                    HapticManager.shared.selection()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14))

                        Text(mode.title)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(selectedView == mode ? .white : DSColors.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        selectedView == mode
                            ? DSColors.primaryAction
                            : DSColors.surface
                    )
                    .clipShape(Capsule())
                    .shadow(
                        color: selectedView == mode ? DSColors.primaryAction.opacity(0.3) : .black.opacity(0.03),
                        radius: selectedView == mode ? 8 : 4,
                        x: 0,
                        y: selectedView == mode ? 4 : 2
                    )
                }
            }

            Spacer()
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChipPremium(
                    title: "Tümü",
                    icon: "square.grid.2x2",
                    isSelected: selectedFilter == nil,
                    color: DSColors.primaryAction
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedFilter = nil
                    }
                }

                ForEach(TaskCategory.allCases, id: \.self) { category in
                    FilterChipPremium(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: selectedFilter == category,
                        color: category.color
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = category
                        }
                    }
                }
            }
        }
    }

    // MARK: - Timeline Content

    private func timelineContent(project: WeddingProject) -> some View {
        let tasks = filteredTasks(project: project)
        let grouped = groupTasksByMonth(tasks)

        return LazyVStack(spacing: 24) {
            ForEach(Array(grouped.enumerated()), id: \.element.0) { index, group in
                VStack(alignment: .leading, spacing: 12) {
                    // Month header
                    HStack {
                        Text(group.0)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DSColors.textPrimary)

                        Spacer()

                        Text("\(group.1.count) görev")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DSColors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(DSColors.surfaceTertiary)
                            .clipShape(Capsule())
                    }

                    // Tasks
                    ForEach(group.1, id: \.id) { task in
                        PremiumTaskCard(task: task)
                    }
                }
            }

            if tasks.isEmpty {
                noTasksView
            }
        }
    }

    // MARK: - Board Content

    private func boardContent(project: WeddingProject) -> some View {
        let tasks = filteredTasks(project: project)

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                BoardColumnPremium(
                    title: "Yapılacak",
                    icon: "circle",
                    tasks: tasks.filter { $0.taskStatus == .pending },
                    color: DSColors.warning
                )

                BoardColumnPremium(
                    title: "Devam Ediyor",
                    icon: "arrow.triangle.2.circlepath",
                    tasks: tasks.filter { $0.taskStatus == .inProgress },
                    color: DSColors.info
                )

                BoardColumnPremium(
                    title: "Tamamlandı",
                    icon: "checkmark.circle.fill",
                    tasks: tasks.filter { $0.taskStatus == .completed },
                    color: DSColors.success
                )
            }
        }
        .padding(.horizontal, -20)
        .padding(.leading, 20)
    }

    // MARK: - Calendar Content

    private func calendarContent(project: WeddingProject) -> some View {
        TaskCalendarViewPremium(project: project, filter: selectedFilter)
    }

    // MARK: - Empty & No Tasks

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 60)

            ZStack {
                Circle()
                    .fill(DSColors.primaryAction.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(DSColors.primaryAction)
            }

            Text("Proje bulunamadı")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DSColors.textPrimary)

            Text("Görevleri görmek için bir proje oluşturun")
                .font(.system(size: 15))
                .foregroundColor(DSColors.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    private var noTasksView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 40))
                .foregroundColor(DSColors.success)

            Text("Görev bulunamadı")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)

            Button {
                showAddTask = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Görev Ekle")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(DSColors.primaryAction)
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 40)
    }

    // MARK: - Helpers

    private func filteredTasks(project: WeddingProject) -> [Task] {
        let tasks = selectedFilter == nil
            ? project.tasks
            : project.tasks.filter { $0.taskCategory == selectedFilter }
        return tasks.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private func groupTasksByMonth(_ tasks: [Task]) -> [(String, [Task])] {
        var groups: [String: [Task]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")

        for task in tasks {
            let key = task.dueDate.map { formatter.string(from: $0) } ?? "Tarih Belirtilmemiş"
            groups[key, default: []].append(task)
        }

        return groups.sorted { $0.key < $1.key }
    }
}

// MARK: - View Mode Enum

enum TimelineViewMode: String, CaseIterable {
    case timeline
    case board
    case calendar

    var title: String {
        switch self {
        case .timeline: return "Liste"
        case .board: return "Pano"
        case .calendar: return "Takvim"
        }
    }

    var icon: String {
        switch self {
        case .timeline: return "list.bullet"
        case .board: return "square.grid.3x3"
        case .calendar: return "calendar"
        }
    }
}

// MARK: - Mini Stat

struct MiniStat: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DSColors.textSecondary)
        }
    }
}

// MARK: - Filter Chip Premium

struct FilterChipPremium: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            HapticManager.shared.selection()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))

                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : DSColors.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : DSColors.surface)
            .clipShape(Capsule())
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 6, x: 0, y: 3)
        }
    }
}

// MARK: - Premium Task Card

struct PremiumTaskCard: View {
    let task: Task
    @State private var showDetail = false
    @State private var isPressed = false

    var body: some View {
        Button {
            showDetail = true
            HapticManager.shared.buttonTap()
        } label: {
            HStack(spacing: 14) {
                // Category icon
                Circle()
                    .fill(task.taskCategory.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: task.taskCategory.icon)
                            .font(.system(size: 18))
                            .foregroundColor(task.taskCategory.color)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(task.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        if task.taskPriority == .high {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(DSColors.warning)
                        }

                        // Status badge
                        Text(task.taskStatus.displayName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(task.taskStatus.color)
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 12) {
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 11))
                                Text(formatDueDate(dueDate))
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(dueDateColor(dueDate))
                        }

                        if !task.checklistItems.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 11))
                                Text("\(task.checklistItems.filter { $0.isCompleted }.count)/\(task.checklistItems.count)")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(DSColors.textSecondary)
                        }
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DSColors.textTertiary)
            }
            .padding(16)
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.3), value: isPressed)
        .sheet(isPresented: $showDetail) {
            TaskDetailView(task: task)
        }
    }

    private func formatDueDate(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 { return "\(abs(days)) gün gecikti" }
        else if days == 0 { return "Bugün" }
        else if days == 1 { return "Yarın" }
        else if days < 7 { return "\(days) gün" }
        else { return date.formatted(.dateTime.day().month(.abbreviated)) }
    }

    private func dueDateColor(_ date: Date) -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 { return DSColors.error }
        else if days <= 3 { return DSColors.warning }
        else { return DSColors.textSecondary }
    }
}

// MARK: - Board Column Premium

struct BoardColumnPremium: View {
    let title: String
    let icon: String
    let tasks: [Task]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)

                Text("\(tasks.count)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.bottom, 4)

            // Tasks
            ForEach(tasks, id: \.id) { task in
                BoardTaskCardPremium(task: task, accentColor: color)
            }

            if tasks.isEmpty {
                Text("Görev yok")
                    .font(.system(size: 13))
                    .foregroundColor(DSColors.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }

            Spacer()
        }
        .frame(width: 280)
        .padding(16)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

struct BoardTaskCardPremium: View {
    let task: Task
    let accentColor: Color
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Circle()
                        .fill(task.taskCategory.color)
                        .frame(width: 8, height: 8)

                    Text(task.taskCategory.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(task.taskCategory.color)

                    Spacer()

                    if task.taskPriority == .high {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 10))
                            .foregroundColor(DSColors.warning)
                    }
                }

                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(dueDate.formatted(.dateTime.day().month(.abbreviated)))
                            .font(.system(size: 11))
                    }
                    .foregroundColor(DSColors.textSecondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DSColors.surfaceTertiary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .sheet(isPresented: $showDetail) {
            TaskDetailView(task: task)
        }
    }
}

// MARK: - Calendar View Premium

struct TaskCalendarViewPremium: View {
    let project: WeddingProject
    let filter: TaskCategory?
    @State private var selectedDate = Date()

    private var tasksForDate: [Task] {
        project.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let matchesFilter = filter == nil || task.taskCategory == filter
            return Calendar.current.isDate(dueDate, inSameDayAs: selectedDate) && matchesFilter
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Calendar
            DatePicker(
                "Tarih",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(DSColors.primaryAction)
            .padding()
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)

            // Tasks for date
            VStack(alignment: .leading, spacing: 12) {
                Text(selectedDate.formatted(.dateTime.day().month(.wide)))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)

                if tasksForDate.isEmpty {
                    HStack {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundColor(DSColors.success)
                        Text("Bu tarihte görev yok")
                            .foregroundColor(DSColors.textSecondary)
                    }
                    .font(.system(size: 14))
                    .padding(.vertical, 12)
                } else {
                    ForEach(tasksForDate, id: \.id) { task in
                        PremiumTaskCard(task: task)
                    }
                }
            }
        }
    }
}

// MARK: - Add Task View (Updated)

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var title = ""
    @State private var description = ""
    @State private var category: TaskCategory = .other
    @State private var priority: TaskPriority = .medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Title input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BAŞLIK")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(DSColors.textSecondary)

                        TextField("Görev başlığı", text: $title)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(DSColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AÇIKLAMA")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(DSColors.textSecondary)

                        TextField("Açıklama (opsiyonel)", text: $description, axis: .vertical)
                            .font(.system(size: 15))
                            .lineLimit(3...6)
                            .padding(16)
                            .background(DSColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 12) {
                        Text("KATEGORİ")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(DSColors.textSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(TaskCategory.allCases, id: \.self) { cat in
                                    Button {
                                        category = cat
                                        HapticManager.shared.selection()
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.icon)
                                            Text(cat.displayName)
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(category == cat ? .white : DSColors.textSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(category == cat ? cat.color : DSColors.surface)
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }

                    // Priority
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ÖNCELİK")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(DSColors.textSecondary)

                        HStack(spacing: 10) {
                            ForEach(TaskPriority.allCases, id: \.self) { pri in
                                Button {
                                    priority = pri
                                    HapticManager.shared.selection()
                                } label: {
                                    Text(pri.displayName)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(priority == pri ? .white : DSColors.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(priority == pri ? pri.color : DSColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Due date
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("SON TARİH")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(DSColors.textSecondary)

                            Spacer()

                            Toggle("", isOn: $hasDueDate)
                                .tint(DSColors.primaryAction)
                        }

                        if hasDueDate {
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .tint(DSColors.primaryAction)
                                .padding(16)
                                .background(DSColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(20)
            }
            .background(DSColors.background)
            .navigationTitle("Yeni Görev")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(DSColors.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") { saveTask() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(title.isEmpty ? DSColors.textTertiary : DSColors.primaryAction)
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveTask() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else { return }

        let task = Task(
            title: title,
            description: description.isEmpty ? nil : description,
            category: category,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil
        )

        project.tasks.append(task)

        do {
            try modelContext.save()
            HapticManager.shared.success()
            dismiss()
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}

// MARK: - Task Detail View (Keep existing)

struct TaskDetailView: View {
    let task: Task
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(task.taskCategory.color.opacity(0.15))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: task.taskCategory.icon)
                                        .font(.system(size: 22))
                                        .foregroundColor(task.taskCategory.color)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.taskCategory.displayName)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(task.taskCategory.color)

                                Text(task.taskStatus.displayName)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(task.taskStatus.color)
                                    .clipShape(Capsule())
                            }
                        }

                        Text(task.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DSColors.textPrimary)

                        if let description = task.taskDescription, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 15))
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }

                    Divider()

                    // Info rows
                    VStack(spacing: 16) {
                        if let dueDate = task.dueDate {
                            InfoRow(icon: "calendar", title: "Son Tarih", value: dueDate.formatted(date: .long, time: .shortened))
                        }

                        InfoRow(icon: "flag.fill", title: "Öncelik", value: task.taskPriority.displayName, color: task.taskPriority.color)

                        if let assignee = task.assignee {
                            InfoRow(icon: "person.fill", title: "Sorumlu", value: assignee.name)
                        }
                    }

                    // Checklist
                    if !task.checklistItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Kontrol Listesi")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DSColors.textPrimary)

                            ForEach(task.checklistItems, id: \.id) { item in
                                HStack(spacing: 12) {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isCompleted ? DSColors.success : DSColors.textSecondary)

                                    Text(item.text)
                                        .font(.system(size: 15))
                                        .foregroundColor(item.isCompleted ? DSColors.textSecondary : DSColors.textPrimary)
                                        .strikethrough(item.isCompleted)
                                }
                            }
                        }
                        .padding(16)
                        .background(DSColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(20)
            }
            .background(DSColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(DSColors.primaryAction)
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = DSColors.primaryAction

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(DSColors.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DSColors.textPrimary)
        }
        .padding(14)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    TimelineView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
