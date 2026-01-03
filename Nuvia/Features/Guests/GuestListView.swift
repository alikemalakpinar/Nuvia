import SwiftUI
import SwiftData

/// Davetli listesi ana ekranı
struct GuestListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var searchText = ""
    @State private var selectedFilter: GuestFilter = .all
    @State private var showAddGuest = false
    @State private var showSeating = false
    @State private var showRSVP = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let project = currentProject {
                    // Summary header
                    GuestSummaryHeader(project: project)

                    // Filter tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(GuestFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.displayName,
                                    isSelected: selectedFilter == filter,
                                    color: filter.color
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }

                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.nuviaSecondaryText)
                        TextField("Misafir ara...", text: $searchText)
                            .font(NuviaTypography.body())
                    }
                    .padding(12)
                    .background(Color.nuviaCardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)

                    // Guest list
                    GuestListContent(
                        project: project,
                        searchText: searchText,
                        filter: selectedFilter
                    )
                } else {
                    NuviaEmptyState(
                        icon: "person.2.slash",
                        title: "Proje bulunamadı",
                        message: "Davetli yönetimi için bir proje oluşturun"
                    )
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Davetliler")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Menu {
                            Button {
                                showSeating = true
                            } label: {
                                Label("Oturma Planı", systemImage: "rectangle.split.3x3")
                            }

                            Button {
                                showRSVP = true
                            } label: {
                                Label("RSVP Yönetimi", systemImage: "envelope.badge")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Button {
                            showAddGuest = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddGuest) {
                AddGuestView()
            }
            .sheet(isPresented: $showSeating) {
                SeatingPlanView()
            }
            .sheet(isPresented: $showRSVP) {
                RSVPDashboardView()
            }
        }
    }
}

// MARK: - Guest Filter

enum GuestFilter: String, CaseIterable {
    case all = "Tümü"
    case attending = "Geliyor"
    case pending = "Bekliyor"
    case notAttending = "Gelmiyor"
    case bride = "Gelin Tarafı"
    case groom = "Damat Tarafı"
    case vip = "VIP"

    var displayName: String { rawValue }

    var color: Color {
        switch self {
        case .all: return .nuviaGoldFallback
        case .attending: return .nuviaSuccess
        case .pending: return .nuviaWarning
        case .notAttending: return .nuviaError
        case .bride: return .categoryDress
        case .groom: return .nuviaInfo
        case .vip: return .nuviaGoldFallback
        }
    }
}

// MARK: - Guest Summary Header

struct GuestSummaryHeader: View {
    let project: WeddingProject

    private var totalHeadcount: Int {
        project.guests.reduce(0) { $0 + 1 + $1.plusOneCount }
    }

    private var attendingCount: Int {
        project.guests.filter { $0.rsvp == .attending }.reduce(0) { $0 + 1 + $1.plusOneCount }
    }

    var body: some View {
        HStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("\(project.guests.count)")
                    .font(NuviaTypography.largeNumber())
                    .foregroundColor(.nuviaPrimaryText)
                Text("Davetli")
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }

            VStack(spacing: 4) {
                Text("\(totalHeadcount)")
                    .font(NuviaTypography.largeNumber())
                    .foregroundColor(.nuviaGoldFallback)
                Text("Toplam Kişi")
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }

            VStack(spacing: 4) {
                Text("\(attendingCount)")
                    .font(NuviaTypography.largeNumber())
                    .foregroundColor(.nuviaSuccess)
                Text("Onaylı")
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.nuviaCardBackground)
    }
}

// MARK: - Guest List Content

struct GuestListContent: View {
    let project: WeddingProject
    let searchText: String
    let filter: GuestFilter

