import Foundation

// MARK: - Localization Helper
// Type-safe string localization for Nuvia
// Convention: feature.section.element (e.g., dashboard.title, tab.budget)

/// Type-safe localization namespace
public enum L10n {

    // MARK: - Tab Bar

    public enum Tab {
        public static let today = "tab.today".localized
        public static let plan = "tab.plan".localized
        public static let budget = "tab.budget".localized
        public static let guests = "tab.guests".localized
        public static let home = "tab.home".localized
        public static let quickAdd = "tab.quickAdd".localized
    }

    // MARK: - Dashboard

    public enum Dashboard {
        public static let goodMorning = "dashboard.greeting.morning".localized
        public static let goodAfternoon = "dashboard.greeting.afternoon".localized
        public static let goodEvening = "dashboard.greeting.evening".localized
        public static let goodNight = "dashboard.greeting.night".localized

        public static let todaysFocus = "dashboard.section.todaysFocus".localized
        public static let progress = "dashboard.section.progress".localized
        public static let quickAccess = "dashboard.section.quickAccess".localized
        public static let atAGlance = "dashboard.section.atAGlance".localized
        public static let comingUp = "dashboard.section.comingUp".localized
        public static let upcomingTasks = "dashboard.section.upcomingTasks".localized
        public static let weeklyBrief = "dashboard.section.weeklyBrief".localized

        public static let noTasks = "dashboard.empty.noTasks".localized
        public static let noProject = "dashboard.empty.noProject".localized
        public static let noProjectMessage = "dashboard.empty.noProjectMessage".localized
        public static let createProject = "dashboard.action.createProject".localized
        public static let complete = "dashboard.action.complete".localized

        public static let allCaughtUp = "dashboard.state.allCaughtUp".localized
        public static let noUrgentTasks = "dashboard.state.noUrgentTasks".localized
        public static let noDeadlines = "dashboard.state.noDeadlines".localized
        public static let daysToGo = "dashboard.countdown.daysToGo".localized

        public static let tasks = "dashboard.metric.tasks".localized
        public static let budget = "dashboard.metric.budget".localized
        public static let attending = "dashboard.metric.attending".localized
        public static let spent = "dashboard.metric.spent".localized

        public static func daysRemaining(_ days: Int) -> String {
            String(format: "dashboard.countdown.daysRemaining".localized, days)
        }
    }

    // MARK: - Quick Actions

    public enum QuickActions {
        public static let timeline = "quickActions.timeline".localized
        public static let vendors = "quickActions.vendors".localized
        public static let files = "quickActions.files".localized
        public static let zenMode = "quickActions.zenMode".localized
        public static let music = "quickActions.music".localized
        public static let photos = "quickActions.photos".localized
        public static let checkIn = "quickActions.checkIn".localized
        public static let postWedding = "quickActions.postWedding".localized
    }

    // MARK: - Settings

    public enum Settings {
        public static let title = "settings.title".localized
        public static let close = "settings.action.close".localized
        public static let logout = "settings.action.logout".localized

        public enum Section {
            public static let project = "settings.section.project".localized
            public static let organizer = "settings.section.organizer".localized
            public static let app = "settings.section.app".localized
            public static let subscription = "settings.section.subscription".localized
            public static let dataPrivacy = "settings.section.dataPrivacy".localized
            public static let about = "settings.section.about".localized
        }

        public enum Item {
            public static let weddingInfo = "settings.item.weddingInfo".localized
            public static let usersRoles = "settings.item.usersRoles".localized
            public static let notifications = "settings.item.notifications".localized
            public static let multiWedding = "settings.item.multiWedding".localized
            public static let appearance = "settings.item.appearance".localized
            public static let language = "settings.item.language".localized
            public static let premium = "settings.item.premium".localized
            public static let backup = "settings.item.backup".localized
            public static let privacy = "settings.item.privacy".localized
            public static let exportData = "settings.item.exportData".localized
            public static let help = "settings.item.help".localized
            public static let privacyPolicy = "settings.item.privacyPolicy".localized
            public static let version = "settings.item.version".localized
        }

        public static let premiumActive = "settings.premium.active".localized
        public static let premiumUpgrade = "settings.premium.upgrade".localized
    }

    // MARK: - Budget

    public enum Budget {
        public static let title = "budget.title".localized
        public static let summary = "budget.section.summary".localized
        public static let expenses = "budget.section.expenses".localized
        public static let calendar = "budget.section.calendar".localized

        public static let totalBudget = "budget.label.totalBudget".localized
        public static let spent = "budget.label.spent".localized
        public static let remaining = "budget.label.remaining".localized

