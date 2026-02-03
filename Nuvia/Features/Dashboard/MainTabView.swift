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

// MARK: - Custom Tab Bar (Clean & Light)

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
                    Spacer()
                    QuickAddButton(action: onQuickAdd)
                    Spacer()
                }

                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    HapticManager.shared.selection()
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            // Clean, light background
            Color.nuviaCardBackground
                .ignoresSafeArea()
                .shadow(color: Color.black.opacity(0.06), radius: 12, y: -4)
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
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .nuviaGoldFallback : .nuviaTertiaryText)
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

                Text(tab.rawValue)
                    .font(NuviaTypography.caption2())
                    .foregroundColor(isSelected ? .nuviaGoldFallback : .nuviaTertiaryText)

                // Active indicator - ince ve zarif
                Capsule()
                    .fill(Color.nuviaGoldFallback)
                    .frame(width: isSelected ? 20 : 0, height: 3)
                    .animation(.spring(response: 0.3), value: isSelected)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(tab.rawValue)
    }
}

struct QuickAddButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.buttonTap()
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.nuviaGradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.nuviaGoldFallback.opacity(0.3), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .pressEffect()
        .offset(y: -20)
        .accessibilityLabel("Hızlı ekle")
    }
}

// MARK: - Quick Add Sheet

struct QuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var selectedType: QuickAddType?
    @State private var showAddTask = false
    @State private var showAddExpense = false
    @State private var showAddGuest = false

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
            case .task: return .nuviaInfoStatic
            case .expense: return .nuviaSuccessStatic
            case .guest: return .categoryDress
            case .shopping: return .nuviaWarningStatic
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
                        switch selectedType {
                        case .task:
                            dismiss()
                            appState.selectedTab = .plan
                        case .expense:
                            dismiss()
                            appState.selectedTab = .budget
                        case .guest:
                            dismiss()
                            appState.selectedTab = .guests
                        case .shopping:
                            dismiss()
                            appState.selectedTab = .plan
                        case .note:
                            dismiss()
                            appState.selectedTab = .today
                        case .none:
                            break
                        }
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
        Button {
            HapticManager.shared.selection()
            action()
        } label: {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? type.color : .nuviaSecondaryText)

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
                    .stroke(
                        isSelected ? type.color : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(color: isSelected ? type.color.opacity(0.15) : Color.black.opacity(0.04), radius: isSelected ? 12 : 8, x: 0, y: 4)
        }
        .pressEffect()
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
