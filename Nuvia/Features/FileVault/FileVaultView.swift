import SwiftUI
import SwiftData
import PhotosUI

// MARK: - File Vault View (FaceID Protected)

struct FileVaultView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState
    @StateObject private var biometricService = BiometricService()

    @State private var isUnlocked = false
    @State private var selectedCategory: FileVaultCategory?
    @State private var showAddFile = false
    @State private var showCamera = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    private var filteredFiles: [FileAttachment] {
        guard let project = currentProject else { return [] }
        guard let cat = selectedCategory else { return project.files }

        switch cat {
        case .contracts:
            return project.files.filter { $0.attachmentType == .contract }
        case .identityDocuments:
            return project.files.filter { $0.attachmentType == .id }
        case .invitationDesigns:
            return project.files.filter { $0.attachmentType == .inspiration }
        case .moodboard:
            return project.files.filter { $0.attachmentType == .photo }
        case .receipts:
            return project.files.filter { $0.attachmentType == .receipt }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if selectedCategory == .identityDocuments && !isUnlocked {
                    faceIDLockScreen
                } else {
                    fileVaultContent
                }
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Dosya Kasası")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.nuviaGoldFallback)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        if isUnlocked {
                            Button {
                                isUnlocked = false
                                biometricService.deauthenticate()
                                HapticManager.shared.buttonTap()
                            } label: {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.nuviaWarning)
                            }
                        }

                        Button { showAddFile = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nuviaGoldFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddFile) {
                AddFileView()
            }
        }
    }

    // MARK: - Face ID Lock Screen

    private var faceIDLockScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: biometricService.biometricType.icon)
                .font(.system(size: 80))
                .foregroundColor(.nuviaGoldFallback)

            VStack(spacing: 8) {
                Text("Korunan Bölüm")
                    .font(NuviaTypography.title2())
                    .foregroundColor(.nuviaPrimaryText)

                Text("Kimlik ve evrak dosyalarına erişmek için \(biometricService.biometricType.displayName) doğrulaması gereklidir.")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            NuviaPrimaryButton("Kilit Aç", icon: biometricService.biometricType.icon) {
                Task {
                    let success = await biometricService.authenticate(reason: "Dosya kasasına erişmek için kimliğinizi doğrulayın")
                    if success {
                        withAnimation { isUnlocked = true }
                        HapticManager.shared.taskCompleted()
                    } else {
                        HapticManager.shared.error()
                    }
                }
            }
            .frame(width: 200)

            if let error = biometricService.error {
                Text(error)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaError)
            }

            Spacer()
        }
    }

    // MARK: - File Vault Content

    private var fileVaultContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Category grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(FileVaultCategory.allCases, id: \.self) { category in
                        FileVaultCategoryCard(
                            category: category,
                            count: countForCategory(category),
                            isSelected: selectedCategory == category,
                            isLocked: category.requiresFaceID && !isUnlocked
                        ) {
                            if category.requiresFaceID && !isUnlocked {
                                selectedCategory = category
                            } else {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                // Files list
                if filteredFiles.isEmpty {
                    NuviaEmptyState(
                        icon: "folder.badge.plus",
                        title: "Dosya bulunamadı",
                        message: "Sözleşme, fiş veya ilham görselleri ekleyin",
                        actionTitle: "Dosya Ekle"
                    ) {
                        showAddFile = true
                    }
                    .padding(.top, 20)
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredFiles, id: \.id) { file in
                            FileAttachmentRow(file: file)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Storage info
                NuviaCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Depolama")
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)

                            let totalSize = currentProject?.files.reduce(Int64(0)) { $0 + ($1.fileSize ?? 0) } ?? 0
                            Text(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file))
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(currentProject?.files.count ?? 0) dosya")
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)

                            HStack(spacing: 4) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 12))
                                Text("Şifreli")
                                    .font(NuviaTypography.caption())
                            }
                            .foregroundColor(.nuviaSuccess)
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 80)
            }
        }
    }

    private func countForCategory(_ category: FileVaultCategory) -> Int {
        guard let project = currentProject else { return 0 }
        switch category {
        case .contracts: return project.files.filter { $0.attachmentType == .contract }.count
        case .identityDocuments: return project.files.filter { $0.attachmentType == .id }.count
        case .invitationDesigns: return project.files.filter { $0.attachmentType == .inspiration }.count
        case .moodboard: return project.files.filter { $0.attachmentType == .photo }.count
        case .receipts: return project.files.filter { $0.attachmentType == .receipt }.count
        }
    }
}

