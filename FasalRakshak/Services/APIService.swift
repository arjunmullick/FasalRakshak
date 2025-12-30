//
//  APIService.swift
//  FasalRakshak
//
//  Backend API service for crop analysis and expert consultation
//

import Foundation
import UIKit

class APIService: ObservableObject {
    static let shared = APIService()

    // API Configuration
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession

    @Published var isLoading: Bool = false

    init() {
        // Load configuration from environment or config file
        self.baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "https://api.fasalrakshak.in/v1"
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

    /// Analyze crop image for diseases
    func analyzeCropImage(imageData: Data, cropType: String?) async throws -> CropAnalysisResponse {
        let endpoint = "/analyze"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue(Locale.current.language.languageCode?.identifier ?? "hi", forHTTPHeaderField: "Accept-Language")

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

        // Add crop type if available
        if let cropType = cropType {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"crop_type\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(cropType)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(CropAnalysisResponse.self, from: data)
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
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case networkError
    case unauthorized

    var errorDescription: String? {
        switch self {
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
