//
//  SymptomCheckerView.swift
//  FasalRakshak
//
//  Guided symptom checker interface for identifying crop issues
//

import SwiftUI

struct SymptomCheckerView: View {
    @EnvironmentObject var voiceAssistant: VoiceAssistantService
    @EnvironmentObject var offlineManager: OfflineDataManager

    @State private var selectedCrop: Crop?
    @State private var selectedPlantPart: PlantPart?
    @State private var selectedSymptoms: Set<Symptom> = []
    @State private var currentStep: CheckerStep = .selectCrop
    @State private var diagnosisResults: [DiagnosedCondition] = []
    @State private var showingResults = false

    enum CheckerStep: Int, CaseIterable {
        case selectCrop = 0
        case selectPart = 1
        case selectSymptoms = 2
        case results = 3

        var title: String {
            switch self {
            case .selectCrop: return "फसल चुनें"
            case .selectPart: return "प्रभावित हिस्सा"
            case .selectSymptoms: return "लक्षण चुनें"
            case .results: return "परिणाम"
            }
        }

        var subtitle: String {
            switch self {
            case .selectCrop: return "किस फसल में समस्या है?"
            case .selectPart: return "पौधे का कौन सा हिस्सा प्रभावित है?"
            case .selectSymptoms: return "आप क्या देख रहे हैं?"
            case .results: return "संभावित समस्याएं"
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator

                // Step content
                ScrollView {
                    VStack(spacing: 20) {
                        // Step header
                        stepHeader

                        // Step content
                        stepContent
                    }
                    .padding()
                }

                // Navigation buttons
                navigationButtons
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("लक्षण जांच")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        speakCurrentStep()
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
            }
            .onAppear {
                speakCurrentStep()
            }
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 4) {
            ForEach(CheckerStep.allCases, id: \.rawValue) { step in
                Rectangle()
                    .fill(step.rawValue <= currentStep.rawValue ? Color.primaryGreen : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Step Header

    private var stepHeader: some View {
        VStack(spacing: 8) {
            Text(currentStep.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(currentStep.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .selectCrop:
            cropSelectionView
        case .selectPart:
            plantPartSelectionView
        case .selectSymptoms:
            symptomSelectionView
        case .results:
            resultsView
        }
    }

    // MARK: - Crop Selection

    private var cropSelectionView: some View {
        VStack(spacing: 16) {
            ForEach(CropCategory.allCases, id: \.self) { category in
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(category.icon) \(category.displayNameHindi)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(offlineManager.getCropsByCategory(category)) { crop in
                            CropSelectionCard(
                                crop: crop,
                                isSelected: selectedCrop?.id == crop.id
                            ) {
                                selectedCrop = crop
                                voiceAssistant.speakHindi("\(crop.nameHindi) चुना गया")
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
            }
        }
    }

    // MARK: - Plant Part Selection

    private var plantPartSelectionView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(PlantPart.allCases, id: \.self) { part in
                PlantPartCard(
                    part: part,
                    isSelected: selectedPlantPart == part
                ) {
                    selectedPlantPart = part
                    voiceAssistant.speakHindi("\(part.displayNameHindi) चुना गया")
                }
            }
        }
    }

    // MARK: - Symptom Selection

    private var symptomSelectionView: some View {
        VStack(spacing: 16) {
            let symptoms = selectedPlantPart != nil
                ? offlineManager.getSymptomsByPlantPart(selectedPlantPart!)
                : offlineManager.getAllSymptoms()

            ForEach(symptoms) { symptom in
                SymptomSelectionCard(
                    symptom: symptom,
                    isSelected: selectedSymptoms.contains(symptom)
                ) {
                    if selectedSymptoms.contains(symptom) {
                        selectedSymptoms.remove(symptom)
                    } else {
                        selectedSymptoms.insert(symptom)
                        voiceAssistant.speakHindi(symptom.nameHindi)
                    }
                }
            }

            if !selectedSymptoms.isEmpty {
                Text("चुने गए लक्षण: \(selectedSymptoms.count)")
                    .font(.subheadline)
                    .foregroundColor(.primaryGreen)
                    .padding()
                    .background(Color.primaryGreen.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Results View

    private var resultsView: some View {
        VStack(spacing: 16) {
            if diagnosisResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("कोई गंभीर समस्या नहीं मिली")
                        .font(.headline)

                    Text("आपकी फसल स्वस्थ प्रतीत होती है। नियमित देखभाल जारी रखें।")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
            } else {
                ForEach(diagnosisResults) { condition in
                    DiagnosedConditionCard(condition: condition)
                }
            }

            // Recommendations
            VStack(alignment: .leading, spacing: 12) {
                Text("सुझाव")
                    .font(.headline)

                if diagnosisResults.isEmpty {
                    RecommendationRow(
                        icon: "drop.fill",
                        title: "नियमित सिंचाई",
                        titleHindi: "नियमित रूप से पानी दें"
                    )
                    RecommendationRow(
                        icon: "leaf.fill",
                        title: "खाद डालें",
                        titleHindi: "आवश्यकतानुसार खाद का प्रयोग करें"
                    )
                } else {
                    ForEach(diagnosisResults.prefix(2)) { condition in
                        if let disease = condition.disease,
                           let treatment = disease.organicTreatments.first {
                            RecommendationRow(
                                icon: "cross.case.fill",
                                title: treatment.name,
                                titleHindi: treatment.nameHindi
                            )
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)

            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    // Take photo for confirmation
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavigateToCamera"),
                        object: nil
                    )
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("फोटो से पुष्टि करें")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen)
                    .cornerRadius(12)
                }

                Button(action: {
                    // Ask expert
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavigateToExpert"),
                        object: nil
                    )
                }) {
                    HStack {
                        Image(systemName: "person.fill.questionmark")
                        Text("विशेषज्ञ से पूछें")
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
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button
            if currentStep != .selectCrop {
                Button(action: goBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("पीछे")
                    }
                    .font(.headline)
                    .foregroundColor(.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen.opacity(0.1))
                    .cornerRadius(12)
                }
            }

            // Next/Submit button
            if currentStep != .results {
                Button(action: goNext) {
                    HStack {
                        Text(currentStep == .selectSymptoms ? "परिणाम देखें" : "आगे")
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceed ? Color.primaryGreen : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!canProceed)
            } else {
                Button(action: startOver) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("नई जांच")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
    }

    // MARK: - Navigation Logic

    private var canProceed: Bool {
        switch currentStep {
        case .selectCrop:
            return selectedCrop != nil
        case .selectPart:
            return selectedPlantPart != nil
        case .selectSymptoms:
            return !selectedSymptoms.isEmpty
        case .results:
            return true
        }
    }

    private func goBack() {
        withAnimation {
            switch currentStep {
            case .selectPart:
                currentStep = .selectCrop
            case .selectSymptoms:
                currentStep = .selectPart
            case .results:
                currentStep = .selectSymptoms
            default:
                break
            }
        }
        speakCurrentStep()
    }

    private func goNext() {
        withAnimation {
            switch currentStep {
            case .selectCrop:
                currentStep = .selectPart
            case .selectPart:
                currentStep = .selectSymptoms
            case .selectSymptoms:
                performDiagnosis()
                currentStep = .results
            default:
                break
            }
        }
        speakCurrentStep()
    }

    private func startOver() {
        withAnimation {
            selectedCrop = nil
            selectedPlantPart = nil
            selectedSymptoms = []
            diagnosisResults = []
            currentStep = .selectCrop
        }
        speakCurrentStep()
    }

    private func performDiagnosis() {
        let diagnosisService = CropDiagnosisService.shared
        diagnosisResults = diagnosisService.diagnoseFromSymptoms(
            Array(selectedSymptoms),
            crop: selectedCrop
        )

        // Speak results
        if diagnosisResults.isEmpty {
            voiceAssistant.speakHindi("कोई गंभीर समस्या नहीं मिली। आपकी फसल स्वस्थ प्रतीत होती है।")
        } else {
            var speechText = "संभावित समस्याएं पाई गईं। "
            for (index, condition) in diagnosisResults.prefix(3).enumerated() {
                speechText += "\(index + 1). \(condition.conditionNameHindi)। "
            }
            voiceAssistant.speakHindi(speechText)
        }
    }

    private func speakCurrentStep() {
        voiceAssistant.speakHindi("\(currentStep.title)। \(currentStep.subtitle)")
    }
}

// MARK: - Crop Selection Card

struct CropSelectionCard: View {
    let crop: Crop
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(crop.category.icon)
                    .font(.title2)

                Text(crop.nameHindi)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 80)
            .background(isSelected ? Color.primaryGreen.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryGreen : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Plant Part Card

struct PlantPartCard: View {
    let part: PlantPart
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: part.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : .primaryGreen)

                Text(part.displayNameHindi)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(isSelected ? Color.primaryGreen : Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Symptom Selection Card

struct SymptomSelectionCard: View {
    let symptom: Symptom
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.primaryGreen : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Image(systemName: symptom.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .primaryGreen)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(symptom.nameHindi)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(symptom.descriptionHindi)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .primaryGreen : .gray.opacity(0.3))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryGreen : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Diagnosed Condition Card

struct DiagnosedConditionCard: View {
    let condition: DiagnosedCondition

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Disease type icon
                if let disease = condition.disease {
                    Text(disease.type.icon)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(condition.conditionNameHindi)
                        .font(.headline)

                    Text(condition.disease?.type.displayNameHindi ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Confidence badge
                VStack {
                    Text("\(Int(condition.confidence * 100))%")
                        .font(.headline)
                        .foregroundColor(condition.severity.color)

                    Text("संभावना")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Severity indicator
            HStack {
                Text("गंभीरता:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(condition.severity.displayNameHindi)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(condition.severity.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(condition.severity.color.opacity(0.1))
                    .cornerRadius(4)
            }

            // Description
            Text(condition.descriptionHindi)
                .font(.caption)
                .foregroundColor(.secondary)

            // View details button
            if condition.disease != nil {
                NavigationLink(destination: DiseaseDetailView(disease: condition.disease!)) {
                    Text("विस्तार से देखें →")
                        .font(.caption)
                        .foregroundColor(.primaryGreen)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Recommendation Row

struct RecommendationRow: View {
    let icon: String
    let title: String
    let titleHindi: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primaryGreen)
                .frame(width: 30)

            Text(titleHindi)
                .font(.subheadline)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    SymptomCheckerView()
        .environmentObject(VoiceAssistantService.shared)
        .environmentObject(OfflineDataManager.shared)
}
