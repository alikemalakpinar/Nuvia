import SwiftUI
import SwiftData

/// Proje oluşturma ekranı
struct CreateProjectView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var partnerName1 = ""
    @State private var partnerName2 = ""
    @State private var weddingDate = Date().addingTimeInterval(180 * 24 * 60 * 60) // 6 ay sonra
    @State private var weddingTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!
    @State private var venueName = ""
    @State private var venueCity = ""
    @State private var allowChildren = false
    @State private var selectedCurrency: Currency = .TRY
    @State private var selectedTheme: ProjectTheme = .minimal
    @State private var totalBudget = ""

    @State private var showingPartnerInvite = false
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Düğününüzü Oluşturun")
                            .font(NuviaTypography.title1())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("Temel bilgileri girin, sonra detayları ekleyin")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                    .padding(.top, 16)

                    // Form
                    VStack(spacing: 20) {
                        // Couple names
                        NuviaCard {
                            VStack(spacing: 16) {
                                NuviaSectionHeader("Çift Bilgileri")

                                NuviaTextField(
                                    "1. Kişi Adı",
                                    placeholder: "Ali Kemal",
                                    text: $partnerName1,
                                    icon: "person.fill"
                                )

                                NuviaTextField(
                                    "2. Kişi Adı",
                                    placeholder: "Elif",
                                    text: $partnerName2,
                                    icon: "person.fill"
                                )
                            }
                        }

                        // Date and time
                        NuviaCard {
                            VStack(spacing: 16) {
                                NuviaSectionHeader("Düğün Tarihi")

                                HStack(spacing: 16) {
                                    NuviaDatePicker(
                                        title: "Tarih",
                                        date: $weddingDate,
                                        displayedComponents: .date
                                    )

                                    NuviaDatePicker(
                                        title: "Saat",
                                        date: $weddingTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                }
                            }
                        }

                        // Venue
                        NuviaCard {
                            VStack(spacing: 16) {
                                NuviaSectionHeader("Mekan")

                                NuviaTextField(
                                    "Mekan Adı",
                                    placeholder: "Grand Ballroom",
                                    text: $venueName,
                                    icon: "building.2.fill"
                                )

                                NuviaTextField(
                                    "Şehir",
                                    placeholder: "İstanbul",
                                    text: $venueCity,
                                    icon: "mappin.circle.fill"
                                )
                            }
                        }

                        // Settings
                        NuviaCard {
                            VStack(spacing: 16) {
                                NuviaSectionHeader("Ayarlar")

                                NuviaToggle(
                                    "Çocuk Davetli",
                                    subtitle: "Kapatırsanız davetiyede belirtilir",
                                    isOn: $allowChildren
                                )

                                Divider()
                                    .background(Color.nuviaTertiaryText)

                                // Currency picker
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Para Birimi")
                                        .font(NuviaTypography.caption())
                                        .foregroundColor(.nuviaSecondaryText)

                                    HStack(spacing: 8) {
                                        ForEach(Currency.allCases, id: \.self) { currency in
                                            CurrencyChip(
                                                currency: currency,
                                                isSelected: selectedCurrency == currency
                                            ) {
                                                selectedCurrency = currency
                                            }
                                        }
                                    }
                                }

                                Divider()
                                    .background(Color.nuviaTertiaryText)

                                // Theme picker
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Tema")
                                        .font(NuviaTypography.caption())
                                        .foregroundColor(.nuviaSecondaryText)

                                    HStack(spacing: 8) {
                                        ForEach(ProjectTheme.allCases, id: \.self) { theme in
                                            ThemeChip(
                                                theme: theme,
                                                isSelected: selectedTheme == theme
                                            ) {
                                                selectedTheme = theme
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Budget
                        NuviaCard {
                            VStack(spacing: 16) {
                                NuviaSectionHeader("Toplam Bütçe", actionTitle: "Opsiyonel")

                                NuviaTextField(
                                    "Tahmini Bütçe",
                                    placeholder: "500000",
                                    text: $totalBudget,
                                    icon: "creditcard.fill",
                                    keyboardType: .numberPad
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // Create button
                    VStack(spacing: 12) {
                        NuviaPrimaryButton(
                            "Düğün Oluştur",
                            icon: "sparkles",
                            isLoading: isCreating,
                            isDisabled: !isFormValid
                        ) {
                            createProject()
                        }

                        NuviaTextButton(title: "Partner'ı Davet Et") {
                            showingPartnerInvite = true
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .background(Color.nuviaBackground)
            .sheet(isPresented: $showingPartnerInvite) {
                InvitePartnerSheet()
            }
        }
    }

    private var isFormValid: Bool {
        !partnerName1.trimmingCharacters(in: .whitespaces).isEmpty &&
        !partnerName2.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func createProject() {
        isCreating = true

        let project = WeddingProject(
            partnerName1: partnerName1.trimmingCharacters(in: .whitespaces),
            partnerName2: partnerName2.trimmingCharacters(in: .whitespaces),
            weddingDate: weddingDate,
            currency: selectedCurrency.rawValue,
            theme: selectedTheme.rawValue,
            appMode: appState.appMode.rawValue,
            allowChildren: allowChildren,
            totalBudget: Double(totalBudget) ?? 0
        )

        project.venueName = venueName.isEmpty ? nil : venueName
        project.venueCity = venueCity.isEmpty ? nil : venueCity
        project.weddingTime = weddingTime

        // Create owner user
        let owner = User(name: partnerName1, role: .owner)
        project.users.append(owner)

        // Create partner user
        let partner = User(name: partnerName2, role: .partner)
        project.users.append(partner)

        // Add default notification rules
        let defaultRules = DefaultNotificationRules.createDefaults()
        for rule in defaultRules {
            project.notificationRules.append(rule)
        }

        // Add default shopping lists if home mode
        if appState.appMode == .weddingAndHome {
            let kitchenList = ShoppingList(title: "Mutfak", type: .home, category: "kitchen")
            let bathroomList = ShoppingList(title: "Banyo", type: .home, category: "bathroom")
            let bedroomList = ShoppingList(title: "Yatak Odası", type: .home, category: "bedroom")
            project.shoppingLists.append(contentsOf: [kitchenList, bathroomList, bedroomList])

            // Add default rooms
            let kitchen = Room(name: "Mutfak", type: .kitchen)
            let bathroom = Room(name: "Banyo", type: .bathroom)
            let bedroom = Room(name: "Yatak Odası", type: .bedroom)
            let livingRoom = Room(name: "Salon", type: .livingRoom)
            project.rooms.append(contentsOf: [kitchen, bathroom, bedroom, livingRoom])
        }

        // Add default wedding shopping lists
        let dressAccessories = ShoppingList(title: "Gelinlik Aksesuarları", type: .wedding)
        let engagementItems = ShoppingList(title: "Nişan/Bohça", type: .wedding)
        let civilDocs = ShoppingList(title: "Nikah Evrakları", type: .wedding)
        project.shoppingLists.append(contentsOf: [dressAccessories, engagementItems, civilDocs])

        // Generate default tasks based on wedding date
        let defaultTasks = TaskTemplateGenerator.generateTasks(for: project)
        project.tasks.append(contentsOf: defaultTasks)

        modelContext.insert(project)

        do {
            try modelContext.save()
            appState.setCurrentProject(project.id.uuidString)
        } catch {
            print("Failed to save project: \(error)")
        }

        isCreating = false
    }
}

// MARK: - Currency Chip

struct CurrencyChip: View {
    let currency: Currency
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(currency.symbol)
                .font(NuviaTypography.bodyBold())
                .foregroundColor(isSelected ? .nuviaMidnight : .nuviaSecondaryText)
                .frame(width: 48, height: 40)
                .background(isSelected ? Color.nuviaGoldFallback : Color.nuviaTertiaryBackground)
                .cornerRadius(10)
        }
    }
}

// MARK: - Theme Chip

struct ThemeChip: View {
    let theme: ProjectTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: theme.iconName)
                    .font(.system(size: 20))
                Text(theme.displayName)
                    .font(NuviaTypography.caption2())
            }
            .foregroundColor(isSelected ? .nuviaMidnight : .nuviaSecondaryText)
            .frame(width: 70, height: 56)
            .background(isSelected ? Color.nuviaGoldFallback : Color.nuviaTertiaryBackground)
            .cornerRadius(10)
        }
    }
}

// MARK: - Invite Partner Sheet

struct InvitePartnerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var partnerContact = ""
    @State private var shareMethod: ShareMethod = .link

    enum ShareMethod: String, CaseIterable {
        case link = "Link"
        case message = "iMessage"
        case whatsapp = "WhatsApp"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Partner'ınızı davet edin ve düğünü birlikte planlayın")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                NuviaTextField(
                    "E-posta veya Telefon",
                    placeholder: "ornek@email.com",
                    text: $partnerContact,
                    icon: "envelope.fill"
                )
                .padding(.horizontal)

                VStack(spacing: 12) {
                    Text("Paylaşım Yöntemi")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)

                    HStack(spacing: 12) {
                        ForEach(ShareMethod.allCases, id: \.self) { method in
                            Button {
                                shareMethod = method
                            } label: {
                                Text(method.rawValue)
                                    .font(NuviaTypography.smallButton())
                                    .foregroundColor(shareMethod == method ? .nuviaMidnight : .nuviaSecondaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(shareMethod == method ? Color.nuviaGoldFallback : Color.nuviaTertiaryBackground)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                NuviaPrimaryButton("Davet Gönder", icon: "paperplane.fill") {
                    // Send invite logic
                    dismiss()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top, 24)
            .background(Color.nuviaBackground)
            .navigationTitle("Partner Davet Et")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundColor(.nuviaGoldFallback)
                }
            }
        }
    }
}

// MARK: - Task Template Generator

struct TaskTemplateGenerator {
    static func generateTasks(for project: WeddingProject) -> [Task] {
        var tasks: [Task] = []
        let weddingDate = project.weddingDate

        // Calculate months until wedding
        let monthsUntil = Calendar.current.dateComponents([.month], from: Date(), to: weddingDate).month ?? 6

        // 6+ months before
        if monthsUntil >= 6 {
            tasks.append(Task(
                title: "Düğün tarihini belirle",
                category: .ceremony,
                priority: .high,
                dueDate: Date()
            ))
            tasks.append(Task(
                title: "Bütçe planı oluştur",
                category: .other,
                priority: .high,
                dueDate: Date().addingTimeInterval(7 * 24 * 60 * 60)
            ))
            tasks.append(Task(
                title: "Mekan araştırması yap",
                category: .venue,
                priority: .high,
                dueDate: weddingDate.addingTimeInterval(-180 * 24 * 60 * 60)
            ))
            tasks.append(Task(
                title: "Fotoğrafçı araştır ve rezerve et",
                category: .photo,
                priority: .high,
                dueDate: weddingDate.addingTimeInterval(-150 * 24 * 60 * 60)
            ))
        }

        // 4-6 months before
        if monthsUntil >= 4 {
            tasks.append(Task(
                title: "Gelinlik/Damatlık seçimi",
                category: .dress,
                priority: .high,
                dueDate: weddingDate.addingTimeInterval(-120 * 24 * 60 * 60)
            ))
            tasks.append(Task(
                title: "Müzik/DJ seçimi",
                category: .music,
                priority: .medium,
                dueDate: weddingDate.addingTimeInterval(-120 * 24 * 60 * 60)
            ))
            tasks.append(Task(
                title: "Davetli listesi oluştur",
                category: .other,
                priority: .high,
                dueDate: weddingDate.addingTimeInterval(-100 * 24 * 60 * 60)
            ))
        }

        // 2-3 months before
        if monthsUntil >= 2 {
            tasks.append(Task(
                title: "Davetiye tasarımı ve baskı",
                category: .invitation,
                priority: .high,
                dueDate: weddingDate.addingTimeInterval(-90 * 24 * 60 * 60)
            ))
            tasks.append(Task(
                title: "Çiçek ve dekorasyon seçimi",
                category: .flowers,
                priority: .medium,
                dueDate: weddingDate.addingTimeInterval(-75 * 24 * 60 * 60)
            ))
            tasks.append(Task(
                title: "Kuaför/Makyaj prova",
                category: .other,
                priority: .medium,
                dueDate: weddingDate.addingTimeInterval(-60 * 24 * 60 * 60)
            ))
        }

        // 1 month before
        if monthsUntil >= 1 {
            tasks.append(Task(
                title: "RSVP takibi",
                category: .other,
                priority: .high,
                dueDate: weddingDate.addingTimeInterval(-30 * 24 * 60 * 60)
            ))
            tasks.append(Task(
                title: "Oturma planı oluştur",
                category: .other,
                priority: .high,
                dueDate: weddingDate.addingTimeInterval(-21 * 24 * 60 * 60)
            ))
            tasks.append(Task(
                title: "Son ödeme kontrolleri",
                category: .other,
                priority: .high,
                dueDate: weddingDate.addingTimeInterval(-14 * 24 * 60 * 60)
            ))
        }

        // 1 week before
        tasks.append(Task(
            title: "Düğün günü akış planı oluştur",
            category: .other,
            priority: .high,
            dueDate: weddingDate.addingTimeInterval(-7 * 24 * 60 * 60)
        ))
        tasks.append(Task(
            title: "Son prova ve kontroller",
            category: .other,
            priority: .high,
            dueDate: weddingDate.addingTimeInterval(-3 * 24 * 60 * 60)
        ))

        return tasks
    }
}

#Preview {
    CreateProjectView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
