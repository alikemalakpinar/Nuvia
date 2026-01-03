import SwiftUI

/// Splash ekranı
/// Logo + minimal animasyon + "Plan. Budget. Celebrate."
struct SplashView: View {
    @Binding var animationComplete: Bool

    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var ringRotation: Double = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.nuviaMidnight,
                    Color(red: 0.10, green: 0.12, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Logo Container
                ZStack {
                    // Animated ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color.nuviaGoldFallback.opacity(0.3),
                                    Color.nuviaGoldFallback,
                                    Color.nuviaCopper,
                                    Color.nuviaGoldFallback.opacity(0.3)
                                ],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(ringRotation))

                    // Logo
                    VStack(spacing: 4) {
                        // Custom logo icon - two interlocking rings
                        ZStack {
                            Circle()
                                .stroke(Color.nuviaGoldFallback, lineWidth: 3)
                                .frame(width: 50, height: 50)
                                .offset(x: -12)

                            Circle()
                                .stroke(Color.nuviaCopper, lineWidth: 3)
                                .frame(width: 50, height: 50)
                                .offset(x: 12)
                        }

                        Text("Nuvia")
                            .font(.custom("Georgia", size: 36))
                            .fontWeight(.medium)
                            .foregroundColor(.nuviaGoldFallback)
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Tagline
                Text("Plan. Budget. Celebrate.")
                    .font(NuviaTypography.callout())
                    .foregroundColor(.nuviaSecondaryText)
                    .opacity(taglineOpacity)
                    .padding(.top, 8)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Ring rotation
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }

        // Logo fade in and scale
        withAnimation(.easeOut(duration: 0.8)) {
            logoOpacity = 1
            logoScale = 1
        }

        // Tagline fade in (delayed)
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            taglineOpacity = 1
        }

        // Complete animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            animationComplete = true
        }
    }
}

#Preview {
    SplashView(animationComplete: .constant(false))
}