// MARK: - File Vault Category Card

struct FileVaultCategoryCard: View {
    let category: FileVaultCategory
    let count: Int
    let isSelected: Bool
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? .nuviaMidnight : .nuviaGoldFallback)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.nuviaWarning)
                            .offset(x: 16, y: -16)
                    }
                }

                Text(category.rawValue)
                    .font(NuviaTypography.caption())
                    .foregroundColor(isSelected ? .nuviaMidnight : .nuviaPrimaryText)
                    .lineLimit(1)

                Text("\(count) dosya")
                    .font(NuviaTypography.caption2())
                    .foregroundColor(isSelected ? .nuviaMidnight.opacity(0.7) : .nuviaSecondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(isSelected ? Color.nuviaGoldFallback : Color.nuviaCardBackground)
            .cornerRadius(16)
        }
    }
}

// MARK: - File Attachment Row

struct FileAttachmentRow: View {
    let file: FileAttachment
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.icon)
                .font(.system(size: 24))
                .foregroundColor(file.attachmentType.color)
                .frame(width: 44, height: 44)
                .background(file.attachmentType.color.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(file.fileName)
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaPrimaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    NuviaTag(file.attachmentType.displayName, color: file.attachmentType.color, size: .small)
                    Text(file.formattedSize)
                        .font(NuviaTypography.caption2())
                        .foregroundColor(.nuviaSecondaryText)
                    Text(file.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(NuviaTypography.caption2())
                        .foregroundColor(.nuviaTertiaryText)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                if file.isEncrypted {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.nuviaSuccess)
                }
                if file.requiresFaceID {
                    Image(systemName: "faceid")
                        .font(.system(size: 12))
                        .foregroundColor(.nuviaWarning)
                }
            }

            Menu {
                Button {
                    // Share file
                } label: {
                    Label("Paylaş", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    modelContext.delete(file)
                    try? modelContext.save()
                    HapticManager.shared.warning()
                } label: {
                    Label("Sil", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.nuviaSecondaryText)
            }
        }
        .padding(12)
        .background(Color.nuviaCardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Add File View

struct AddFileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var fileName = ""
    @State private var fileType: FileAttachmentType = .document
    @State private var requiresFaceID = false
    @State private var notes = ""
    @State private var selectedTags: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Dosya Bilgileri") {
                    TextField("Dosya Adı", text: $fileName)

                    Picker("Dosya Tipi", selection: $fileType) {
                        ForEach(FileAttachmentType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon).tag(type)
                        }
                    }
                }

                Section("Kaynak") {
                    Button {
                        // Camera capture
                    } label: {
                        Label("Kamera ile Çek", systemImage: "camera.fill")
                            .foregroundColor(.nuviaGoldFallback)
                    }

                    Button {
                        // Photo library
                    } label: {
                        Label("Galeriden Seç", systemImage: "photo.on.rectangle")
                            .foregroundColor(.nuviaGoldFallback)
                    }

                    Button {
                        // Document picker
                    } label: {
                        Label("Dosya Seç", systemImage: "folder.fill")
                            .foregroundColor(.nuviaGoldFallback)
                    }
                }

                Section("Güvenlik") {
                    Toggle("FaceID Koruması", isOn: $requiresFaceID)

                    if fileType.requiresEncryption {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.nuviaSuccess)
                            Text("Bu dosya tipi otomatik şifrelenir")
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }
                }

                Section("Notlar") {
                    TextField("Not ekle...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Dosya Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") { saveFile() }
                        .disabled(fileName.isEmpty)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveFile() {
        guard let project = projects.first(where: { $0.id.uuidString == appState.currentProjectId }) else { return }

        let file = FileAttachment(fileName: fileName, type: fileType)
        file.requiresFaceID = requiresFaceID
        file.isEncrypted = fileType.requiresEncryption || requiresFaceID
        file.notes = notes.isEmpty ? nil : notes

        project.files.append(file)
        do {
            try modelContext.save()
            HapticManager.shared.taskCompleted()
            dismiss()
        } catch {
            print("Failed to save file: \(error)")
        }
    }
}

#Preview {
    FileVaultView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
