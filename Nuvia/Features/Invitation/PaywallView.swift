import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.nuviaChampagne)
                            .padding(.top, 20)
                        
                        Text("Unlock Premium")
                            .font(NuviaTypography.displayMedium())
                            .foregroundColor(.nuviaPrimaryText)
                        
                        Text("Create stunning invitations with unlimited access to all premium features")
                            .font(NuviaTypography.body())
                            .foregroundColor(.nuviaSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Features
                    VStack(spacing: 16) {
                        PremiumFeatureRow(
                            icon: "star.fill",
                            title: "Premium Templates",
                            description: "Access luxury, modern, classic & romantic designs"
                        )
                        
                        PremiumFeatureRow(
                            icon: "sparkles",
                            title: "Premium Stickers",
                            description: "Exclusive decorative elements and graphics"
                        )
                        
                        PremiumFeatureRow(
                            icon: "paintpalette.fill",
                            title: "Custom Backgrounds",
                            description: "Beautiful color palettes and patterns"
                        )
                        
                        PremiumFeatureRow(
                            icon: "square.and.arrow.up",
                            title: "Export Designs",
                            description: "Download high-quality invitations"
                        )
                        
                        PremiumFeatureRow(
                            icon: "checkmark.seal.fill",
                            title: "No Watermark",
                            description: "Professional, clean exports"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Plans
                    VStack(spacing: 12) {
                        PlanCard(
                            plan: .yearly,
                            isSelected: selectedPlan == .yearly
                        ) {
                            selectedPlan = .yearly
                        }
                        
                        PlanCard(
                            plan: .monthly,
                            isSelected: selectedPlan == .monthly
                        ) {
                            selectedPlan = .monthly
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // CTA
                    NuviaPrimaryButton(
                        isLoading ? "Processing..." : "Start Free Trial",
                        icon: "arrow.right"
                    ) {
                        startTrial()
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 20)
                    
                    // Fine print
                    VStack(spacing: 8) {
                        Text("7-day free trial, then \(selectedPlan.price) per \(selectedPlan.duration)")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                        
                        Text("Cancel anytime. Auto-renews unless cancelled.")
                            .font(NuviaTypography.caption2())
                            .foregroundColor(.nuviaSecondaryText.opacity(0.7))
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.nuviaBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }
            }
        }
    }
    
    private func startTrial() {
        isLoading = true
        HapticManager.shared.impact()
        
        // TODO: Integrate with StoreKit for actual subscription
        // For now, simulate a purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            appState.isPremium = true
            HapticManager.shared.success()
            isLoading = false
            dismiss()
        }
    }
}

// MARK: - Premium Feature Row

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.nuviaChampagne)
                .frame(width: 40, height: 40)
                .background(Color.nuviaSurface)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(NuviaTypography.title3())
                    .foregroundColor(.nuviaPrimaryText)
                
                Text(description)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }
            
            Spacer()
        }
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: PremiumPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(NuviaTypography.title2())
                            .foregroundColor(.nuviaPrimaryText)
                        
                        if plan == .yearly {
                            Text("BEST VALUE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.nuviaChampagne)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text("\(plan.price)/\(plan.duration)")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                    
                    if let savings = plan.savings {
                        Text(savings)
                            .font(NuviaTypography.caption2())
                            .foregroundColor(.nuviaChampagne)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .nuviaChampagne : .nuviaSecondaryText.opacity(0.3))
            }
            .padding(20)
            .background(Color.nuviaSurface)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.nuviaChampagne : Color.clear, lineWidth: 2)
            )
            .etherealShadow(isSelected ? .medium : .soft)
        }
        .pressEffect()
    }
}

// MARK: - Premium Plan Model

enum PremiumPlan {
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var price: String {
        switch self {
        case .monthly: return "$9.99"
        case .yearly: return "$59.99"
        }
    }
    
    var duration: String {
        switch self {
        case .monthly: return "month"
        case .yearly: return "year"
        }
    }
    
    var savings: String? {
        switch self {
        case .monthly: return nil
        case .yearly: return "Save $60/year vs monthly"
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
        .environmentObject(AppState())
}
