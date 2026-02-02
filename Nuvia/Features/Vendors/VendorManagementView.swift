import SwiftUI
import SwiftData

// MARK: - Full Vendor Management View

struct VendorManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var selectedCategory: VendorCategory?
    @State private var selectedStatus: VendorStatus?
    @State private var searchText = ""
    @State private var showAddVendor = false
    @State private var sortBy: VendorSortOption = .name

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    private var filteredVendors: [Vendor] {
        guard let project = currentProject else { return [] }
        var vendors = project.vendors

        if let cat = selectedCategory {
            vendors = vendors.filter { $0.vendorCategory == cat }
        }
        if let status = selectedStatus {
            vendors = vendors.filter { $0.vendorStatus == status }
        }
        if !searchText.isEmpty {
            vendors = vendors.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        switch sortBy {
        case .name: return vendors.sorted { $0.name < $1.name }
        case .status: return vendors.sorted { $0.status < $1.status }
        case .price: return vendors.sorted { ($0.agreedPrice ?? 0) < ($1.agreedPrice ?? 0) }
        case .rating: return vendors.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        }
    }

    private var vendorSummary: (total: Int, booked: Int, totalSpent: Double) {
        guard let project = currentProject else { return (0, 0, 0) }
        let total = project.vendors.count
        let booked = project.vendors.filter { $0.vendorStatus == .booked }.count
        let spent = project.vendors.reduce(0.0) { $0 + $1.totalPaid }
        return (total, booked, spent)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary
                HStack(spacing: 20) {
                    StatBadge(icon: "person.2.fill", value: "\(vendorSummary.total)", label: "Tedarikçi")
                    StatBadge(icon: "checkmark.seal.fill", value: "\(vendorSummary.booked)", label: "Rezerve", color: .nuviaSuccess)
                    StatBadge(icon: "turkishlirasign.circle", value: "₺\(Int(vendorSummary.totalSpent).formatted())", label: "Ödenen")
                }
                .padding(12)
                .background(Color.nuviaCardBackground)

                // Search & Filters
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.nuviaSecondaryText)
                        TextField("Tedarikçi ara...", text: $searchText)
                            .font(NuviaTypography.body())
                    }
                    .padding(10)
                    .background(Color.nuviaTertiaryBackground)
                    .cornerRadius(10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Tümü", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(VendorCategory.allCases, id: \.self) { cat in
                                FilterChip(title: cat.displayName, isSelected: selectedCategory == cat, color: cat.color) {
                                    selectedCategory = selectedCategory == cat ? nil : cat
                                }
                            }
                        }
                    }

                    // Status filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Tüm Durumlar", isSelected: selectedStatus == nil) {
                                selectedStatus = nil
                            }
                            ForEach(VendorStatus.allCases, id: \.self) { status in
                                FilterChip(title: status.displayName, isSelected: selectedStatus == status, color: status.color) {
                                    selectedStatus = selectedStatus == status ? nil : status
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                // Vendor list
                if filteredVendors.isEmpty {
                    Spacer()
                    NuviaEmptyState(
                        icon: "person.2.badge.gearshape",
                        title: "Tedarikçi bulunamadı",
                        message: selectedCategory == nil ? "İlk tedarikçinizi ekleyin" : "Bu filtreyle eşleşen tedarikçi yok",
                        actionTitle: "Tedarikçi Ekle"
                    ) {
                        showAddVendor = true
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredVendors, id: \.id) { vendor in
                                VendorDetailCard(vendor: vendor)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Tedarikçiler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Menu {
                            ForEach(VendorSortOption.allCases, id: \.self) { option in
                                Button {
                                    sortBy = option
                                } label: {
                                    Label(option.displayName, systemImage: sortBy == option ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Button {
                            showAddVendor = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddVendor) {
                AddVendorView()
            }
        }
    }
}

enum VendorSortOption: String, CaseIterable {
    case name, status, price, rating

    var displayName: String {
        switch self {
        case .name: return "İsim"
        case .status: return "Durum"
        case .price: return "Fiyat"
        case .rating: return "Puan"
        }
    }
}

// MARK: - Vendor Detail Card

struct VendorDetailCard: View {
    let vendor: Vendor
    @State private var showDetail = false

    var body: some View {
        Button { showDetail = true } label: {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: vendor.vendorCategory.icon)
                        .font(.system(size: 24))
                        .foregroundColor(vendor.vendorCategory.color)
                        .frame(width: 48, height: 48)
                        .background(vendor.vendorCategory.color.opacity(0.15))
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(vendor.name)
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)

                        HStack(spacing: 6) {
                            NuviaTag(vendor.vendorCategory.displayName, color: vendor.vendorCategory.color, size: .small)
                            NuviaTag(vendor.vendorStatus.displayName, color: vendor.vendorStatus.color, size: .small)
                        }
                    }

                    Spacer()

                    if let rating = vendor.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.nuviaGoldFallback)
                            Text("\(rating)")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)
                        }
                    }
                }

                // Price and payment info
                HStack {
                    if let agreed = vendor.agreedPrice {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Anlaşılan")
                                .font(NuviaTypography.caption2())
                                .foregroundColor(.nuviaSecondaryText)
                            Text("₺\(Int(agreed).formatted())")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)
                        }

                        Spacer()

                        VStack(alignment: .center, spacing: 2) {
                            Text("Ödenen")
                                .font(NuviaTypography.caption2())
                                .foregroundColor(.nuviaSecondaryText)
                            Text("₺\(Int(vendor.totalPaid).formatted())")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaSuccess)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Kalan")
                                .font(NuviaTypography.caption2())
                                .foregroundColor(.nuviaSecondaryText)
                            Text("₺\(Int(vendor.remainingAmount).formatted())")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(vendor.remainingAmount > 0 ? .nuviaWarning : .nuviaSuccess)
                        }
                    } else if let min = vendor.priceMin, let max = vendor.priceMax {
                        Text("Fiyat Aralığı: ₺\(Int(min).formatted()) - ₺\(Int(max).formatted())")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }

                // Contact quick actions
                if vendor.phone != nil || vendor.email != nil || vendor.instagram != nil {
                    HStack(spacing: 16) {
                        if let phone = vendor.phone {
                            Link(destination: URL(string: "tel:\(phone)")!) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.nuviaSuccess)
                            }
                        }
                        if let email = vendor.email {
                            Link(destination: URL(string: "mailto:\(email)")!) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.nuviaInfo)
                            }
                        }
                        if vendor.instagram != nil {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.categoryPhoto)
                        }
                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.nuviaTertiaryText)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(16)
            .background(Color.nuviaCardBackground)
            .cornerRadius(16)
        }
        .sheet(isPresented: $showDetail) {
            VendorFullDetailView(vendor: vendor)
        }
    }
}

