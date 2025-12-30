//
//  FasalRakshakApp.swift
//  FasalRakshak - Crop Health Diagnosis App for Indian Farmers
//
//  फसल रक्षक - भारतीय किसानों के लिए फसल स्वास्थ्य निदान ऐप
//

import SwiftUI
import UserNotifications

@main
struct FasalRakshakApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var voiceAssistant = VoiceAssistantService.shared
    @StateObject private var offlineManager = OfflineDataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        // Configure app appearance for outdoor visibility
        configureAppearance()

        // Request notification permissions
        requestNotificationPermissions()

        // Initialize offline data
        Task {
            await OfflineDataManager.shared.initializeOfflineData()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(voiceAssistant)
                .environmentObject(offlineManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(.light) // Better for outdoor use
        }
    }

    private func configureAppearance() {
        // Large, high-contrast navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.primaryGreen)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.white
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted")
            }
        }
    }
}

// MARK: - App State Management
class AppState: ObservableObject {
    @Published var isOnboarded: Bool = UserDefaults.standard.bool(forKey: "isOnboarded")
    @Published var selectedLanguage: AppLanguage = .hindi
    @Published var isOfflineMode: Bool = false
    @Published var currentUser: FarmerProfile?

    func completeOnboarding() {
        isOnboarded = true
        UserDefaults.standard.set(true, forKey: "isOnboarded")
    }

    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguage")
    }
}

// MARK: - Supported Languages
enum AppLanguage: String, CaseIterable, Identifiable {
    case hindi = "hi"
    case english = "en"
    case telugu = "te"
    case tamil = "ta"
    case kannada = "kn"
    case bengali = "bn"
    case marathi = "mr"
    case gujarati = "gu"
    case punjabi = "pa"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hindi: return "हिंदी"
        case .english: return "English"
        case .telugu: return "తెలుగు"
        case .tamil: return "தமிழ்"
        case .kannada: return "ಕನ್ನಡ"
        case .bengali: return "বাংলা"
        case .marathi: return "मराठी"
        case .gujarati: return "ગુજરાતી"
        case .punjabi: return "ਪੰਜਾਬੀ"
        }
    }

    var voiceIdentifier: String {
        switch self {
        case .hindi: return "hi-IN"
        case .english: return "en-IN"
        case .telugu: return "te-IN"
        case .tamil: return "ta-IN"
        case .kannada: return "kn-IN"
        case .bengali: return "bn-IN"
        case .marathi: return "mr-IN"
        case .gujarati: return "gu-IN"
        case .punjabi: return "pa-IN"
        }
    }
}
