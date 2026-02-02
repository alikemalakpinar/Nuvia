import SwiftUI
import SwiftData

/// Ayarlar ekranı
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @Query private var projects: [WeddingProject]

    @State private var showSubscription = false
    @State private var showPrivacy = false
    @State private var showBackup = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            List {
                // Project Settings
                if let project = currentProject {
                    Section("Proje Ayarları") {
                        NavigationLink {
                            ProjectSettingsView(project: project)
                        } label: {
                            SettingsRow(icon: "calendar", title: "Düğün Bilgileri", color: .nuviaGoldFallback)
                        }

                        NavigationLink {
                            UsersSettingsView(project: project)
                        } label: {
                            SettingsRow(icon: "person.2.fill", title: "Kullanıcılar & Roller", color: .nuviaInfo)
                        }

                        NavigationLink {
                            NotificationSettingsView()
                        } label: {
                            SettingsRow(icon: "bell.fill", title: "Bildirimler", color: .nuviaWarning)
                        }
                    }
                }

                // App Settings
                Section("Uygulama") {
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        SettingsRow(icon: "paintbrush.fill", title: "Görünüm", color: .categoryVenue)
                    }

                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        SettingsRow(icon: "globe", title: "Dil", color: .nuviaSuccess)
                    }
                }

                // Subscription
                Section("Üyelik") {
                    Button {
                        showSubscription = true
                    } label: {
                        HStack {
                            SettingsRow(icon: "crown.fill", title: "Premium", color: .nuviaGoldFallback)

                            Spacer()

                            if appState.isPremium {
                                Text("Aktif")
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaSuccess)
                            } else {
                                Text("Yükselt")
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaGoldFallback)
                            }
                        }
                    }
                }

                // Data & Privacy
                Section("Veri & Gizlilik") {
                    Button {
                        showBackup = true
                    } label: {
                        SettingsRow(icon: "icloud.fill", title: "Yedekleme", color: .nuviaInfo)
                    }

                    Button {
                        showPrivacy = true
                    } label: {
                        SettingsRow(icon: "hand.raised.fill", title: "Gizlilik", color: .nuviaError)
                    }

                    NavigationLink {
                        ExportDataView()
                    } label: {
                        SettingsRow(icon: "square.and.arrow.up", title: "Veri Dışa Aktar", color: .nuviaSecondaryText)
                    }
                }

                // About
                Section("Hakkında") {
                    HStack {
                        Text("Versiyon")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaPrimaryText)
                        Spacer()
                        Text("1.0.0")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                    }

                    Link(destination: URL(string: "https://nuvia.app/help")!) {
                        SettingsRow(icon: "questionmark.circle", title: "Yardım", color: .nuviaSecondaryText)
                    }

                    Link(destination: URL(string: "https://nuvia.app/privacy")!) {
                        SettingsRow(icon: "doc.text", title: "Gizlilik Politikası", color: .nuviaSecondaryText)
                    }
                }

                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        appState.hasCompletedOnboarding = false
                        appState.currentProjectId = nil
                        HapticManager.shared.warning()
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Çıkış Yap")
                                .font(NuviaTypography.body())
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.nuviaGoldFallback)
                }
            }
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacySettingsView()
            }
            .sheet(isPresented: $showBackup) {
                BackupSettingsView()
            }
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15))
                .cornerRadius(6)

            Text(title)
                .font(NuviaTypography.body())
                .foregroundColor(.nuviaPrimaryText)
        }
    }
}

// MARK: - Project Settings View

struct ProjectSettingsView: View {
    let project: WeddingProject
    @State private var partnerName1: String
    @State private var partnerName2: String
    @State private var weddingDate: Date
    @State private var venueName: String
    @State private var venueCity: String
    @State private var allowChildren: Bool
    @State private var currency: Currency

    init(project: WeddingProject) {
        self.project = project
        _partnerName1 = State(initialValue: project.partnerName1)
        _partnerName2 = State(initialValue: project.partnerName2)
        _weddingDate = State(initialValue: project.weddingDate)
        _venueName = State(initialValue: project.venueName ?? "")
        _venueCity = State(initialValue: project.venueCity ?? "")
        _allowChildren = State(initialValue: project.allowChildren)
        _currency = State(initialValue: Currency(rawValue: project.currency) ?? .TRY)
    }

