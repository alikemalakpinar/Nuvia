import SwiftUI

/// Premium Splash Screen
/// Glow + spring animations + gold particles
struct SplashView: View {
    @Binding var animationComplete: Bool

    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var ringRotation: Double = -360
    @State private var glowScale: CGFloat = 0.5
    @State private var glowOpacity: Double = 0
    @State private var ring1Opacity: Double = 0
    @State private var ring2Opacity: Double = 0
    @State private var versionOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.nuviaMidnight,
                    Color(red: 0.08, green: 0.10, blue: 0.18),
                    Color(red: 0.10, green: 0.12, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle particle field
            GeometryReader { geo in
                ForEach(0..<12, id: \.self) { i in
                    Circle()
                        .fill(Color.nuviaGoldFallback.opacity(Double.random(in: 0.03...0.08)))
                        .frame(width: CGFloat.random(in: 2...6))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .opacity(taglineOpacity)
                }
            }

            VStack(spacing: 40) {
                Spacer()

                // Logo Container
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.nuviaGoldFallback.opacity(0.2),
                                    Color.nuviaGoldFallback.opacity(0.05),
                                    Color.nuviaGoldFallback.opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(glowScale)
                        .opacity(glowOpacity)

                    // Animated ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color.nuviaGoldFallback.opacity(0.1),
                                    Color.nuviaGoldFallback.opacity(0.8),
                                    Color.nuviaCopper,
                                    Color.nuviaGoldFallback.opacity(0.1)
                                ],
                                center: .center
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(ringRotation))

                    // Inner subtle ring
                    Circle()
                        .stroke(Color.nuviaGoldFallback.opacity(0.15), lineWidth: 0.5)
                        .frame(width: 120, height: 120)

                    // Logo: interlocking rings
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.nuviaGoldFallback, Color.nuviaGoldFallback.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 50, height: 50)
                                .offset(x: -12)
                                .opacity(ring1Opacity)

                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.nuviaCopper, Color.nuviaCopper.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 50, height: 50)
                                .offset(x: 12)
                                .opacity(ring2Opacity)
                        }

                        Text("Nuvia")
                            .font(.custom("Georgia", size: 38))
                            .fontWeight(.medium)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.nuviaGoldFallback, Color.nuviaCopper],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Tagline with letter spacing
                Text("Plan. Budget. Celebrate.")
                    .font(NuviaTypography.callout())
                    .tracking(2)
                    .foregroundColor(.nuviaSecondaryText.opacity(0.8))
                    .opacity(taglineOpacity)

                Spacer()

                // Version
                Text("v1.0")
                    .font(NuviaTypography.caption2())
                    .foregroundColor(.nuviaTertiaryText.opacity(0.4))
                    .opacity(versionOpacity)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Phase 1: Glow appears (0s)
        withAnimation(.easeOut(duration: 0.8)) {
            glowOpacity = 1
            glowScale = 1.0
        }

        // Phase 2: Logo springs in (0.2s)
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.15)) {
            logoScale = 1
            logoOpacity = 1
        }

        // Phase 3: Rings fade in sequentially
        withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
            ring1Opacity = 1
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            ring2Opacity = 1
        }

        // Phase 4: Ring starts rotating
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            ringRotation = 0
        }

        // Phase 5: Tagline (0.7s)
        withAnimation(.easeOut(duration: 0.8).delay(0.7)) {
            taglineOpacity = 1
        }

        // Phase 6: Version
        withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
            versionOpacity = 1
        }

        // Transition out
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.4)) {
                animationComplete = true
            }
        }
    }
}

#Preview {
    SplashView(animationComplete: .constant(false))
}
