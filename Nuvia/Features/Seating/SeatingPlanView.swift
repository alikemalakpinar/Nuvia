import SwiftUI
import SwiftData

/// Oturma planı ana ekranı
struct SeatingPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var selectedTable: SeatingTable?
    @State private var showAddTable = false
    @State private var showConflicts = false
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    private var conflicts: [SeatingConflict] {
        guard let project = currentProject else { return [] }
        var allConflicts: [SeatingConflict] = []

        for table in project.tables {
            let guests = table.seatedGuests
            for i in 0..<guests.count {
                for j in (i+1)..<guests.count {
                    if guests[i].conflictWithGuestIds.contains(guests[j].id) ||
                       guests[j].conflictWithGuestIds.contains(guests[i].id) {
                        allConflicts.append(SeatingConflict(
                            type: .personalConflict,
                            guest1: guests[i],
                            guest2: guests[j],
                            table: table
                        ))
                    }
                }
            }
        }
        return allConflicts
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.nuviaBackground.ignoresSafeArea()

                if let project = currentProject {
                    VStack(spacing: 0) {
                        // Summary bar
                        SeatingPlanSummaryBar(project: project, conflictCount: conflicts.count) {
                            showConflicts = true
                        }

                        // Canvas
                        if project.tables.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "rectangle.split.3x3")
                                    .font(.system(size: 64))
                                    .foregroundColor(.nuviaSecondaryText)

                                Text("Henüz masa eklenmedi")
                                    .font(NuviaTypography.title3())
                                    .foregroundColor(.nuviaPrimaryText)

                                Text("Oturma planınızı oluşturmak için masa ekleyin")
                                    .font(NuviaTypography.body())
                                    .foregroundColor(.nuviaSecondaryText)

                                NuviaPrimaryButton("Masa Ekle", icon: "plus.circle.fill") {
                                    showAddTable = true
                                }
                                .frame(width: 200)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            SeatingCanvasView(
                                tables: project.tables,
                                selectedTable: $selectedTable,
                                scale: $scale,
                                offset: $offset
                            )
                        }

                        // Table detail panel
                        if let table = selectedTable {
                            TableDetailPanel(table: table) {
                                selectedTable = nil
                            }
                        }
                    }
                } else {
                    NuviaEmptyState(
                        icon: "rectangle.split.3x3",
                        title: "Proje bulunamadı",
                        message: "Oturma planı için bir proje oluşturun"
                    )
                }
            }
            .navigationTitle("Oturma Planı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.nuviaGoldFallback)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showConflicts = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(conflicts.isEmpty ? .nuviaSecondaryText : .nuviaWarning)

                                if !conflicts.isEmpty {
                                    Text("\(conflicts.count)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.nuviaError)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }

                        Button {
                            showAddTable = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddTable) {
                AddTableView()
            }
            .sheet(isPresented: $showConflicts) {
                ConflictsListView(conflicts: conflicts)
            }
        }
    }
}

// MARK: - Seating Plan Summary Bar

struct SeatingPlanSummaryBar: View {
    let project: WeddingProject
    let conflictCount: Int
    let onConflictTap: () -> Void

    private var totalCapacity: Int {
        project.tables.reduce(0) { $0 + $1.capacity }
    }

    private var seatedCount: Int {
        project.tables.reduce(0) { $0 + $1.occupiedSeats }
    }

    private var unseatedCount: Int {
        project.guests.filter { $0.rsvp == .attending && !$0.isSeated }.reduce(0) { $0 + 1 + $1.plusOneCount }
    }

    var body: some View {
        HStack(spacing: 16) {
            StatBadge(icon: "rectangle.split.3x3", value: "\(project.tables.count)", label: "Masa")
            StatBadge(icon: "person.fill", value: "\(seatedCount)/\(totalCapacity)", label: "Doluluk")
            StatBadge(icon: "person.badge.plus", value: "\(unseatedCount)", label: "Bekleyen")

            if conflictCount > 0 {
                Button(action: onConflictTap) {
                    StatBadge(
                        icon: "exclamationmark.triangle.fill",
                        value: "\(conflictCount)",
                        label: "Çatışma",
                        color: .nuviaError
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.nuviaCardBackground)
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = .nuviaGoldFallback

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(value)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)
            }
            Text(label)
                .font(NuviaTypography.caption2())
                .foregroundColor(.nuviaSecondaryText)
        }
    }
}