    var body: some View {
        Form {
            Section("Çift Bilgileri") {
                TextField("1. Kişi Adı", text: $partnerName1)
                TextField("2. Kişi Adı", text: $partnerName2)
            }

            Section("Düğün") {
                DatePicker("Tarih", selection: $weddingDate, displayedComponents: .date)
                TextField("Mekan Adı", text: $venueName)
                TextField("Şehir", text: $venueCity)
            }

            Section("Tercihler") {
                Toggle("Çocuk Davetli", isOn: $allowChildren)

                Picker("Para Birimi", selection: $currency) {
                    ForEach(Currency.allCases, id: \.self) { curr in
                        Text(curr.displayName).tag(curr)
                    }
                }
            }
        }
        .navigationTitle("Düğün Bilgileri")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Users Settings View

struct UsersSettingsView: View {
    let project: WeddingProject

    var body: some View {
        List {
            Section("Aktif Kullanıcılar") {
                ForEach(project.users, id: \.id) { user in
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.nuviaGoldFallback.opacity(0.2))
                                .frame(width: 40, height: 40)

                            Text(user.initials)
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaGoldFallback)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaPrimaryText)

                            Text(user.userRole.displayName)
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Spacer()

                        if user.userRole == .owner {
                            NuviaTag("Yönetici", color: .nuviaGoldFallback, size: .small)
                        }
                    }
                }
            }

            Section {
                Button {
                    // Invite user
                } label: {
                    HStack {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.nuviaGoldFallback)
                        Text("Kullanıcı Davet Et")
                            .foregroundColor(.nuviaGoldFallback)
                    }
                }
            }
        }
        .navigationTitle("Kullanıcılar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section("Bildirim Yoğunluğu") {
                Picker("Yoğunluk", selection: $appState.notificationIntensity) {
                    ForEach(NotificationIntensity.allCases, id: \.self) { intensity in
                        Text(intensity.displayName).tag(intensity)
                    }
                }
                .pickerStyle(.segmented)

                Text(intensityDescription)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }

            Section("Bildirim Türleri") {
                Toggle("Görev Hatırlatmaları", isOn: .constant(true))
                Toggle("Ödeme Hatırlatmaları", isOn: .constant(true))
                Toggle("RSVP Bildirimleri", isOn: .constant(true))
                Toggle("Teslimat Bildirimleri", isOn: .constant(true))
                Toggle("Garanti Uyarıları", isOn: .constant(true))
            }
        }
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var intensityDescription: String {
        switch appState.notificationIntensity {
        case .calm: return "Sadece kritik bildirimler gönderilir"
        case .normal: return "Önemli hatırlatmalar ve güncellemeler"
        case .intense: return "Tüm aktiviteler için bildirim"
        }
    }
}

// MARK: - Appearance Settings View

struct AppearanceSettingsView: View {
    @AppStorage("colorScheme") private var colorScheme = "system"

    var body: some View {
        Form {
            Section("Tema") {
                Picker("Görünüm", selection: $colorScheme) {
                    Text("Sistem").tag("system")
                    Text("Açık").tag("light")
                    Text("Koyu").tag("dark")
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Görünüm")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Language Settings View

struct LanguageSettingsView: View {
    @AppStorage("language") private var language = "tr"

    var body: some View {
        Form {
            Section("Dil Seçimi") {
                Picker("Dil", selection: $language) {
                    Text("Türkçe").tag("tr")
                    Text("English").tag("en")
                }
            }
        }
        .navigationTitle("Dil")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subscription View

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.nuviaGoldFallback)

                        Text("Nuvia Premium")
                            .font(NuviaTypography.title1())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("Tüm özelliklere erişin")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                    .padding(.top, 32)

                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        PremiumFeatureRow(icon: "person.2.fill", text: "Partner Senkronizasyonu")
                        PremiumFeatureRow(icon: "envelope.fill", text: "Sınırsız Davetiye Şablonu")
                        PremiumFeatureRow(icon: "rectangle.split.3x3", text: "Oturma Planı + PDF")
                        PremiumFeatureRow(icon: "book.fill", text: "Düğün Kitabı Oluşturma")
                        PremiumFeatureRow(icon: "chart.bar.fill", text: "Gelişmiş Raporlar")
                        PremiumFeatureRow(icon: "faceid", text: "FaceID Dosya Kasası")
                        PremiumFeatureRow(icon: "clock.fill", text: "Düğün Günü Run of Show")
                    }
                    .padding(.horizontal, 32)

                    // Pricing
                    VStack(spacing: 12) {
                        SubscriptionOption(
                            title: "Aylık",
                            price: "₺149.99/ay",
                            isPopular: false
                        )

                        SubscriptionOption(
                            title: "Yıllık",
                            price: "₺999.99/yıl",
                            subtitle: "₺83.33/ay - %44 tasarruf",
                            isPopular: true
                        )

                        SubscriptionOption(
                            title: "Düğün Paketi",
                            price: "₺599.99",
                            subtitle: "6 aylık erişim",
                            isPopular: false
                        )
                    }
                    .padding(.horizontal, 16)

                    // CTA
                    NuviaPrimaryButton("Premium'a Geç", icon: "crown.fill") {
                        appState.isPremium = true
                        dismiss()
                    }
                    .padding(.horizontal, 16)

                    // Terms
                    Text("Satın alma işlemi Apple ID hesabınıza faturalandırılır. Abonelik, mevcut dönemin bitiminden en az 24 saat önce iptal edilmezse otomatik olarak yenilenir.")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaTertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer()
                }
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

struct PremiumFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.nuviaSuccess)

            Image(systemName: icon)
                .foregroundColor(.nuviaGoldFallback)
                .frame(width: 24)

            Text(text)
                .font(NuviaTypography.body())
                .foregroundColor(.nuviaPrimaryText)
        }
    }
}

