//
//  OnboardingView.swift
//  FasalRakshak
//
//  Simple English-only onboarding flow
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var farmerName = ""

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "leaf.circle.fill",
            title: "Welcome to Crop Guardian",
            description: "AI-powered crop disease detection to help protect your harvest",
            color: .green
        ),
        OnboardingPage(
            icon: "camera.fill",
            title: "Instant Diagnosis",
            description: "Simply take a photo of your crop and get instant AI analysis",
            color: .blue
        ),
        OnboardingPage(
            icon: "checkmark.shield.fill",
            title: "Expert Recommendations",
            description: "Get treatment suggestions and preventive measures",
            color: .purple
        )
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.green.opacity(0.1), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }

                    // Final page - Name input
                    finalPage
                        .tag(pages.count)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                // Page indicators and button
                VStack(spacing: 24) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0...(pages.count), id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }

                    // Navigation button
                    Button(action: nextAction) {
                        HStack {
                            Text(currentPage == pages.count ? "Get Started" : "Next")
                            if currentPage < pages.count {
                                Image(systemName: "arrow.right")
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            currentPage == pages.count && farmerName.isEmpty
                                ? Color.gray
                                : Color.green
                        )
                        .cornerRadius(16)
                    }
                    .disabled(currentPage == pages.count && farmerName.isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Final Page

    private var finalPage: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)

            VStack(spacing: 12) {
                Text("What's your name?")
                    .font(.system(size: 28, weight: .bold))

                Text("We'll personalize your experience")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Name input
            TextField("Enter your name", text: $farmerName)
                .font(.system(size: 17))
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }

    // MARK: - Actions

    private func nextAction() {
        if currentPage < pages.count {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        // Save farmer name
        if !farmerName.isEmpty {
            UserDefaults.standard.set(farmerName, forKey: "farmerName")
        }

        // Mark onboarding as complete
        withAnimation {
            appState.isOnboarded = true
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(page.color)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
