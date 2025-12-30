//
//  CropDiagnosisService.swift
//  FasalRakshak
//
//  AI-powered crop disease diagnosis service using Vision and ML
//

import Foundation
import UIKit
import Vision
import CoreML
import Combine

class CropDiagnosisService: ObservableObject {
    static let shared = CropDiagnosisService()

    @Published var isProcessing: Bool = false
    @Published var progress: Double = 0.0
    @Published var lastError: DiagnosisError?

    private let apiService = APIService.shared
    private let offlineManager = OfflineDataManager.shared

    // MARK: - Public Methods

    /// Analyze a crop image for diseases and health issues
    func analyzeCropImage(_ image: UIImage, cropType: Crop? = nil) async throws -> DiagnosisResult {
        isProcessing = true
        progress = 0.0
        lastError = nil

        defer {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.progress = 1.0
            }
        }

        do {
            // Step 1: Preprocess image
            updateProgress(0.1)
            guard let processedImage = preprocessImage(image) else {
                throw DiagnosisError.imageProcessingFailed
            }

            // Step 2: Try online analysis first
            if await NetworkMonitor.shared.isConnected {
                updateProgress(0.3)
                return try await performOnlineAnalysis(processedImage, cropType: cropType)
            } else {
                // Step 3: Fall back to offline analysis
                updateProgress(0.3)
                return try await performOfflineAnalysis(processedImage, cropType: cropType)
            }
        } catch {
            lastError = error as? DiagnosisError ?? .unknown(error.localizedDescription)
            throw error
        }
    }

    /// Identify crop type from image
    func identifyCrop(_ image: UIImage) async throws -> Crop? {
        guard let processedImage = preprocessImage(image) else {
            throw DiagnosisError.imageProcessingFailed
        }

        // Use Vision framework for plant identification
        let classifications = try await classifyImage(processedImage)

        // Match classification to known crops
        for classification in classifications {
            if let crop = matchCropFromClassification(classification) {
                return crop
            }
        }

        return nil
    }

    /// Get possible diagnoses based on symptoms
    func diagnoseFromSymptoms(_ symptoms: [Symptom], crop: Crop? = nil) -> [DiagnosedCondition] {
        let diseases = offlineManager.getAllDiseases()

        var matchedConditions: [DiagnosedCondition] = []

        for disease in diseases {
            // Check if crop matches
            if let crop = crop, !disease.affectedCrops.contains(crop.id.uuidString) {
                continue
            }

            // Calculate symptom match score
            let matchScore = calculateSymptomMatchScore(symptoms: symptoms, disease: disease)

            if matchScore > 0.3 {
                let condition = DiagnosedCondition(
                    disease: disease,
                    conditionName: disease.name,
                    conditionNameHindi: disease.nameHindi,
                    confidence: matchScore,
                    severity: disease.severity,
                    description: disease.symptoms.first?.description ?? "",
                    descriptionHindi: disease.symptoms.first?.descriptionHindi ?? ""
                )
                matchedConditions.append(condition)
            }
        }

        // Sort by confidence
        return matchedConditions.sorted { $0.confidence > $1.confidence }
    }

    // MARK: - Private Methods

    private func preprocessImage(_ image: UIImage) -> UIImage? {
        // Resize to optimal size for ML model
        let maxDimension: CGFloat = 1024
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)

        if scale >= 1.0 {
            return image
        }

        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    private func performOnlineAnalysis(_ image: UIImage, cropType: Crop?) async throws -> DiagnosisResult {
        updateProgress(0.4)

        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw DiagnosisError.imageProcessingFailed
        }

        updateProgress(0.5)

        // Send to backend API for AI analysis
        let response = try await apiService.analyzeCropImage(imageData: imageData, cropType: cropType?.id.uuidString)

        updateProgress(0.8)

        // Process response and create diagnosis result
        let result = try processAPIResponse(response, image: image)

        updateProgress(0.9)

        // Cache result for offline access
        try? await offlineManager.cacheDiagnosisResult(result)

        return result
    }

    private func performOfflineAnalysis(_ image: UIImage, cropType: Crop?) async throws -> DiagnosisResult {
        updateProgress(0.4)

        // Use on-device Vision framework
        let classifications = try await classifyImage(image)

        updateProgress(0.6)

        // Match to known diseases
        let conditions = matchClassificationsToDiseases(classifications, crop: cropType)

        updateProgress(0.8)

        // Create diagnosis result
        let result = DiagnosisResult(
            imageData: image.jpegData(compressionQuality: 0.8),
            identifiedCrop: cropType,
            diagnosedConditions: conditions,
            overallHealthScore: calculateHealthScore(conditions),
            recommendations: generateRecommendations(conditions)
        )

        return result
    }

    private func classifyImage(_ image: UIImage) async throws -> [(identifier: String, confidence: Float)] {
        return try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(throwing: DiagnosisError.imageProcessingFailed)
                return
            }

            // Create Vision request
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: DiagnosisError.visionError(error.localizedDescription))
                    return
                }

                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let classifications = results.prefix(10).map { observation in
                    (identifier: observation.identifier, confidence: observation.confidence)
                }

                continuation.resume(returning: classifications)
            }

            // Perform request
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: DiagnosisError.visionError(error.localizedDescription))
            }
        }
    }

    private func matchCropFromClassification(_ classification: (identifier: String, confidence: Float)) -> Crop? {
        let identifier = classification.identifier.lowercased()
        let crops = offlineManager.getAllCrops()

        // Simple matching based on crop names
        for crop in crops {
            if identifier.contains(crop.name.lowercased()) ||
                identifier.contains(crop.scientificName.lowercased()) {
                return crop
            }
        }

        return nil
    }

    private func matchClassificationsToDiseases(_ classifications: [(identifier: String, confidence: Float)], crop: Crop?) -> [DiagnosedCondition] {
        var conditions: [DiagnosedCondition] = []
        let diseases = offlineManager.getAllDiseases()

        // Match classifications to disease keywords
        for classification in classifications {
            let identifier = classification.identifier.lowercased()

            for disease in diseases {
                if crop != nil && !disease.affectedCrops.contains(crop!.id.uuidString) {
                    continue
                }

                // Check for disease-related keywords
                let diseaseKeywords = getDiseaseKeywords(disease)
                for keyword in diseaseKeywords {
                    if identifier.contains(keyword.lowercased()) {
                        let condition = DiagnosedCondition(
                            disease: disease,
                            conditionName: disease.name,
                            conditionNameHindi: disease.nameHindi,
                            confidence: Double(classification.confidence),
                            severity: disease.severity,
                            description: disease.symptoms.first?.description ?? "",
                            descriptionHindi: disease.symptoms.first?.descriptionHindi ?? ""
                        )
                        conditions.append(condition)
                        break
                    }
                }
            }
        }

        return conditions.sorted { $0.confidence > $1.confidence }
    }

    private func getDiseaseKeywords(_ disease: Disease) -> [String] {
        var keywords: [String] = [disease.name]

        // Add type-specific keywords
        switch disease.type {
        case .fungal:
            keywords.append(contentsOf: ["fungus", "mold", "mildew", "rust", "blight", "spot"])
        case .bacterial:
            keywords.append(contentsOf: ["bacteria", "wilt", "rot", "canker"])
        case .viral:
            keywords.append(contentsOf: ["virus", "mosaic", "yellowing", "curl"])
        case .nutrientDeficiency:
            keywords.append(contentsOf: ["deficiency", "chlorosis", "yellowing", "necrosis"])
        case .pest:
            keywords.append(contentsOf: ["insect", "pest", "aphid", "caterpillar", "beetle"])
        case .waterStress:
            keywords.append(contentsOf: ["drought", "wilting", "drying"])
        case .physiological:
            keywords.append(contentsOf: ["stress", "damage", "burn"])
        }

        return keywords
    }

    private func calculateSymptomMatchScore(symptoms: [Symptom], disease: Disease) -> Double {
        guard !disease.symptoms.isEmpty else { return 0 }

        var matchCount = 0
        for symptom in symptoms {
            if disease.symptoms.contains(where: { $0.id == symptom.id }) {
                matchCount += 1
            }
        }

        return Double(matchCount) / Double(disease.symptoms.count)
    }

    private func calculateHealthScore(_ conditions: [DiagnosedCondition]) -> Double {
        if conditions.isEmpty {
            return 100
        }

        var totalImpact: Double = 0
        for condition in conditions {
            let severityImpact: Double
            switch condition.severity {
            case .low: severityImpact = 10
            case .moderate: severityImpact = 25
            case .high: severityImpact = 40
            case .critical: severityImpact = 60
            }
            totalImpact += severityImpact * condition.confidence
        }

        return max(0, 100 - totalImpact)
    }

    private func generateRecommendations(_ conditions: [DiagnosedCondition]) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        for (index, condition) in conditions.prefix(3).enumerated() {
            if let disease = condition.disease {
                // Immediate treatment recommendation
                if let treatment = disease.organicTreatments.first ?? disease.chemicalTreatments.first {
                    let rec = Recommendation(
                        priority: index + 1,
                        title: "Apply \(treatment.name)",
                        titleHindi: "\(treatment.nameHindi) लगाएं",
                        description: treatment.description,
                        descriptionHindi: treatment.descriptionHindi,
                        actionType: condition.severity == .critical || condition.severity == .high ? .immediate : .scheduled,
                        treatment: treatment
                    )
                    recommendations.append(rec)
                }

                // Preventive recommendation
                if let preventive = disease.preventiveMeasures.first {
                    let rec = Recommendation(
                        priority: index + 4,
                        title: "Prevent spread",
                        titleHindi: "फैलाव रोकें",
                        description: preventive,
                        descriptionHindi: disease.preventiveMeasuresHindi.first ?? preventive,
                        actionType: .preventive
                    )
                    recommendations.append(rec)
                }
            }
        }

        // Add monitoring recommendation
        if !conditions.isEmpty {
            let monitorRec = Recommendation(
                priority: 10,
                title: "Monitor crop health",
                titleHindi: "फसल स्वास्थ्य की निगरानी करें",
                description: "Check your crop again in 3-5 days to monitor progress",
                descriptionHindi: "3-5 दिनों में अपनी फसल की फिर से जांच करें",
                actionType: .monitoring,
                deadline: Calendar.current.date(byAdding: .day, value: 4, to: Date())
            )
            recommendations.append(monitorRec)
        }

        return recommendations.sorted { $0.priority < $1.priority }
    }

    private func processAPIResponse(_ response: CropAnalysisResponse, image: UIImage) throws -> DiagnosisResult {
        var conditions: [DiagnosedCondition] = []

        for detection in response.detections {
            let condition = DiagnosedCondition(
                conditionName: detection.name,
                conditionNameHindi: detection.nameHindi,
                confidence: detection.confidence,
                severity: DiseaseSeverity(rawValue: detection.severity) ?? .moderate,
                description: detection.description,
                descriptionHindi: detection.descriptionHindi
            )
            conditions.append(condition)
        }

        var affectedAreas: [AffectedArea] = []
        for area in response.affectedAreas {
            let affected = AffectedArea(
                boundingBox: CGRect(x: area.x, y: area.y, width: area.width, height: area.height),
                label: area.label,
                confidence: area.confidence
            )
            affectedAreas.append(affected)
        }

        var crop: Crop?
        if let cropId = response.identifiedCropId {
            crop = offlineManager.getCrop(id: cropId)
        }

        return DiagnosisResult(
            imageData: image.jpegData(compressionQuality: 0.8),
            identifiedCrop: crop,
            diagnosedConditions: conditions,
            overallHealthScore: response.healthScore,
            recommendations: response.recommendations.map { rec in
                Recommendation(
                    priority: rec.priority,
                    title: rec.title,
                    titleHindi: rec.titleHindi,
                    description: rec.description,
                    descriptionHindi: rec.descriptionHindi,
                    actionType: ActionType(rawValue: rec.actionType) ?? .scheduled
                )
            },
            affectedAreas: affectedAreas
        )
    }

    private func updateProgress(_ value: Double) {
        DispatchQueue.main.async {
            self.progress = value
        }
    }
}

