import SwiftUI
import SwiftData
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Music Voting System

struct MusicVotingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var songs: [SongRequest] = []
    @State private var showAddSong = false
    @State private var newSongTitle = ""
    @State private var newSongArtist = ""
    @State private var selectedGenre: MusicGenre = .pop

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        StatBadge(icon: "music.note.list", value: "\(songs.count)", label: "Şarkı")
                        StatBadge(icon: "heart.fill", value: "\(songs.reduce(0) { $0 + $1.votes })", label: "Toplam Oy", color: .nuviaError)
                    }
                }
                .padding(12)
                .background(Color.nuviaCardBackground)

                // Add song bar
                HStack {
                    VStack(spacing: 4) {
                        TextField("Şarkı adı...", text: $newSongTitle)
                            .font(NuviaTypography.body())
                        TextField("Sanatçı...", text: $newSongArtist)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }

                    Button {
                        addSong()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.nuviaGoldFallback)
                    }
                    .disabled(newSongTitle.isEmpty)
                }
                .padding(12)
                .background(Color.nuviaTertiaryBackground)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                // Genre filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "Tümü", isSelected: selectedGenre == .pop) {
                            // Show all
                        }
                        ForEach(MusicGenre.allCases, id: \.self) { genre in
                            FilterChip(title: genre.displayName, isSelected: false, color: genre.color) {}
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Song list
                if songs.isEmpty {
                    Spacer()
                    NuviaEmptyState(
                        icon: "music.note",
                        title: "Henüz şarkı eklenmedi",
                        message: "Düğün müzik listesini misafirlerinizle birlikte oluşturun!"
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(songs.sorted(by: { $0.votes > $1.votes })) { song in
                            SongRequestRow(song: song) {
                                if let idx = songs.firstIndex(where: { $0.id == song.id }) {
                                    songs[idx].votes += 1
                                    HapticManager.shared.selection()
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Müzik Oylama")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Share voting link
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.nuviaGoldFallback)
                    }
                }
            }
        }
    }

    private func addSong() {
        let song = SongRequest(title: newSongTitle, artist: newSongArtist.isEmpty ? nil : newSongArtist, genre: selectedGenre)
        songs.append(song)
        newSongTitle = ""
        newSongArtist = ""
        HapticManager.shared.taskCompleted()
    }
}

struct SongRequest: Identifiable {
    let id = UUID()
    var title: String
    var artist: String?
    var genre: MusicGenre
    var votes: Int = 0
    var requestedBy: String?
}

enum MusicGenre: String, CaseIterable {
    case pop, rock, hiphop, turkish, romantic, dance, classic

    var displayName: String {
        switch self {
        case .pop: return "Pop"
        case .rock: return "Rock"
        case .hiphop: return "Hip-Hop"
        case .turkish: return "Türkçe"
        case .romantic: return "Romantik"
        case .dance: return "Dans"
        case .classic: return "Klasik"
        }
    }

    var color: Color {
        switch self {
        case .pop: return .categoryDress
        case .rock: return .nuviaError
        case .hiphop: return .categoryMusic
        case .turkish: return .nuviaGoldFallback
        case .romantic: return .categoryFlowers
        case .dance: return .nuviaInfo
        case .classic: return .nuviaSecondaryText
        }
    }
}

struct SongRequestRow: View {
    let song: SongRequest
    let onVote: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)
                if let artist = song.artist {
                    Text(artist)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }

            Spacer()

            NuviaTag(song.genre.displayName, color: song.genre.color, size: .small)

            Button(action: onVote) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                    Text("\(song.votes)")
                        .font(NuviaTypography.bodyBold())
                }
                .foregroundColor(.nuviaError)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.nuviaError.opacity(0.1))
                .cornerRadius(16)
            }
        }
    }
}

// MARK: - Live Photo Stream View