// MARK: - Add Vendor View

struct AddVendorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var name = ""
    @State private var category: VendorCategory = .venue
    @State private var status: VendorStatus = .researching
    @State private var contactName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var website = ""
    @State private var instagram = ""
    @State private var address = ""
    @State private var city = ""
    @State private var priceMin = ""
    @State private var priceMax = ""
    @State private var agreedPrice = ""
    @State private var rating = 0
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Tedarikçi Bilgileri") {
                    TextField("Firma/Kişi Adı", text: $name)

                    Picker("Kategori", selection: $category) {
                        ForEach(VendorCategory.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.icon).tag(cat)
                        }
                    }

                    Picker("Durum", selection: $status) {
                        ForEach(VendorStatus.allCases, id: \.self) { s in
                            Label(s.displayName, systemImage: s.icon).tag(s)
                        }
                    }
                }

                Section("İletişim") {
                    TextField("İlgili Kişi", text: $contactName)
                    TextField("Telefon", text: $phone).keyboardType(.phonePad)
                    TextField("E-posta", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                    TextField("Website", text: $website).keyboardType(.URL).textInputAutocapitalization(.never)
                    TextField("Instagram", text: $instagram).textInputAutocapitalization(.never)
                }

                Section("Konum") {
                    TextField("Adres", text: $address)
                    TextField("Şehir", text: $city)
                }

                Section("Fiyat") {
                    HStack {
                        TextField("Min Fiyat", text: $priceMin).keyboardType(.decimalPad)
                        Text("-")
                        TextField("Max Fiyat", text: $priceMax).keyboardType(.decimalPad)
                    }
                    TextField("Anlaşılan Fiyat", text: $agreedPrice).keyboardType(.decimalPad)
                }

                Section("Değerlendirme") {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                rating = star
                                HapticManager.shared.selection()
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.system(size: 24))
                                    .foregroundColor(.nuviaGoldFallback)
                            }
                        }
                    }
                }

                Section("Notlar") {
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Yeni Tedarikçi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") { saveVendor() }
                        .disabled(name.isEmpty)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveVendor() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else { return }

        let vendor = Vendor(name: name, category: category, status: status)
        vendor.contactName = contactName.isEmpty ? nil : contactName
        vendor.phone = phone.isEmpty ? nil : phone
        vendor.email = email.isEmpty ? nil : email
        vendor.website = website.isEmpty ? nil : website
        vendor.instagram = instagram.isEmpty ? nil : instagram
        vendor.address = address.isEmpty ? nil : address
        vendor.city = city.isEmpty ? nil : city
        vendor.priceMin = Double(priceMin)
        vendor.priceMax = Double(priceMax)
        vendor.agreedPrice = Double(agreedPrice)
        vendor.rating = rating > 0 ? rating : nil
        vendor.notes = notes.isEmpty ? nil : notes

        project.vendors.append(vendor)

        do {
            try modelContext.save()
            HapticManager.shared.taskCompleted()
            dismiss()
        } catch {
            print("Failed to save vendor: \(error)")
        }
    }
}

