import SwiftUI
import SwiftData

/// Ana Tab Bar navigasyonu
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var showQuickAdd = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $appState.selectedTab) {
                TodayDashboardView()
                    .tag(MainTab.today)

                TimelineView()
                    .tag(MainTab.plan)

                BudgetHomeView()
                    .tag(MainTab.budget)

                GuestListView()
                    .tag(MainTab.guests)

                if appState.appMode == .weddingAndHome {
                    HomeSetupDashboardView()
                        .tag(MainTab.home)
                }
            }
            .tint(.nuviaGoldFallback)

            // Custom Tab Bar
            CustomTabBar(
                selectedTab: $appState.selectedTab,
                showHomeTab: appState.appMode == .weddingAndHome,
                onQuickAdd: { showQuickAdd = true }
            )
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showQuickAdd) {
            QuickAddSheet()
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    let showHomeTab: Bool
    let onQuickAdd: () -> Void

    private var visibleTabs: [MainTab] {
        var tabs: [MainTab] = [.today, .plan, .budget, .guests]
        if showHomeTab {
            tabs.append(.home)
        }
        return tabs
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(visibleTabs, id: \.self) { tab in
                if tab == .budget {
                    // Quick add button in the middle
                    Spacer()
                    QuickAddButton(action: onQuickAdd)
                    Spacer()
                }

                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(
            Rectangle()
                .fill(Color.nuviaCharcoal)
                .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
                .ignoresSafeArea()
        )
    }
}

struct TabBarButton: View {
    let tab: MainTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .nuviaGoldFallback : .nuviaSecondaryText)

                Text(tab.rawValue)
                    .font(NuviaTypography.caption2())
                    .foregroundColor(isSelected ? .nuviaGoldFallback : .nuviaSecondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct QuickAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.nuviaGradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: .nuviaGoldFallback.opacity(0.4), radius: 8, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.nuviaMidnight)
            }
        }
        .offset(y: -20)
    }
}

// MARK: - Quick Add Sheet

struct QuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: QuickAddType?

    enum QuickAddType: String, CaseIterable {
        case task = "Görev"
        case expense = "Harcama"
        case guest = "Misafir"
        case shopping = "Alışveriş"
        case note = "Not"

        var icon: String {
            switch self {
            case .task: return "checkmark.circle"
            case .expense: return "creditcard"
            case .guest: return "person.badge.plus"
            case .shopping: return "cart.badge.plus"
            case .note: return "note.text.badge.plus"
            }
        }

        var color: Color {
            switch self {
            case .task: return .nuviaInfo
            case .expense: return .nuviaSuccess
            case .guest: return .categoryDress
            case .shopping: return .nuviaWarning
            case .note: return .categoryVenue
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Ne eklemek istersiniz?")
                    .font(NuviaTypography.title2())
                    .foregroundColor(.nuviaPrimaryText)
                    .padding(.top, 8)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(QuickAddType.allCases, id: \.self) { type in
                        QuickAddTypeCard(type: type, isSelected: selectedType == type) {
                            selectedType = type
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                if selectedType != nil {
                    NuviaPrimaryButton("Devam", icon: "arrow.right") {
                        // Navigate to specific add screen
                        dismiss()
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .background(Color.nuviaBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.nuviaSecondaryText)
                            .font(.system(size: 24))
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct QuickAddTypeCard: View {
    let type: QuickAddSheet.QuickAddType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(type.color)

                Text(type.rawValue)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.nuviaCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