struct LivePhotoStreamView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var photos: [StreamPhoto] = []
    @State private var showCamera = false
    @State private var showQRCode = false
    @State private var selectedLayout: PhotoStreamLayout = .grid

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.nuviaSuccess)
                                .frame(width: 8, height: 8)
                            Text("Canlı Fotoğraf Akışı")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)
                        }
                        Text("\(photos.count) fotoğraf paylaşıldı")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }

                    Spacer()

                    Picker("", selection: $selectedLayout) {
                        Image(systemName: "square.grid.2x2").tag(PhotoStreamLayout.grid)
                        Image(systemName: "list.bullet").tag(PhotoStreamLayout.list)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                }
                .padding(16)
                .background(Color.nuviaCardBackground)

                if photos.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 64))
                            .foregroundColor(.nuviaGoldFallback)

                        Text("Anları Paylaşın!")
                            .font(NuviaTypography.title2())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("Düğün gününde misafirlerinizin çektiği fotoğraflar burada canlı olarak görünecek.")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        NuviaPrimaryButton("QR Kod Oluştur", icon: "qrcode") {
                            showQRCode = true
                        }
                        .frame(width: 200)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        switch selectedLayout {
                        case .grid:
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                                ForEach(photos) { photo in
                                    photoThumbnail(photo)
                                }
                            }
                        case .list:
                            LazyVStack(spacing: 16) {
                                ForEach(photos) { photo in
                                    photoListItem(photo)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Fotoğraf Akışı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            // Download all
                        } label: {
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(.nuviaSecondaryText)
                        }
                        Button {
                            showCamera = true
                        } label: {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showQRCode) {
                QRCodeView(content: "nuvia://photo-stream/\(UUID().uuidString.prefix(8))")
            }
        }
    }

    private func photoThumbnail(_ photo: StreamPhoto) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.nuviaTertiaryBackground)
                .aspectRatio(1, contentMode: .fill)

            Image(systemName: "photo")
                .font(.system(size: 24))
                .foregroundColor(.nuviaSecondaryText)

            VStack {
                Spacer()
                HStack {
                    Text(photo.uploadedBy)
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                    Spacer()
                    if photo.likes > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 8))
                            Text("\(photo.likes)")
                                .font(.system(size: 8))
                        }
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.nuviaError.opacity(0.7))
                        .cornerRadius(4)
                    }
                }
                .padding(4)
            }
        }
        .cornerRadius(4)
    }

    private func photoListItem(_ photo: StreamPhoto) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Rectangle()
                    .fill(Color.nuviaTertiaryBackground)
                    .aspectRatio(4/3, contentMode: .fill)
                    .cornerRadius(12)

                Image(systemName: "photo.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.nuviaSecondaryText)
            }

            HStack {
                Text(photo.uploadedBy)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaPrimaryText)

                Text(photo.uploadedAt.formatted(date: .omitted, time: .shortened))
                    .font(NuviaTypography.caption2())
                    .foregroundColor(.nuviaSecondaryText)

                Spacer()

                Button {
                    // Like
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                        Text("\(photo.likes)")
                    }
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaError)
                }
            }
        }
    }
}

struct StreamPhoto: Identifiable {
    let id = UUID()
    var uploadedBy: String
    var uploadedAt: Date = Date()
    var likes: Int = 0
    var caption: String?
}

enum PhotoStreamLayout { case grid, list }

// MARK: - Check-in System View

