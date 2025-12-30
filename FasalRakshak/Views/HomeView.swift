//
//  HomeView.swift
//  FasalRakshak
//
//  Main home screen with quick actions and dashboard
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceAssistant: VoiceAssistantService
    @EnvironmentObject var offlineManager: OfflineDataManager

    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var recentDiagnoses: [DiagnosisResult] = []
    @State private var upcomingReminders: [CropReminder] = []
    @State private var showingCropSelector = false
    @State private var selectedCrop: Crop?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Offline Banner
                    NetworkStatusBanner()

                    // Welcome Section
                    welcomeSection

                    // Quick Actions
                    quickActionsSection

                    // Crop Health Stats
                    if !recentDiagnoses.isEmpty {
                        recentDiagnosesSection
                    }

                    // Upcoming Reminders
                    if !upcomingReminders.isEmpty {
                        remindersSection
                    }

                    // Crop Categories
                    cropCategoriesSection

                    // Weather Info (if available)
                    weatherInfoSection

                    // Tips Section
                    dailyTipsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("फसल रक्षक")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    voiceToggleButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ConnectionIndicator()
                }
            }
            .onAppear {
                loadData()
                speakWelcome()
            }
            .sheet(isPresented: $showingCropSelector) {
                CropSelectorView(selectedCrop: $selectedCrop)
            }
        }
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("नमस्ते! 🙏")
                .font(.title)
                .fontWeight(.bold)

            Text("अपनी फसल की जांच करें और समस्याओं का समाधान पाएं")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [Color.primaryGreen.opacity(0.1), Color.secondaryGreen.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("त्वरित कार्य")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    icon: "camera.fill",
                    title: "फोटो लें",
                    subtitle: "फसल स्कैन करें",
                    color: .primaryGreen
                ) {
                    // Navigate to camera
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavigateToCamera"),
                        object: nil
                    )
                }

                QuickActionCard(
                    icon: "photo.on.rectangle",
                    title: "गैलरी",
                    subtitle: "फोटो चुनें",
                    color: .blue
                ) {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavigateToGallery"),
                        object: nil
                    )
                }

                QuickActionCard(
                    icon: "list.bullet.clipboard",
                    title: "लक्षण जांच",
                    subtitle: "समस्या पहचानें",
                    color: .orange
                ) {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavigateToSymptoms"),
                        object: nil
                    )
                }

                QuickActionCard(
                    icon: "person.fill.questionmark",
                    title: "विशेषज्ञ सलाह",
                    subtitle: "मदद लें",
                    color: .purple
                ) {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavigateToExpert"),
                        object: nil
                    )
                }
            }
        }
    }

    // MARK: - Recent Diagnoses

    private var recentDiagnosesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("हाल की जांच")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                NavigationLink(destination: DiagnosisHistoryView()) {
                    Text("सभी देखें")
                        .font(.caption)
                        .foregroundColor(.primaryGreen)
                }
            }

            ForEach(recentDiagnoses.prefix(3)) { diagnosis in
                NavigationLink(destination: DiagnosisDetailView(diagnosis: diagnosis)) {
                    RecentDiagnosisCard(diagnosis: diagnosis)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: - Reminders Section

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("आगामी याद दिलाना")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                NavigationLink(destination: RemindersListView()) {
                    Text("सभी देखें")
                        .font(.caption)
                        .foregroundColor(.primaryGreen)
                }
            }

            ForEach(upcomingReminders.prefix(2)) { reminder in
                ReminderCard(reminder: reminder)
            }
        }
    }

    // MARK: - Crop Categories

    private var cropCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("फसल श्रेणियां")
                .font(.headline)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CropCategory.allCases, id: \.self) { category in
                        NavigationLink(destination: CropCategoryView(category: category)) {
                            CropCategoryCard(category: category)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    // MARK: - Weather Info

    private var weatherInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("मौसम की जानकारी")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                WeatherInfoItem(icon: "thermometer", value: "28°C", label: "तापमान")
                WeatherInfoItem(icon: "humidity", value: "65%", label: "आर्द्रता")
                WeatherInfoItem(icon: "cloud.rain", value: "30%", label: "बारिश")
            }
            .padding()
            .background(Color.skyBlue.opacity(0.1))
            .cornerRadius(12)
        }
    }

    // MARK: - Daily Tips

    private var dailyTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("आज की सलाह 💡")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("नाइट्रोजन की कमी से बचाव")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("पौधों में पीलापन रोकने के लिए नियमित रूप से जैविक खाद का उपयोग करें। वर्मीकम्पोस्ट एक अच्छा विकल्प है।")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: {
                    voiceAssistant.speakHindi("नाइट्रोजन की कमी से बचाव। पौधों में पीलापन रोकने के लिए नियमित रूप से जैविक खाद का उपयोग करें। वर्मीकम्पोस्ट एक अच्छा विकल्प है।")
                }) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("सुनें")
                    }
                    .font(.caption)
                    .foregroundColor(.primaryGreen)
                }
            }
            .padding()
            .background(Color.sunYellow.opacity(0.1))
            .cornerRadius(12)
        }
    }

    // MARK: - Voice Toggle Button

    private var voiceToggleButton: some View {
        Button(action: {
            voiceAssistant.toggleVoice()
        }) {
            Image(systemName: voiceAssistant.isEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .foregroundColor(voiceAssistant.isEnabled ? .primaryGreen : .gray)
        }
    }

    // MARK: - Data Loading

    private func loadData() {
        recentDiagnoses = offlineManager.getDiagnosisHistory()
        upcomingReminders = offlineManager.getUpcomingReminders()
    }

    private func speakWelcome() {
        if voiceAssistant.isEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                voiceAssistant.speakHindi(VoiceAssistantService.VoiceMessages.welcomeHindi)
            }
        }
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recent Diagnosis Card

struct RecentDiagnosisCard: View {
    let diagnosis: DiagnosisResult

    var body: some View {
        HStack(spacing: 12) {
            // Image thumbnail
            if let imageData = diagnosis.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.gray)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                // Crop name or condition
                Text(diagnosis.identifiedCrop?.nameHindi ?? "फसल जांच")
                    .font(.subheadline)
                    .fontWeight(.medium)

                // Health status
                HStack(spacing: 4) {
                    Image(systemName: diagnosis.healthStatus.icon)
                        .font(.caption)
                        .foregroundColor(diagnosis.healthStatus.color)

                    Text(diagnosis.healthStatus.displayNameHindi)
                        .font(.caption)
                        .foregroundColor(diagnosis.healthStatus.color)
                }

                // Date
                Text(formatDate(diagnosis.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "hi_IN")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Reminder Card

struct ReminderCard: View {
    let reminder: CropReminder

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: reminder.type.icon)
                    .font(.title3)
                    .foregroundColor(.orange)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.titleHindi)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(formatReminderDate(reminder.scheduledDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(reminder.type.displayNameHindi)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
    }

    private func formatReminderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "hi_IN")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Crop Category Card

struct CropCategoryCard: View {
    let category: CropCategory

    var body: some View {
        VStack(spacing: 8) {
            Text(category.icon)
                .font(.title)

            Text(category.displayNameHindi)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(width: 80, height: 80)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Weather Info Item

struct WeatherInfoItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(VoiceAssistantService.shared)
        .environmentObject(OfflineDataManager.shared)
}
