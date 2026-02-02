import SwiftUI
import SwiftData

// MARK: - Wedding Day Event Model

struct WeddingDayEvent: Codable, Identifiable, Hashable {
    var id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var location: String?
    var responsible: String?
    var notes: String?
    var category: WeddingDayCategory
    var isCompleted: Bool
    var vendorName: String?
    var contactPhone: String?

    init(title: String, startTime: Date, endTime: Date, category: WeddingDayCategory = .ceremony, location: String? = nil, responsible: String? = nil) {
        self.id = UUID()
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.responsible = responsible
        self.category = category
        self.isCompleted = false
    }

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var durationText: String {
        let minutes = Int(duration / 60)
        if minutes < 60 { return "\(minutes) dk" }
        let hours = minutes / 60
        let remaining = minutes % 60
        return remaining > 0 ? "\(hours) sa \(remaining) dk" : "\(hours) saat"
    }

    var isActive: Bool {
        let now = Date()
        return now >= startTime && now <= endTime
    }

    var isPast: Bool {
        Date() > endTime
    }
}

enum WeddingDayCategory: String, Codable, CaseIterable {
    case preparation = "hazirlik"
    case ceremony = "nikah"
    case photo = "foto"
    case reception = "karsilama"
    case dinner = "yemek"
    case entertainment = "eglence"
    case special = "ozel"
    case logistics = "lojistik"

    var displayName: String {
        switch self {
        case .preparation: return "Hazırlık"
        case .ceremony: return "Nikah"
        case .photo: return "Fotoğraf"
        case .reception: return "Karşılama"
        case .dinner: return "Yemek"
        case .entertainment: return "Eğlence"
        case .special: return "Özel An"
        case .logistics: return "Lojistik"
        }
    }

    var icon: String {
        switch self {
        case .preparation: return "sparkles"
        case .ceremony: return "heart.fill"
        case .photo: return "camera.fill"
        case .reception: return "person.2.fill"
        case .dinner: return "fork.knife"
        case .entertainment: return "music.note"
        case .special: return "star.fill"
        case .logistics: return "car.fill"
        }
    }

    var color: Color {
        switch self {
        case .preparation: return .categoryDress
        case .ceremony: return .nuviaGoldFallback
        case .photo: return .categoryPhoto
        case .reception: return .nuviaInfo
        case .dinner: return .categoryFood
        case .entertainment: return .categoryMusic
        case .special: return .nuviaWarning
        case .logistics: return .nuviaSecondaryText
        }
    }
}

// MARK: - Run of Show View

