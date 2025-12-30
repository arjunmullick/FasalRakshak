//
//  AnalyticsService.swift
//  FasalRakshak
//
//  Analytics and impact tracking service
//

import Foundation
import UIKit
import Combine
import SwiftUI

class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()

    private let apiService = APIService.shared
    private let userDefaults = UserDefaults.standard
    private var deviceId: String

    @Published var sessionCount: Int = 0
    @Published var totalDiagnoses: Int = 0

    init() {
        // Get or create device ID
        if let existingId = userDefaults.string(forKey: "deviceId") {
            deviceId = existingId
        } else {
            deviceId = UUID().uuidString
            userDefaults.set(deviceId, forKey: "deviceId")
        }

        loadStats()
    }

    // MARK: - Event Tracking

    /// Track app session start
    func trackSessionStart() {
        sessionCount += 1
        userDefaults.set(sessionCount, forKey: "sessionCount")

        trackEvent(
            type: .sessionStart,
            data: [
                "session_number": "\(sessionCount)",
                "app_version": appVersion,
                "os_version": UIDevice.current.systemVersion,
                "device_model": UIDevice.current.model
            ]
        )
    }

    /// Track diagnosis event
    func trackDiagnosis(result: DiagnosisResult) {
        totalDiagnoses += 1
        userDefaults.set(totalDiagnoses, forKey: "totalDiagnoses")

        var data: [String: String] = [
            "diagnosis_id": result.id.uuidString,
            "health_score": String(format: "%.1f", result.overallHealthScore),
            "conditions_count": "\(result.diagnosedConditions.count)"
        ]

        if let crop = result.identifiedCrop {
            data["crop_type"] = crop.id.uuidString
            data["crop_name"] = crop.name
        }

        if !result.diagnosedConditions.isEmpty {
            data["primary_condition"] = result.diagnosedConditions.first?.conditionName ?? ""
            data["severity"] = result.diagnosedConditions.first?.severity.rawValue ?? ""
        }

        if let location = result.location {
            data["region"] = location.region?.rawValue ?? ""
            data["state"] = location.state ?? ""
        }

        trackEvent(type: .diagnosis, data: data)
    }

    /// Track symptom check
    func trackSymptomCheck(symptoms: [Symptom], crop: Crop?, results: [DiagnosedCondition]) {
        var data: [String: String] = [
            "symptoms_count": "\(symptoms.count)",
            "results_count": "\(results.count)"
        ]

        if let crop = crop {
            data["crop_type"] = crop.name
        }

        data["symptoms"] = symptoms.map { $0.name }.joined(separator: ",")

        trackEvent(type: .symptomCheck, data: data)
    }

    /// Track treatment viewed
    func trackTreatmentViewed(treatment: Treatment, disease: Disease?) {
        var data: [String: String] = [
            "treatment_id": treatment.id.uuidString,
            "treatment_name": treatment.name,
            "treatment_type": treatment.type.rawValue
        ]

        if let disease = disease {
            data["disease_id"] = disease.id.uuidString
            data["disease_name"] = disease.name
        }

        trackEvent(type: .treatmentViewed, data: data)
    }

    /// Track expert consultation request
    func trackExpertConsultRequest(cropType: String, urgency: String) {
        trackEvent(
            type: .expertConsultRequest,
            data: [
                "crop_type": cropType,
                "urgency": urgency
            ]
        )
    }

    /// Track feature usage
    func trackFeatureUsed(_ feature: AppFeature) {
        trackEvent(
            type: .featureUsed,
            data: [
                "feature": feature.rawValue
            ]
        )
    }

    /// Track voice assistant usage
    func trackVoiceUsage(action: String, language: String) {
        trackEvent(
            type: .voiceUsed,
            data: [
                "action": action,
                "language": language
            ]
        )
    }

    /// Track offline mode usage
    func trackOfflineUsage(feature: String) {
        trackEvent(
            type: .offlineUsed,
            data: [
                "feature": feature
            ]
        )
    }

    /// Track reminder created
    func trackReminderCreated(type: ReminderType) {
        trackEvent(
            type: .reminderCreated,
            data: [
                "reminder_type": type.rawValue
            ]
        )
    }

    /// Track error
    func trackError(type: String, message: String, context: String?) {
        var data: [String: String] = [
            "error_type": type,
            "error_message": message
        ]

        if let context = context {
            data["context"] = context
        }

        trackEvent(type: .error, data: data)
    }

    // MARK: - Private Methods

    private func trackEvent(type: EventType, data: [String: String]) {
        let event = AnalyticsEvent(
            eventType: type.rawValue,
            eventData: data,
            timestamp: Date(),
            deviceId: deviceId,
            appVersion: appVersion,
            region: currentRegion
        )

        // Send to server asynchronously
        Task {
            await apiService.submitAnalytics(event)
        }

        // Also log locally for debugging
        #if DEBUG
        print("📊 Analytics: \(type.rawValue) - \(data)")
        #endif
    }

    private func loadStats() {
        sessionCount = userDefaults.integer(forKey: "sessionCount")
        totalDiagnoses = userDefaults.integer(forKey: "totalDiagnoses")
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var currentRegion: String? {
        // Get from user profile or location
        return nil
    }

    // MARK: - Impact Metrics

    /// Get usage statistics for the current session
    func getUsageStats() -> UsageStats {
        UsageStats(
            totalSessions: sessionCount,
            totalDiagnoses: totalDiagnoses,
            lastSessionDate: userDefaults.object(forKey: "lastSessionDate") as? Date,
            averageDiagnosesPerSession: sessionCount > 0 ? Double(totalDiagnoses) / Double(sessionCount) : 0
        )
    }

    /// Get crop health trends
    func getCropHealthTrends() -> [CropHealthTrend] {
        // Analyze diagnosis history for trends
        let offlineManager = OfflineDataManager.shared
        let diagnoses = offlineManager.getDiagnosisHistory()

        var cropTrends: [String: [DiagnosisResult]] = [:]

        for diagnosis in diagnoses {
            if let crop = diagnosis.identifiedCrop {
                if cropTrends[crop.name] == nil {
                    cropTrends[crop.name] = []
                }
                cropTrends[crop.name]?.append(diagnosis)
            }
        }

        return cropTrends.map { cropName, results in
            let averageHealth = results.reduce(0) { $0 + $1.overallHealthScore } / Double(results.count)
            let issueCount = results.filter { !$0.diagnosedConditions.isEmpty }.count

            return CropHealthTrend(
                cropName: cropName,
                diagnosisCount: results.count,
                averageHealthScore: averageHealth,
                issuesFound: issueCount
            )
        }.sorted { $0.diagnosisCount > $1.diagnosisCount }
    }

    /// Get regional issue distribution
    func getRegionalIssues() -> [RegionalIssue] {
        let offlineManager = OfflineDataManager.shared
        let diagnoses = offlineManager.getDiagnosisHistory()

        var regionIssues: [String: Int] = [:]

        for diagnosis in diagnoses {
            if let region = diagnosis.location?.region {
                regionIssues[region.displayName, default: 0] += diagnosis.diagnosedConditions.count
            }
        }

        return regionIssues.map { RegionalIssue(region: $0.key, issueCount: $0.value) }
            .sorted { $0.issueCount > $1.issueCount }
    }
}

