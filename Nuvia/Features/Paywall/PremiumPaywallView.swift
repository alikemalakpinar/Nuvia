import SwiftUI
import CoreMotion

// MARK: - Premium Paywall View
// Luxurious 3D membership card with CoreMotion gyroscope shimmer
// The crown jewel of the monetization experience

struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var motionManager = MotionManager()

    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var isProcessing = false
    @State private var showSuccessAnimation = false

    var body: some View {
        ZStack {
            // Background
            backgroundGradient

            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignTokens.Spacing.xl) {
                    // Header
                    headerSection

                    // 3D Membership Card
                    MembershipCard3D(
                        motionManager: motionManager,
                        plan: selectedPlan
                    )
                    .padding(.vertical, DesignTokens.Spacing.md)

                    // Plan selector
                    planSelector

                    // Features list
                    featuresSection

                    // CTA Button
                    ctaButton

                    // Legal text
                    legalText
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.xl)
                .padding(.bottom, DesignTokens.Spacing.xxxl)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    closeButton
                }
                Spacer()
            }
            .padding()

            // Success overlay
            if showSuccessAnimation {
                successOverlay
            }
        }
        .onAppear {
            motionManager.startUpdates()
        }
        .onDisappear {
            motionManager.stopUpdates()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "0D0D0F"),
                    Color(hex: "1A1A1E"),
                    Color(hex: "0D0D0F")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Animated particles
            ParticleField()
                .opacity(0.6)

            // Spotlight effect
            RadialGradient(
                colors: [
                    Color.nuviaChampagne.opacity(0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            // Crown icon with glow
            ZStack {
                Circle()
                    .fill(Color.nuviaChampagne.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)

                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("Unlock Premium")
                .font(NuviaTypography.displayMedium())
                .foregroundColor(.white)

            Text("Elevate your wedding planning experience")
                .font(NuviaTypography.body())
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Plan Selector

    private var planSelector: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ForEach(PremiumPlan.allCases, id: \.self) { plan in
                PlanButton(
                    plan: plan,
                    isSelected: selectedPlan == plan
                ) {
                    withAnimation(DesignTokens.Animation.snappy) {
                        selectedPlan = plan
                    }
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ForEach(PremiumFeature.allFeatures, id: \.title) { feature in
                PaywallPremiumFeatureRow(feature: feature)
            }
        }
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            startPurchase()
        } label: {
            HStack(spacing: DesignTokens.Spacing.sm) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "sparkles")
                }

                Text(isProcessing ? "Processing..." : "Start Free Trial")
                    .font(NuviaTypography.button())
            }
            .foregroundColor(Color(hex: "0D0D0F"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                LinearGradient(
                    colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
            .shadow(color: Color.nuviaChampagne.opacity(0.4), radius: 16, x: 0, y: 8)
        }
        .disabled(isProcessing)
        .padding(.top, DesignTokens.Spacing.md)
    }

    // MARK: - Legal Text

    private var legalText: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text("7-day free trial, then \(selectedPlan.priceString)")
                .font(NuviaTypography.footnote())
                .foregroundColor(.white.opacity(0.5))

            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Terms") {}
                    .font(NuviaTypography.caption())
                    .foregroundColor(.white.opacity(0.4))

                Text("•")
                    .foregroundColor(.white.opacity(0.3))

                Button("Privacy") {}
                    .font(NuviaTypography.caption())
                    .foregroundColor(.white.opacity(0.4))

                Text("•")
                    .foregroundColor(.white.opacity(0.3))

                Button("Restore") {}
                    .font(NuviaTypography.caption())
                    .foregroundColor(.white.opacity(0.4))
            }
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
        }
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.lg) {
                // Checkmark animation
                ZStack {
                    Circle()
                        .fill(Color.nuviaChampagne.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text("Welcome to Premium!")
                    .font(NuviaTypography.displaySmall())
                    .foregroundColor(.white)

                Text("Your wedding planning just got magical")
                    .font(NuviaTypography.body())
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .transition(.opacity)
    }

    // MARK: - Actions

    private func startPurchase() {
        isProcessing = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // Simulate purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            withAnimation {
                showSuccessAnimation = true
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
    }
}

// MARK: - Motion Manager

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()

    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var yaw: Double = 0

    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }

            withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.8)) {
                self?.pitch = motion.attitude.pitch
                self?.roll = motion.attitude.roll
                self?.yaw = motion.attitude.yaw
            }
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - 3D Membership Card

struct MembershipCard3D: View {
    @ObservedObject var motionManager: MotionManager
    let plan: PremiumPlan

    @State private var shimmerOffset: CGFloat = -1
    @State private var isHovered = false

    private var rotationX: Double {
        motionManager.pitch * 15
    }

    private var rotationY: Double {
        motionManager.roll * 15
    }

    var body: some View {
        ZStack {
            // Card base
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "2C2C2C"),
                            Color(hex: "1A1A1A"),
                            Color(hex: "2C2C2C")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Metallic border
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.nuviaChampagne.opacity(0.6),
                            Color.nuviaRoseGold.opacity(0.3),
                            Color.nuviaChampagne.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )

