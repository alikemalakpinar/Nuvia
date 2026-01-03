import SwiftUI
import SwiftData

/// Root View - Uygulama giriş noktası
/// Splash → Onboarding → Main App akışını yönetir
struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true
    @State private var splashAnimationComplete = false

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(animationComplete: $splashAnimationComplete)
                    .transition(.opacity)
            } else if !appState.isOnboardingComplete {
                OnboardingContainerView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            } else if !appState.hasActiveProject {
                CreateProjectView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: appState.isOnboardingComplete)
        .animation(.easeInOut(duration: 0.4), value: appState.hasActiveProject)
        .onChange(of: splashAnimationComplete) { _, complete in
            if complete {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
        .environmentObject(NotificationManager())
}
