import SwiftUI
import SwiftData

/// Zaman Çizelgesi ve Görevler ekranı
struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var selectedView: TimelineViewMode = .timeline
    @State private var selectedFilter: TaskCategory?
    @State private var showAddTask = false
    @State private var showVendors = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View mode picker
                Picker("Görünüm", selection: $selectedView) {
                    ForEach(TimelineViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "Tümü", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }

                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.displayName,
                                isSelected: selectedFilter == category,
                                color: category.color
                            ) {
                                selectedFilter = category
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                // Content
                if let project = currentProject {
                    switch selectedView {
                    case .timeline:
                        TimelineListView(project: project, filter: selectedFilter)
                    case .board:
                        TaskBoardView(project: project, filter: selectedFilter)
                    case .calendar:
                        TaskCalendarView(project: project, filter: selectedFilter)
                    }
                } else {
                    NuviaEmptyState(
                        icon: "calendar.badge.exclamationmark",
                        title: "Proje bulunamadı",
                        message: "Görevleri görmek için bir proje oluşturun"
                    )
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showVendors = true
                        } label: {
                            Image(systemName: "person.2.badge.gearshape.fill")
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Button {
                            showAddTask = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView()
            }
            .sheet(isPresented: $showVendors) {
                VendorManagementView()
            }
        }
    }
}

// MARK: - View Mode

enum TimelineViewMode: String, CaseIterable {
    case timeline = "Zaman Çizelgesi"
    case board = "Pano"
    case calendar = "Takvim"
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .nuviaGoldFallback
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(NuviaTypography.smallButton())
                .foregroundColor(isSelected ? .nuviaMidnight : .nuviaSecondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.nuviaCardBackground)
                .cornerRadius(20)
        }
    }
}

// MARK: - Timeline List View

struct TimelineListView: View {
    let project: WeddingProject
    let filter: TaskCategory?

    private var groupedTasks: [(String, [Task])] {
        let filteredTasks = filter == nil
            ? project.tasks
            : project.tasks.filter { $0.taskCategory == filter }

        let sorted = filteredTasks.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }

        // Group by month
        var groups: [String: [Task]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")

        for task in sorted {
            let key = task.dueDate.map { formatter.string(from: $0) } ?? "Tarih Belirtilmemiş"
            groups[key, default: []].append(task)
        }

        return groups.sorted { $0.key < $1.key }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedTasks, id: \.0) { month, tasks in
                    Section {
                        VStack(spacing: 12) {
                            ForEach(tasks, id: \.id) { task in
                                TaskCard(task: task)
                            }
                        }
                        .padding(.horizontal, 16)
                    } header: {
                        HStack {
                            Text(month)
                                .font(NuviaTypography.title3())
                                .foregroundColor(.nuviaPrimaryText)
                            Spacer()
                            Text("\(tasks.count) görev")
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.nuviaBackground)
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Task Card

struct TaskCard: View {
    let task: Task
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: 16) {
                // Status indicator
                VStack {
                    Circle()
                        .fill(task.taskStatus.color)
                        .frame(width: 12, height: 12)

                    if task.checklistItems.count > 0 {
                        Rectangle()
                            .fill(Color.nuviaTertiaryText)
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }
                .frame(width: 12)

                VStack(alignment: .leading, spacing: 8) {
                    // Title and priority
                    HStack {
                        Text(task.title)
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if task.taskPriority == .high {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.priorityHigh)
                                .font(.system(size: 14))
                        }
                    }

                    // Category and date
                    HStack(spacing: 12) {
                        NuviaTag(task.taskCategory.displayName, color: task.taskCategory.color, size: .small)

                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(NuviaTypography.caption())
                            }
                            .foregroundColor(task.isOverdue ? .nuviaError : .nuviaSecondaryText)
                        }

                        if let assignee = task.assignee {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12))
                                Text(assignee.name)
                                    .font(NuviaTypography.caption())
                            }
                            .foregroundColor(.nuviaSecondaryText)
                        }
                    }

                    // Checklist progress
                    if !task.checklistItems.isEmpty {
                        HStack(spacing: 8) {
                            ProgressView(value: task.checklistProgress)
                                .tint(.nuviaGoldFallback)

                            Text("\(task.checklistItems.filter { $0.isCompleted }.count)/\(task.checklistItems.count)")
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.nuviaTertiaryText)
                    .font(.system(size: 14))
            }
            .padding(16)
            .background(Color.nuviaCardBackground)
            .cornerRadius(16)
        }
        .sheet(isPresented: $showDetail) {
            TaskDetailView(task: task)
        }
    }
}

