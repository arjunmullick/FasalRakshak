//
//  ContentView.swift
//  FasalRakshak
//
//  Main content view with tab-based navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home

    enum Tab: Int, CaseIterable {
        case home = 0
        case camera = 1
        case symptoms = 2
        case history = 3
        case profile = 4

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .camera: return "camera.fill"
            case .symptoms: return "list.bullet.clipboard.fill"
            case .history: return "clock.fill"
            case .profile: return "person.fill"
            }
        }

        var title: String {
            switch self {
            case .home: return "होम"
            case .camera: return "कैमरा"
            case .symptoms: return "लक्षण"
            case .history: return "इतिहास"
            case .profile: return "प्रोफाइल"
            }
        }

        var englishTitle: String {
            switch self {
            case .home: return "Home"
            case .camera: return "Camera"
            case .symptoms: return "Symptoms"
            case .history: return "History"
            case .profile: return "Profile"
            }
        }
    }

    var body: some View {
        Group {
            if appState.isOnboarded {
                mainTabView
            } else {
                OnboardingView()
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: Tab.home.icon)
                    Text(Tab.home.title)
                }
                .tag(Tab.home)

            CameraCaptureView()
                .tabItem {
                    Image(systemName: Tab.camera.icon)
                    Text(Tab.camera.title)
                }
                .tag(Tab.camera)

            SymptomCheckerView()
                .tabItem {
                    Image(systemName: Tab.symptoms.icon)
                    Text(Tab.symptoms.title)
                }
                .tag(Tab.symptoms)

            DiagnosisHistoryView()
                .tabItem {
                    Image(systemName: Tab.history.icon)
                    Text(Tab.history.title)
                }
                .tag(Tab.history)

            FarmerProfileView()
                .tabItem {
                    Image(systemName: Tab.profile.icon)
                    Text(Tab.profile.title)
                }
                .tag(Tab.profile)
        }
        .accentColor(.primaryGreen)
        .onAppear {
            // Configure tab bar for large touch targets
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white

            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

// MARK: - Custom Color Extensions
extension Color {
    static let primaryGreen = Color(red: 34/255, green: 139/255, blue: 34/255)
    static let secondaryGreen = Color(red: 60/255, green: 179/255, blue: 113/255)
    static let warningOrange = Color(red: 255/255, green: 165/255, blue: 0/255)
    static let dangerRed = Color(red: 220/255, green: 53/255, blue: 69/255)
    static let earthBrown = Color(red: 139/255, green: 90/255, blue: 43/255)
    static let skyBlue = Color(red: 135/255, green: 206/255, blue: 235/255)
    static let sunYellow = Color(red: 255/255, green: 215/255, blue: 0/255)
    static let leafGreen = Color(red: 0/255, green: 128/255, blue: 0/255)
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(VoiceAssistantService.shared)
        .environmentObject(OfflineDataManager.shared)
        .environmentObject(NotificationManager.shared)
}