// MARK: - Event Types

enum EventType: String {
    case sessionStart = "session_start"
    case diagnosis = "diagnosis"
    case symptomCheck = "symptom_check"
    case treatmentViewed = "treatment_viewed"
    case expertConsultRequest = "expert_consult_request"
    case featureUsed = "feature_used"
    case voiceUsed = "voice_used"
    case offlineUsed = "offline_used"
    case reminderCreated = "reminder_created"
    case error = "error"
}

enum AppFeature: String {
    case camera = "camera"
    case gallery = "gallery"
    case symptomChecker = "symptom_checker"
    case cropDatabase = "crop_database"
    case diseaseGuide = "disease_guide"
    case reminders = "reminders"
    case expertConsult = "expert_consult"
    case voiceAssistant = "voice_assistant"
    case history = "history"
    case profile = "profile"
}

// MARK: - Analytics Models

struct UsageStats {
    let totalSessions: Int
    let totalDiagnoses: Int
    let lastSessionDate: Date?
    let averageDiagnosesPerSession: Double
}

struct CropHealthTrend {
    let cropName: String
    let diagnosisCount: Int
    let averageHealthScore: Double
    let issuesFound: Int
}

struct RegionalIssue {
    let region: String
    let issueCount: Int
}

// MARK: - Analytics Dashboard View

struct AnalyticsDashboardView: View {
    @StateObject private var analyticsService = AnalyticsService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Usage stats
                usageStatsSection

                // Crop trends
                cropTrendsSection

                // Regional distribution
                regionalSection
            }
            .padding()
        }
        .navigationTitle("उपयोग विश्लेषण")
    }

    private var usageStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("उपयोग सांख्यिकी")
                .font(.headline)

            let stats = analyticsService.getUsageStats()

            HStack(spacing: 20) {
                AnalyticsStatCard(
                    value: "\(stats.totalSessions)",
                    label: "सत्र",
                    icon: "person.fill"
                )

                AnalyticsStatCard(
                    value: "\(stats.totalDiagnoses)",
                    label: "जांच",
                    icon: "magnifyingglass"
                )

                AnalyticsStatCard(
                    value: String(format: "%.1f", stats.averageDiagnosesPerSession),
                    label: "औसत/सत्र",
                    icon: "chart.bar.fill"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    private var cropTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("फसल स्वास्थ्य रुझान")
                .font(.headline)

            let trends = analyticsService.getCropHealthTrends()

            if trends.isEmpty {
                Text("अभी तक कोई डेटा नहीं")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(trends.prefix(5), id: \.cropName) { trend in
                    CropTrendRow(trend: trend)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    private var regionalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("क्षेत्रीय वितरण")
                .font(.headline)

            let issues = analyticsService.getRegionalIssues()

            if issues.isEmpty {
                Text("अभी तक कोई डेटा नहीं")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(issues.prefix(5), id: \.region) { issue in
                    HStack {
                        Text(issue.region)
                            .font(.subheadline)

                        Spacer()

                        Text("\(issue.issueCount) समस्याएं")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct AnalyticsStatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primaryGreen)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CropTrendRow: View {
    let trend: CropHealthTrend

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(trend.cropName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(trend.diagnosisCount) जांच")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(trend.averageHealthScore))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(trend.averageHealthScore >= 70 ? .green : .orange)

                Text("\(trend.issuesFound) समस्याएं")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
