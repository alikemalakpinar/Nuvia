import SwiftUI
import SwiftData

// MARK: - Haptic Helper (avoids ambiguity)
private let haptics = haptics

// MARK: - Full RSVP Management System

struct RSVPManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var showBulkMessage = false
    @State private var showDeadlineSettings = false
    @State private var rsvpDeadline: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
    @State private var showShareLink = false
    @State private var reminderSent = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    private var guestsByRSVP: (attending: [Guest], pending: [Guest], maybe: [Guest], notAttending: [Guest]) {
        guard let project = currentProject else { return ([], [], [], []) }
        return (
            project.guests.filter { $0.rsvp == .attending },
            project.guests.filter { $0.rsvp == .pending },
            project.guests.filter { $0.rsvp == .maybe },
            project.guests.filter { $0.rsvp == .notAttending }
        )
    }

    private var responseRate: Double {
        guard let project = currentProject, !project.guests.isEmpty else { return 0 }
        let responded = project.guests.filter { $0.rsvp != .pending }.count
        return Double(responded) / Double(project.guests.count)
    }

    private var daysUntilDeadline: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: rsvpDeadline).day ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // RSVP Overview Dashboard
                    rsvpDashboard

                    // Deadline card
                    deadlineCard

                    // Quick Actions
                    quickActions

                    // Guests by status
                    rsvpGroupSection(title: "Bekleyen Yanıtlar", guests: guestsByRSVP.pending, icon: "questionmark.circle", color: .nuviaWarning)
                    rsvpGroupSection(title: "Belki", guests: guestsByRSVP.maybe, icon: "minus.circle.fill", color: .nuviaWarning)
                    rsvpGroupSection(title: "Geliyor", guests: guestsByRSVP.attending, icon: "checkmark.circle.fill", color: .nuviaSuccess)
                    rsvpGroupSection(title: "Gelmiyor", guests: guestsByRSVP.notAttending, icon: "xmark.circle.fill", color: .nuviaError)

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 16)
            }
            .background(Color.nuviaBackground)
            .navigationTitle("RSVP Yönetimi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showShareLink = true
                        } label: {
                            Label("RSVP Linki Paylaş", systemImage: "link")
                        }
                        Button {
                            showDeadlineSettings = true
                        } label: {
                            Label("Kapanış Tarihi Ayarla", systemImage: "calendar.badge.clock")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }
            }
            .sheet(isPresented: $showBulkMessage) {
                BulkRSVPMessageView()
            }
            .sheet(isPresented: $showShareLink) {
                RSVPShareLinkView()
            }
            .sheet(isPresented: $showDeadlineSettings) {
                RSVPDeadlineSettingsView(deadline: $rsvpDeadline)
            }
        }
    }

    // MARK: - Dashboard

    private var rsvpDashboard: some View {
        NuviaCard {
            VStack(spacing: 16) {
                // Response rate ring
                HStack(spacing: 24) {
                    NuviaProgressRing(progress: responseRate, size: 80, lineWidth: 8)
                        .overlay(
                            VStack(spacing: 0) {
                                Text("\(Int(responseRate * 100))%")
                                    .font(NuviaTypography.bodyBold())
                                    .foregroundColor(.nuviaPrimaryText)
                                Text("Yanıt")
                                    .font(NuviaTypography.caption2())
                                    .foregroundColor(.nuviaSecondaryText)
                            }
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        rsvpStatRow(icon: "checkmark.circle.fill", color: .nuviaSuccess, label: "Geliyor", count: guestsByRSVP.attending.count, headcount: guestsByRSVP.attending.reduce(0) { $0 + $1.totalHeadcount })
                        rsvpStatRow(icon: "minus.circle.fill", color: .nuviaWarning, label: "Belki", count: guestsByRSVP.maybe.count, headcount: guestsByRSVP.maybe.reduce(0) { $0 + $1.totalHeadcount })
                        rsvpStatRow(icon: "xmark.circle.fill", color: .nuviaError, label: "Gelmiyor", count: guestsByRSVP.notAttending.count, headcount: guestsByRSVP.notAttending.reduce(0) { $0 + $1.totalHeadcount })
                        rsvpStatRow(icon: "questionmark.circle", color: .nuviaSecondaryText, label: "Bekliyor", count: guestsByRSVP.pending.count, headcount: guestsByRSVP.pending.reduce(0) { $0 + $1.totalHeadcount })
                    }
                }
            }
        }
    }

    private func rsvpStatRow(icon: String, color: Color, label: String, count: Int, headcount: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(label)
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaSecondaryText)
            Spacer()
            Text("\(count)")
                .font(NuviaTypography.bodyBold())
                .foregroundColor(.nuviaPrimaryText)
            Text("(\(headcount) kişi)")
                .font(NuviaTypography.caption2())
                .foregroundColor(.nuviaTertiaryText)
        }
    }

    // MARK: - Deadline Card

    private var deadlineCard: some View {
        NuviaCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RSVP Kapanış Tarihi")
                        .font(NuviaTypography.bodyBold())
                        .foregroundColor(.nuviaPrimaryText)

                    Text(rsvpDeadline.formatted(date: .long, time: .omitted))
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaSecondaryText)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(abs(daysUntilDeadline))")
                        .font(NuviaTypography.largeNumber())
                        .foregroundColor(daysUntilDeadline < 0 ? .nuviaError : daysUntilDeadline < 7 ? .nuviaWarning : .nuviaGoldFallback)
                    Text(daysUntilDeadline < 0 ? "gün geçti" : "gün kaldı")
                        .font(NuviaTypography.caption2())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: 12) {
            NuviaPrimaryButton("Hatırlatma Gönder", icon: "bell.badge") {
                sendReminders()
            }

            NuviaSecondaryButton("Toplu Mesaj", icon: "bubble.left.and.bubble.right") {
                showBulkMessage = true
            }
        }
    }

    // MARK: - RSVP Group Section

    @ViewBuilder
    private func rsvpGroupSection(title: String, guests: [Guest], icon: String, color: Color) -> some View {
        if !guests.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Text(title)
                        .font(NuviaTypography.bodyBold())
                        .foregroundColor(.nuviaPrimaryText)
                    Text("\(guests.count)")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.nuviaTertiaryBackground)
                        .cornerRadius(10)
                    Spacer()
                }

                ForEach(guests, id: \.id) { guest in
                    RSVPGuestRow(guest: guest)
                }
            }
        }
    }

    private func sendReminders() {
        guard let project = currentProject else { return }
        let pending = project.guests.filter { $0.rsvp == .pending }

        for guest in pending {
            if let phone = guest.phone {
                // Would send SMS/WhatsApp reminder in production
                _ = phone
            }
        }

        reminderSent = true
        haptics.taskCompleted()
    }
}

