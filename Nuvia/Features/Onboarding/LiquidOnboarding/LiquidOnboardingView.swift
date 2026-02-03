import SwiftUI
import AVKit
import Combine

// MARK: - Liquid Onboarding
// Premium onboarding experience with video background and typewriter effect

struct LiquidOnboardingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = LiquidOnboardingViewModel()
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Video Background
            VideoBackgroundView(videoName: viewModel.pages[currentPage].videoName)
                .ignoresSafeArea()

            // Gradient overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                Spacer()

                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(viewModel.pages.indices, id: \.self) { index in
                        OnboardingPageContent(
                            page: viewModel.pages[index],
                            isActive: currentPage == index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 350)

                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(viewModel.pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(DesignTokens.Animation.smooth, value: currentPage)
                    }
                }
                .padding(.top, DesignTokens.Spacing.lg)

                Spacer()
                    .frame(height: DesignTokens.Spacing.xxl)

                // Action Buttons
                VStack(spacing: DesignTokens.Spacing.md) {
                    if currentPage == viewModel.pages.count - 1 {
                        // Get Started Button
                        Button {
                            HapticEngine.shared.impact(.medium)
                            withAnimation(DesignTokens.Animation.smooth) {
                                appState.hasCompletedOnboarding = true
                            }
                        } label: {
                            Text("Get Started")
                                .font(DSTypography.button)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
                        }
                        .pressable()
                        .entrance(.scale, delay: 0.3)
                    } else {
                        // Continue Button
                        Button {
                            HapticEngine.shared.impact(.light)
                            withAnimation(DesignTokens.Animation.smooth) {
                                currentPage += 1
                            }
                        } label: {
                            Text("Continue")
                                .font(DSTypography.button)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
                        }
                        .pressable()
                    }

                    // Skip Button
                    if currentPage < viewModel.pages.count - 1 {
                        Button {
                            HapticEngine.shared.selection()
                            withAnimation(DesignTokens.Animation.smooth) {
                                currentPage = viewModel.pages.count - 1
                            }
                        } label: {
                            Text("Skip")
                                .font(DSTypography.body(.regular))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.xxl)
            }
        }
        .onChange(of: currentPage) { _, _ in
            HapticEngine.shared.selection()
        }
    }
}

// MARK: - Onboarding Page Content
struct OnboardingPageContent: View {
    let page: OnboardingPage
    let isActive: Bool

    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showDescription = false

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.white)
                .opacity(showTitle ? 1 : 0)
                .scaleEffect(showTitle ? 1 : 0.8)

            // Title with Typewriter Effect
            TypewriterText(
                text: page.title,
                isActive: isActive && showTitle,
                speed: 0.05
            )
            .font(DSTypography.display(.small))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)

            // Subtitle
            Text(page.subtitle)
                .font(DSTypography.body(.large))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .opacity(showSubtitle ? 1 : 0)
                .offset(y: showSubtitle ? 0 : 20)

            // Description
            if let description = page.description {
                Text(description)
                    .font(DSTypography.body(.small))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .opacity(showDescription ? 1 : 0)
                    .offset(y: showDescription ? 0 : 10)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.xl)
        .onChange(of: isActive) { _, active in
            if active {
                animateIn()
            } else {
                resetAnimation()
            }
        }
        .onAppear {
            if isActive {
                animateIn()
            }
        }
    }

    private func animateIn() {
        showTitle = false
        showSubtitle = false
        showDescription = false

        withAnimation(DesignTokens.Animation.smooth.delay(0.1)) {
            showTitle = true
        }
        withAnimation(DesignTokens.Animation.smooth.delay(0.4)) {
            showSubtitle = true
        }
        withAnimation(DesignTokens.Animation.smooth.delay(0.7)) {
            showDescription = true
        }
    }

    private func resetAnimation() {
        showTitle = false
        showSubtitle = false
        showDescription = false
    }
}

// MARK: - Typewriter Text
struct TypewriterText: View {
    let text: String
    let isActive: Bool
    let speed: Double

    @State private var displayedText = ""
    @State private var currentIndex = 0

    var body: some View {
        Text(displayedText)
            .onChange(of: isActive) { _, active in
                if active {
                    startTyping()
                } else {
                    resetTyping()
                }
            }
            .onAppear {
                if isActive {
                    startTyping()
                }
            }
    }

    private func startTyping() {
        displayedText = ""
        currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText += String(text[index])
                currentIndex += 1

                // Haptic on each character (subtle)
                if currentIndex % 3 == 0 {
                    HapticEngine.shared.impact(.soft)
                }
            } else {
                timer.invalidate()
            }
        }
    }

    private func resetTyping() {
        displayedText = ""
        currentIndex = 0
    }
}

// MARK: - Video Background View
struct VideoBackgroundView: View {
    let videoName: String?

    var body: some View {
        if let videoName = videoName {
            VideoPlayerView(videoName: videoName)
        } else {
            // Fallback animated gradient
            AnimatedGradientView()
        }
    }
}

// MARK: - Video Player View
struct VideoPlayerView: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> UIView {
        let view = VideoPlayerUIView(videoName: videoName)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class VideoPlayerUIView: UIView {
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?

    init(videoName: String) {
        super.init(frame: .zero)
        setupPlayer(videoName: videoName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlayer(videoName: String) {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            return
        }

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer(playerItem: item)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)

        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = bounds
        layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer

        queuePlayer.isMuted = true
        queuePlayer.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}

// MARK: - Animated Gradient View (Fallback)
struct AnimatedGradientView: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "D4AF37").opacity(0.8),
                Color(hex: "9CAF88").opacity(0.6),
                Color(hex: "D4A5A5").opacity(0.7),
                Color(hex: "7BA3B8").opacity(0.6)
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let description: String?
    let videoName: String?

    static let defaultPages: [OnboardingPage] = [
        OnboardingPage(
            icon: "heart.fill",
            title: "Plan Your Dream Wedding",
            subtitle: "Everything you need in one beautiful app",
            description: "From guest lists to vendor management, we've got you covered",
            videoName: nil
        ),
        OnboardingPage(
            icon: "paintpalette.fill",
            title: "Create Stunning Invitations",
            subtitle: "Design like a pro with our Invitation Studio",
            description: "Drag, drop, and customize with premium templates",
            videoName: nil
        ),
        OnboardingPage(
            icon: "person.3.fill",
            title: "Manage Your Guests",
            subtitle: "RSVP tracking made simple",
            description: "Real-time updates and seating arrangements",
            videoName: nil
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Let's Begin",
            subtitle: "Your perfect wedding starts now",
            description: nil,
            videoName: nil
        )
    ]
}

// MARK: - Liquid Onboarding ViewModel
@MainActor
class LiquidOnboardingViewModel: ObservableObject {
    @Published var pages: [OnboardingPage] = OnboardingPage.defaultPages
}

// MARK: - Preview
#Preview {
    LiquidOnboardingView()
        .environmentObject(AppState())
}