struct CheckInSystemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var searchText = ""
    @State private var showQRScanner = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    private var attendingGuests: [Guest] {
        currentProject?.guests.filter { $0.rsvp == .attending }.sorted { $0.lastName < $1.lastName } ?? []
    }

    private var checkedInCount: Int {
        attendingGuests.filter { $0.tags.contains("checked_in") }.count
    }

    private var filteredGuests: [Guest] {
        if searchText.isEmpty { return attendingGuests }
        return attendingGuests.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary
                HStack(spacing: 20) {
                    StatBadge(icon: "person.crop.circle.badge.checkmark", value: "\(checkedInCount)", label: "Giriş Yapan", color: .nuviaSuccess)
                    StatBadge(icon: "person.crop.circle.badge.clock", value: "\(attendingGuests.count - checkedInCount)", label: "Beklenen")
                    StatBadge(icon: "person.2.fill", value: "\(attendingGuests.count)", label: "Toplam")
                }
                .padding(12)
                .background(Color.nuviaCardBackground)

                // Progress
                GeometryReader { geo in
                    let progress = attendingGuests.isEmpty ? 0.0 : Double(checkedInCount) / Double(attendingGuests.count)
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.nuviaTertiaryBackground).frame(height: 4)
                        Rectangle().fill(Color.nuviaSuccess).frame(width: geo.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)

                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.nuviaSecondaryText)
                    TextField("Misafir ara...", text: $searchText)
                        .font(NuviaTypography.body())
                }
                .padding(10)
                .background(Color.nuviaTertiaryBackground)
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                // Guest list
                List {
                    ForEach(filteredGuests, id: \.id) { guest in
                        CheckInGuestRow(guest: guest) {
                            toggleCheckIn(guest)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showQRScanner = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .foregroundColor(.nuviaGoldFallback)
                    }
                }
            }
        }
    }

    private func toggleCheckIn(_ guest: Guest) {
        if guest.tags.contains("checked_in") {
            guest.removeTag("checked_in")
        } else {
            guest.addTag("checked_in")
            HapticManager.shared.taskCompleted()
        }
        try? modelContext.save()
    }
}

struct CheckInGuestRow: View {
    let guest: Guest
    let onCheckIn: () -> Void

    private var isCheckedIn: Bool {
        guest.tags.contains("checked_in")
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onCheckIn) {
                Image(systemName: isCheckedIn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundColor(isCheckedIn ? .nuviaSuccess : .nuviaSecondaryText)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(guest.fullName)
                        .font(NuviaTypography.body())
                        .foregroundColor(isCheckedIn ? .nuviaSecondaryText : .nuviaPrimaryText)
                        .strikethrough(isCheckedIn)
                    if guest.isVIP {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.nuviaGoldFallback)
                    }
                }
                if guest.plusOneCount > 0 {
                    Text("+\(guest.plusOneCount) kişi")
                        .font(NuviaTypography.caption2())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }

            Spacer()

            if let table = guest.seatAssignment?.table {
                NuviaTag(table.name, color: .nuviaInfo, size: .small)
            }
        }
    }
}

// MARK: - Post-Wedding Features View

struct PostWeddingView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var selectedTab: PostWeddingTab = .thankYou

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    ForEach(PostWeddingTab.allCases, id: \.self) { tab in
                        Text(tab.displayName).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                switch selectedTab {
                case .thankYou:
                    ThankYouListView()
                case .documents:
                    DocumentGuideView()
                case .memories:
                    MemoriesView()
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Düğün Sonrası")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
            }
        }
    }
}

enum PostWeddingTab: String, CaseIterable {
    case thankYou, documents, memories

    var displayName: String {
        switch self {
        case .thankYou: return "Teşekkür"
        case .documents: return "Evraklar"
        case .memories: return "Anılar"
        }
    }
}

// MARK: - Thank You List

struct ThankYouListView: View {
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    private var attendedGuests: [Guest] {
        currentProject?.guests.filter { $0.rsvp == .attending }.sorted { $0.lastName < $1.lastName } ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                NuviaCard {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.nuviaGoldFallback)

                        Text("Teşekkür Listesi")
                            .font(NuviaTypography.title3())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("Düğüne katılan misafirlerinize teşekkür mesajı göndermeyi unutmayın!")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                            .multilineTextAlignment(.center)

                        let sent = attendedGuests.filter { $0.tags.contains("thank_you_sent") }.count
                        Text("\(sent)/\(attendedGuests.count) mesaj gönderildi")
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaGoldFallback)
                    }
                }

                ForEach(attendedGuests, id: \.id) { guest in
                    ThankYouRow(guest: guest)
                }
            }
            .padding(16)
            .padding(.bottom, 80)
        }
    }
}

struct ThankYouRow: View {
    let guest: Guest

