//
//  APIService.swift
//  FasalRakshak
//
//  Backend API service for crop analysis and expert consultation
//

import Foundation
import UIKit
import Combine

class APIService: ObservableObject {
    static let shared = APIService()

    // API Configuration
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession

    @Published var isLoading: Bool = false

    init() {
        // Load configuration from environment or config file
        // For development: http://localhost:8000
        // For production: Deploy backend and update this URL
        self.baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:8000"
        self.apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""

        // Configure URLSession with appropriate timeouts for rural connectivity
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60 // 60 seconds for slow connections
        config.timeoutIntervalForResource = 300 // 5 minutes for large uploads
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        config.httpMaximumConnectionsPerHost = 2 // Limit concurrent connections

        self.session = URLSession(configuration: config)
    }

    // MARK: - Crop Analysis

    /// Analyze crop image for diseases using AI backend
    func analyzeCropImage(imageData: Data, cropType: String?, language: String = "en") async throws -> DiagnosisResult {
        isLoading = true
        defer { isLoading = false }

        let endpoint = "/api/diagnose"
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        // Add query parameters
        var queryItems: [URLQueryItem] = []
        if let cropType = cropType {
            queryItems.append(URLQueryItem(name: "crop_type", value: cropType))
        }
        queryItems.append(URLQueryItem(name: "language", value: language))
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Prepare multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"crop.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        print("🌐 Sending request to: \(url.absoluteString)")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("📡 Response status code: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            // Try to parse error message
            if let errorMessage = String(data: data, encoding: .utf8) {
                print("❌ Error response: \(errorMessage)")
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let apiResponse = try decoder.decode(BackendDiagnosisResponse.self, from: data)

        // Convert backend response to app's DiagnosisResult
        return convertToAppDiagnosisResult(apiResponse)
    }

    /// Convert backend API response to app's DiagnosisResult model
    private func convertToAppDiagnosisResult(_ response: BackendDiagnosisResponse) -> DiagnosisResult {
        // Parse detected conditions
        let condition = DiagnosedCondition(
            conditionName: response.diseaseName,
            conditionNameHindi: response.diseaseNameLocal,
            confidence: response.confidence / 100.0, // Convert percentage to 0-1
            severity: parseSeverity(response.severity),
            description: response.description,
            descriptionHindi: response.description // TODO: Get Hindi from backend
        )

        // Convert treatments to recommendations
        var recommendations: [Recommendation] = []
        var priority = 1

        // Add organic treatments as recommendations
        for orgTreatment in response.organicTreatments {
            let treatment = Treatment(
                name: orgTreatment.name,
                nameHindi: orgTreatment.name, // TODO: Translate
                description: orgTreatment.description,
                descriptionHindi: orgTreatment.description,
                type: .organic,
                applicationMethod: orgTreatment.method,
                applicationMethodHindi: orgTreatment.method,
                frequency: orgTreatment.frequency ?? "As needed",
                frequencyHindi: orgTreatment.frequency ?? "आवश्यकतानुसार",
                dosage: "See instructions"
            )

            recommendations.append(Recommendation(
                priority: priority,
                title: "Apply \(orgTreatment.name)",
                titleHindi: "\(orgTreatment.name) लगाएं",
                description: orgTreatment.description,
                descriptionHindi: orgTreatment.description,
                actionType: .immediate,
                treatment: treatment
            ))
            priority += 1
        }

        // Add chemical treatments as recommendations
        for chemTreatment in response.chemicalTreatments {
            let treatment = Treatment(
                name: chemTreatment.name,
                nameHindi: chemTreatment.name,
                description: chemTreatment.description,
                descriptionHindi: chemTreatment.description,
                type: .chemical,
                applicationMethod: chemTreatment.method,
                applicationMethodHindi: chemTreatment.method,
                frequency: "Follow label",
                frequencyHindi: "लेबल के अनुसार",
                dosage: "Follow label",
                precautions: chemTreatment.precautions ?? []
            )

            recommendations.append(Recommendation(
                priority: priority,
                title: "Apply \(chemTreatment.name)",
                titleHindi: "\(chemTreatment.name) लगाएं",
                description: chemTreatment.description,
                descriptionHindi: chemTreatment.description,
                actionType: .scheduled,
                treatment: treatment
            ))
            priority += 1
        }

        // Add preventive measures as recommendations
        for (index, measure) in response.preventiveMeasures.enumerated() {
            recommendations.append(Recommendation(
                priority: priority + index,
                title: "Prevention",
                titleHindi: "रोकथाम",
                description: measure,
                descriptionHindi: measure, // TODO: Translate
                actionType: .preventive
            ))
        }

        // Convert affected parts to affected areas with placeholder bounding boxes
        let affectedAreas = response.affectedParts.enumerated().map { (index, part) in
            AffectedArea(
                boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100),
                label: part,
                confidence: response.confidence / 100.0
            )
        }

        return DiagnosisResult(
            imageData: nil,
            identifiedCrop: nil,
            diagnosedConditions: [condition],
            overallHealthScore: calculateOverallHealth(response.confidence, response.severity),
            recommendations: recommendations,
            affectedAreas: affectedAreas
        )
    }