struct SubscriptionOption: View {
    let title: String
    let price: String
    var subtitle: String?
    let isPopular: Bool

    var body: some View {
        VStack(spacing: 8) {
            if isPopular {
                Text("EN POPÜLER")
                    .font(NuviaTypography.caption2())
                    .foregroundColor(.nuviaMidnight)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.nuviaGoldFallback)
                    .cornerRadius(10)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(NuviaTypography.bodyBold())
                        .foregroundColor(.nuviaPrimaryText)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }

                Spacer()

                Text(price)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaGoldFallback)
            }
            .padding(16)
            .background(Color.nuviaCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isPopular ? Color.nuviaGoldFallback : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Privacy Settings View

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("Veri Gizliliği") {
                    Text("Nuvia, verilerinizi korumayı öncelik olarak görür. Verileriniz cihazınızda şifrelenir ve iCloud senkronizasyonu tamamen isteğe bağlıdır.")
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                }

                Section("Misafir Linkleri") {
                    Toggle("Link şifreleme", isOn: .constant(true))
                    Toggle("Erişim süresi sınırı", isOn: .constant(true))
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Text("Tüm Verilerimi Sil")
                    }
                }
            }
            .navigationTitle("Gizlilik")
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

// MARK: - Backup Settings View

struct BackupSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var iCloudEnabled = true
    @State private var lastBackup = Date()

    var body: some View {
        NavigationStack {
            List {
                Section("iCloud Senkronizasyonu") {
                    Toggle("iCloud Yedekleme", isOn: $iCloudEnabled)

                    if iCloudEnabled {
                        HStack {
                            Text("Son Yedekleme")
                            Spacer()
                            Text(lastBackup.formatted(date: .abbreviated, time: .shortened))
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Button {
                            lastBackup = Date()
                        } label: {
                            Text("Şimdi Yedekle")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }

                Section("Yerel Yedekleme") {
                    Button {
                        // Export local backup
                    } label: {
                        Text("Yerel Yedek Al")
                            .foregroundColor(.nuviaGoldFallback)
                    }

                    Button {
                        // Import backup
                    } label: {
                        Text("Yedekten Geri Yükle")
                            .foregroundColor(.nuviaInfo)
                    }
                }
            }
            .navigationTitle("Yedekleme")
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

// MARK: - Export Data View

struct ExportDataView: View {
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState
    @State private var isExporting = false
    @State private var exportMessage: String?

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        List {
            Section("Dışa Aktarma Seçenekleri") {
                Button {
                    exportPDF()
                } label: {
                    SettingsRow(icon: "doc.fill", title: "PDF olarak dışa aktar", color: .nuviaError)
                }

                Button {
                    exportCSV()
                } label: {
                    SettingsRow(icon: "tablecells", title: "CSV olarak dışa aktar", color: .nuviaSuccess)
                }

                Button {
                    exportJSON()
                } label: {
                    SettingsRow(icon: "curlybraces", title: "JSON olarak dışa aktar", color: .nuviaInfo)
                }
            }

            if appState.isPremium {
                Section("Premium") {
                    Button {
                        // Generate wedding book
                        HapticManager.shared.taskCompleted()
                    } label: {
                        SettingsRow(icon: "book.fill", title: "Düğün Kitabı PDF Oluştur", color: .nuviaGoldFallback)
                    }
                }
            }

            if let message = exportMessage {
                Section {
                    Text(message)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSuccess)
                }
            }
        }
        .navigationTitle("Veri Dışa Aktar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func exportPDF() {
        guard let project = currentProject else { return }
        let service = ExportService()
        if let data = service.generateBudgetReportPDF(project: project) {
            ExportService.shareFile(data: data, fileName: "\(project.partnerName1)_\(project.partnerName2)_rapor.pdf", mimeType: "application/pdf")
            exportMessage = "PDF dışa aktarıldı"
            HapticManager.shared.taskCompleted()
        }
    }

    private func exportCSV() {
        guard let project = currentProject else { return }
        let service = ExportService()
        let csv = service.exportGuestListCSV(project: project)
        if let data = csv.data(using: .utf8) {
            ExportService.shareFile(data: data, fileName: "\(project.partnerName1)_\(project.partnerName2)_misafirler.csv", mimeType: "text/csv")
            exportMessage = "CSV dışa aktarıldı"
            HapticManager.shared.taskCompleted()
        }
    }

    private func exportJSON() {
        guard let project = currentProject else { return }
        let service = ExportService()
        if let data = service.exportProjectJSON(project: project) {
            ExportService.shareFile(data: data, fileName: "\(project.partnerName1)_\(project.partnerName2)_proje.json", mimeType: "application/json")
            exportMessage = "JSON dışa aktarıldı"
            HapticManager.shared.taskCompleted()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