// MARK: - Seating Canvas View

struct SeatingCanvasView: View {
    let tables: [SeatingTable]
    @Binding var selectedTable: SeatingTable?
    @Binding var scale: CGFloat
    @Binding var offset: CGSize

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background
                GridPattern()
                    .stroke(Color.nuviaTertiaryText.opacity(0.2), lineWidth: 0.5)

                // Tables
                ForEach(tables, id: \.id) { table in
                    TableView(
                        table: table,
                        isSelected: selectedTable?.id == table.id
                    ) {
                        selectedTable = table
                    }
                    .position(
                        x: geometry.size.width / 2 + CGFloat(table.positionX),
                        y: geometry.size.height / 2 + CGFloat(table.positionY)
                    )
                }
            }
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = min(max(value, 0.5), 2.0)
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
            )
        }
    }
}

struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let gridSize: CGFloat = 40

        for x in stride(from: 0, to: rect.width, by: gridSize) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }

        for y in stride(from: 0, to: rect.height, by: gridSize) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }

        return path
    }
}

// MARK: - Table View

struct TableView: View {
    let table: SeatingTable
    let isSelected: Bool
    let onTap: () -> Void

    private var tableSize: CGFloat {
        switch table.tableLayoutType {
        case .round: return 80
        case .rectangular: return 100
        case .oval: return 90
        case .uShape: return 120
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Table shape
                Group {
                    switch table.tableLayoutType {
                    case .round:
                        Circle()
                    case .rectangular:
                        RoundedRectangle(cornerRadius: 8)
                    case .oval:
                        Ellipse()
                    case .uShape:
                        RoundedRectangle(cornerRadius: 8)
                    }
                }
                .fill(table.isFull ? Color.nuviaSuccess.opacity(0.3) : Color.nuviaCardBackground)
                .frame(width: tableSize, height: table.tableLayoutType == .rectangular ? tableSize * 0.6 : tableSize)
                .overlay(
                    Group {
                        switch table.tableLayoutType {
                        case .round:
                            Circle().stroke(isSelected ? Color.nuviaGoldFallback : Color.nuviaTertiaryText, lineWidth: isSelected ? 3 : 1)
                        case .rectangular, .uShape:
                            RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.nuviaGoldFallback : Color.nuviaTertiaryText, lineWidth: isSelected ? 3 : 1)
                        case .oval:
                            Ellipse().stroke(isSelected ? Color.nuviaGoldFallback : Color.nuviaTertiaryText, lineWidth: isSelected ? 3 : 1)
                        }
                    }
                )

                // Table info
                VStack(spacing: 2) {
                    Text(table.name)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaPrimaryText)
                        .lineLimit(1)

                    Text("\(table.occupiedSeats)/\(table.capacity)")
                        .font(NuviaTypography.caption2())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }
        }
        .rotationEffect(.degrees(table.rotation))
    }
}

// MARK: - Table Detail Panel

struct TableDetailPanel: View {
    let table: SeatingTable
    let onClose: () -> Void
    @State private var showGuestPicker = false
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(table.name)
                        .font(NuviaTypography.title3())
                        .foregroundColor(.nuviaPrimaryText)

                    Text("\(table.occupiedSeats)/\(table.capacity) koltuk dolu")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                }

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.nuviaSecondaryText)
                }
            }

            Divider()

            // Seated guests
            if table.seatedGuests.isEmpty {
                Text("Henüz misafir eklenmedi")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(table.seatedGuests, id: \.id) { guest in
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(guest.guestGroup.color.opacity(0.2))
                                        .frame(width: 40, height: 40)

                                    Text(guest.initials)
                                        .font(NuviaTypography.caption())
                                        .foregroundColor(guest.guestGroup.color)
                                }

                                Text(guest.firstName)
                                    .font(NuviaTypography.caption2())
                                    .foregroundColor(.nuviaPrimaryText)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }

            // Actions
            HStack(spacing: 12) {
                NuviaSecondaryButton("Misafir Ekle", icon: "person.badge.plus") {
                    showGuestPicker = true
                }
                .disabled(table.isFull)
            }
        }
        .padding(16)
        .background(Color.nuviaCardBackground)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.2), radius: 10, y: -5)
        .sheet(isPresented: $showGuestPicker) {
            GuestToTablePickerView(table: table)
        }
    }
}

