//
//  FarmerProfileView.swift
//  FasalRakshak
//
//  Farmer profile and settings view
//

import SwiftUI

struct FarmerProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceAssistant: VoiceAssistantService
    @EnvironmentObject var offlineManager: OfflineDataManager

    @State private var showingEditProfile = false
    @State private var showingLanguageSelector = false
    @State private var showingReminders = false
    @State private var showingExpertConsult = false
    @State private var showingAbout = false
    @State private var showingPrivacy = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader

                    // Quick Stats
                    quickStats

                    // Settings Sections
                    settingsSection

                    // App Info
                    appInfoSection

                    // Version info
                    versionInfo
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("प्रोफाइल")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingLanguageSelector) {
                LanguageSelectorView()
            }
            .sheet(isPresented: $showingReminders) {
                RemindersListView()
            }
            .sheet(isPresented: $showingExpertConsult) {
                ExpertConsultationView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutAppView()
            }
            .sheet(isPresented: $showingPrivacy) {
                PrivacyPolicyView()
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.primaryGreen)
            }

            // Name and location
            VStack(spacing: 4) {
                Text(appState.currentUser?.name ?? "किसान")
                    .font(.title2)
                    .fontWeight(.bold)

                if let village = appState.currentUser?.village,
                   let district = appState.currentUser?.district {
                    Text("\(village), \(district)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Edit profile button
            Button(action: { showingEditProfile = true }) {
                Text("प्रोफाइल संपादित करें")
                    .font(.subheadline)
                    .foregroundColor(.primaryGreen)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.primaryGreen.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }

    // MARK: - Quick Stats

    private var quickStats: some View {
        HStack(spacing: 0) {
            ProfileStatItem(
                value: "\(offlineManager.getDiagnosisHistory().count)",
                label: "जांच",
                icon: "magnifyingglass"
            )

            Divider()
                .frame(height: 40)

            ProfileStatItem(
                value: "\(appState.currentUser?.registeredCrops.count ?? 0)",
                label: "फसलें",
                icon: "leaf"
            )

            Divider()
                .frame(height: 40)

            ProfileStatItem(
                value: "\(offlineManager.getUpcomingReminders().count)",
                label: "याद दिलाना",
                icon: "bell"
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 0) {
            // Voice Settings
            SettingsRow(
                icon: "speaker.wave.2.fill",
                iconColor: .blue,
                title: "आवाज सहायता",
                subtitle: voiceAssistant.isEnabled ? "चालू" : "बंद"
            ) {
                Toggle("", isOn: Binding(
                    get: { voiceAssistant.isEnabled },
                    set: { _ in voiceAssistant.toggleVoice() }
                ))
                .labelsHidden()
            }

            Divider().padding(.leading, 56)

            // Language
            SettingsRow(
                icon: "globe",
                iconColor: .green,
                title: "भाषा",
                subtitle: appState.selectedLanguage.displayName
            ) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .onTapGesture { showingLanguageSelector = true }

            Divider().padding(.leading, 56)

            // Reminders
            SettingsRow(
                icon: "bell.fill",
                iconColor: .orange,
                title: "याद दिलाना",
                subtitle: "\(offlineManager.getUpcomingReminders().count) सक्रिय"
            ) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .onTapGesture { showingReminders = true }

            Divider().padding(.leading, 56)

            // Offline Data
            SettingsRow(
                icon: "arrow.down.circle.fill",
                iconColor: .purple,
                title: "ऑफलाइन डेटा",
                subtitle: formatDataSize(offlineManager.offlineDataSize)
            ) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }

            Divider().padding(.leading, 56)

            // Expert Consultation
            SettingsRow(
                icon: "person.fill.questionmark",
                iconColor: .primaryGreen,
                title: "विशेषज्ञ सलाह",
                subtitle: "सहायता प्राप्त करें"
            ) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .onTapGesture { showingExpertConsult = true }
        }
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        VStack(spacing: 0) {
            SettingsRow(
                icon: "info.circle.fill",
                iconColor: .blue,
                title: "ऐप के बारे में",
                subtitle: ""
            ) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .onTapGesture { showingAbout = true }

            Divider().padding(.leading, 56)

            SettingsRow(
                icon: "hand.raised.fill",
                iconColor: .gray,
                title: "गोपनीयता नीति",
                subtitle: ""
            ) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .onTapGesture { showingPrivacy = true }

            Divider().padding(.leading, 56)

            SettingsRow(
                icon: "star.fill",
                iconColor: .yellow,
                title: "ऐप रेट करें",
                subtitle: ""
            ) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }

            Divider().padding(.leading, 56)

            SettingsRow(
                icon: "square.and.arrow.up",
                iconColor: .green,
                title: "ऐप साझा करें",
                subtitle: ""
            ) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Version Info

    private var versionInfo: some View {
        VStack(spacing: 4) {
            Text("फसल रक्षक")
                .font(.subheadline)
                .fontWeight(.medium)

            Text("संस्करण 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("किसानों के लिए, किसानों द्वारा 🌾")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - Helper

    private func formatDataSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Profile Stat Item

struct ProfileStatItem: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primaryGreen)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Settings Row

struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let trailing: Content

    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Content
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            trailing
        }
        .padding()
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var village: String = ""
    @State private var district: String = ""
    @State private var state: String = ""
    @State private var farmSize: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("व्यक्तिगत जानकारी")) {
                    TextField("नाम", text: $name)
                    TextField("फोन नंबर", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("स्थान")) {
                    TextField("गांव", text: $village)
                    TextField("जिला", text: $district)
                    TextField("राज्य", text: $state)
                }

                Section(header: Text("खेती की जानकारी")) {
                    TextField("खेत का आकार (एकड़)", text: $farmSize)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("प्रोफाइल संपादित करें")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("रद्द करें") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("सहेजें") { saveProfile() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadProfile()
            }
        }
    }

    private func loadProfile() {
        if let user = appState.currentUser {
            name = user.name
            phone = user.phone ?? ""
            village = user.village ?? ""
            district = user.district ?? ""
            state = user.state ?? ""
            farmSize = user.farmSize.map { String($0) } ?? ""
        }
    }

    private func saveProfile() {
        let profile = FarmerProfile(
            id: appState.currentUser?.id ?? UUID(),
            name: name,
            phone: phone.isEmpty ? nil : phone,
            village: village.isEmpty ? nil : village,
            district: district.isEmpty ? nil : district,
            state: state.isEmpty ? nil : state,
            farmSize: Double(farmSize)
        )
        appState.currentUser = profile
        dismiss()
    }
}

// MARK: - Language Selector View

struct LanguageSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceAssistant: VoiceAssistantService

    var body: some View {
        NavigationView {
            List {
                ForEach(AppLanguage.allCases) { language in
                    Button(action: {
                        appState.setLanguage(language)
                        dismiss()
                    }) {
                        HStack {
                            Text(language.displayName)
                                .foregroundColor(.primary)

                            Spacer()

                            if appState.selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primaryGreen)
                            }
                        }
                    }
                }
            }
            .navigationTitle("भाषा चुनें")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("बंद करें") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Reminders List View

struct RemindersListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var offlineManager: OfflineDataManager

    @State private var reminders: [CropReminder] = []
    @State private var showingAddReminder = false

    var body: some View {
        NavigationView {
            Group {
                if reminders.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("कोई याद दिलाना नहीं")
                            .font(.headline)

                        Text("नया याद दिलाना जोड़ें")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(reminders) { reminder in
                            ReminderListRow(reminder: reminder)
                        }
                        .onDelete(perform: deleteReminder)
                    }
                }
            }
            .navigationTitle("याद दिलाना")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("बंद करें") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddReminder = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                reminders = offlineManager.getAllReminders()
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
        }
    }

    private func deleteReminder(at offsets: IndexSet) {
        for index in offsets {
            try? offlineManager.deleteReminder(id: reminders[index].id)
        }
        reminders = offlineManager.getAllReminders()
    }
}