    private var filteredGuests: [Guest] {
        var guests = project.guests

        // Apply filter
        switch filter {
        case .all:
            break
        case .attending:
            guests = guests.filter { $0.rsvp == .attending }
        case .pending:
            guests = guests.filter { $0.rsvp == .pending }
        case .notAttending:
            guests = guests.filter { $0.rsvp == .notAttending }
        case .bride:
            guests = guests.filter { $0.guestGroup == .bride }
        case .groom:
            guests = guests.filter { $0.guestGroup == .groom }
        case .vip:
            guests = guests.filter { $0.isVIP }
        }

        // Apply search
        if !searchText.isEmpty {
            guests = guests.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return guests.sorted { $0.lastName < $1.lastName }
    }

    var body: some View {
        if filteredGuests.isEmpty {
            Spacer()
            NuviaEmptyState(
                icon: "person.badge.plus",
                title: "Misafir bulunamadı",
                message: filter == .all ? "İlk misafirinizi ekleyin" : "Bu filtreyle eşleşen misafir yok"
            )
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredGuests, id: \.id) { guest in
                        GuestCard(guest: guest)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Guest Card

struct GuestCard: View {
    let guest: Guest
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(guest.guestGroup.color.opacity(0.2))
                        .frame(width: 48, height: 48)

                    Text(guest.initials)
                        .font(NuviaTypography.bodyBold())
                        .foregroundColor(guest.guestGroup.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(guest.fullName)
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)

                        if guest.isVIP {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }

                    HStack(spacing: 8) {
                        NuviaTag(guest.guestGroup.displayName, color: guest.guestGroup.color, size: .small)

                        if guest.plusOneCount > 0 {
                            Text("+\(guest.plusOneCount)")
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }
                }

                Spacer()

                // RSVP Status
                Image(systemName: guest.rsvp.icon)
                    .font(.system(size: 24))
                    .foregroundColor(guest.rsvp.color)
            }
            .padding(16)
            .background(Color.nuviaCardBackground)
            .cornerRadius(16)
        }
        .sheet(isPresented: $showDetail) {
            GuestDetailView(guest: guest)
        }
    }
}

// MARK: - Add Guest View

struct AddGuestView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var group: GuestGroup = .mutual
    @State private var plusOneCount = 0
    @State private var isVIP = false
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Kişi Bilgileri") {
                    TextField("Ad", text: $firstName)
                    TextField("Soyad", text: $lastName)
                    TextField("Telefon (opsiyonel)", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("E-posta (opsiyonel)", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("Grup") {
                    Picker("Taraf", selection: $group) {
                        ForEach(GuestGroup.allCases, id: \.self) { grp in
                            Text(grp.displayName).tag(grp)
                        }
                    }
                }

                Section("Ek Bilgiler") {
                    Stepper("Eşlik Eden: \(plusOneCount)", value: $plusOneCount, in: 0...5)

                    Toggle("VIP Misafir", isOn: $isVIP)

                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Yeni Misafir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        saveGuest()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveGuest() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else {
            return
        }

        let guest = Guest(
            firstName: firstName,
            lastName: lastName,
            group: group,
            plusOneCount: plusOneCount
        )

        guest.phone = phone.isEmpty ? nil : phone
        guest.email = email.isEmpty ? nil : email
        guest.notes = notes.isEmpty ? nil : notes

        if isVIP {
            guest.addTag(GuestTag.vip.rawValue)
        }

        project.guests.append(guest)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save guest: \(error)")
        }
    }
}

// MARK: - Guest Detail View

struct GuestDetailView: View {
    let guest: Guest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(guest.guestGroup.color.opacity(0.2))
                                .frame(width: 80, height: 80)

                            Text(guest.initials)
                                .font(NuviaTypography.title1())
                                .foregroundColor(guest.guestGroup.color)
                        }

                        VStack(spacing: 4) {
                            HStack {
                                Text(guest.fullName)
                                    .font(NuviaTypography.title2())
                                    .foregroundColor(.nuviaPrimaryText)

                                if guest.isVIP {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.nuviaGoldFallback)
                                }
                            }

                            HStack(spacing: 8) {
                                NuviaTag(guest.guestGroup.displayName, color: guest.guestGroup.color)
                                NuviaTag(guest.rsvp.displayName, color: guest.rsvp.color)
                            }
                        }
                    }
                    .padding(.top, 24)

                    Divider()

                    // Contact info
                    if guest.phone != nil || guest.email != nil {
                        NuviaCard {
                            VStack(spacing: 12) {
                                if let phone = guest.phone {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.nuviaGoldFallback)
                                        Text(phone)
                                            .font(NuviaTypography.body())
                                            .foregroundColor(.nuviaPrimaryText)
                                        Spacer()
                                    }
                                }

                                if let email = guest.email {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(.nuviaGoldFallback)
                                        Text(email)
                                            .font(NuviaTypography.body())
                                            .foregroundColor(.nuviaPrimaryText)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }

                    // Plus ones
                    if guest.plusOneCount > 0 {
                        NuviaCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Eşlik Edenler")
                                    .font(NuviaTypography.bodyBold())
                                    .foregroundColor(.nuviaPrimaryText)

                                Text("\(guest.plusOneCount) kişi")
                                    .font(NuviaTypography.body())
                                    .foregroundColor(.nuviaSecondaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    // Notes
                    if let notes = guest.notes {
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

                    // RSVP Actions
                    NuviaCard {
                        VStack(spacing: 16) {
                            Text("RSVP Durumu")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)

                            HStack(spacing: 12) {
                                ForEach([RSVPStatus.attending, .notAttending, .maybe], id: \.self) { status in
                                    Button {
                                        // Update RSVP
                                    } label: {
                                        VStack(spacing: 4) {
                                            Image(systemName: status.icon)
                                                .font(.system(size: 24))
                                            Text(status.displayName)
                                                .font(NuviaTypography.caption())
                                        }
                                        .foregroundColor(guest.rsvp == status ? .white : status.color)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(guest.rsvp == status ? status.color : status.color.opacity(0.15))
                                        .cornerRadius(12)
                                    }
                                }
                            }
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

// MARK: - RSVP Dashboard View

struct RSVPDashboardView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    NuviaCard {
                        VStack(spacing: 16) {
                            Image(systemName: "envelope.badge.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.nuviaGoldFallback)

                            Text("RSVP Yönetimi")
                                .font(NuviaTypography.title2())
                                .foregroundColor(.nuviaPrimaryText)

                            Text("Otomatik hatırlatma mesajları, RSVP kapanış tarihi ayarlama ve toplu mesaj gönderme özellikleri yakında eklenecek.")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.nuviaBackground)
            .navigationTitle("RSVP")
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
    GuestListView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
