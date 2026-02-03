import SwiftUI
import SwiftData

/// Alışveriş listeleri ana ekranı
struct ShoppingListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var selectedType: ShoppingListType?
    @State private var showAddList = false
    @State private var showDeliveries = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let project = currentProject {
                    VStack(spacing: 20) {
                        // Filter tabs
                        HStack(spacing: 12) {
                            FilterChip(title: "Tümü", isSelected: selectedType == nil) {
                                selectedType = nil
                            }
                            FilterChip(title: "Düğün", isSelected: selectedType == .wedding, color: .nuviaGoldFallback) {
                                selectedType = .wedding
                            }
                            FilterChip(title: "Ev", isSelected: selectedType == .home, color: .nuviaInfo) {
                                selectedType = .home
                            }
                        }
                        .padding(.horizontal, 16)

                        // Lists
                        let filteredLists = selectedType == nil
                            ? project.shoppingLists
                            : project.shoppingLists.filter { $0.shoppingListType == selectedType }

                        if filteredLists.isEmpty {
                            NuviaEmptyState(
                                icon: "cart",
                                title: "Liste bulunamadı",
                                message: "İlk alışveriş listenizi oluşturun",
                                actionTitle: "Liste Oluştur"
                            ) {
                                showAddList = true
                            }
                            .padding(.top, 40)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredLists, id: \.id) { list in
                                    ShoppingListCard(list: list)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer()
                    }
                    .padding(.bottom, 100)
                } else {
                    NuviaEmptyState(
                        icon: "cart.badge.questionmark",
                        title: "Proje bulunamadı",
                        message: "Alışveriş listesi için bir proje oluşturun"
                    )
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Alışveriş")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showDeliveries = true
                        } label: {
                            Image(systemName: "shippingbox.fill")
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Button {
                            showAddList = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddList) {
                AddShoppingListView()
            }
            .sheet(isPresented: $showDeliveries) {
                DeliveriesView()
            }
        }
    }
}

// MARK: - Shopping List Card

struct ShoppingListCard: View {
    let list: ShoppingList
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(list.title)
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)

                            NuviaTag(
                                list.shoppingListType.displayName,
                                color: list.shoppingListType.color,
                                size: .small
                            )
                        }

                        Text("\(list.completedItems)/\(list.totalItems) tamamlandı")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }

                    Spacer()

                    NuviaProgressRing(
                        progress: list.progress,
                        size: 48,
                        lineWidth: 5
                    )
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.nuviaTertiaryBackground)
                            .frame(height: 6)
                            .cornerRadius(3)

                        Rectangle()
                            .fill(list.shoppingListType.color)
                            .frame(width: geometry.size.width * CGFloat(list.progress), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)

                // Pending items preview
                if !list.pendingItems.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(list.pendingItems.prefix(3), id: \.id) { item in
                            Text(item.name)
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.nuviaTertiaryBackground)
                                .cornerRadius(6)
                        }

                        if list.pendingItems.count > 3 {
                            Text("+\(list.pendingItems.count - 3)")
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.nuviaCardBackground)
            .cornerRadius(16)
        }
        .sheet(isPresented: $showDetail) {
            ShoppingListDetailView(list: list)
        }
    }
}

// MARK: - Add Shopping List View