            // Shimmer effect
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0)
                        ],
                        startPoint: UnitPoint(x: shimmerOffset, y: shimmerOffset),
                        endPoint: UnitPoint(x: shimmerOffset + 0.5, y: shimmerOffset + 0.5)
                    )
                )

            // Card content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NUVIA")
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .tracking(4)
                            .foregroundColor(.white.opacity(0.5))

                        Text("Premium Member")
                            .font(NuviaTypography.title2())
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Premium badge
                    Image(systemName: "crown.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Spacer()

                // Plan info
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(plan.name.uppercased())
                        .font(.system(size: 10, weight: .semibold, design: .default))
                        .tracking(2)
                        .foregroundColor(.nuviaChampagne)

                    Text(plan.priceString)
                        .font(NuviaTypography.title1())
                        .foregroundColor(.white)
                }

                // Card number style decoration
                HStack {
                    ForEach(0..<4, id: \.self) { _ in
                        Text("****")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .padding(DesignTokens.Spacing.xl)
        }
        .frame(width: 320, height: 200)
        .rotation3DEffect(
            .degrees(rotationX),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.5
        )
        .rotation3DEffect(
            .degrees(rotationY),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .shadow(
            color: Color.nuviaChampagne.opacity(0.3),
            radius: 30,
            x: CGFloat(rotationY),
            y: CGFloat(-rotationX)
        )
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.5
            }
        }
    }
}

// MARK: - Plan Button

struct PlanButton: View {
    let plan: PremiumPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.Spacing.sm) {
                // Savings badge
                if plan.savingsPercentage > 0 {
                    Text("Save \(plan.savingsPercentage)%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "0D0D0F"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.nuviaChampagne)
                        .clipShape(Capsule())
                } else {
                    Spacer()
                        .frame(height: 20)
                }

                // Plan name
                Text(plan.name)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                // Price
                VStack(spacing: 2) {
                    Text(plan.priceString)
                        .font(NuviaTypography.title3())
                        .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                    Text(plan.billingCycle)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                            .stroke(
                                isSelected ?
                                    LinearGradient(
                                        colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(colors: [Color.white.opacity(0.2)], startPoint: .leading, endPoint: .trailing),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
    }
}

// MARK: - Paywall Premium Feature Row

struct PaywallPremiumFeatureRow: View {
    let feature: PremiumFeature

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(feature.iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: feature.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(feature.iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.white)

                Text(feature.subtitle)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.nuviaChampagne)
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Particle Field

struct ParticleField: View {
    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: particle.blur)
            }
            .onAppear {
                generateParticles(in: geo.size)
                animateParticles()
            }
        }
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<30).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 2...6),
                color: [Color.nuviaChampagne, Color.nuviaRoseGold, Color.white].randomElement()!.opacity(Double.random(in: 0.1...0.4)),
                blur: CGFloat.random(in: 0...2)
            )
        }
    }

    private func animateParticles() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            particles = particles.map { particle in
                var newParticle = particle
                newParticle.position.y -= 600
                return newParticle
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let color: Color
    let blur: CGFloat
}

// MARK: - Premium Plan

enum PremiumPlan: String, CaseIterable {
    case monthly = "Monthly"
    case yearly = "Yearly"
    case lifetime = "Lifetime"

    var name: String { rawValue }

    var priceString: String {
        switch self {
        case .monthly:  return "$9.99"
        case .yearly:   return "$59.99"
        case .lifetime: return "$149.99"
        }
    }

    var billingCycle: String {
        switch self {
        case .monthly:  return "per month"
        case .yearly:   return "per year"
        case .lifetime: return "one time"
        }
    }

    var savingsPercentage: Int {
        switch self {
        case .monthly:  return 0
        case .yearly:   return 50
        case .lifetime: return 75
        }
    }
}

// MARK: - Premium Feature

struct PremiumFeature {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    @MainActor
    static let allFeatures: [PremiumFeature] = [
        PremiumFeature(
            icon: "wand.and.stars",
            iconColor: .nuviaChampagne,
            title: "Unlimited Invitations",
            subtitle: "Create as many designs as you want"
        ),
        PremiumFeature(
            icon: "paintpalette.fill",
            iconColor: .nuviaRoseGold,
            title: "Premium Templates",
            subtitle: "Access 100+ exclusive designs"
        ),
        PremiumFeature(
            icon: "square.and.arrow.up",
            iconColor: .nuviaSage,
            title: "High-Res Export",
            subtitle: "Print-quality PDF & PNG export"
        ),
        PremiumFeature(
            icon: "moon.fill",
            iconColor: .nuviaDustyBlue,
            title: "Dark Romance Theme",
            subtitle: "Exclusive premium theme"
        ),
        PremiumFeature(
            icon: "sparkles",
            iconColor: .nuviaWisteria,
            title: "Premium Stickers",
            subtitle: "500+ exclusive decorations"
        ),
        PremiumFeature(
            icon: "icloud.fill",
            iconColor: .nuviaTerracotta,
            title: "Cloud Backup",
            subtitle: "Never lose your designs"
        )
    ]
}

// MARK: - Preview

#Preview("Premium Paywall") {
    PremiumPaywallView()
}
