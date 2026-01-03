import SwiftUI
import SwiftData

/// Davetiye düzenleyici ana ekranı
struct InvitationEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var selectedTemplate: InvitationTemplate = .minimal
    @State private var familyNames = ""
    @State private var customMessage = ""
    @State private var showChildNotice = true
    @State private var showMap = true
    @State private var showProgram = false
    @State private var showRSVP = true
    @State private var showPreview = false
    @State private var showShare = false

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Template Selection
                    NuviaCard {
                        VStack(spacing: 16) {
                            NuviaSectionHeader("Şablon Seçimi")

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(InvitationTemplate.allCases, id: \.self) { template in
                                        TemplateCard(
                                            template: template,
                                            isSelected: selectedTemplate == template
                                        ) {
                                            selectedTemplate = template
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Content
                    NuviaCard {
                        VStack(spacing: 16) {
                            NuviaSectionHeader("İçerik")

                            NuviaTextField(
                                "Aile İsimleri",
                                placeholder: "Akpınar & Yılmaz Aileleri",
                                text: $familyNames,
                                icon: "person.2.fill"
                            )

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Özel Mesaj")
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaSecondaryText)

                                TextEditor(text: $customMessage)
                                    .font(NuviaTypography.body())
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color.nuviaTertiaryBackground)
                                    .cornerRadius(12)
                            }
                        }
                    }

                    // Options
                    NuviaCard {
                        VStack(spacing: 16) {
                            NuviaSectionHeader("Seçenekler")

                            if let project = currentProject, !project.allowChildren {
                                NuviaToggle(
                                    "Çocuk Davetli Değildir Notu",
                                    subtitle: "Davetiyede belirtilir",
                                    isOn: $showChildNotice
                                )
                            }

                            NuviaToggle(
                                "Harita Göster",
                                subtitle: "Mekan konumunu ekle",
                                isOn: $showMap
                            )

                            NuviaToggle(
                                "Program Akışı",
                                subtitle: "Düğün günü akışını göster",
                                isOn: $showProgram
                            )

                            NuviaToggle(
                                "RSVP Butonu",
                                subtitle: "Misafirler yanıt verebilsin",
                                isOn: $showRSVP
                            )
                        }
                    }

                    // Preview button
                    NuviaPrimaryButton("Önizleme", icon: "eye.fill") {
                        showPreview = true
                    }

                    // Share button
                    NuviaSecondaryButton("Paylaş", icon: "square.and.arrow.up") {
                        showShare = true
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Davetiye")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.nuviaGoldFallback)
                }
            }
            .sheet(isPresented: $showPreview) {
                if let project = currentProject {
                    InvitationPreviewView(
                        project: project,
                        template: selectedTemplate,
                        familyNames: familyNames,
                        customMessage: customMessage,
                        showChildNotice: showChildNotice,
                        showMap: showMap,
                        showRSVP: showRSVP
                    )
                }
            }
            .sheet(isPresented: $showShare) {
                InvitationShareSheet()
            }
        }
    }
}

// MARK: - Invitation Template

enum InvitationTemplate: String, CaseIterable {
    case minimal = "Minimal"
    case floral = "Çiçekli"
    case modern = "Modern"
    case luxury = "Lüks"
    case classic = "Klasik"
    case romantic = "Romantik"

    var previewColor: Color {
        switch self {
        case .minimal: return .nuviaSecondaryText
        case .floral: return .categoryFlowers
        case .modern: return .nuviaInfo
        case .luxury: return .nuviaGoldFallback
        case .classic: return .nuviaCopper
        case .romantic: return .categoryDress
        }
    }

    var icon: String {
        switch self {
        case .minimal: return "square"
        case .floral: return "leaf.fill"
        case .modern: return "diamond.fill"
        case .luxury: return "crown.fill"
        case .classic: return "scroll.fill"
        case .romantic: return "heart.fill"
        }
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: InvitationTemplate
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(template.previewColor.opacity(0.15))
                        .frame(width: 80, height: 100)

                    Image(systemName: template.icon)
                        .font(.system(size: 32))
                        .foregroundColor(template.previewColor)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? template.previewColor : Color.clear, lineWidth: 2)
                )

                Text(template.rawValue)
                    .font(NuviaTypography.caption())
                    .foregroundColor(isSelected ? .nuviaPrimaryText : .nuviaSecondaryText)
            }
        }
    }
}