// MARK: - Diagnosis Errors

enum DiagnosisError: Error, LocalizedError {
    case imageProcessingFailed
    case networkError
    case visionError(String)
    case apiError(String)
    case offlineNotAvailable
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process image"
        case .networkError:
            return "Network connection error"
        case .visionError(let message):
            return "Vision analysis error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .offlineNotAvailable:
            return "Offline analysis not available"
        case .unknown(let message):
            return message
        }
    }

    var errorDescriptionHindi: String {
        switch self {
        case .imageProcessingFailed:
            return "फोटो प्रोसेस करने में समस्या"
        case .networkError:
            return "नेटवर्क कनेक्शन त्रुटि"
        case .visionError:
            return "विश्लेषण में त्रुटि"
        case .apiError:
            return "सर्वर त्रुटि"
        case .offlineNotAvailable:
            return "ऑफलाइन विश्लेषण उपलब्ध नहीं"
        case .unknown:
            return "अज्ञात त्रुटि"
        }
    }
}

// MARK: - API Response Models

struct CropAnalysisResponse: Codable {
    let success: Bool
    let healthScore: Double
    let identifiedCropId: String?
    let detections: [DetectionResult]
    let affectedAreas: [BoundingBoxResult]
    let recommendations: [RecommendationResult]
}

struct DetectionResult: Codable {
    let name: String
    let nameHindi: String
    let confidence: Double
    let severity: String
    let description: String
    let descriptionHindi: String
}

struct BoundingBoxResult: Codable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let label: String
    let confidence: Double
}

struct RecommendationResult: Codable {
    let priority: Int
    let title: String
    let titleHindi: String
    let description: String
    let descriptionHindi: String
    let actionType: String
}
