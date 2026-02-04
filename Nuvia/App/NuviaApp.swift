import SwiftUI
import SwiftData

/// Nuvia - Düğün ve Ev Planlama Uygulaması
/// "Plan. Budget. Celebrate."
@main
struct NuviaApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var notificationManager = NotificationManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WeddingProject.self,
            User.self,
            Task.self,
            Vendor.self,
            Expense.self,
            Guest.self,
            SeatingTable.self,
            SeatAssignment.self,
            ShoppingList.self,
            ShoppingItem.self,
            Delivery.self,
            JournalEntry.self,
            FileAttachment.self,
            NotificationRule.self,
            Room.self,
            InventoryItem.self
        ])

        // Try with CloudKit first
        let cloudConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [cloudConfig])
        } catch {
            print("CloudKit ModelContainer failed: \(error)")

            // Try without CloudKit
            let localConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )

            do {
                return try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                print("Local ModelContainer failed: \(error)")

                // Last resort: delete the store and try again
                let url = localConfig.url
                try? FileManager.default.removeItem(at: url)
                try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("sqlite-shm"))
                try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("sqlite-wal"))

                do {
                    return try ModelContainer(for: schema, configurations: [localConfig])
                } catch {
                    fatalError("Could not create ModelContainer after recovery: \(error)")
                }
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(notificationManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

/// App State - Uygulama durumu yönetimi
@MainActor
class AppState: ObservableObject {
    @Published var isOnboardingComplete: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingComplete, forKey: "isOnboardingComplete")
        }
    }
    @Published var hasActiveProject: Bool = false
    @Published var currentProjectId: String?
    @Published var selectedTab: MainTab = .today
    @Published var appMode: AppMode = .weddingOnly
    @Published var userRole: UserRole = .owner
    @Published var isPremium: Bool = false
    @Published var notificationIntensity: NotificationIntensity = .normal

    init() {
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
        self.currentProjectId = UserDefaults.standard.string(forKey: "currentProjectId")
        self.hasActiveProject = currentProjectId != nil

        if let modeRaw = UserDefaults.standard.string(forKey: "appMode"),
           let mode = AppMode(rawValue: modeRaw) {
            self.appMode = mode
        }
    }

    func setCurrentProject(_ projectId: String) {
        currentProjectId = projectId
        hasActiveProject = true
        UserDefaults.standard.set(projectId, forKey: "currentProjectId")
    }

    func clearProject() {
        currentProjectId = nil
        hasActiveProject = false
        UserDefaults.standard.removeObject(forKey: "currentProjectId")
    }
}

/// Ana sekme türleri
enum MainTab: String, CaseIterable {
    case today
    case plan
    case budget
    case guests
    case studio
    case home

    /// Localized display name
    var displayName: String {
        switch self {
        case .today: return "Bugün"
        case .plan: return "Plan"
        case .budget: return "Bütçe"
        case .guests: return "Davetliler"
        case .studio: return "Stüdyo"
        case .home: return "Ev"
        }
    }

    var icon: String {
        switch self {
        case .today: return "sun.max"
        case .plan: return "calendar.badge.clock"
        case .budget: return "creditcard"
        case .guests: return "person.2"
        case .studio: return "paintpalette"
        case .home: return "house"
        }
    }

    var selectedIcon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .plan: return "calendar.badge.clock"
        case .budget: return "creditcard.fill"
        case .guests: return "person.2.fill"
        case .studio: return "paintpalette.fill"
        case .home: return "house.fill"
        }
    }
}

/// Uygulama modları
enum AppMode: String, CaseIterable {
    case weddingOnly = "wedding"
    case weddingAndHome = "weddingHome"
    case organizer = "organizer"

    var displayName: String {
        switch self {
        case .weddingOnly: return "Sadece Düğün"
        case .weddingAndHome: return "Düğün + Yeni Ev"
        case .organizer: return "Organizatörüm"
        }
    }
}

/// Kullanıcı rolleri
enum UserRole: String, CaseIterable, Codable {
    case owner = "owner"
    case partner = "partner"
    case family = "family"
    case organizer = "organizer"
    case guest = "guest"

    var displayName: String {
        switch self {
        case .owner: return "Çift (Admin)"
        case .partner: return "Partner"
        case .family: return "Aile"
        case .organizer: return "Organizatör"
        case .guest: return "Misafir"
        }
    }

    var canEdit: Bool {
        switch self {
        case .owner, .partner, .organizer: return true
        case .family, .guest: return false
        }
    }

    var canManageUsers: Bool {
        switch self {
        case .owner, .partner: return true
        default: return false
        }
    }
}

/// Bildirim yoğunluğu
enum NotificationIntensity: String, CaseIterable {
    case calm = "calm"
    case normal = "normal"
    case intense = "intense"

    var displayName: String {
        switch self {
        case .calm: return "Sakin"
        case .normal: return "Normal"
        case .intense: return "Yoğun"
        }
    }
}