// MARK: - Invitation Preview View

struct InvitationPreviewView: View {
    let project: WeddingProject
    let template: InvitationTemplate
    let familyNames: String
    let customMessage: String
    let showChildNotice: Bool
    let showMap: Bool
    let showRSVP: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header decoration
                    Image(systemName: template.icon)
                        .font(.system(size: 48))
                        .foregroundColor(template.previewColor)
                        .padding(.top, 40)

                    // Family names
                    if !familyNames.isEmpty {
                        Text(familyNames)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                            .textCase(.uppercase)
                            .tracking(2)
                    }

                    // Couple names
                    VStack(spacing: 8) {
                        Text(project.partnerName1)
                            .font(NuviaTypography.title1())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("&")
                            .font(NuviaTypography.title3())
                            .foregroundColor(template.previewColor)

                        Text(project.partnerName2)
                            .font(NuviaTypography.title1())
                            .foregroundColor(.nuviaPrimaryText)
                    }

                    // Date
                    VStack(spacing: 4) {
                        Text(project.weddingDate.formatted(date: .complete, time: .omitted))
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)

                        if let time = project.weddingTime {
                            Text(time.formatted(date: .omitted, time: .shortened))
                                .font(NuviaTypography.body())
                                .foregroundColor(.nuviaSecondaryText)
                        }
                    }

                    // Venue
                    if let venue = project.venueName {
                        VStack(spacing: 4) {
                            Text(venue)
                                .font(NuviaTypography.bodyBold())
                                .foregroundColor(.nuviaPrimaryText)

                            if let city = project.venueCity {
                                Text(city)
                                    .font(NuviaTypography.caption())
                                    .foregroundColor(.nuviaSecondaryText)
                            }
                        }
                    }

                    // Custom message
                    if !customMessage.isEmpty {
                        Text(customMessage)
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    // Child notice
                    if showChildNotice && !project.allowChildren {
                        Text("Çocuk davetli bulunmamaktadır.")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                            .italic()
                    }

                    // Map button
                    if showMap, project.venueName != nil {
                        Button {
                            // Open map
                        } label: {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Haritada Göster")
                            }
                            .font(NuviaTypography.smallButton())
                            .foregroundColor(template.previewColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(template.previewColor.opacity(0.15))
                            .cornerRadius(24)
                        }
                    }

                    // RSVP button
                    if showRSVP {
                        NuviaPrimaryButton("Katılımımı Bildir") {}
                            .padding(.horizontal, 40)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Önizleme")
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

// MARK: - Invitation Share Sheet

struct InvitationShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var generatedLink = "https://nuvia.app/invite/abc123"
    @State private var copied = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Link
                NuviaCard {
                    VStack(spacing: 16) {
                        Text("Davetiye Linki")
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)

                        HStack {
                            Text(generatedLink)
                                .font(NuviaTypography.caption())
                                .foregroundColor(.nuviaSecondaryText)
                                .lineLimit(1)

                            Spacer()

                            Button {
                                UIPasteboard.general.string = generatedLink
                                copied = true
                            } label: {
                                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                    .foregroundColor(.nuviaGoldFallback)
                            }
                        }
                        .padding(12)
                        .background(Color.nuviaTertiaryBackground)
                        .cornerRadius(8)
                    }
                }

                // Share options
                NuviaCard {
                    VStack(spacing: 16) {
                        Text("Paylaşım Seçenekleri")
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)

                        HStack(spacing: 24) {
                            ShareOption(icon: "message.fill", title: "iMessage", color: .nuviaSuccess) {}
                            ShareOption(icon: "phone.fill", title: "WhatsApp", color: .categoryFlowers) {}
                            ShareOption(icon: "doc.fill", title: "PDF", color: .nuviaError) {}
                            ShareOption(icon: "square.and.arrow.up", title: "Diğer", color: .nuviaInfo) {}
                        }
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(Color.nuviaBackground)
            .navigationTitle("Paylaş")
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

struct ShareOption: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.15))
                    .cornerRadius(12)

                Text(title)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }
        }
    }
}

#Preview {
    InvitationEditorView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
