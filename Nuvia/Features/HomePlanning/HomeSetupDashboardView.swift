import SwiftUI
import SwiftData

/// Ev Planlama Dashboard
struct HomeSetupDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var showAddRoom = false
    @State private var showInventory = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let project = currentProject {
                    VStack(spacing: 20) {
                        // Summary Card
                        HomeSetupSummaryCard(project: project)

                        // Rooms Grid
                        NuviaCard {
                            VStack(spacing: 16) {
                                NuviaSectionHeader("Odalar", actionTitle: "Ekle") {
                                    showAddRoom = true
                                }

                                if project.rooms.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "door.left.hand.open")
                                            .font(.system(size: 32))
                                            .foregroundColor(.nuviaSecondaryText)

                                        Text("Henüz oda eklenmedi")
                                            .font(NuviaTypography.body())
                                            .foregroundColor(.nuviaSecondaryText)
                                    }
                                    .padding(.vertical, 20)
                                } else {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                        ForEach(project.rooms, id: \.id) { room in
                                            RoomCard(room: room)
                                        }
                                    }
                                }
                            }
                        }

                        // Shopping Lists
                        NuviaCard {
                            VStack(spacing: 16) {
                                NuviaSectionHeader("Ev Alışveriş Listeleri")

                                let homeLists = project.shoppingLists.filter { $0.shoppingListType == .home }

                                if homeLists.isEmpty {
                                    Text("Henüz liste eklenmedi")
                                        .font(NuviaTypography.body())
                                        .foregroundColor(.nuviaSecondaryText)
                                        .padding(.vertical, 8)
                                } else {
                                    VStack(spacing: 8) {
                                        ForEach(homeLists, id: \.id) { list in
                                            ShoppingListRow(list: list)
                                        }
                                    }
                                }
                            }
                        }

                        // Warranty Alerts
                        NuviaCard {
                            VStack(spacing: 16) {
                                NuviaSectionHeader("Garanti Takibi", actionTitle: "Tümü") {
                                    showInventory = true
                                }

                                let expiringItems = project.rooms.flatMap { $0.inventoryItems }.filter { $0.isWarrantyExpiring }

                                if expiringItems.isEmpty {
                                    HStack {
                                        Image(systemName: "shield.checkered")
                                            .foregroundColor(.nuviaSuccess)
                                        Text("Yaklaşan garanti süresi yok")
                                            .font(NuviaTypography.body())
                                            .foregroundColor(.nuviaSecondaryText)
                                    }
                                    .padding(.vertical, 8)
                                } else {
                                    VStack(spacing: 8) {
                                        ForEach(expiringItems.prefix(3), id: \.id) { item in
                                            WarrantyAlertRow(item: item)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                } else {
                    NuviaEmptyState(
                        icon: "house.slash",
                        title: "Proje bulunamadı",
                        message: "Ev planlaması için bir proje oluşturun"
                    )
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Ev")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showInventory = true
                    } label: {
                        Image(systemName: "archivebox.fill")
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }
            }
            .sheet(isPresented: $showAddRoom) {
                AddRoomView()
            }
            .sheet(isPresented: $showInventory) {
                InventoryView()
            }
        }
    }
}

// MARK: - Home Setup Summary Card

struct HomeSetupSummaryCard: View {
    let project: WeddingProject

    private var totalRooms: Int {
        project.rooms.count
    }

    private var completedRooms: Int {
        project.rooms.filter { $0.setupProgress >= 1.0 }.count
    }

    private var averageProgress: Double {
        guard !project.rooms.isEmpty else { return 0 }
        return project.rooms.reduce(0) { $0 + $1.setupProgress } / Double(project.rooms.count)
    }

    var body: some View {
        NuviaCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ev Kurulum Durumu")
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("\(completedRooms)/\(totalRooms) oda tamamlandı")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }

                    Spacer()

                    NuviaProgressRing(
                        progress: averageProgress,
                        size: 60,
                        lineWidth: 6
                    )
                }

                // Quick stats
                HStack(spacing: 16) {
                    QuickStatCard(
                        icon: "door.left.hand.open",
                        value: "\(totalRooms)",
                        label: "Oda",
                        color: .nuviaInfo
                    )

                    QuickStatCard(
                        icon: "shippingbox.fill",
                        value: "\(project.rooms.flatMap { $0.inventoryItems }.filter { !$0.isDelivered }.count)",
                        label: "Bekleyen",
                        color: .nuviaWarning
                    )
                }
            }
        }
    }
}

// MARK: - Room Card