// MARK: - Vendor Full Detail View

struct VendorFullDetailView: View {
    let vendor: Vendor
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showEditStatus = false
    @State private var showAddPayment = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: vendor.vendorCategory.icon)
                            .font(.system(size: 48))
                            .foregroundColor(vendor.vendorCategory.color)

                        Text(vendor.name)
                            .font(NuviaTypography.title2())
                            .foregroundColor(.nuviaPrimaryText)

                        HStack(spacing: 8) {
                            NuviaTag(vendor.vendorCategory.displayName, color: vendor.vendorCategory.color)
                            NuviaTag(vendor.vendorStatus.displayName, color: vendor.vendorStatus.color)
                        }

                        if let rating = vendor.rating {
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.system(size: 16))
                                        .foregroundColor(.nuviaGoldFallback)
                                }
                            }
                        }
                    }
                    .padding(.top, 16)

                    // Status Pipeline
                    NuviaCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Durum Akışı")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)

                            HStack(spacing: 4) {
                                ForEach(VendorStatus.allCases, id: \.self) { status in
                                    let isActive = statusOrder(vendor.vendorStatus) >= statusOrder(status)
                                    let isCancelled = vendor.vendorStatus == .cancelled

                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(isCancelled && status == .cancelled ? Color.nuviaError : (isActive ? status.color : Color.nuviaTertiaryBackground))
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Image(systemName: status.icon)
                                                    .font(.system(size: 10))
                                                    .foregroundColor(isActive || (isCancelled && status == .cancelled) ? .white : .nuviaSecondaryText)
                                            )

                                        Text(status.displayName)
                                            .font(.system(size: 8))
                                            .foregroundColor(isActive ? .nuviaPrimaryText : .nuviaTertiaryText)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }

                            Button {
                                showEditStatus = true
                            } label: {
                                Text("Durumu Güncelle")
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaGoldFallback)
                            }
                        }
                    }

                    // Contact Info
                    if vendor.contactName != nil || vendor.phone != nil || vendor.email != nil {
                        NuviaCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("İletişim")
                                    .font(NuviaTypography.bodyBold())
                                    .foregroundColor(.nuviaPrimaryText)

                                if let contact = vendor.contactName {
                                    contactRow(icon: "person.fill", text: contact)
                                }
                                if let phone = vendor.phone {
                                    Link(destination: URL(string: "tel:\(phone)")!) {
                                        contactRow(icon: "phone.fill", text: phone, color: .nuviaSuccess)
                                    }
                                }
                                if let email = vendor.email {
                                    Link(destination: URL(string: "mailto:\(email)")!) {
                                        contactRow(icon: "envelope.fill", text: email, color: .nuviaInfo)
                                    }
                                }
                                if let address = vendor.address {
                                    contactRow(icon: "mappin.circle.fill", text: "\(address)\(vendor.city.map { ", \($0)" } ?? "")")
                                }
                            }
                        }
                    }

                    // Financials
                    if vendor.agreedPrice != nil || vendor.priceMin != nil {
                        NuviaCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Finansal")
                                    .font(NuviaTypography.bodyBold())
                                    .foregroundColor(.nuviaPrimaryText)

                                if let agreed = vendor.agreedPrice {
                                    HStack {
                                        Text("Anlaşılan Fiyat")
                                            .foregroundColor(.nuviaSecondaryText)
                                        Spacer()
                                        Text("₺\(Int(agreed).formatted())")
                                            .font(NuviaTypography.bodyBold())
                                            .foregroundColor(.nuviaPrimaryText)
                                    }

                                    // Payment progress
                                    let progress = agreed > 0 ? vendor.totalPaid / agreed : 0
                                    VStack(spacing: 4) {
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Rectangle().fill(Color.nuviaTertiaryBackground).frame(height: 8).cornerRadius(4)
                                                Rectangle().fill(Color.nuviaSuccess).frame(width: geo.size.width * min(progress, 1.0), height: 8).cornerRadius(4)
                                            }
                                        }
                                        .frame(height: 8)

                                        HStack {
                                            Text("Ödenen: ₺\(Int(vendor.totalPaid).formatted())")
                                                .font(NuviaTypography.caption())
                                                .foregroundColor(.nuviaSuccess)
                                            Spacer()
                                            Text("Kalan: ₺\(Int(vendor.remainingAmount).formatted())")
                                                .font(NuviaTypography.caption())
                                                .foregroundColor(.nuviaWarning)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Payments History
                    if !vendor.payments.isEmpty {
                        NuviaCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Ödeme Geçmişi")
                                    .font(NuviaTypography.bodyBold())
                                    .foregroundColor(.nuviaPrimaryText)

                                ForEach(vendor.payments.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { payment in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(payment.title)
                                                .font(NuviaTypography.body())
                                                .foregroundColor(.nuviaPrimaryText)
                                            Text(payment.createdAt.formatted(date: .abbreviated, time: .omitted))
                                                .font(NuviaTypography.caption())
                                                .foregroundColor(.nuviaSecondaryText)
                                        }
                                        Spacer()
                                        Text("₺\(Int(payment.amount).formatted())")
                                            .font(NuviaTypography.bodyBold())
                                            .foregroundColor(payment.isPaid ? .nuviaSuccess : .nuviaWarning)
                                    }
                                }
                            }
                        }
                    }

                    // Notes
                    if let notes = vendor.notes {
                        NuviaCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notlar")
                                    .font(NuviaTypography.bodyBold())
                                    .foregroundColor(.nuviaPrimaryText)
                                Text(notes)
                                    .font(NuviaTypography.body())
                                    .foregroundColor(.nuviaSecondaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    // Actions
                    VStack(spacing: 12) {
                        NuviaPrimaryButton("Ödeme Ekle", icon: "creditcard") {
                            showAddPayment = true
                        }

                        Button(role: .destructive) {
                            deleteVendor()
                        } label: {
                            Text("Tedarikçiyi Sil")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaError)
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
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
            }
            .confirmationDialog("Durumu Güncelle", isPresented: $showEditStatus) {
                ForEach(VendorStatus.allCases, id: \.self) { status in
                    Button(status.displayName) {
                        vendor.vendorStatus = status
                        vendor.updatedAt = Date()
                        try? modelContext.save()
                        HapticManager.shared.taskCompleted()
                    }
                }
            }
        }
    }

    private func contactRow(icon: String, text: String, color: Color = .nuviaGoldFallback) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(text)
                .font(NuviaTypography.body())
                .foregroundColor(.nuviaPrimaryText)
        }
    }

    private func statusOrder(_ status: VendorStatus) -> Int {
        switch status {
        case .researching: return 0
        case .contacted: return 1
        case .meeting: return 2
        case .selected: return 3
        case .booked: return 4
        case .cancelled: return -1
        }
    }

    private func deleteVendor() {
        modelContext.delete(vendor)
        try? modelContext.save()
        HapticManager.shared.warning()
        dismiss()
    }
}

#Preview {
    VendorManagementView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