    private var isSent: Bool {
        guest.tags.contains("thank_you_sent")
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(guest.guestGroup.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                Text(guest.initials)
                    .font(NuviaTypography.caption())
                    .foregroundColor(guest.guestGroup.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(guest.fullName)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)
                Text(guest.guestGroup.displayName)
                    .font(NuviaTypography.caption2())
                    .foregroundColor(.nuviaSecondaryText)
            }

            Spacer()

            if isSent {
                NuviaTag("Gönderildi", color: .nuviaSuccess, size: .small)
            } else {
                Button {
                    guest.addTag("thank_you_sent")
                    HapticManager.shared.taskCompleted()
                } label: {
                    Text("Gönder")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaGoldFallback)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.nuviaGoldFallback.opacity(0.15))
                        .cornerRadius(12)
                }
            }
        }
        .padding(12)
        .background(Color.nuviaCardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Document Guide View

struct DocumentGuideView: View {
    let documents: [PostWeddingDocument] = [
        PostWeddingDocument(title: "Aile Cüzdanı Başvurusu", description: "Nikahtan sonra 30 gün içinde nüfus müdürlüğüne başvurun", icon: "doc.text.fill", deadline: "30 gün"),
        PostWeddingDocument(title: "Soyadı Değişikliği", description: "Kimlik, ehliyet, pasaport, banka hesapları için başvurular", icon: "person.text.rectangle", deadline: "60 gün"),
        PostWeddingDocument(title: "Adres Değişikliği", description: "Yeni adresiniz için nüfus müdürlüğü bildirimi", icon: "house.fill", deadline: "20 gün"),
        PostWeddingDocument(title: "Sağlık Sigortası", description: "Eşinizi sağlık sigortanıza ekleyin", icon: "cross.case.fill", deadline: "30 gün"),
        PostWeddingDocument(title: "Vergi Beyanı Güncelleme", description: "Medeni durum değişikliği bildirimi", icon: "building.columns.fill", deadline: "Yıl sonu"),
        PostWeddingDocument(title: "Banka Hesap Güncellemeleri", description: "Ortak hesap veya isim değişikliği", icon: "creditcard.fill", deadline: "Opsiyonel"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                NuviaCard {
                    VStack(spacing: 8) {
                        Image(systemName: "checklist.checked")
                            .font(.system(size: 40))
                            .foregroundColor(.nuviaInfo)
                        Text("Evrak Rehberi")
                            .font(NuviaTypography.title3())
                            .foregroundColor(.nuviaPrimaryText)
                        Text("Düğün sonrası yapmanız gereken resmi işlemler")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }

                ForEach(documents) { doc in
                    PostWeddingDocumentRow(document: doc)
                }
            }
            .padding(16)
            .padding(.bottom, 80)
        }
    }
}

struct PostWeddingDocument: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let deadline: String
}