struct AddShoppingListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var title = ""
    @State private var listType: ShoppingListType = .wedding

    var body: some View {
        NavigationStack {
            Form {
                Section("Liste Bilgileri") {
                    TextField("Liste Adı", text: $title)

                    Picker("Tip", selection: $listType) {
                        ForEach(ShoppingListType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Yeni Liste")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Oluştur") {
                        createList()
                    }
                    .disabled(title.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func createList() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else {
            return
        }

        let list = ShoppingList(title: title, type: listType)
        project.shoppingLists.append(list)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save list: \(error)")
        }
    }
}

// MARK: - Shopping List Detail View

struct ShoppingListDetailView: View {
    let list: ShoppingList
    @Environment(\.dismiss) private var dismiss
    @State private var showAddItem = false
    @State private var newItemName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(list.completedItems)/\(list.totalItems) tamamlandı")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaPrimaryText)

                        if list.estimatedTotal > 0 {
                            Text("Tahmini: ₺\(Int(list.estimatedTotal).formatted())")
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }

                    Spacer()

                    NuviaProgressRing(progress: list.progress, size: 48, lineWidth: 5)
                }
                .padding(16)
                .background(Color.nuviaCardBackground)

                // Add item bar
                HStack {
                    TextField("Yeni ürün ekle...", text: $newItemName)
                        .font(NuviaTypography.body())

                    Button {
                        addItem()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.nuviaGoldFallback)
                    }
                    .disabled(newItemName.isEmpty)
                }
                .padding(12)
                .background(Color.nuviaTertiaryBackground)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Items list
                if list.items.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .font(.system(size: 48))
                            .foregroundColor(.nuviaSecondaryText)

                        Text("Henüz ürün eklenmedi")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(list.items.sorted { $0.itemStatus.rawValue < $1.itemStatus.rawValue }, id: \.id) { item in
                            ShoppingItemRow(item: item)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle(list.title)
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

    private func addItem() {
        let item = ShoppingItem(name: newItemName)
        list.items.append(item)
        newItemName = ""
    }
}

// MARK: - Shopping Item Row

struct ShoppingItemRow: View {
    let item: ShoppingItem
    @State private var isCompleted: Bool

    init(item: ShoppingItem) {
        self.item = item
        self._isCompleted = State(initialValue: item.itemStatus == .purchased)
    }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                isCompleted.toggle()
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isCompleted ? .nuviaSuccess : .nuviaSecondaryText)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(NuviaTypography.body())
                    .foregroundColor(isCompleted ? .nuviaSecondaryText : .nuviaPrimaryText)
                    .strikethrough(isCompleted)

                HStack(spacing: 8) {
                    if item.quantity > 1 {
                        Text("x\(item.quantity)")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }

                    if let price = item.estimatedPrice {
                        Text("₺\(Int(price).formatted())")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }

                    if let store = item.storeName {
                        Text(store)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaInfo)
                    }
                }
            }

            Spacer()

            NuviaTag(item.itemStatus.displayName, color: item.itemStatus.color, size: .small)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Deliveries View

struct DeliveriesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var deliveries: [Delivery]
    @State private var showAddDelivery = false
    @State private var selectedFilter: DeliveryFilter = .all

    enum DeliveryFilter: String, CaseIterable {
        case all = "Tümü"
        case active = "Aktif"
        case delivered = "Teslim Edilen"
    }

    private var filteredDeliveries: [Delivery] {
        switch selectedFilter {
        case .all: return deliveries.sorted { ($0.estimatedDeliveryDate ?? .distantFuture) < ($1.estimatedDeliveryDate ?? .distantFuture) }
        case .active: return deliveries.filter { !$0.isDelivered }.sorted { ($0.estimatedDeliveryDate ?? .distantFuture) < ($1.estimatedDeliveryDate ?? .distantFuture) }
        case .delivered: return deliveries.filter { $0.isDelivered }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filtre", selection: $selectedFilter) {
                    ForEach(DeliveryFilter.allCases, id: \.self) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if filteredDeliveries.isEmpty {
                    Spacer()
                    NuviaEmptyState(
                        icon: "shippingbox",
                        title: "Teslimat yok",
                        message: "Yeni bir teslimat ekleyerek siparişlerinizi takip edin"
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredDeliveries) { delivery in
                                DeliveryCard(delivery: delivery)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Teslimatlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showAddDelivery = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                        Button("Kapat") {
                            dismiss()
                        }
                        .foregroundColor(.nuviaGoldFallback)
                    }
                }
            }
            .sheet(isPresented: $showAddDelivery) {
                AddDeliverySheet()
            }
        }
    }
}

