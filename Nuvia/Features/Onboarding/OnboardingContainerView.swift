import SwiftUI

/// Onboarding konteyner view
/// 5 ekranlık onboarding akışını yönetir
struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0

    private let totalPages = 5

    var body: some View {
        ZStack {
            Color.nuviaBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    OnboardingWelcomeView()
                        .tag(0)

                    OnboardingPermissionsView()
                        .tag(1)

                    OnboardingModeView()
                        .tag(2)

                    OnboardingPrivacyView()
                        .tag(3)

                    OnboardingSetupView {
                        completeOnboarding()
                    }
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Bottom controls
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.nuviaGoldFallback : Color.nuviaTertiaryText)
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            NuviaSecondaryButton("Geri") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                        }

                        if currentPage < totalPages - 1 {
                            NuviaPrimaryButton("Devam") {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }

            // Skip button
            VStack {
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button("Atla") {
                            withAnimation {
                                currentPage = totalPages - 1
                            }
                        }
                        .font(NuviaTypography.smallButton())
                        .foregroundColor(.nuviaSecondaryText)
                        .padding()
                    }
                }
                Spacer()
            }
        }
    }

    private func completeOnboarding() {
        withAnimation {
            appState.isOnboardingComplete = true
        }
    }
}

// MARK: - Welcome Screen

struct OnboardingWelcomeView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Illustration
            ZStack {
                Circle()
                    .fill(Color.nuviaGoldFallback.opacity(0.1))
                    .frame(width: 200, height: 200)

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.nuviaGradient)
            }

            VStack(spacing: 16) {
                Text("Nuvia'ya Hoş Geldiniz")
                    .font(NuviaTypography.title1())
                    .foregroundColor(.nuviaPrimaryText)
                    .multilineTextAlignment(.center)

                Text("Düğün ve ev kurulumunu tek yerden yönetin. Görev, bütçe, davetli, oturma planı ve daha fazlası.")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Permissions Screen

struct OnboardingPermissionsView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("İzinler")
                    .font(NuviaTypography.title1())
                    .foregroundColor(.nuviaPrimaryText)

                Text("Nuvia'nın tüm özelliklerinden faydalanmak için aşağıdaki izinlere ihtiyacımız olacak. İzinleri ihtiyaç anında isteyeceğiz.")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 16) {
                PermissionRow(
                    icon: "bell.fill",
                    title: "Bildirimler",
                    description: "Görev, ödeme ve RSVP hatırlatmaları"
                )

                PermissionRow(
                    icon: "calendar",
                    title: "Takvim",
                    description: "Düğün tarihini takviminize ekleyin"
                )

                PermissionRow(
                    icon: "person.crop.circle",
                    title: "Kişiler",
                    description: "Davetlileri kişilerinizden ekleyin"
                )

                PermissionRow(
                    icon: "camera.fill",
                    title: "Kamera",
                    description: "Fiş ve sözleşme fotoğrafı çekin"
                )
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.nuviaGoldFallback)
                .frame(width: 48, height: 48)
                .background(Color.nuviaGoldFallback.opacity(0.15))
                .cornerRadius(12)

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
        .background(Color.nuviaCardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Mode Selection Screen

struct OnboardingModeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMode: AppMode = .weddingOnly

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("Ne Planlıyorsunuz?")
                    .font(NuviaTypography.title1())
                    .foregroundColor(.nuviaPrimaryText)

                Text("İhtiyacınıza göre bir mod seçin. Sonra değiştirebilirsiniz.")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                ModeCard(
                    mode: .weddingOnly,
                    icon: "heart.fill",
                    title: "Sadece Düğün",
                    description: "Düğün planlaması, bütçe, davetli ve oturma planı",
                    isSelected: selectedMode == .weddingOnly
                ) {
                    selectedMode = .weddingOnly
                    appState.appMode = .weddingOnly
                }

                ModeCard(
                    mode: .weddingAndHome,
                    icon: "house.and.flag.fill",
                    title: "Düğün + Yeni Ev",
                    description: "Düğün + ev kurulumu, alışveriş, demirbaş takibi",
                    isSelected: selectedMode == .weddingAndHome
                ) {
                    selectedMode = .weddingAndHome
                    appState.appMode = .weddingAndHome
                }

                ModeCard(
                    mode: .organizer,
                    icon: "person.3.fill",
                    title: "Organizatörüm",
                    description: "Birden fazla düğün yönetimi (Pro özellik)",
                    isSelected: selectedMode == .organizer,
                    isPro: true
                ) {
                    selectedMode = .organizer
                    appState.appMode = .organizer
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }
}

struct ModeCard: View {
    let mode: AppMode
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    var isPro: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .nuviaGoldFallback : .nuviaSecondaryText)
                    .frame(width: 56, height: 56)
                    .background(
                        isSelected
                            ? Color.nuviaGoldFallback.opacity(0.15)
                            : Color.nuviaTertiaryBackground
                    )
                    .cornerRadius(16)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)

                        if isPro {
                            Text("PRO")
                                .font(NuviaTypography.caption2())
                                .foregroundColor(.nuviaMidnight)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.nuviaGoldFallback)
                                .cornerRadius(4)
                        }
                    }

                    Text(description)
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .nuviaGoldFallback : .nuviaTertiaryText)
            }
            .padding(16)
            .background(Color.nuviaCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.nuviaGoldFallback : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Privacy Screen

struct OnboardingPrivacyView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.nuviaSuccess.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.nuviaSuccess)
            }

            VStack(spacing: 16) {
                Text("Gizlilik Önceliğimiz")
                    .font(NuviaTypography.title1())
                    .foregroundColor(.nuviaPrimaryText)

                Text("Verileriniz güvende")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
            }

            VStack(spacing: 12) {
                PrivacyFeatureRow(
                    icon: "iphone",
                    title: "Offline-First",
                    description: "Verileriniz önce cihazınızda saklanır"
                )

                PrivacyFeatureRow(
                    icon: "icloud",
                    title: "iCloud Sync",
                    description: "Opsiyonel bulut senkronizasyonu"
                )

                PrivacyFeatureRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "Minimum Veri",
                    description: "Misafir linklerinde sadece gerekli bilgiler"
                )

                PrivacyFeatureRow(
                    icon: "faceid",
                    title: "FaceID Koruması",
                    description: "Hassas dosyalar için ek güvenlik"
                )
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }
}

struct PrivacyFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.nuviaSuccess)
                .frame(width: 40, height: 40)
                .background(Color.nuviaSuccess.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(NuviaTypography.bodyBold())
                    .foregroundColor(.nuviaPrimaryText)

                Text(description)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.nuviaCardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Setup Screen

struct OnboardingSetupView: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.nuviaGoldFallback.opacity(0.1))
                    .frame(width: 160, height: 160)

                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48))
                        .foregroundColor(.nuviaGoldFallback)

                    Text("Hazır!")
                        .font(NuviaTypography.title2())
                        .foregroundColor(.nuviaGoldFallback)
                }
            }

            VStack(spacing: 16) {
                Text("Düğününüzü Oluşturalım")
                    .font(NuviaTypography.title1())
                    .foregroundColor(.nuviaPrimaryText)
                    .multilineTextAlignment(.center)

                Text("Birkaç temel bilgi ile başlayalım. Sonrasında her şeyi özelleştirebilirsiniz.")
                    .font(NuviaTypography.body())
                    .foregroundColor(.nuviaSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            NuviaPrimaryButton("Düğün Oluştur", icon: "plus.circle.fill") {
                onComplete()
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AppState())
}
