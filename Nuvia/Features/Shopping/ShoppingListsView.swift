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

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                NuviaCard {
                    VStack(spacing: 16) {
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.nuviaGoldFallback)

                        Text("Teslimat Takibi")
                            .font(NuviaTypography.title2())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("Sipariş numarası, kargo firması ve tahmini teslimat tarihi ile teslimatlarınızı takip edin. Kurulum randevularınızı da buradan yönetebilirsiniz.")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(16)

                Spacer()
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Teslimatlar")
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

#Preview {
    ShoppingListsView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