struct DeliveryCard: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var delivery: Delivery
    @State private var showActions = false

    var body: some View {
        NuviaCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: delivery.deliveryStatus.icon)
                        .font(.system(size: 20))
                        .foregroundColor(delivery.deliveryStatus.color)

                    VStack(alignment: .leading, spacing: 2) {
                        if let item = delivery.linkedItem {
                            Text(item.name)
                                .font(NuviaTypography.headline())
                                .foregroundColor(.nuviaPrimaryText)
                        } else if let orderNum = delivery.orderNumber {
                            Text("Sipariş #\(orderNum)")
                                .font(NuviaTypography.headline())
                                .foregroundColor(.nuviaPrimaryText)
                        } else {
                            Text("Teslimat")
                                .font(NuviaTypography.headline())
                                .foregroundColor(.nuviaPrimaryText)
                        }

                        if let carrier = delivery.carrierName {
                            Text(carrier)
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }

                    Spacer()

                    NuviaTag(delivery.deliveryStatus.displayName, color: delivery.deliveryStatus.color, size: .small)
                }

                // Status pipeline
                DeliveryPipeline(currentStatus: delivery.deliveryStatus)

                // Details
                HStack(spacing: 16) {
                    if let eta = delivery.estimatedDeliveryDate {
                        Label(eta.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(NuviaTypography.caption())
                            .foregroundColor(delivery.isLate ? .nuviaError : .nuviaSecondaryText)
                    }
                    if let tracking = delivery.trackingNumber {
                        Label(tracking, systemImage: "number")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                            .lineLimit(1)
                    }
                }

                if delivery.isLate {
                    Text("Tahmini teslim tarihi geçti!")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaError)
                }

                // Actions
                if !delivery.isDelivered {
                    HStack(spacing: 8) {
                        let nextStatus = nextDeliveryStatus(delivery.deliveryStatus)
                        if let next = nextStatus {
                            Button {
                                HapticManager.shared.buttonTap()
                                withAnimation { delivery.deliveryStatus = next }
                                if next == .delivered { delivery.actualDeliveryDate = Date() }
                                delivery.updatedAt = Date()
                                try? modelContext.save()
                            } label: {
                                Label(next.displayName, systemImage: next.icon)
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaPrimaryText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(next.color.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                if let notes = delivery.notes, !notes.isEmpty {
                    Text(notes)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaTertiaryText)
                        .lineLimit(2)
                }
            }
        }
    }

    private func nextDeliveryStatus(_ current: DeliveryStatus) -> DeliveryStatus? {
        switch current {
        case .ordered: return .shipped
        case .shipped: return .outForDelivery
        case .outForDelivery: return .delivered
        case .delivered: return .installed
        case .installed: return nil
        }
    }
}

struct DeliveryPipeline: View {
    let currentStatus: DeliveryStatus
    private let allStatuses: [DeliveryStatus] = [.ordered, .shipped, .outForDelivery, .delivered, .installed]

    private func statusIndex(_ s: DeliveryStatus) -> Int {
        allStatuses.firstIndex(of: s) ?? 0
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(allStatuses, id: \.self) { status in
                let idx = statusIndex(status)
                let currentIdx = statusIndex(currentStatus)
                let isCompleted = idx <= currentIdx
                let isCurrent = idx == currentIdx

                Circle()
                    .fill(isCompleted ? status.color : Color.nuviaTertiaryBackground)
                    .frame(width: isCurrent ? 12 : 8, height: isCurrent ? 12 : 8)

                if status != .installed {
                    Rectangle()
                        .fill(idx < currentIdx ? currentStatus.color : Color.nuviaTertiaryBackground)
                        .frame(height: 2)
                }
            }
        }
        .frame(height: 14)
    }
}

struct AddDeliverySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var orderNumber = ""
    @State private var carrierName = ""
    @State private var trackingNumber = ""
    @State private var estimatedDate = Date().addingTimeInterval(7 * 86400)
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Sipariş Bilgileri") {
                    TextField("Sipariş Numarası", text: $orderNumber)
                    TextField("Kargo Firması", text: $carrierName)
                    TextField("Takip Numarası", text: $trackingNumber)
                }

                Section("Tarih") {
                    DatePicker("Tahmini Teslimat", selection: $estimatedDate, displayedComponents: .date)
                }

                Section("Notlar") {
                    TextField("Not ekleyin...", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.nuviaBackground)
            .navigationTitle("Yeni Teslimat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(.nuviaSecondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        let delivery = Delivery(
                            orderNumber: orderNumber.isEmpty ? nil : orderNumber,
                            carrierName: carrierName.isEmpty ? nil : carrierName,
                            estimatedDeliveryDate: estimatedDate
                        )
                        delivery.trackingNumber = trackingNumber.isEmpty ? nil : trackingNumber
                        delivery.notes = notes.isEmpty ? nil : notes
                        modelContext.insert(delivery)
                        try? modelContext.save()
                        HapticManager.shared.taskCompleted()
                        dismiss()
                    }
                    .foregroundColor(.nuviaGoldFallback)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ShoppingListsView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