struct WeddingDayRunOfShowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var events: [WeddingDayEvent] = []
    @State private var showAddEvent = false
    @State private var selectedEvent: WeddingDayEvent?
    @State private var isLiveMode = false
    @State private var currentTime = Date()

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.nuviaBackground.ignoresSafeArea()

                if events.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        if isLiveMode {
                            liveModeBanner
                        }
                        summaryBar
                        eventTimeline
                    }
                }
            }
            .navigationTitle("Düğün Günü Akışı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation { isLiveMode.toggle() }
                            HapticManager.shared.buttonTap()
                        } label: {
                            Image(systemName: isLiveMode ? "livephoto" : "livephoto.slash")
                                .foregroundColor(isLiveMode ? .nuviaSuccess : .nuviaSecondaryText)
                        }

                        Button {
                            showAddEvent = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddEvent) {
                AddWeddingDayEventView(events: $events)
            }
            .sheet(item: $selectedEvent) { event in
                WeddingDayEventDetailView(event: event, events: $events)
            }
            .onReceive(timer) { _ in
                if isLiveMode { currentTime = Date() }
            }
            .onAppear { loadDefaultEventsIfNeeded() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 64))
                .foregroundColor(.nuviaGoldFallback)

            Text("Düğün Günü Programı")
                .font(NuviaTypography.title2())
                .foregroundColor(.nuviaPrimaryText)

            Text("Düğün gününüzün dakika dakika akışını planlayın. Canlı modda gün içinde etkinlikleri takip edin.")
                .font(NuviaTypography.body())
                .foregroundColor(.nuviaSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 12) {
                NuviaPrimaryButton("Şablon Kullan", icon: "doc.on.doc") {
                    loadTemplateEvents()
                    HapticManager.shared.taskCompleted()
                }

                NuviaSecondaryButton("Manuel Oluştur", icon: "plus.circle") {
                    showAddEvent = true
                }
            }
            .padding(.horizontal, 32)
        }
    }

    private var liveModeBanner: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.nuviaError)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.nuviaError, lineWidth: 2)
                        .scaleEffect(1.5)
                        .opacity(0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isLiveMode)
                )

            Text("CANLI MOD")
                .font(NuviaTypography.caption())
                .foregroundColor(.white)
                .fontWeight(.bold)

            Spacer()

            Text(currentTime.formatted(date: .omitted, time: .shortened))
                .font(NuviaTypography.bodyBold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.nuviaError.opacity(0.9))
    }

    private var summaryBar: some View {
        let completed = events.filter { $0.isCompleted }.count
        let active = events.first { $0.isActive }
        let next = events.sorted(by: { $0.startTime < $1.startTime }).first { !$0.isPast && !$0.isActive }

        return VStack(spacing: 8) {
            HStack(spacing: 20) {
                StatBadge(icon: "checkmark.circle", value: "\(completed)/\(events.count)", label: "Tamamlanan")
                if let active = active {
                    StatBadge(icon: "livephoto", value: active.title, label: "Şu An", color: .nuviaSuccess)
                }
                if let next = next {
                    StatBadge(icon: "forward.fill", value: next.startTime.formatted(date: .omitted, time: .shortened), label: next.title)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.nuviaCardBackground)
    }

    private var eventTimeline: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(events.sorted(by: { $0.startTime < $1.startTime })) { event in
                    RunOfShowEventRow(event: event, isLiveMode: isLiveMode) {
                        selectedEvent = event
                    } onToggle: {
                        if let idx = events.firstIndex(where: { $0.id == event.id }) {
                            events[idx].isCompleted.toggle()
                            HapticManager.shared.taskCompleted()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }

    private func loadDefaultEventsIfNeeded() {
        // Events are stored in-memory for now
    }

    private func loadTemplateEvents() {
        guard let project = currentProject else { return }
        let baseDate = project.weddingDate
        let cal = Calendar.current

        func time(_ hour: Int, _ minute: Int) -> Date {
            cal.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate) ?? baseDate
        }

        events = [
            WeddingDayEvent(title: "Gelin Hazırlık Başlangıcı", startTime: time(9, 0), endTime: time(10, 30), category: .preparation, location: "Otel/Ev", responsible: project.partnerName1),
            WeddingDayEvent(title: "Damat Hazırlık", startTime: time(10, 0), endTime: time(11, 0), category: .preparation, responsible: project.partnerName2),
            WeddingDayEvent(title: "Kuaför & Makyaj", startTime: time(10, 30), endTime: time(12, 30), category: .preparation, location: "Kuaför Salonu"),
            WeddingDayEvent(title: "First Look Fotoğraf Çekimi", startTime: time(13, 0), endTime: time(14, 0), category: .photo, location: project.venueName),
            WeddingDayEvent(title: "Nikah Töreni", startTime: time(15, 0), endTime: time(16, 0), category: .ceremony, location: project.venueName),
            WeddingDayEvent(title: "Kokteyl & Karşılama", startTime: time(16, 0), endTime: time(17, 0), category: .reception, location: project.venueName),
            WeddingDayEvent(title: "İlk Dans", startTime: time(17, 0), endTime: time(17, 15), category: .special),
            WeddingDayEvent(title: "Yemek Servisi", startTime: time(17, 30), endTime: time(19, 0), category: .dinner),
            WeddingDayEvent(title: "Pasta Kesimi", startTime: time(19, 0), endTime: time(19, 15), category: .special),
            WeddingDayEvent(title: "Müzik & Dans", startTime: time(19, 30), endTime: time(23, 0), category: .entertainment),
            WeddingDayEvent(title: "Gelin Buketi Atma", startTime: time(22, 0), endTime: time(22, 15), category: .special),
            WeddingDayEvent(title: "Uğurlama", startTime: time(23, 0), endTime: time(23, 30), category: .logistics),
        ]
    }
}

// MARK: - Run of Show Event Row

struct RunOfShowEventRow: View {
    let event: WeddingDayEvent
    let isLiveMode: Bool
    let onTap: () -> Void
    let onToggle: () -> Void

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Time column
                VStack(spacing: 2) {
                    Text(timeFormatter.string(from: event.startTime))
                        .font(NuviaTypography.bodyBold())
                        .foregroundColor(event.isActive && isLiveMode ? .nuviaSuccess : .nuviaPrimaryText)

                    Text(event.durationText)
                        .font(NuviaTypography.caption2())
                        .foregroundColor(.nuviaSecondaryText)
                }
                .frame(width: 56)

                // Timeline indicator
                VStack(spacing: 0) {
                    Circle()
                        .fill(event.isCompleted ? Color.nuviaSuccess : (event.isActive && isLiveMode ? Color.nuviaSuccess : event.category.color))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Group {
                                if event.isActive && isLiveMode {
                                    Circle()
                                        .stroke(Color.nuviaSuccess, lineWidth: 2)
                                        .frame(width: 20, height: 20)
                                }
                            }
                        )

                    Rectangle()
                        .fill(Color.nuviaTertiaryText.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
                .frame(width: 20)

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(event.title)
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(event.isCompleted ? .nuviaSecondaryText : .nuviaPrimaryText)
                            .strikethrough(event.isCompleted)

                        Spacer()

                        Button(action: onToggle) {
                            Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(event.isCompleted ? .nuviaSuccess : .nuviaSecondaryText)
                        }
                    }

                    HStack(spacing: 8) {
                        NuviaTag(event.category.displayName, color: event.category.color, size: .small)

                        if let location = event.location {
                            HStack(spacing: 2) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 10))
                                Text(location)
                                    .font(NuviaTypography.caption2())
                            }
                            .foregroundColor(.nuviaSecondaryText)
                        }

                        if let responsible = event.responsible {
                            HStack(spacing: 2) {
                                Image(systemName: "person")
                                    .font(.system(size: 10))
                                Text(responsible)
                                    .font(NuviaTypography.caption2())
                            }
                            .foregroundColor(.nuviaSecondaryText)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.trailing, 8)
            }
        }
        .background(
            event.isActive && isLiveMode
                ? Color.nuviaSuccess.opacity(0.05)
                : Color.clear
        )
    }
}