    private func parseSeverity(_ severity: String) -> DiseaseSeverity {
        switch severity.lowercased() {
        case "low": return .low
        case "moderate", "medium": return .moderate
        case "high", "severe": return .high
        case "critical": return .critical
        default: return .moderate
        }
    }

    private func calculateOverallHealth(_ confidence: Double, _ severity: String) -> Double {
        // Calculate health score from 0-100
        let severityImpact: Double
        switch severity.lowercased() {
        case "low": severityImpact = 10
        case "moderate", "medium": severityImpact = 30
        case "high", "severe": severityImpact = 50
        case "critical": severityImpact = 70
        default: severityImpact = 30
        }

        let confidenceFactor = confidence / 100.0
        let totalImpact = severityImpact * confidenceFactor

        return max(0, 100 - totalImpact)
    }

    // MARK: - Expert Consultation

    /// Request expert consultation
    func requestExpertConsultation(_ request: ExpertConsultationRequest) async throws -> ExpertConsultationResponse {
        let endpoint = "/expert/request"
        let url = URL(string: baseURL + endpoint)!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try encoder.encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(ExpertConsultationResponse.self, from: data)
    }

    /// Get consultation status
    func getConsultationStatus(consultationId: String) async throws -> ExpertConsultationResponse {
        let endpoint = "/expert/status/\(consultationId)"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(ExpertConsultationResponse.self, from: data)
    }

    // MARK: - Crop Database

    /// Fetch latest crop database
    func fetchCropDatabase() async throws -> [Crop] {
        let endpoint = "/crops"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Crop].self, from: data)
    }

    /// Fetch disease database
    func fetchDiseaseDatabase() async throws -> [Disease] {
        let endpoint = "/diseases"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Disease].self, from: data)
    }

    // MARK: - Analytics

    /// Submit anonymous usage analytics
    func submitAnalytics(_ event: AnalyticsEvent) async {
        let endpoint = "/analytics"
        guard let url = URL(string: baseURL + endpoint) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        do {
            request.httpBody = try encoder.encode(event)
            _ = try await session.data(for: request)
        } catch {
            // Silently fail for analytics
            print("Analytics submission failed: \(error)")
        }
    }

    // MARK: - Weather Integration

    /// Fetch weather data for location
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherContext {
        let endpoint = "/weather?lat=\(latitude)&lon=\(longitude)"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(WeatherContext.self, from: data)
    }

    // MARK: - User Management

    /// Register farmer profile
    func registerFarmer(_ profile: FarmerProfile) async throws -> FarmerProfile {
        let endpoint = "/farmers/register"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(profile)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(FarmerProfile.self, from: data)
    }

    /// Update farmer profile
    func updateFarmerProfile(_ profile: FarmerProfile) async throws -> FarmerProfile {
        let endpoint = "/farmers/\(profile.id.uuidString)"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(profile)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(FarmerProfile.self, from: data)
    }
}

// MARK: - API Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case networkError
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "Server error: \(statusCode)"
        case .decodingError:
            return "Failed to process response"
        case .networkError:
            return "Network connection error"
        case .unauthorized:
            return "Authentication required"
        }
    }

    var errorDescriptionHindi: String {
        switch self {
        case .invalidURL:
            return "अमान्य API URL"
        case .invalidResponse:
            return "सर्वर प्रतिक्रिया अमान्य"
        case .httpError:
            return "सर्वर त्रुटि"
        case .decodingError:
            return "प्रतिक्रिया प्रोसेस करने में विफल"
        case .networkError:
            return "नेटवर्क कनेक्शन त्रुटि"
        case .unauthorized:
            return "प्रमाणीकरण आवश्यक"
        }
    }
}

// MARK: - Request/Response Models

struct ExpertConsultationRequest: Codable {
    let farmerId: String
    let diagnosisId: String?
    let cropType: String
    let description: String
    let imageData: Data?
    let urgency: String
    let preferredLanguage: String
}

struct ExpertConsultationResponse: Codable {
    let consultationId: String
    let status: String
    let estimatedResponseTime: String?
    let expertName: String?
    let expertResponse: String?
    let expertResponseHindi: String?
    let recommendations: [String]?
    let createdAt: Date
    let updatedAt: Date
}

struct AnalyticsEvent: Codable {
    let eventType: String
    let eventData: [String: String]
    let timestamp: Date
    let deviceId: String
    let appVersion: String
    let region: String?
}

// MARK: - Backend API Models

/// Response from the FastAPI backend
struct BackendDiagnosisResponse: Codable {
    let diseaseName: String
    let diseaseNameLocal: String
    let confidence: Double
    let severity: String
    let affectedParts: [String]
    let description: String
    let causes: [String]
    let organicTreatments: [BackendTreatment]
    let chemicalTreatments: [BackendTreatment]
    let preventiveMeasures: [String]
    let diagnosisId: String
    let timestamp: String
}

struct BackendTreatment: Codable {
    let name: String
    let description: String
    let method: String
    let frequency: String?
    let precautions: [String]?
}
