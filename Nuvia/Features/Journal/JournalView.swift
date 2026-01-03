import SwiftUI
import SwiftData

/// Günlük/Anı Defteri ana ekranı
struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var showAddEntry = false
    @State private var showExport = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let project = currentProject {
                    if project.journalEntries.isEmpty {
                        VStack(spacing: 24) {
                            Spacer()
                                .frame(height: 60)

                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.nuviaSecondaryText)

                            VStack(spacing: 8) {
                                Text("Anı Defteri")
                                    .font(NuviaTypography.title2())
                                    .foregroundColor(.nuviaPrimaryText)

                                Text("Düğün yolculuğunuzdaki özel anları, kararları ve duyguları kaydedin. Düğün sonunda güzel bir anı kitabına dönüştürün.")
                                    .font(NuviaTypography.body())
                                    .foregroundColor(.nuviaSecondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }

                            NuviaPrimaryButton("İlk Notunuzu Yazın", icon: "pencil") {
                                showAddEntry = true
                            }
                            .frame(width: 220)

                            Spacer()
                        }
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(project.journalEntries.sorted { $0.date > $1.date }, id: \.id) { entry in
                                JournalEntryCard(entry: entry)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                } else {
                    NuviaEmptyState(
                        icon: "book.closed",
                        title: "Proje bulunamadı",
                        message: "Günlük için bir proje oluşturun"
                    )
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Günlük")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        if let project = currentProject, !project.journalEntries.isEmpty {
                            Button {
                                showExport = true
                            } label: {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.nuviaSecondaryText)
                            }
                        }

                        Button {
                            showAddEntry = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddJournalEntryView()
            }
            .sheet(isPresented: $showExport) {
                ExportJournalView()
            }
        }
    }
}

// MARK: - Journal Entry Card

struct JournalEntryCard: View {
    let entry: JournalEntry
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(entry.formattedDate)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)

                    Spacer()

                    if let mood = entry.entryMood {
                        HStack(spacing: 4) {
                            Text(mood.emoji)
                            Text(mood.displayName)
                                .font(NuviaTypography.caption())
                                .foregroundColor(mood.color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(mood.color.opacity(0.15))
                        .cornerRadius(8)
                    }
                }

                // Title
                if let title = entry.title {
                    Text(title)
                        .font(NuviaTypography.bodyBold())
                        .foregroundColor(.nuviaPrimaryText)
                        .lineLimit(1)
                }

                // Content preview
                Text(entry.preview)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Tags
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(entry.tags, id: \.self) { tag in
                                if let journalTag = JournalTag(rawValue: tag) {
                                    HStack(spacing: 4) {
                                        Image(systemName: journalTag.icon)
                                            .font(.system(size: 10))
                                        Text(journalTag.displayName)
                                            .font(NuviaTypography.caption2())
                                    }
                                    .foregroundColor(.nuviaSecondaryText)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.nuviaTertiaryBackground)
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                }

                // Photos indicator
                if entry.hasPhotos {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 12))
                        Text("\(entry.photoIdentifiers.count) fotoğraf")
                            .font(NuviaTypography.caption())
                    }
                    .foregroundColor(.nuviaInfo)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.nuviaCardBackground)
            .cornerRadius(16)
        }
        .sheet(isPresented: $showDetail) {
            JournalEntryDetailView(entry: entry)
        }
    }
}

// MARK: - Add Journal Entry View

struct AddJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: JournalMood?
    @State private var selectedTags: Set<JournalTag> = []
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Date
                    NuviaDatePicker(title: "Tarih", date: $date, displayedComponents: .date)

                    // Title
                    NuviaTextField(
                        "Başlık",
                        placeholder: "Bugünün öne çıkanı...",
                        text: $title,
                        icon: "text.cursor"
                    )

                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("İçerik")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)

                        TextEditor(text: $content)
                            .font(NuviaTypography.body())
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color.nuviaTertiaryBackground)
                            .cornerRadius(12)
                    }

                    // Mood
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ruh Hali")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                            ForEach(JournalMood.allCases, id: \.self) { mood in
                                Button {
                                    selectedMood = mood
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(mood.emoji)
                                            .font(.system(size: 24))
                                        Text(mood.displayName)
                                            .font(NuviaTypography.caption2())
                                            .foregroundColor(selectedMood == mood ? .nuviaPrimaryText : .nuviaSecondaryText)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedMood == mood ? mood.color.opacity(0.2) : Color.nuviaTertiaryBackground)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Etiketler")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                            ForEach(JournalTag.allCases, id: \.self) { tag in
                                Button {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: tag.icon)
                                            .font(.system(size: 12))
                                        Text(tag.displayName)
                                            .font(NuviaTypography.caption())
                                    }
                                    .foregroundColor(selectedTags.contains(tag) ? .nuviaPrimaryText : .nuviaSecondaryText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedTags.contains(tag) ? Color.nuviaGoldFallback.opacity(0.2) : Color.nuviaTertiaryBackground)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(16)
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Yeni Not")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        saveEntry()
                    }
                    .disabled(content.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveEntry() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else {
            return
        }

        let entry = JournalEntry(content: content, date: date, mood: selectedMood)
        entry.title = title.isEmpty ? nil : title

        for tag in selectedTags {
            entry.addTag(tag.rawValue)
        }

        project.journalEntries.append(entry)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
}

// MARK: - Journal Entry Detail View

struct JournalEntryDetailView: View {
    let entry: JournalEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.formattedDate)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)

                        if let title = entry.title {
                            Text(title)
                                .font(NuviaTypography.title2())
                                .foregroundColor(.nuviaPrimaryText)
                        }

                        if let mood = entry.entryMood {
                            HStack(spacing: 4) {
                                Text(mood.emoji)
                                Text(mood.displayName)
                                    .font(NuviaTypography.body())
                                    .foregroundColor(mood.color)
                            }
                        }
                    }

                    Divider()

                    // Content
                    Text(entry.content)
                        .font(NuviaTypography.body())
                        .foregroundColor(.nuviaPrimaryText)
                        .lineSpacing(6)

                    // Tags
                    if !entry.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    if let journalTag = JournalTag(rawValue: tag) {
                                        NuviaTag(journalTag.displayName, color: .nuviaGoldFallback, size: .small)
                                    }
                                }
                            }
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
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.nuviaGoldFallback)
                }
            }
        }
    }
}

// MARK: - Export Journal View

struct ExportJournalView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                NuviaCard {
                    VStack(spacing: 16) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.nuviaGoldFallback)

                        Text("Düğün Kitabı")
                            .font(NuviaTypography.title2())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("Tüm anılarınızı, kararlarınızı ve fotoğraflarınızı güzel bir PDF kitabına dönüştürün. Bu özellik Premium abonelik gerektirir.")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                            .multilineTextAlignment(.center)

                        NuviaPrimaryButton("Premium'a Geç", icon: "crown.fill") {}
                            .frame(width: 200)
                    }
                }
                .padding(16)

                Spacer()
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Dışa Aktar")
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
    JournalView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
