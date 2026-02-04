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
                    .toolbar(.hidden, for: .tabBar)

                TimelineView()
                    .tag(MainTab.plan)
                    .toolbar(.hidden, for: .tabBar)

                BudgetHomeView()
                    .tag(MainTab.budget)
                    .toolbar(.hidden, for: .tabBar)

                GuestListView()
                    .tag(MainTab.guests)
                    .toolbar(.hidden, for: .tabBar)

                InvitationStudioView()
                    .tag(MainTab.studio)
                    .toolbar(.hidden, for: .tabBar)

                if appState.appMode == .weddingAndHome {
                    HomeSetupDashboardView()
                        .tag(MainTab.home)
                        .toolbar(.hidden, for: .tabBar)
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

// MARK: - Floating Glass Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    let showHomeTab: Bool
    let onQuickAdd: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var leftTabs: [MainTab] {
        [.today, .plan]
    }

    private var rightTabs: [MainTab] {
        var tabs: [MainTab] = [.budget, .guests, .studio]
        if showHomeTab {
            tabs.append(.home)
        }
        return tabs
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left side tabs
            HStack(spacing: DSSpacing.xxs) {
                ForEach(leftTabs, id: \.self) { tab in
                    FloatingTabButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        HapticManager.shared.selection()
                        withAnimation(DesignTokens.Animation.snappy) {
                            selectedTab = tab
                        }
                    }
                }
            }

            Spacer()

            // Center Quick Add Button
            QuickAddButton(action: onQuickAdd)

            Spacer()

            // Right side tabs
            HStack(spacing: DSSpacing.xxs) {
                ForEach(rightTabs, id: \.self) { tab in
                    FloatingTabButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        HapticManager.shared.selection()
                        withAnimation(DesignTokens.Animation.snappy) {
                            selectedTab = tab
                        }
                    }
                }
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(
            // Floating glass capsule
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.15 : 0.6),
                                    Color.white.opacity(colorScheme == .dark ? 0.05 : 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, DSSpacing.md)
        .padding(.bottom, DSSpacing.sm)
    }
}

// MARK: - Floating Tab Button

struct FloatingTabButton: View {
    let tab: MainTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AnyShapeStyle(Color.nuviaGradient) : AnyShapeStyle(Color.nuviaTertiaryText))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(DesignTokens.Animation.bouncy, value: isSelected)

                Text(tab.displayName)
                    .font(DSTypography.captionSmall)
                    .foregroundColor(isSelected ? .nuviaGoldFallback : .nuviaTertiaryText)
                    .lineLimit(1)
            }
            .frame(width: 52, height: 44)
            .background(
                // Subtle highlight for selected tab
                Capsule()
                    .fill(isSelected ? Color.nuviaGoldFallback.opacity(0.12) : Color.clear)
                    .animation(DesignTokens.Animation.snappy, value: isSelected)
            )
        }
        .accessibilityLabel(tab.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
                // Outer glow ring
                Circle()
                    .fill(Color.nuviaGoldFallback.opacity(0.15))
                    .frame(width: 64, height: 64)

                // Main button
                Circle()
                    .fill(Color.nuviaGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.nuviaGoldFallback.opacity(0.4), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)

                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .pressEffect()
        .offset(y: -16)
        .accessibilityLabel("Hızlı Ekle")
    }
}

// MARK: - Quick Add Sheet

struct QuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var selectedType: QuickAddType?

    enum QuickAddType: CaseIterable {
        case task
        case expense
        case guest
        case shopping
        case note

        var displayName: String {
            switch self {
            case .task: return "Görev"
            case .expense: return "Harcama"
            case .guest: return "Davetli"
            case .shopping: return "Alışveriş"
            case .note: return "Not"
            }
        }

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
            VStack(spacing: DSSpacing.lg) {
                Text("Ne eklemek istersiniz?")
                    .font(DSTypography.heading2)
                    .foregroundColor(DSColors.textPrimary)
                    .padding(.top, DSSpacing.xs)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
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
            .background(DSColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DSColors.textSecondary)
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
            VStack(spacing: DSSpacing.sm) {
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? type.color : .nuviaSecondaryText)

                Text(type.displayName)
                    .font(DSTypography.bodyBold)
                    .foregroundColor(DSColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(DSColors.surface)
            .cornerRadius(DSRadii.card)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.card)
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