// MARK: - Add Wedding Day Event View

struct AddWeddingDayEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var events: [WeddingDayEvent]

    @State private var title = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var category: WeddingDayCategory = .ceremony
    @State private var location = ""
    @State private var responsible = ""
    @State private var notes = ""
    @State private var vendorName = ""
    @State private var contactPhone = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Etkinlik Bilgileri") {
                    TextField("Etkinlik Adı", text: $title)

                    Picker("Kategori", selection: $category) {
                        ForEach(WeddingDayCategory.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section("Zaman") {
                    DatePicker("Başlangıç", selection: $startTime, displayedComponents: [.hourAndMinute])
                    DatePicker("Bitiş", selection: $endTime, displayedComponents: [.hourAndMinute])
                }

                Section("Detaylar") {
                    TextField("Konum (opsiyonel)", text: $location)
                    TextField("Sorumlu Kişi (opsiyonel)", text: $responsible)
                    TextField("Tedarikçi (opsiyonel)", text: $vendorName)
                    TextField("İletişim Telefon (opsiyonel)", text: $contactPhone)
                        .keyboardType(.phonePad)
                }

                Section("Notlar") {
                    TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Yeni Etkinlik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ekle") {
                        var event = WeddingDayEvent(
                            title: title,
                            startTime: startTime,
                            endTime: endTime,
                            category: category,
                            location: location.isEmpty ? nil : location,
                            responsible: responsible.isEmpty ? nil : responsible
                        )
                        event.notes = notes.isEmpty ? nil : notes
                        event.vendorName = vendorName.isEmpty ? nil : vendorName
                        event.contactPhone = contactPhone.isEmpty ? nil : contactPhone
                        events.append(event)
                        HapticManager.shared.taskCompleted()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Wedding Day Event Detail View

struct WeddingDayEventDetailView: View {
    let event: WeddingDayEvent
    @Binding var events: [WeddingDayEvent]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: event.category.icon)
                            .font(.system(size: 48))
                            .foregroundColor(event.category.color)

                        Text(event.title)
                            .font(NuviaTypography.title2())
                            .foregroundColor(.nuviaPrimaryText)

                        HStack(spacing: 8) {
                            NuviaTag(event.category.displayName, color: event.category.color)
                            if event.isCompleted {
                                NuviaTag("Tamamlandı", color: .nuviaSuccess)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // Time info
                    NuviaCard {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.nuviaGoldFallback)
                                Text("\(event.startTime.formatted(date: .omitted, time: .shortened)) - \(event.endTime.formatted(date: .omitted, time: .shortened))")
                                    .font(NuviaTypography.body())
                                Spacer()
                                Text(event.durationText)
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaSecondaryText)
                            }

                            if let location = event.location {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.nuviaGoldFallback)
                                    Text(location)
                                        .font(NuviaTypography.body())
                                    Spacer()
                                }
                            }

                            if let responsible = event.responsible {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.nuviaGoldFallback)
                                    Text(responsible)
                                        .font(NuviaTypography.body())
                                    Spacer()
                                }
                            }

                            if let vendor = event.vendorName {
                                HStack {
                                    Image(systemName: "building.2.fill")
                                        .foregroundColor(.nuviaGoldFallback)
                                    Text(vendor)
                                        .font(NuviaTypography.body())
                                    Spacer()
                                    if let phone = event.contactPhone {
                                        Link(destination: URL(string: "tel:\(phone)")!) {
                                            Image(systemName: "phone.fill")
                                                .foregroundColor(.nuviaSuccess)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if let notes = event.notes {
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
                    HStack(spacing: 12) {
                        NuviaPrimaryButton(event.isCompleted ? "Geri Al" : "Tamamla", icon: event.isCompleted ? "arrow.uturn.backward" : "checkmark") {
                            if let idx = events.firstIndex(where: { $0.id == event.id }) {
                                events[idx].isCompleted.toggle()
                                HapticManager.shared.taskCompleted()
                            }
                            dismiss()
                        }

                        NuviaSecondaryButton("Sil", icon: "trash") {
                            events.removeAll { $0.id == event.id }
                            HapticManager.shared.warning()
                            dismiss()
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
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
            }
        }
    }
}

#Preview {
    WeddingDayRunOfShowView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