struct RoomCard: View {
    let room: Room
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(room.roomCategory.color.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: room.roomCategory.icon)
                        .font(.system(size: 24))
                        .foregroundColor(room.roomCategory.color)
                }

                VStack(spacing: 4) {
                    Text(room.name)
                        .font(NuviaTypography.bodyBold())
                        .foregroundColor(.nuviaPrimaryText)
                        .lineLimit(1)

                    Text("\(Int(room.setupProgress * 100))%")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                }

                ProgressView(value: room.setupProgress)
                    .tint(room.roomCategory.color)
            }
            .padding(16)
            .background(Color.nuviaTertiaryBackground)
            .cornerRadius(16)
        }
        .sheet(isPresented: $showDetail) {
            RoomDetailView(room: room)
        }
    }
}

// MARK: - Shopping List Row

struct ShoppingListRow: View {
    let list: ShoppingList

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "cart.fill")
                .foregroundColor(.nuviaGoldFallback)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(list.title)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)

                Text("\(list.completedItems)/\(list.totalItems) tamamlandı")
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }

            Spacer()

            NuviaProgressRing(
                progress: list.progress,
                size: 32,
                lineWidth: 4,
                showPercentage: false
            )
        }
        .padding(12)
        .background(Color.nuviaTertiaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Warranty Alert Row

struct WarrantyAlertRow: View {
    let item: InventoryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.shield.fill")
                .foregroundColor(.nuviaWarning)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)

                Text(item.formattedWarrantyStatus)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaWarning)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.nuviaTertiaryText)
                .font(.system(size: 14))
        }
        .padding(12)
        .background(Color.nuviaWarning.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Add Room View

struct AddRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var name = ""
    @State private var roomType: RoomType = .livingRoom
    @State private var width = ""
    @State private var length = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Oda Bilgileri") {
                    TextField("Oda Adı", text: $name)

                    Picker("Oda Tipi", selection: $roomType) {
                        ForEach(RoomType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }

                Section("Ölçüler (Opsiyonel)") {
                    HStack {
                        TextField("Genişlik (m)", text: $width)
                            .keyboardType(.decimalPad)
                        Text("x")
                        TextField("Uzunluk (m)", text: $length)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Yeni Oda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ekle") {
                        addRoom()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func addRoom() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else {
            return
        }

        let room = Room(name: name, type: roomType)
        room.width = Double(width)
        room.length = Double(length)

        project.rooms.append(room)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save room: \(error)")
        }
    }
}

// MARK: - Room Detail View

struct RoomDetailView: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(room.roomCategory.color.opacity(0.15))
                                .frame(width: 80, height: 80)

                            Image(systemName: room.roomCategory.icon)
                                .font(.system(size: 36))
                                .foregroundColor(room.roomCategory.color)
                        }

                        Text(room.name)
                            .font(NuviaTypography.title2())
                            .foregroundColor(.nuviaPrimaryText)

                        if room.formattedArea != "Belirtilmedi" {
                            Text(room.formattedArea)
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        NuviaProgressRing(progress: room.setupProgress, size: 80, lineWidth: 8)
                    }
                    .padding(.top, 24)

                    Divider()

                    // Inventory items
                    NuviaCard {
                        VStack(spacing: 16) {
                            NuviaSectionHeader("Eşyalar")

                            if room.inventoryItems.isEmpty {
                                Text("Henüz eşya eklenmedi")
                                    .font(NuviaTypography.body())
                                    .foregroundColor(.nuviaSecondaryText)
                                    .padding(.vertical, 8)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(room.inventoryItems, id: \.id) { item in
                                        InventoryItemRow(item: item)
                                    }
                                }
                            }

                            NuviaPrimaryButton("Eşya Ekle", icon: "plus.circle.fill") {}
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
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

// MARK: - Inventory View

struct InventoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    private var allItems: [InventoryItem] {
        currentProject?.rooms.flatMap { $0.inventoryItems } ?? []
    }

    var body: some View {
        NavigationStack {
            if allItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 64))
                        .foregroundColor(.nuviaSecondaryText)

                    Text("Henüz envanter eklenmedi")
                        .font(NuviaTypography.title3())
                        .foregroundColor(.nuviaPrimaryText)

                    Text("Odalara eşya ekleyerek envanter oluşturun")
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                }
            } else {
                List {
                    ForEach(allItems, id: \.id) { item in
                        InventoryItemRow(item: item)
                    }
                }
            }
        }
        .navigationTitle("Envanter")
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

struct InventoryItemRow: View {
    let item: InventoryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.isDelivered ? "checkmark.circle.fill" : "clock.fill")
                .foregroundColor(item.isDelivered ? .nuviaSuccess : .nuviaWarning)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)

                if let brand = item.brand {
                    Text(brand)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }

            Spacer()

            if item.warrantyEndDate != nil {
                VStack(alignment: .trailing, spacing: 2) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 12))
                        .foregroundColor(item.isWarrantyExpiring ? .nuviaWarning : .nuviaSuccess)

                    Text(item.formattedWarrantyStatus)
                        .font(NuviaTypography.caption2())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }
        }
        .padding(12)
        .background(Color.nuviaTertiaryBackground)
        .cornerRadius(12)
    }
}

#Preview {
    HomeSetupDashboardView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
