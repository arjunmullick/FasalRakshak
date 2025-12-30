//
//  DiagnosisDetailView.swift
//  FasalRakshak
//
//  Detailed view of a diagnosis result with treatment options
//

import SwiftUI

struct DiagnosisDetailView: View {
    let diagnosis: DiagnosisResult
    @EnvironmentObject var voiceAssistant: VoiceAssistantService
    @State private var selectedTreatmentType: TreatmentType = .organic

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image and health overview
                imageAndHealthSection

                // Identified crop
                if let crop = diagnosis.identifiedCrop {
                    cropInfoSection(crop)
                }

                // Diagnosed conditions
                if !diagnosis.diagnosedConditions.isEmpty {
                    conditionsSection
                }

                // Affected areas visualization
                if !diagnosis.affectedAreas.isEmpty {
                    affectedAreasSection
                }

                // Recommendations
                if !diagnosis.recommendations.isEmpty {
                    recommendationsSection
                }

                // Action buttons
                actionButtons
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("जांच विवरण")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    voiceAssistant.speakDiagnosisResult(diagnosis)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                }
            }
        }
    }

    // MARK: - Image and Health Section

    private var imageAndHealthSection: some View {
        VStack(spacing: 16) {
            // Image with affected area overlay
            if let imageData = diagnosis.imageData,
               let uiImage = UIImage(data: imageData) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)

                    // Affected area markers
                    GeometryReader { geometry in
                        ForEach(diagnosis.affectedAreas) { area in
                            AffectedAreaMarker(area: area, imageSize: geometry.size)
                        }
                    }
                }
                .frame(height: 250)
            }

            // Health score
            HealthScoreCard(
                score: diagnosis.overallHealthScore,
                status: diagnosis.healthStatus
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }

    // MARK: - Crop Info Section

    private func cropInfoSection(_ crop: Crop) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("पहचानी गई फसल")
                .font(.headline)

            HStack(spacing: 16) {
                Text(crop.category.icon)
                    .font(.largeTitle)

                VStack(alignment: .leading, spacing: 4) {
                    Text(crop.nameHindi)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(crop.scientificName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }

                Spacer()

                NavigationLink(destination: CropDetailView(crop: crop)) {
                    Text("विवरण")
                        .font(.caption)
                        .foregroundColor(.primaryGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.primaryGreen.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Conditions Section

    private var conditionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("पाई गई समस्याएं")
                .font(.headline)

            ForEach(diagnosis.diagnosedConditions) { condition in
                ConditionDetailCard(condition: condition)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Affected Areas Section

    private var affectedAreasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("प्रभावित क्षेत्र")
                .font(.headline)

            HStack {
                ForEach(diagnosis.affectedAreas.prefix(5)) { area in
                    VStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("\(Int(area.confidence * 100))%")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            )

                        Text(area.label)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Recommendations Section

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("सुझाव")
                .font(.headline)

            ForEach(diagnosis.recommendations) { recommendation in
                RecommendationDetailCard(recommendation: recommendation)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Set reminder
            Button(action: {
                setFollowUpReminder()
            }) {
                HStack {
                    Image(systemName: "bell.fill")
                    Text("फॉलो-अप याद दिलाना सेट करें")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen)
                .cornerRadius(12)
            }

            // Share report
            Button(action: {
                shareReport()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("रिपोर्ट साझा करें")
                }
                .font(.headline)
                .foregroundColor(.primaryGreen)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen.opacity(0.1))
                .cornerRadius(12)
            }

            // Ask expert
            Button(action: {
                askExpert()
            }) {
                HStack {
                    Image(systemName: "person.fill.questionmark")
                    Text("विशेषज्ञ से पूछें")
                }
                .font(.headline)
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Actions

    private func setFollowUpReminder() {
        NotificationManager.shared.scheduleFollowUpNotification(for: diagnosis)
        voiceAssistant.speakHindi("फॉलो-अप याद दिलाना 3 दिन बाद के लिए सेट किया गया")
    }

    private func shareReport() {
        // Generate and share report
    }

    private func askExpert() {
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToExpert"),
            object: nil,
            userInfo: ["diagnosisId": diagnosis.id.uuidString]
        )
    }
}

// MARK: - Health Score Card

struct HealthScoreCard: View {
    let score: Double
    let status: HealthStatus

    var body: some View {
        HStack(spacing: 20) {
            // Score circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: score / 100)
                    .stroke(status.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(score))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(status.color)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("स्वास्थ्य स्कोर")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: status.icon)
                        .foregroundColor(status.color)

                    Text(status.displayNameHindi)
                        .font(.headline)
                        .foregroundColor(status.color)
                }
            }

            Spacer()
        }
        .padding()
        .background(status.color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Condition Detail Card

struct ConditionDetailCard: View {
    let condition: DiagnosedCondition
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(condition.conditionNameHindi)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        if let disease = condition.disease {
                            Text(disease.type.displayNameHindi)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // Confidence
                    VStack(alignment: .trailing) {
                        Text("\(Int(condition.confidence * 100))%")
                            .font(.headline)
                            .foregroundColor(condition.severity.color)

                        Text("विश्वास")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Severity badge
            HStack {
                Text("गंभीरता:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(condition.severity.displayNameHindi)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(condition.severity.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(condition.severity.color.opacity(0.15))
                    .cornerRadius(4)
            }

            // Expanded content
            if isExpanded {
                Divider()

                Text(condition.descriptionHindi)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let disease = condition.disease {
                    NavigationLink(destination: DiseaseDetailView(disease: disease)) {
                        HStack {
                            Text("उपचार देखें")
                            Image(systemName: "arrow.right")
                        }
                        .font(.subheadline)
                        .foregroundColor(.primaryGreen)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Recommendation Detail Card

struct RecommendationDetailCard: View {
    let recommendation: Recommendation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Priority indicator
            ZStack {
                Circle()
                    .fill(recommendation.actionType.color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Text("\(recommendation.priority)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(recommendation.actionType.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.titleHindi)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(recommendation.descriptionHindi)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Text(recommendation.actionType.displayNameHindi)
                        .font(.caption2)
                        .foregroundColor(recommendation.actionType.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(recommendation.actionType.color.opacity(0.1))
                        .cornerRadius(4)

                    if let deadline = recommendation.deadline {
                        Text("तक: \(formatDate(deadline))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "hi_IN")
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Affected Area Marker

struct AffectedAreaMarker: View {
    let area: AffectedArea
    let imageSize: CGSize

    var body: some View {
        Rectangle()
            .stroke(Color.red, lineWidth: 2)
            .background(Color.red.opacity(0.1))
            .frame(
                width: area.boundingBox.width * imageSize.width,
                height: area.boundingBox.height * imageSize.height
            )
            .position(
                x: area.boundingBox.midX * imageSize.width,
                y: area.boundingBox.midY * imageSize.height
            )
            .overlay(
                Text(area.label)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(2)
                    .background(Color.red)
                    .cornerRadius(4)
                    .position(
                        x: area.boundingBox.midX * imageSize.width,
                        y: (area.boundingBox.minY * imageSize.height) - 10
                    )
            )
    }
}

// MARK: - Diagnosis Result View (Modal)

struct DiagnosisResultView: View {
    let result: DiagnosisResult
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var voiceAssistant: VoiceAssistantService

    var body: some View {
        NavigationView {
            DiagnosisDetailView(diagnosis: result)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("बंद करें") { dismiss() }
                    }
                }
        }
        .onAppear {
            voiceAssistant.speakDiagnosisResult(result)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        DiagnosisDetailView(diagnosis: DiagnosisResult())
            .environmentObject(VoiceAssistantService.shared)
    }
}
