//
//  DiseaseDetailView.swift
//  FasalRakshak
//
//  Detailed disease information with treatment guides
//

import SwiftUI

struct DiseaseDetailView: View {
    let disease: Disease
    @EnvironmentObject var voiceAssistant: VoiceAssistantService
    @State private var selectedTreatmentType: TreatmentTab = .organic

    enum TreatmentTab: String, CaseIterable {
        case organic = "जैविक"
        case chemical = "रासायनिक"
        case prevention = "रोकथाम"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Disease header
                diseaseHeader

                // Symptoms section
                symptomsSection

                // Causes section
                causesSection

                // Treatment tabs
                treatmentSection

                // Spread information
                spreadSection

                // Action buttons
                actionButtons
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(disease.nameHindi)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: speakDiseaseInfo) {
                    Image(systemName: "speaker.wave.2.fill")
                }
            }
        }
    }

    // MARK: - Disease Header

    private var diseaseHeader: some View {
        VStack(spacing: 16) {
            // Type icon
            ZStack {
                Circle()
                    .fill(disease.type.color.opacity(0.15))
                    .frame(width: 80, height: 80)

                Text(disease.type.icon)
                    .font(.system(size: 40))
            }

            // Name and type
            VStack(spacing: 4) {
                Text(disease.nameHindi)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(disease.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(disease.type.displayNameHindi)
                    .font(.caption)
                    .foregroundColor(disease.type.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(disease.type.color.opacity(0.1))
                    .cornerRadius(12)
            }

            // Severity indicator
            HStack {
                Text("गंभीरता:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(0..<4) { index in
                    Circle()
                        .fill(index < severityLevel ? disease.severity.color : Color.gray.opacity(0.2))
                        .frame(width: 12, height: 12)
                }

                Text(disease.severity.displayNameHindi)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(disease.severity.color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }

    private var severityLevel: Int {
        switch disease.severity {
        case .low: return 1
        case .moderate: return 2
        case .high: return 3
        case .critical: return 4
        }
    }

    // MARK: - Symptoms Section

    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "लक्षण", icon: "eye.fill")

            if disease.symptoms.isEmpty {
                Text("लक्षण की जानकारी उपलब्ध नहीं है")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(disease.symptoms) { symptom in
                    SymptomInfoCard(symptom: symptom)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Causes Section

    private var causesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "कारण", icon: "questionmark.circle.fill")

            ForEach(disease.causesHindi.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 12) {
                    Text("•")
                        .foregroundColor(.primaryGreen)

                    Text(disease.causesHindi[index])
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Treatment Section

    private var treatmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "उपचार", icon: "cross.case.fill")

            // Treatment type tabs
            HStack(spacing: 0) {
                ForEach(TreatmentTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTreatmentType = tab }) {
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedTreatmentType == tab ? .semibold : .regular)
                            .foregroundColor(selectedTreatmentType == tab ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedTreatmentType == tab ? Color.primaryGreen : Color.clear)
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            // Treatment content
            switch selectedTreatmentType {
            case .organic:
                treatmentList(disease.organicTreatments, type: .organic)
            case .chemical:
                treatmentList(disease.chemicalTreatments, type: .chemical)
            case .prevention:
                preventionList
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    private func treatmentList(_ treatments: [Treatment], type: TreatmentType) -> some View {
        VStack(spacing: 16) {
            if treatments.isEmpty {
                Text("उपचार की जानकारी उपलब्ध नहीं है")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(treatments) { treatment in
                    TreatmentCard(treatment: treatment)
                }
            }
        }
    }

    private var preventionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(disease.preventiveMeasuresHindi.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 28, height: 28)

                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }

                    Text(disease.preventiveMeasuresHindi[index])
                        .font(.subheadline)
                }
            }
        }
    }

    // MARK: - Spread Section

    private var spreadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "फैलाव का तरीका", icon: "arrow.triangle.branch")

            Text(disease.spreadMechanismHindi)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Seasonal prevalence
            if !disease.seasonalPrevalence.isEmpty {
                HStack {
                    Text("मौसम:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(disease.seasonalPrevalence, id: \.self) { season in
                        Text(season.displayNameHindi)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: speakDiseaseInfo) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("सारी जानकारी सुनें")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen)
                .cornerRadius(12)
            }

            Button(action: {}) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("जानकारी साझा करें")
                }
                .font(.headline)
                .foregroundColor(.primaryGreen)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Voice

    private func speakDiseaseInfo() {
        var speech = "\(disease.nameHindi)। "
        speech += "यह \(disease.type.displayNameHindi) है। "
        speech += "गंभीरता \(disease.severity.displayNameHindi) है। "

        if !disease.causesHindi.isEmpty {
            speech += "कारण: "
            for cause in disease.causesHindi.prefix(2) {
                speech += "\(cause)। "
            }
        }

        if let treatment = disease.organicTreatments.first ?? disease.chemicalTreatments.first {
            speech += "उपचार: \(treatment.nameHindi)। \(treatment.descriptionHindi)"
        }

        voiceAssistant.speakHindi(speech)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.primaryGreen)

            Text(title)
                .font(.headline)
        }
    }
}

// MARK: - Symptom Info Card

struct SymptomInfoCard: View {
    let symptom: Symptom

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symptom.icon)
                .font(.title3)
                .foregroundColor(.primaryGreen)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(symptom.nameHindi)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(symptom.descriptionHindi)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("प्रभावित हिस्सा: \(symptom.affectedPart.displayNameHindi)")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Treatment Card

struct TreatmentCard: View {
    let treatment: Treatment
    @EnvironmentObject var voiceAssistant: VoiceAssistantService
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(treatment.nameHindi)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text(treatment.type.displayNameHindi)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        voiceAssistant.speakTreatmentSteps(treatment)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.primaryGreen)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                Divider()

                // Description
                Text(treatment.descriptionHindi)
                    .font(.subheadline)

                // Details
                TreatmentDetailRow(label: "प्रयोग विधि:", value: treatment.applicationMethodHindi)
                TreatmentDetailRow(label: "मात्रा:", value: treatment.dosage)
                TreatmentDetailRow(label: "आवृत्ति:", value: treatment.frequencyHindi)

                if let cost = treatment.estimatedCost {
                    TreatmentDetailRow(label: "अनुमानित लागत:", value: cost)
                }

                // Precautions
                if !treatment.precautionsHindi.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("सावधानियां:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)

                        ForEach(treatment.precautionsHindi, id: \.self) { precaution in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)

                                Text(precaution)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct TreatmentDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        DiseaseDetailView(disease: Disease(
            name: "Rice Blast",
            nameHindi: "धान का ब्लास्ट",
            type: .fungal
        ))
        .environmentObject(VoiceAssistantService.shared)
    }
}