struct PostWeddingDocumentRow: View {
    let document: PostWeddingDocument
    @State private var isCompleted = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                isCompleted.toggle()
                HapticManager.shared.taskCompleted()
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isCompleted ? .nuviaSuccess : .nuviaSecondaryText)
            }

            Image(systemName: document.icon)
                .font(.system(size: 20))
                .foregroundColor(.nuviaInfo)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(NuviaTypography.body())
                    .foregroundColor(isCompleted ? .nuviaSecondaryText : .nuviaPrimaryText)
                    .strikethrough(isCompleted)
                Text(document.description)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
                    .lineLimit(2)
            }

            Spacer()

            NuviaTag(document.deadline, color: .nuviaWarning, size: .small)
        }
        .padding(12)
        .background(Color.nuviaCardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Memories View

struct MemoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: MemoryTab = .timeline
    @State private var showAddMemory = false
    @State private var newMemoryText = ""
    @State private var isGeneratingPDF = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    enum MemoryTab: String, CaseIterable {
        case timeline = "Zaman Çizelgesi"
        case messages = "Mesajlar"
        case book = "Düğün Kitabı"
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                ForEach(MemoryTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            switch selectedTab {
            case .timeline:
                timelineView
            case .messages:
                messagesView
            case .book:
                weddingBookView
            }
        }
    }

    private var timelineView: some View {
        ScrollView {
            if let project = currentProject {
                let entries = project.journalEntries.sorted { $0.date > $1.date }
                if entries.isEmpty {
                    NuviaEmptyState(
                        icon: "book.closed",
                        title: "Henüz anı yok",
                        message: "Günlük yazarak düğün sürecinizi kaydedin"
                    )
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(entries, id: \.id) { entry in
                            NuviaCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        if let mood = entry.entryMood {
                                            Text(mood.emoji)
                                                .font(.system(size: 20))
                                        }
                                        VStack(alignment: .leading, spacing: 2) {
                                            if let title = entry.title {
                                                Text(title)
                                                    .font(NuviaTypography.bodyBold())
                                                    .foregroundColor(.nuviaPrimaryText)
                                            }
                                            Text(entry.formattedDate)
                                                .font(NuviaTypography.caption())
                                                .foregroundColor(.nuviaSecondaryText)
                                        }
                                        Spacer()
                                    }

                                    Text(entry.content)
                                        .font(NuviaTypography.body())
                                        .foregroundColor(.nuviaPrimaryText)
                                        .lineLimit(4)

                                    if !entry.tags.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 6) {
                                                ForEach(entry.tags, id: \.self) { tag in
                                                    NuviaTag(tag, color: .nuviaGoldFallback, size: .small)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .cardEntrance(delay: 0.05)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private var messagesView: some View {
        ScrollView {
            if let project = currentProject {
                let guests = project.guests.filter { $0.notes != nil && !($0.notes?.isEmpty ?? true) }
                if guests.isEmpty {
                    NuviaEmptyState(
                        icon: "message",
                        title: "Henüz mesaj yok",
                        message: "Misafirlerinizin bıraktığı mesajlar burada görünecek"
                    )
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(guests) { guest in
                            NuviaGlassCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Circle()
                                            .fill(Color.nuviaGoldFallback.opacity(0.2))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Text(String(guest.firstName.prefix(1)))
                                                    .font(NuviaTypography.bodyBold())
                                                    .foregroundColor(.nuviaGoldFallback)
                                            )
                                        Text(guest.fullName)
                                            .font(NuviaTypography.bodyBold())
                                            .foregroundColor(.nuviaPrimaryText)
                                        Spacer()
                                    }
                                    if let notes = guest.notes {
                                        Text(notes)
                                            .font(NuviaTypography.body())
                                            .foregroundColor(.nuviaSecondaryText)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private var weddingBookView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Preview header
                NuviaHeroCard(accent: .nuviaGoldFallback) {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.nuviaGoldFallback)

                        if let project = currentProject {
                            Text("\(project.partnerName1) & \(project.partnerName2)")
                                .font(NuviaTypography.title2())
                                .foregroundColor(.nuviaPrimaryText)

                            Text(project.weddingDate.formatted(date: .long, time: .omitted))
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Text("Düğün Anı Defteri")
                            .font(NuviaTypography.callout())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }

                // Stats preview
                if let project = currentProject {
                    NuviaCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Kitap İçeriği")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)

                            HStack(spacing: 16) {
                                BookStatItem(icon: "pencil.line", count: project.journalEntries.count, label: "Günlük")
                                BookStatItem(icon: "person.2", count: project.guests.count, label: "Davetli")
                                BookStatItem(icon: "checkmark.circle", count: project.completedTasksCount, label: "Görev")
                                BookStatItem(icon: "chart.bar", count: project.expenses.count, label: "Harcama")
                            }
                        }
                    }
                }

                // Generate button
                NuviaPrimaryButton(
                    isGeneratingPDF ? "Oluşturuluyor..." : "Düğün Kitabı PDF Oluştur",
                    icon: "doc.richtext"
                ) {
                    guard let project = currentProject else { return }
                    isGeneratingPDF = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let data = ExportService.generateWeddingBookPDF(project: project) {
                            ExportService.shareFile(data: data, fileName: "dugun-kitabi.pdf")
                        }
                        isGeneratingPDF = false
                        HapticManager.shared.taskCompleted()
                    }
                }
                .disabled(isGeneratingPDF)
                .padding(.horizontal)
            }
            .padding(16)
        }
    }
}

struct BookStatItem: View {
    let icon: String
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.nuviaGoldFallback)
            Text("\(count)")
                .font(NuviaTypography.bodyBold())
                .foregroundColor(.nuviaPrimaryText)
            Text(label)
                .font(NuviaTypography.caption2())
                .foregroundColor(.nuviaSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - QR Code View

struct QRCodeView: View {
    @Environment(\.dismiss) private var dismiss
    let content: String
    @State private var qrImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                if let qrImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .nuviaShadow(.elevated)
                } else {
                    ProgressView()
                        .frame(width: 240, height: 240)
                }

                Text("Misafirleriniz bu QR kodu okutarak fotoğraf paylaşabilir")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                NuviaPrimaryButton("Paylaş", icon: "square.and.arrow.up") {
                    guard let qrImage else { return }
                    if let data = qrImage.pngData() {
                        ExportService.shareFile(data: data, fileName: "nuvia-qr.png")
                    }
                }
                .frame(width: 180)

                Spacer()
            }
            .background(Color.nuviaBackground)
            .navigationTitle("QR Kod")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
            }
            .onAppear {
                generateQR()
            }
        }
    }

    private func generateQR() {
        let data = content.data(using: .utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else { return }

        // Scale up from small CIImage
        let scale = 10.0
        let transformed = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let context = CIContext()
        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else { return }
        qrImage = UIImage(cgImage: cgImage)
    }
}