struct ReminderListRow: View {
    let reminder: CropReminder

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reminder.type.icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.titleHindi)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(formatDate(reminder.scheduledDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if reminder.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "hi_IN")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Add Reminder View

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var offlineManager: OfflineDataManager

    @State private var title = ""
    @State private var description = ""
    @State private var scheduledDate = Date()
    @State private var reminderType: ReminderType = .general
    @State private var repeatInterval: ReminderRepeat = .none

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("विवरण")) {
                    TextField("शीर्षक", text: $title)
                    TextField("विवरण", text: $description)
                }

                Section(header: Text("समय")) {
                    DatePicker("तारीख और समय", selection: $scheduledDate)
                        .datePickerStyle(.graphical)
                }

                Section(header: Text("प्रकार")) {
                    Picker("प्रकार", selection: $reminderType) {
                        ForEach(ReminderType.allCases, id: \.self) { type in
                            Text(type.displayNameHindi).tag(type)
                        }
                    }

                    Picker("दोहराएं", selection: $repeatInterval) {
                        ForEach(ReminderRepeat.allCases, id: \.self) { interval in
                            Text(interval.displayNameHindi).tag(interval)
                        }
                    }
                }
            }
            .navigationTitle("नया याद दिलाना")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("रद्द करें") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("सहेजें") { saveReminder() }
                        .fontWeight(.semibold)
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveReminder() {
        let reminder = CropReminder(
            title: title,
            titleHindi: title,
            description: description,
            descriptionHindi: description,
            scheduledDate: scheduledDate,
            repeatInterval: repeatInterval,
            type: reminderType
        )

        try? offlineManager.saveReminder(reminder)
        NotificationManager.shared.scheduleReminder(reminder)
        dismiss()
    }
}

