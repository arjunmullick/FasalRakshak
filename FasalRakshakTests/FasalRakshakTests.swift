//
//  FasalRakshakTests.swift
//  FasalRakshakTests
//
//  Unit tests for FasalRakshak app
//

import XCTest
@testable import FasalRakshak

final class FasalRakshakTests: XCTestCase {

    // MARK: - Model Tests

    func testCropCreation() {
        let crop = Crop(
            name: "Rice",
            nameHindi: "धान",
            scientificName: "Oryza sativa",
            category: .cereals,
            season: [.kharif],
            regions: [.northIndia],
            description: "Staple crop",
            descriptionHindi: "मुख्य फसल"
        )

        XCTAssertEqual(crop.name, "Rice")
        XCTAssertEqual(crop.nameHindi, "धान")
        XCTAssertEqual(crop.category, .cereals)
    }

    func testDiseaseCreation() {
        let disease = Disease(
            name: "Rice Blast",
            nameHindi: "धान का ब्लास्ट",
            type: .fungal
        )

        XCTAssertEqual(disease.name, "Rice Blast")
        XCTAssertEqual(disease.type, .fungal)
    }

    func testDiagnosisResult() {
        let result = DiagnosisResult(
            overallHealthScore: 75.0
        )

        XCTAssertEqual(result.overallHealthScore, 75.0)
        XCTAssertEqual(result.healthStatus, .mild)
    }

    func testHealthStatus() {
        XCTAssertEqual(DiagnosisResult(overallHealthScore: 90).healthStatus, .healthy)
        XCTAssertEqual(DiagnosisResult(overallHealthScore: 70).healthStatus, .mild)
        XCTAssertEqual(DiagnosisResult(overallHealthScore: 50).healthStatus, .moderate)
        XCTAssertEqual(DiagnosisResult(overallHealthScore: 30).healthStatus, .severe)
        XCTAssertEqual(DiagnosisResult(overallHealthScore: 10).healthStatus, .critical)
    }

    // MARK: - Enum Tests

    func testCropCategory() {
        XCTAssertEqual(CropCategory.cereals.displayNameHindi, "अनाज")
        XCTAssertEqual(CropCategory.vegetables.icon, "🥬")
    }

    func testDiseaseType() {
        XCTAssertEqual(DiseaseType.fungal.displayNameHindi, "फफूंद रोग")
        XCTAssertEqual(DiseaseType.pest.icon, "🐛")
    }

    func testAppLanguage() {
        XCTAssertEqual(AppLanguage.hindi.displayName, "हिंदी")
        XCTAssertEqual(AppLanguage.hindi.voiceIdentifier, "hi-IN")
    }

    // MARK: - Reminder Tests

    func testReminderCreation() {
        let reminder = CropReminder(
            title: "Spray",
            titleHindi: "छिड़काव",
            description: "Apply fungicide",
            descriptionHindi: "कवकनाशी लगाएं",
            scheduledDate: Date(),
            type: .spraying
        )

        XCTAssertEqual(reminder.title, "Spray")
        XCTAssertEqual(reminder.type, .spraying)
        XCTAssertFalse(reminder.isCompleted)
    }

    // MARK: - Service Tests

    func testOfflineDataManager() {
        let manager = OfflineDataManager.shared
        let crops = manager.getAllCrops()

        XCTAssertFalse(crops.isEmpty, "Default crops should be loaded")
    }

    func testVoiceAssistantService() {
        let service = VoiceAssistantService.shared

        XCTAssertNotNil(service)
        XCTAssertEqual(service.currentLanguage, .hindi)
    }

    // MARK: - Analytics Tests

    func testAnalyticsService() {
        let service = AnalyticsService.shared
        let stats = service.getUsageStats()

        XCTAssertGreaterThanOrEqual(stats.totalSessions, 0)
        XCTAssertGreaterThanOrEqual(stats.totalDiagnoses, 0)
    }

    // MARK: - Symptom Matching Tests

    func testSymptomCreation() {
        let symptom = Symptom(
            name: "Yellowing",
            nameHindi: "पीलापन",
            description: "Leaves turning yellow",
            descriptionHindi: "पत्तियां पीली हो रही हैं",
            affectedPart: .leaf
        )

        XCTAssertEqual(symptom.name, "Yellowing")
        XCTAssertEqual(symptom.affectedPart, .leaf)
    }

    // MARK: - Treatment Tests

    func testTreatmentCreation() {
        let treatment = Treatment(
            name: "Neem Oil",
            nameHindi: "नीम तेल",
            description: "Natural insecticide",
            descriptionHindi: "प्राकृतिक कीटनाशक",
            type: .organic,
            applicationMethod: "Spray",
            applicationMethodHindi: "छिड़काव",
            frequency: "Weekly",
            frequencyHindi: "साप्ताहिक",
            dosage: "5ml per liter"
        )

        XCTAssertEqual(treatment.name, "Neem Oil")
        XCTAssertEqual(treatment.type, .organic)
    }

    // MARK: - Farmer Profile Tests

    func testFarmerProfile() {
        let profile = FarmerProfile(
            name: "Ramesh",
            village: "Patna",
            preferredLanguage: .hindi
        )

        XCTAssertEqual(profile.name, "Ramesh")
        XCTAssertEqual(profile.preferredLanguage, .hindi)
    }
}