// MARK: - RSVP Guest Row

struct RSVPGuestRow: View {
    let guest: Guest
    @Environment(\.modelContext) private var modelContext

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
                HStack(spacing: 4) {
                    Text(guest.fullName)
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaPrimaryText)
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

            // Quick RSVP buttons
            HStack(spacing: 6) {
                rsvpButton(.attending, icon: "checkmark", color: .nuviaSuccess)
                rsvpButton(.maybe, icon: "minus", color: .nuviaWarning)
                rsvpButton(.notAttending, icon: "xmark", color: .nuviaError)
            }
        }
        .padding(12)
        .background(Color.nuviaCardBackground)
        .cornerRadius(12)
    }

    private func rsvpButton(_ status: RSVPStatus, icon: String, color: Color) -> some View {
        Button {
            guest.updateRSVP(status)
            try? modelContext.save()
            haptics.selection()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(guest.rsvp == status ? .white : color)
                .frame(width: 28, height: 28)
                .background(guest.rsvp == status ? color : color.opacity(0.15))
                .cornerRadius(8)
        }
    }
}

// MARK: - Bulk RSVP Message View

struct BulkRSVPMessageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageType: BulkMessageType = .reminder
    @State private var customMessage = ""
    @State private var targetGroup: BulkMessageTarget = .pending

    var body: some View {
        NavigationStack {
            Form {
                Section("Hedef Kitle") {
                    Picker("Gönder", selection: $targetGroup) {
                        Text("Bekleyenler").tag(BulkMessageTarget.pending)
                        Text("Belki Diyenler").tag(BulkMessageTarget.maybe)
                        Text("Tüm Davetliler").tag(BulkMessageTarget.all)
                    }
                }

                Section("Mesaj Tipi") {
                    Picker("Tip", selection: $messageType) {
                        Text("RSVP Hatırlatma").tag(BulkMessageType.reminder)
                        Text("Düğün Bilgilendirme").tag(BulkMessageType.info)
                        Text("Özel Mesaj").tag(BulkMessageType.custom)
                    }
                }

                if messageType == .custom {
                    Section("Mesaj") {
                        TextField("Mesajınız...", text: $customMessage, axis: .vertical)
                            .lineLimit(5...10)
                    }
                }

                Section("Gönderim Kanalı") {
                    Label("SMS", systemImage: "message.fill")
                    Label("WhatsApp", systemImage: "bubble.left.fill")
                    Label("E-posta", systemImage: "envelope.fill")
                }
            }
            .navigationTitle("Toplu Mesaj")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Gönder") {
                        haptics.taskCompleted()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

enum BulkMessageType { case reminder, info, custom }
enum BulkMessageTarget { case pending, maybe, all }

// MARK: - RSVP Share Link View

struct RSVPShareLinkView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var linkGenerated = false
    @State private var rsvpLink = "https://nuvia.app/rsvp/abc123"

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.nuviaGoldFallback)

                Text("RSVP Linki")
                    .font(NuviaTypography.title2())
                    .foregroundColor(.nuviaPrimaryText)

                Text("Bu linki misafirlerinizle paylaşarak RSVP yanıtlarını kolayca toplayın.")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                NuviaCard {
                    VStack(spacing: 12) {
                        HStack {
                            Text(rsvpLink)
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaInfo)
                                .lineLimit(1)
                            Spacer()
                            Button {
                                UIPasteboard.general.string = rsvpLink
                                haptics.taskCompleted()
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.nuviaGoldFallback)
                            }
                        }

                        Divider()

                        Toggle("Şifreli Link", isOn: .constant(true))
                            .font(NuviaTypography.body())

                        Toggle("Erişim Süresi Sınırı (30 gün)", isOn: .constant(true))
                            .font(NuviaTypography.body())
                    }
                }
                .padding(.horizontal, 16)

                HStack(spacing: 12) {
                    NuviaPrimaryButton("WhatsApp ile Paylaş", icon: "bubble.left.fill") {}
                    NuviaSecondaryButton("SMS ile Paylaş", icon: "message.fill") {}
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.top, 32)
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

// MARK: - RSVP Deadline Settings View

struct RSVPDeadlineSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var deadline: Date
    @State private var autoReminder = true
    @State private var reminderDays = 7

    var body: some View {
        NavigationStack {
            Form {
                Section("Kapanış Tarihi") {
                    DatePicker("RSVP Son Tarihi", selection: $deadline, displayedComponents: .date)
                }

                Section("Otomatik Hatırlatma") {
                    Toggle("Otomatik hatırlatma gönder", isOn: $autoReminder)

                    if autoReminder {
                        Stepper("\(reminderDays) gün önce hatırlat", value: $reminderDays, in: 1...30)

                        Text("Kapanış tarihinden \(reminderDays) gün önce bekleyen misafirlere otomatik hatırlatma gönderilecek.")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }
            }
            .navigationTitle("RSVP Kapanış")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        haptics.taskCompleted()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    RSVPManagementView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