// MARK: - Zen Mode View

struct ZenModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var breathPhase: BreathPhase = .inhale
    @State private var circleScale: CGFloat = 0.6
    @State private var showQuote = false
    @State private var currentQuote = 0

    let quotes = [
        "Her şey mükemmel olmak zorunda değil. Önemli olan sevgiyle geçen her an.",
        "Bu gün sadece bir gün değil, hayatınızın en güzel başlangıcı.",
        "Stres geçici, aşk kalıcıdır.",
        "Derin bir nefes alın. Her şey yolunda gidecek.",
        "Bu anın tadını çıkarın. Her detay sevgiyle planlandı.",
        "Kendinize güvenin. Her şeyi düşündünüz.",
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.nuviaMidnight, Color.nuviaMidnight.opacity(0.8), Color.nuviaGoldFallback.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Breathing circle
                    ZStack {
                        Circle()
                            .fill(Color.nuviaGoldFallback.opacity(0.1))
                            .frame(width: 200, height: 200)
                            .scaleEffect(circleScale)

                        Circle()
                            .stroke(Color.nuviaGoldFallback.opacity(0.3), lineWidth: 2)
                            .frame(width: 200, height: 200)
                            .scaleEffect(circleScale)

                        VStack(spacing: 8) {
                            Text(breathPhase.instruction)
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaGoldFallback)

                            Text(breathPhase.emoji)
                                .font(.system(size: 32))
                        }
                    }
                    .onAppear { startBreathingAnimation() }

                    // Quote
                    Text(quotes[currentQuote])
                        .font(NuviaTypography.body())
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showQuote ? 1 : 0)
                        .onAppear {
                            withAnimation(.easeIn(duration: 2)) {
                                showQuote = true
                            }
                        }

                    // Quote navigation
                    HStack(spacing: 20) {
                        Button {
                            withAnimation {
                                currentQuote = (currentQuote - 1 + quotes.count) % quotes.count
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white.opacity(0.5))
                        }

                        Text("\(currentQuote + 1)/\(quotes.count)")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.white.opacity(0.3))

                        Button {
                            withAnimation {
                                currentQuote = (currentQuote + 1) % quotes.count
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
    }

    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            circleScale = 1.0
        }

        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            breathPhase = breathPhase == .inhale ? .exhale : .inhale
        }
    }
}

enum BreathPhase {
    case inhale, exhale

    var instruction: String {
        switch self {
        case .inhale: return "Nefes Al..."
        case .exhale: return "Nefes Ver..."
        }
    }

    var emoji: String {
        switch self {
        case .inhale: return "🌸"
        case .exhale: return "🍃"
        }
    }
}

#Preview {
    MusicVotingView()
}