        public static let addExpense = "budget.action.addExpense".localized
        public static let installment = "budget.installment".localized
    }

    // MARK: - Guests

    public enum Guests {
        public static let title = "guests.title".localized
        public static let addGuest = "guests.action.addGuest".localized
        public static let attending = "guests.status.attending".localized
        public static let notAttending = "guests.status.notAttending".localized
        public static let pending = "guests.status.pending".localized
    }

    // MARK: - Common

    public enum Common {
        public static let ok = "common.ok".localized
        public static let cancel = "common.cancel".localized
        public static let save = "common.save".localized
        public static let delete = "common.delete".localized
        public static let edit = "common.edit".localized
        public static let done = "common.done".localized
        public static let add = "common.add".localized
        public static let search = "common.search".localized
        public static let loading = "common.loading".localized
        public static let error = "common.error".localized
        public static let retry = "common.retry".localized
        public static let seeAll = "common.seeAll".localized
    }

    // MARK: - Quick Add

    public enum QuickAdd {
        public static let title = "quickAdd.title".localized
        public static let prompt = "quickAdd.prompt".localized
        public static let continueAction = "quickAdd.continue".localized
        public static let task = "quickAdd.item.task".localized
        public static let expense = "quickAdd.item.expense".localized
        public static let guest = "quickAdd.item.guest".localized
        public static let shopping = "quickAdd.item.shopping".localized
        public static let note = "quickAdd.item.note".localized
    }

    // MARK: - Weekly Brief

    public enum WeeklyBrief {
        public static let title = "weeklyBrief.title".localized
        public static let thisWeeksTasks = "weeklyBrief.section.tasks".localized
        public static let upcomingPayments = "weeklyBrief.section.payments".localized
        public static let rsvpUpdate = "weeklyBrief.section.rsvp".localized
        public static let proTip = "weeklyBrief.section.tip".localized
    }

    // MARK: - Notifications

    public enum Notifications {
        public static let title = "notifications.title".localized
        public static let empty = "notifications.empty".localized
        public static let markAllRead = "notifications.action.markAllRead".localized
    }

    // MARK: - Invitation Studio

    public enum Studio {
        public static let title = "studio.title".localized
        public static let add = "studio.add".localized
        public static let layers = "studio.layers".localized
        public static let edit = "studio.edit".localized
        public static let templates = "studio.templates".localized
        public static let export = "studio.export".localized
        public static let addElement = "studio.addElement".localized
        public static let text = "studio.text".localized
        public static let shapes = "studio.shapes".localized
        public static let stickers = "studio.stickers".localized
        public static let images = "studio.images".localized
        public static let heading = "studio.heading".localized
        public static let subheading = "studio.subheading".localized
        public static let body = "studio.body".localized
        public static let caption = "studio.caption".localized
        public static func tapToAdd(_ element: String) -> String {
            String(format: "studio.tapToAdd".localized, element)
        }
        public static let chooseFromLibrary = "studio.chooseFromLibrary".localized
        public static let selectPhoto = "studio.selectPhoto".localized
        public static let takePhoto = "studio.takePhoto".localized
        public static let captureImage = "studio.captureImage".localized
        public static let comingSoon = "studio.comingSoon".localized
        public static let format = "studio.format".localized
        public static let resolution = "studio.resolution".localized
        public static let standard = "studio.standard".localized
        public static let high = "studio.high".localized
        public static let print = "studio.print".localized
        public static let exportShare = "studio.exportShare".localized
        public static let exporting = "studio.exporting".localized
    }
}

// MARK: - String Extension

extension String {
    /// Returns localized string from Localizable.strings
    var localized: String {
        NSLocalizedString(self, tableName: nil, bundle: .main, value: self, comment: "")
    }

    /// Returns localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Preview Helper

#if DEBUG
extension L10n {
    /// Print all localization keys for debugging
    static func printAllKeys() {
        print("=== Localization Keys ===")
        print("Tab: today, plan, budget, guests, home")
        print("Dashboard: greeting.*, section.*, empty.*, action.*, countdown.*")
        print("Settings: title, section.*, item.*")
        print("Budget: title, section.*, label.*, action.*")
        print("Guests: title, status.*, action.*")
        print("Common: ok, cancel, save, delete, edit, done, add, search, loading, error, retry")
        print("QuickAdd: title, item.*")
        print("WeeklyBrief: title, section.*")
        print("Notifications: title, empty, action.*")
        print("========================")
    }
}
#endif