// MARK: - Task Board View

struct TaskBoardView: View {
    let project: WeddingProject
    let filter: TaskCategory?

    private var pendingTasks: [Task] {
        project.tasks.filter { $0.taskStatus == .pending }
    }

    private var inProgressTasks: [Task] {
        project.tasks.filter { $0.taskStatus == .inProgress }
    }

    private var completedTasks: [Task] {
        project.tasks.filter { $0.taskStatus == .completed }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                BoardColumn(title: "Yapılacak", tasks: pendingTasks, color: .statusPending)
                BoardColumn(title: "Devam Ediyor", tasks: inProgressTasks, color: .statusInProgress)
                BoardColumn(title: "Tamamlandı", tasks: completedTasks, color: .statusCompleted)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
}

struct BoardColumn: View {
    let title: String
    let tasks: [Task]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)

                Text(title)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)

                Text("\(tasks.count)")
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.nuviaTertiaryBackground)
                    .cornerRadius(10)
            }

            ForEach(tasks, id: \.id) { task in
                BoardTaskCard(task: task)
            }

            Spacer()
        }
        .frame(width: 280)
        .padding(12)
        .background(Color.nuviaCardBackground)
        .cornerRadius(16)
    }
}

struct BoardTaskCard: View {
    let task: Task

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(NuviaTypography.body())
                .foregroundColor(.nuviaPrimaryText)
                .lineLimit(2)

            HStack {
                NuviaTag(task.taskCategory.displayName, color: task.taskCategory.color, size: .small)

                Spacer()

                if let days = task.daysUntilDue {
                    Text(days == 0 ? "Bugün" : "\(days) gün")
                        .font(NuviaTypography.caption())
                        .foregroundColor(days < 0 ? .nuviaError : .nuviaSecondaryText)
                }
            }
        }
        .padding(12)
        .background(Color.nuviaTertiaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Task Calendar View

struct TaskCalendarView: View {
    let project: WeddingProject
    let filter: TaskCategory?
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 16) {
            DatePicker(
                "Tarih Seç",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(.nuviaGoldFallback)
            .padding(.horizontal)

            Divider()

            // Tasks for selected date
            let tasksForDate = project.tasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDate(dueDate, inSameDayAs: selectedDate)
            }

            if tasksForDate.isEmpty {
                Text("Bu tarihte görev yok")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(tasksForDate, id: \.id) { task in
                            TaskCard(task: task)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Add Task View

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
            Form {
                Section("Görev Bilgileri") {
                    TextField("Başlık", text: $title)

                    TextField("Açıklama (opsiyonel)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Kategori") {
                    Picker("Kategori", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }

                Section("Öncelik") {
                    Picker("Öncelik", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { pri in
                            Text(pri.displayName).tag(pri)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Tarih") {
                    Toggle("Son tarih ekle", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker("Son Tarih", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Yeni Görev")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveTask() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else {
            return
        }

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
            dismiss()
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}

// MARK: - Task Detail View

struct TaskDetailView: View {
    let task: Task
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            NuviaTag(task.taskCategory.displayName, color: task.taskCategory.color)
                            NuviaTag(task.taskPriority.displayName, color: task.taskPriority.color)
                            Spacer()
                            NuviaTag(task.taskStatus.displayName, color: task.taskStatus.color)
                        }

                        Text(task.title)
                            .font(NuviaTypography.title2())
                            .foregroundColor(.nuviaPrimaryText)

                        if let description = task.taskDescription {
                            Text(description)
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }

                    Divider()

                    // Due date
                    if let dueDate = task.dueDate {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.nuviaGoldFallback)
                            Text("Son Tarih: \(dueDate.formatted(date: .long, time: .shortened))")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaPrimaryText)
                        }
                    }

                    // Assignee
                    if let assignee = task.assignee {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.nuviaGoldFallback)
                            Text("Sorumlu: \(assignee.name)")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaPrimaryText)
                        }
                    }

                    // Checklist
                    if !task.checklistItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Kontrol Listesi")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)

                            ForEach(task.checklistItems, id: \.id) { item in
                                HStack {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isCompleted ? .nuviaSuccess : .nuviaSecondaryText)
                                    Text(item.text)
                                        .font(NuviaTypography.body())
                                        .foregroundColor(item.isCompleted ? .nuviaSecondaryText : .nuviaPrimaryText)
                                        .strikethrough(item.isCompleted)
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(16)
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

// VendorsListView replaced by VendorManagementView in Vendors/VendorManagementView.swift

#Preview {
    TimelineView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