// MARK: - Expert Consultation View

struct ExpertConsultationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var description = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 50))
                        .foregroundColor(.primaryGreen)
                }

                Text("विशेषज्ञ से सलाह लें")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("कृषि विशेषज्ञों से सीधे जुड़ें और अपनी समस्या का समाधान पाएं")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Description input
                VStack(alignment: .leading, spacing: 8) {
                    Text("अपनी समस्या बताएं")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    TextEditor(text: $description)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()

                // Submit button
                Button(action: submitRequest) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("सलाह के लिए अनुरोध करें")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(description.isEmpty ? Color.gray : Color.primaryGreen)
                .cornerRadius(12)
                .disabled(description.isEmpty || isSubmitting)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("विशेषज्ञ सलाह")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("बंद करें") { dismiss() }
                }
            }
        }
    }

    private func submitRequest() {
        isSubmitting = true
        // Submit consultation request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSubmitting = false
            dismiss()
        }
    }
}

// MARK: - About App View

struct AboutAppView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App logo
                    VStack(spacing: 16) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.primaryGreen)

                        Text("फसल रक्षक")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Fasal Rakshak")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("फसल रक्षक भारतीय किसानों के लिए एक AI-संचालित फसल स्वास्थ्य निदान ऐप है।")
                            .font(.body)

                        Text("इस ऐप की विशेषताएं:")
                            .font(.headline)
                            .padding(.top)

                        FeatureRow(icon: "camera.fill", text: "फोटो से रोग पहचान")
                        FeatureRow(icon: "speaker.wave.2.fill", text: "हिंदी में आवाज सहायता")
                        FeatureRow(icon: "wifi.slash", text: "ऑफलाइन मोड समर्थन")
                        FeatureRow(icon: "bell.fill", text: "उपचार याद दिलाना")
                        FeatureRow(icon: "person.fill.questionmark", text: "विशेषज्ञ सलाह")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)

                    // Credits
                    Text("भारतीय किसानों के लिए, प्यार से बनाया गया 🇮🇳")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("ऐप के बारे में")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("बंद करें") { dismiss() }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primaryGreen)
                .frame(width: 30)

            Text(text)
                .font(.subheadline)

            Spacer()
        }
    }
}

// MARK: - Privacy Policy View

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("गोपनीयता नीति")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("अंतिम अपडेट: दिसंबर 2024")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Group {
                        Text("डेटा संग्रहण")
                            .font(.headline)

                        Text("हम आपकी फसल की तस्वीरें और स्थान की जानकारी केवल निदान के लिए उपयोग करते हैं। आपका व्यक्तिगत डेटा सुरक्षित रूप से संग्रहीत किया जाता है।")

                        Text("डेटा उपयोग")
                            .font(.headline)
                            .padding(.top)

                        Text("आपके द्वारा साझा किया गया डेटा केवल फसल निदान और सुधार के लिए उपयोग किया जाता है। हम आपका डेटा तीसरे पक्ष को नहीं बेचते।")

                        Text("डेटा सुरक्षा")
                            .font(.headline)
                            .padding(.top)

                        Text("हम आपके डेटा की सुरक्षा के लिए उद्योग-मानक एन्क्रिप्शन का उपयोग करते हैं।")
                    }
                }
                .padding()
            }
            .navigationTitle("गोपनीयता नीति")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("बंद करें") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FarmerProfileView()
        .environmentObject(AppState())
        .environmentObject(VoiceAssistantService.shared)
        .environmentObject(OfflineDataManager.shared)
}
