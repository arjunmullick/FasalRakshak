//
//  OnboardingView.swift
//  FasalRakshak
//
//  Onboarding flow for first-time users
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceAssistant: VoiceAssistantService
    @State private var currentPage = 0
    @State private var farmerName = ""
    @State private var selectedLanguage: AppLanguage = .hindi

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "leaf.circle.fill",
            title: "फसल रक्षक में आपका स्वागत है",
            titleEnglish: "Welcome to Fasal Rakshak",
            description: "भारतीय किसानों के लिए AI-संचालित फसल स्वास्थ्य निदान ऐप",
            descriptionEnglish: "AI-powered crop health diagnosis app for Indian farmers",
            color: .primaryGreen
        ),
        OnboardingPage(
            icon: "camera.fill",
            title: "फोटो से पहचान",
            titleEnglish: "Photo Diagnosis",
            description: "अपनी फसल की फोटो लें और तुरंत बीमारी की पहचान करें",
            descriptionEnglish: "Take a photo of your crop and instantly identify diseases",
            color: .blue
        ),
        OnboardingPage(
            icon: "speaker.wave.2.fill",
            title: "हिंदी में आवाज सहायता",
            titleEnglish: "Voice Assistance in Hindi",
            description: "सभी जानकारी हिंदी में सुनें - पढ़ने की जरूरत नहीं",
            descriptionEnglish: "Listen to all information in Hindi - no need to read",
            color: .orange
        ),
        OnboardingPage(
            icon: "wifi.slash",
            title: "ऑफलाइन भी काम करे",
            titleEnglish: "Works Offline Too",
            description: "इंटरनेट के बिना भी बुनियादी सुविधाएं उपलब्ध",
            descriptionEnglish: "Basic features available even without internet",
            color: .purple
        ),
        OnboardingPage(
            icon: "person.fill",
            title: "अपनी जानकारी दें",
            titleEnglish: "Enter Your Details",
            description: "बेहतर सेवा के लिए अपना नाम बताएं",
            descriptionEnglish: "Tell us your name for better service",
            color: .primaryGreen,
            isInputPage: true
        )
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [pages[currentPage].color.opacity(0.1), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        if pages[index].isInputPage {
                            inputPage
                                .tag(index)
                        } else {
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                // Page indicators and buttons
                VStack(spacing: 24) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? pages[currentPage].color : Color.gray.opacity(0.3))
                                .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }

                    // Navigation buttons
                    HStack(spacing: 16) {
                        // Skip button
                        if currentPage < pages.count - 1 {
                            Button("छोड़ें") {
                                currentPage = pages.count - 1
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Next/Start button
                        Button(action: nextAction) {
                            HStack {
                                Text(currentPage == pages.count - 1 ? "शुरू करें" : "आगे")
                                if currentPage < pages.count - 1 {
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                currentPage == pages.count - 1 && farmerName.isEmpty
                                    ? Color.gray
                                    : pages[currentPage].color
                            )
                            .cornerRadius(25)
                        }
                        .disabled(currentPage == pages.count - 1 && farmerName.isEmpty)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            speakCurrentPage()
        }
        .onChange(of: currentPage) { _ in
            speakCurrentPage()
        }
    }

    // MARK: - Input Page

    private var inputPage: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "person.fill")
                .font(.system(size: 80))
                .foregroundColor(.primaryGreen)

            // Title
            VStack(spacing: 8) {
                Text("अपनी जानकारी दें")
                    .font(.title)
                    .fontWeight(.bold)

                Text("बेहतर सेवा के लिए अपना नाम बताएं")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Name input
            VStack(alignment: .leading, spacing: 8) {
                Text("आपका नाम")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("नाम दर्ज करें", text: $farmerName)
                    .font(.title3)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            // Language selector
            VStack(alignment: .leading, spacing: 8) {
                Text("भाषा चुनें")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    ForEach([AppLanguage.hindi, AppLanguage.english], id: \.self) { language in
                        Button(action: {
                            selectedLanguage = language
                            voiceAssistant.setLanguage(language)
                        }) {
                            Text(language.displayName)
                                .font(.subheadline)
                                .foregroundColor(selectedLanguage == language ? .white : .primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(selectedLanguage == language ? Color.primaryGreen : Color.gray.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // Voice toggle
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.primaryGreen)

                Text("आवाज सहायता")
                    .font(.subheadline)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { voiceAssistant.isEnabled },
                    set: { _ in voiceAssistant.toggleVoice() }
                ))
                .labelsHidden()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Actions

    private func nextAction() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        // Create farmer profile
        let profile = FarmerProfile(
            name: farmerName.isEmpty ? "किसान" : farmerName,
            preferredLanguage: selectedLanguage
        )
        appState.currentUser = profile
        appState.setLanguage(selectedLanguage)
        appState.completeOnboarding()

        // Welcome message
        voiceAssistant.speakHindi("नमस्ते \(profile.name)! फसल रक्षक में आपका स्वागत है। अब आप अपनी फसल की जांच कर सकते हैं।")
    }

    private func speakCurrentPage() {
        let page = pages[currentPage]
        voiceAssistant.speakHindi("\(page.title)। \(page.description)")
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let titleEnglish: String
    let description: String
    let descriptionEnglish: String
    let color: Color
    var isInputPage: Bool = false
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 160, height: 160)

                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundColor(page.color)
            }

            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.titleEnglish)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(VoiceAssistantService.shared)
}
