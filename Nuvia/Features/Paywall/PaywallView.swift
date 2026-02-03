import SwiftUI

// MARK: - Nuvia Gold Paywall
// High-conversion subscription screen
// Designed as a "Membership Card" not a popup

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isProcessing = false
    @State private var showConfetti = false
    @State private var parallaxOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Animated background
            AnimatedGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                        .padding(.top, 60)

                    // Features
                    featuresSection
                        .padding(.top, 48)

                    // Plans
                    plansSection
                        .padding(.top, 40)

                    // CTA
                    ctaSection
                        .padding(.top, 32)

                    // Legal
                    legalSection
                        .padding(.top, 24)
                        .padding(.bottom, 60)
                }
                .padding(.horizontal, 24)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.nuviaSecondaryText)
                            .frame(width: 32, height: 32)
                            .background(Color.nuviaSurface.opacity(0.9))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }

            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 20) {
            // Crown icon with glow
            ZStack {
                Circle()
                    .fill(Color.nuviaChampagne.opacity(0.15))
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(Color.nuviaChampagne.opacity(0.1))
                    .frame(width: 140, height: 140)

                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.etherealGradient)
            }

            VStack(spacing: 12) {
                Text("Nuvia Gold")
                    .font(NuviaTypography.displayMedium())
                    .foregroundColor(.nuviaPrimaryText)

                Text("Plan the wedding of the century")
                    .font(NuviaTypography.bodyLarge())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(spacing: 20) {
            FeatureRow(
                icon: "person.3.fill",
                title: "Unlimited Guests",
                description: "No limits on your guest list"
            )

            FeatureRow(
                icon: "paintpalette.fill",
                title: "Full Invitation Studio",
                description: "All templates, fonts & stickers"
            )

            FeatureRow(
                icon: "sparkles",
                title: "AI Wedding Assistant",
                description: "Smart suggestions & planning help"
            )

            FeatureRow(
                icon: "chart.bar.fill",
                title: "Advanced Analytics",
                description: "Budget insights & RSVP tracking"
            )

            FeatureRow(
                icon: "square.and.arrow.up.fill",
                title: "Premium Exports",
                description: "PDF, Excel & print-ready files"
            )
        }
    }

    // MARK: - Plans Section

    private var plansSection: some View {
        VStack(spacing: 16) {
            // Yearly (Best value)
            PlanCard(
                plan: .yearly,
                isSelected: selectedPlan == .yearly,
                onSelect: { selectedPlan = .yearly }
            )

            // Monthly
            PlanCard(
                plan: .monthly,
                isSelected: selectedPlan == .monthly,
                onSelect: { selectedPlan = .monthly }
            )

            // Lifetime
            PlanCard(
                plan: .lifetime,
                isSelected: selectedPlan == .lifetime,
                onSelect: { selectedPlan = .lifetime }
            )
        }
    }

    // MARK: - CTA Section

    private var ctaSection: some View {
        VStack(spacing: 16) {
            Button {
                subscribe()
            } label: {
                HStack(spacing: 10) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Start Your Journey")
                            .font(NuviaTypography.button())

                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.etherealGradient)
                .foregroundColor(.white)
                .cornerRadius(20)
                .etherealShadow(.medium, colored: .nuviaChampagne)
            }
            .disabled(isProcessing)
            .pressEffect()

            // Trial info
            if selectedPlan == .yearly {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.nuviaSuccess)

                    Text("7-day free trial included")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }
        }
    }

    // MARK: - Legal Section

    private var legalSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button("Restore Purchase") {
                    restorePurchases()
                }
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaSecondaryText)

                Text("•")
                    .foregroundColor(.nuviaTertiaryText)

                Button("Terms") { /* Open terms */ }
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)

                Text("•")
                    .foregroundColor(.nuviaTertiaryText)

                Button("Privacy") { /* Open privacy */ }
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }

            Text("Payment will be charged to your Apple ID account. Subscription renews automatically unless cancelled at least 24 hours before the end of the current period.")
                .font(NuviaTypography.caption2())
                .foregroundColor(.nuviaTertiaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Actions

    private func subscribe() {
        isProcessing = true
        HapticManager.shared.buttonTap()

        // Simulate purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            showConfetti = true
            HapticManager.shared.success()

            // Update premium status
            // appState.isPremium = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
    }

    private func restorePurchases() {
        HapticManager.shared.selection()
        // Implement restore logic
    }
}

// MARK: - Subscription Plan

enum SubscriptionPlan {
    case monthly
    case yearly
    case lifetime

    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    var price: String {
        switch self {
        case .monthly: return "$9.99"
        case .yearly: return "$59.99"
        case .lifetime: return "$149.99"
        }
    }

    var pricePerMonth: String? {
        switch self {
        case .monthly: return nil
        case .yearly: return "$4.99/mo"
        case .lifetime: return "One-time"
        }
    }

    var badge: String? {
        switch self {
        case .yearly: return "BEST VALUE"
        case .lifetime: return "FOREVER"
        default: return nil
        }
    }

    var savings: String? {
        switch self {
        case .yearly: return "Save 50%"
        default: return nil
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.nuviaChampagne)
                .frame(width: 48, height: 48)
                .background(Color.nuviaChampagne.opacity(0.1))
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)

                Text(description)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.nuviaSurface)
        .cornerRadius(16)
        .etherealShadow(.whisper)
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.nuviaChampagne : Color.nuviaTertiaryText.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.nuviaChampagne)
                            .frame(width: 14, height: 14)
                    }
                }

                // Plan info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)

                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.nuviaChampagne)
                                .cornerRadius(4)
                        }
                    }

                    if let pricePerMonth = plan.pricePerMonth {
                        Text(pricePerMonth)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }

                Spacer()

                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.price)
                        .font(NuviaTypography.title3())
                        .foregroundColor(.nuviaPrimaryText)

                    if let savings = plan.savings {
                        Text(savings)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSuccess)
                    }
                }
            }
            .padding(20)
            .background(
                ZStack {
                    Color.nuviaSurface

                    if isSelected {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.nuviaChampagne.opacity(0.05))
                    }
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.nuviaChampagne : Color.nuviaTertiaryBackground,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .etherealShadow(isSelected ? .soft : .none)
        }
        .pressEffect()
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "FDFCFB"),
                Color(hex: "FAF8F5"),
                Color(hex: "F9F5F0"),
                Color(hex: "FDFCFB")
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiPiece(particle: particle)
            }
        }
        .onAppear {
            generateParticles()
        }
    }

    private func generateParticles() {
        let colors: [Color] = [.nuviaChampagne, .nuviaRoseDust, .nuviaSage, .nuviaDustyBlue]

        for i in 0..<50 {
            let particle = ConfettiParticle(
                id: i,
                color: colors.randomElement() ?? .nuviaChampagne,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                delay: Double.random(in: 0...0.5)
            )
            particles.append(particle)
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let x: CGFloat
    let delay: Double
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    @State private var y: CGFloat = -50
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: 8, height: 8)
            .position(x: particle.x, y: y)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 2).delay(particle.delay)) {
                    y = UIScreen.main.bounds.height + 50
                    rotation = Double.random(in: 180...720)
                }
                withAnimation(.easeIn(duration: 1.5).delay(particle.delay + 0.5)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
        .environmentObject(AppState())
}