// MARK: - Guest to Table Picker

struct GuestToTablePickerView: View {
    let table: SeatingTable
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    private var unseatedGuests: [Guest] {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else { return [] }
        return project.guests.filter { $0.rsvp == .attending && !$0.isSeated }.sorted { $0.lastName < $1.lastName }
    }

    var body: some View {
        NavigationStack {
            List {
                if unseatedGuests.isEmpty {
                    Text("Tüm misafirler bir masaya atanmış")
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                } else {
                    ForEach(unseatedGuests, id: \.id) { guest in
                        Button {
                            assignGuest(guest)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(guest.guestGroup.color.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    Text(guest.initials)
                                        .font(NuviaTypography.caption())
                                        .foregroundColor(guest.guestGroup.color)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(guest.fullName)
                                        .font(NuviaTypography.body())
                                        .foregroundColor(.nuviaPrimaryText)
                                    HStack(spacing: 4) {
                                        NuviaTag(guest.guestGroup.displayName, color: guest.guestGroup.color, size: .small)
                                        if guest.plusOneCount > 0 {
                                            Text("+\(guest.plusOneCount)")
                                                .font(NuviaTypography.caption2())
                                                .foregroundColor(.nuviaSecondaryText)
                                        }
                                    }
                                }
                                Spacer()

                                // Conflict warning
                                let hasConflict = table.seatedGuests.contains { seated in
                                    guest.conflictWithGuestIds.contains(seated.id) || seated.conflictWithGuestIds.contains(guest.id)
                                }
                                if hasConflict {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.nuviaWarning)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("\(table.name) - Misafir Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
            }
        }
    }

    private func assignGuest(_ guest: Guest) {
        guard !table.isFull else { return }
        let assignment = SeatAssignment(guest: guest, table: table, seatNumber: table.occupiedSeats + 1)
        table.seatAssignments.append(assignment)
        do {
            try modelContext.save()
            HapticManager.shared.seatingDrop()
        } catch {
            print("Failed to assign guest: \(error)")
        }
    }
}

// MARK: - Add Table View

struct AddTableView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var name = ""
    @State private var tableNumber = 1
    @State private var capacity = 10
    @State private var layoutType: TableLayoutType = .round
    @State private var isVIP = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Masa Bilgileri") {
                    TextField("Masa Adı", text: $name)
                    Stepper("Masa No: \(tableNumber)", value: $tableNumber, in: 1...100)
                    Stepper("Kapasite: \(capacity)", value: $capacity, in: 2...20)
                }

                Section("Masa Tipi") {
                    Picker("Tip", selection: $layoutType) {
                        ForEach(TableLayoutType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Toggle("VIP Masa", isOn: $isVIP)
                }
            }
            .navigationTitle("Yeni Masa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ekle") {
                        addTable()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func addTable() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else {
            return
        }

        let table = SeatingTable(
            name: name,
            tableNumber: tableNumber,
            capacity: capacity,
            layoutType: layoutType
        )

        // Position tables in a grid pattern
        let existingCount = project.tables.count
        let row = existingCount / 4
        let col = existingCount % 4
        table.positionX = Double((col - 2) * 120)
        table.positionY = Double((row - 1) * 120)

        if isVIP {
            table.tags.append("VIP")
        }

        project.tables.append(table)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save table: \(error)")
        }
    }
}

// MARK: - Conflicts List View

struct ConflictsListView: View {
    let conflicts: [SeatingConflict]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            if conflicts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.nuviaSuccess)

                    Text("Çatışma Yok!")
                        .font(NuviaTypography.title2())
                        .foregroundColor(.nuviaPrimaryText)

                    Text("Oturma planınızda herhangi bir çatışma bulunmuyor.")
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List {
                    ForEach(conflicts) { conflict in
                        HStack(spacing: 12) {
                            Image(systemName: conflict.type.icon)
                                .foregroundColor(conflict.type.color)
                                .font(.system(size: 20))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(conflict.type.displayName)
                                    .font(NuviaTypography.bodyBold())
                                    .foregroundColor(.nuviaPrimaryText)

                                Text(conflict.message)
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaSecondaryText)

                                Text(conflict.table.name)
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaGoldFallback)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Çatışmalar")
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

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    SeatingPlanView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
