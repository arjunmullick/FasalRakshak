//
//  CropModels.swift
//  FasalRakshak
//
//  Core data models for crops, diseases, and diagnostics
//

import Foundation
import SwiftUI

// MARK: - Crop Model
struct Crop: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let nameHindi: String
    let scientificName: String
    let category: CropCategory
    let season: [CropSeason]
    let regions: [IndianRegion]
    let imageURL: String?
    let description: String
    let descriptionHindi: String
    let commonDiseases: [String] // Disease IDs
    let commonPests: [String] // Pest IDs
    let waterRequirement: WaterRequirement
    let soilType: [SoilType]

    init(
        id: UUID = UUID(),
        name: String,
        nameHindi: String,
        scientificName: String,
        category: CropCategory,
        season: [CropSeason],
        regions: [IndianRegion],
        imageURL: String? = nil,
        description: String,
        descriptionHindi: String,
        commonDiseases: [String] = [],
        commonPests: [String] = [],
        waterRequirement: WaterRequirement = .moderate,
        soilType: [SoilType] = [.loamy]
    ) {
        self.id = id
        self.name = name
        self.nameHindi = nameHindi
        self.scientificName = scientificName
        self.category = category
        self.season = season
        self.regions = regions
        self.imageURL = imageURL
        self.description = description
        self.descriptionHindi = descriptionHindi
        self.commonDiseases = commonDiseases
        self.commonPests = commonPests
        self.waterRequirement = waterRequirement
        self.soilType = soilType
    }
}

enum CropCategory: String, Codable, CaseIterable {
    case cereals = "cereals"
    case pulses = "pulses"
    case oilseeds = "oilseeds"
    case vegetables = "vegetables"
    case fruits = "fruits"
    case spices = "spices"
    case fibers = "fibers"
    case sugarcane = "sugarcane"
    case plantation = "plantation"

    var displayName: String {
        switch self {
        case .cereals: return "Cereals"
        case .pulses: return "Pulses"
        case .oilseeds: return "Oilseeds"
        case .vegetables: return "Vegetables"
        case .fruits: return "Fruits"
        case .spices: return "Spices"
        case .fibers: return "Fibers"
        case .sugarcane: return "Sugarcane"
        case .plantation: return "Plantation"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .cereals: return "अनाज"
        case .pulses: return "दालें"
        case .oilseeds: return "तिलहन"
        case .vegetables: return "सब्जियां"
        case .fruits: return "फल"
        case .spices: return "मसाले"
        case .fibers: return "रेशे"
        case .sugarcane: return "गन्ना"
        case .plantation: return "बागवानी"
        }
    }

    var icon: String {
        switch self {
        case .cereals: return "🌾"
        case .pulses: return "🫘"
        case .oilseeds: return "🌻"
        case .vegetables: return "🥬"
        case .fruits: return "🍎"
        case .spices: return "🌶️"
        case .fibers: return "🧵"
        case .sugarcane: return "🎋"
        case .plantation: return "🌴"
        }
    }
}

enum CropSeason: String, Codable, CaseIterable {
    case kharif = "kharif"     // Monsoon (June-October)
    case rabi = "rabi"         // Winter (October-March)
    case zaid = "zaid"         // Summer (March-June)
    case perennial = "perennial" // Year-round

    var displayName: String {
        switch self {
        case .kharif: return "Kharif (Monsoon)"
        case .rabi: return "Rabi (Winter)"
        case .zaid: return "Zaid (Summer)"
        case .perennial: return "Perennial"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .kharif: return "खरीफ (मानसून)"
        case .rabi: return "रबी (सर्दी)"
        case .zaid: return "जायद (गर्मी)"
        case .perennial: return "बारहमासी"
        }
    }

    var months: String {
        switch self {
        case .kharif: return "June - October"
        case .rabi: return "October - March"
        case .zaid: return "March - June"
        case .perennial: return "Year-round"
        }
    }
}

enum IndianRegion: String, Codable, CaseIterable {
    case northIndia = "north"
    case southIndia = "south"
    case eastIndia = "east"
    case westIndia = "west"
    case centralIndia = "central"
    case northEast = "northeast"

    var displayName: String {
        switch self {
        case .northIndia: return "North India"
        case .southIndia: return "South India"
        case .eastIndia: return "East India"
        case .westIndia: return "West India"
        case .centralIndia: return "Central India"
        case .northEast: return "North East"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .northIndia: return "उत्तर भारत"
        case .southIndia: return "दक्षिण भारत"
        case .eastIndia: return "पूर्वी भारत"
        case .westIndia: return "पश्चिम भारत"
        case .centralIndia: return "मध्य भारत"
        case .northEast: return "पूर्वोत्तर"
        }
    }

    var states: [String] {
        switch self {
        case .northIndia:
            return ["Punjab", "Haryana", "Uttar Pradesh", "Uttarakhand", "Himachal Pradesh", "Jammu & Kashmir", "Delhi"]
        case .southIndia:
            return ["Tamil Nadu", "Kerala", "Karnataka", "Andhra Pradesh", "Telangana"]
        case .eastIndia:
            return ["West Bengal", "Bihar", "Jharkhand", "Odisha"]
        case .westIndia:
            return ["Maharashtra", "Gujarat", "Rajasthan", "Goa"]
        case .centralIndia:
            return ["Madhya Pradesh", "Chhattisgarh"]
        case .northEast:
            return ["Assam", "Meghalaya", "Manipur", "Mizoram", "Nagaland", "Tripura", "Arunachal Pradesh", "Sikkim"]
        }
    }
}

enum WaterRequirement: String, Codable, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "very_high"

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .low: return "कम"
        case .moderate: return "मध्यम"
        case .high: return "अधिक"
        case .veryHigh: return "बहुत अधिक"
        }
    }
}

enum SoilType: String, Codable, CaseIterable {
    case sandy = "sandy"
    case clayey = "clayey"
    case loamy = "loamy"
    case alluvial = "alluvial"
    case black = "black"
    case red = "red"
    case laterite = "laterite"

    var displayName: String {
        switch self {
        case .sandy: return "Sandy"
        case .clayey: return "Clayey"
        case .loamy: return "Loamy"
        case .alluvial: return "Alluvial"
        case .black: return "Black (Regur)"
        case .red: return "Red"
        case .laterite: return "Laterite"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .sandy: return "बलुई"
        case .clayey: return "चिकनी"
        case .loamy: return "दोमट"
        case .alluvial: return "जलोढ़"
        case .black: return "काली (रेगुर)"
        case .red: return "लाल"
        case .laterite: return "लैटेराइट"
        }
    }
}

// MARK: - Disease Model
struct Disease: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let nameHindi: String
    let type: DiseaseType
    let affectedCrops: [String] // Crop IDs
    let symptoms: [Symptom]
    let causes: [String]
    let causesHindi: [String]
    let preventiveMeasures: [String]
    let preventiveMeasuresHindi: [String]
    let organicTreatments: [Treatment]
    let chemicalTreatments: [Treatment]
    let severity: DiseaseSeverity
    let spreadMechanism: String
    let spreadMechanismHindi: String
    let imageURLs: [String]
    let seasonalPrevalence: [CropSeason]

    init(
        id: UUID = UUID(),
        name: String,
        nameHindi: String,
        type: DiseaseType,
        affectedCrops: [String] = [],
        symptoms: [Symptom] = [],
        causes: [String] = [],
        causesHindi: [String] = [],
        preventiveMeasures: [String] = [],
        preventiveMeasuresHindi: [String] = [],
        organicTreatments: [Treatment] = [],
        chemicalTreatments: [Treatment] = [],
        severity: DiseaseSeverity = .moderate,
        spreadMechanism: String = "",
        spreadMechanismHindi: String = "",
        imageURLs: [String] = [],
        seasonalPrevalence: [CropSeason] = []
    ) {
        self.id = id
        self.name = name
        self.nameHindi = nameHindi
        self.type = type
        self.affectedCrops = affectedCrops
        self.symptoms = symptoms
        self.causes = causes
        self.causesHindi = causesHindi
        self.preventiveMeasures = preventiveMeasures
        self.preventiveMeasuresHindi = preventiveMeasuresHindi
        self.organicTreatments = organicTreatments
        self.chemicalTreatments = chemicalTreatments
        self.severity = severity
        self.spreadMechanism = spreadMechanism
        self.spreadMechanismHindi = spreadMechanismHindi
        self.imageURLs = imageURLs
        self.seasonalPrevalence = seasonalPrevalence
    }
}

enum DiseaseType: String, Codable, CaseIterable {
    case fungal = "fungal"
    case bacterial = "bacterial"
    case viral = "viral"
    case nutrientDeficiency = "nutrient_deficiency"
    case pest = "pest"
    case waterStress = "water_stress"
    case physiological = "physiological"

    var displayName: String {
        switch self {
        case .fungal: return "Fungal Disease"
        case .bacterial: return "Bacterial Disease"
        case .viral: return "Viral Disease"
        case .nutrientDeficiency: return "Nutrient Deficiency"
        case .pest: return "Pest Infestation"
        case .waterStress: return "Water Stress"
        case .physiological: return "Physiological Disorder"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .fungal: return "फफूंद रोग"
        case .bacterial: return "जीवाणु रोग"
        case .viral: return "विषाणु रोग"
        case .nutrientDeficiency: return "पोषक तत्व की कमी"
        case .pest: return "कीट प्रकोप"
        case .waterStress: return "जल तनाव"
        case .physiological: return "शारीरिक विकार"
        }
    }

    var icon: String {
        switch self {
        case .fungal: return "🍄"
        case .bacterial: return "🦠"
        case .viral: return "🔬"
        case .nutrientDeficiency: return "⚗️"
        case .pest: return "🐛"
        case .waterStress: return "💧"
        case .physiological: return "🌡️"
        }
    }

    var color: Color {
        switch self {
        case .fungal: return .brown
        case .bacterial: return .orange
        case .viral: return .purple
        case .nutrientDeficiency: return .yellow
        case .pest: return .red
        case .waterStress: return .blue
        case .physiological: return .gray
        }
    }
}

enum DiseaseSeverity: String, Codable, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case critical = "critical"

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .low: return "कम"
        case .moderate: return "मध्यम"
        case .high: return "अधिक"
        case .critical: return "गंभीर"
        }
    }

    var color: Color {
        switch self {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Symptom Model
struct Symptom: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let nameHindi: String
    let description: String
    let descriptionHindi: String
    let affectedPart: PlantPart
    let visualIndicators: [String]
    let icon: String

    init(
        id: UUID = UUID(),
        name: String,
        nameHindi: String,
        description: String,
        descriptionHindi: String,
        affectedPart: PlantPart,
        visualIndicators: [String] = [],
        icon: String = "leaf"
    ) {
        self.id = id
        self.name = name
        self.nameHindi = nameHindi
        self.description = description
        self.descriptionHindi = descriptionHindi
        self.affectedPart = affectedPart
        self.visualIndicators = visualIndicators
        self.icon = icon
    }
}

enum PlantPart: String, Codable, CaseIterable {
    case leaf = "leaf"
    case stem = "stem"
    case root = "root"
    case flower = "flower"
    case fruit = "fruit"
    case seed = "seed"
    case wholePlant = "whole_plant"

    var displayName: String {
        switch self {
        case .leaf: return "Leaf"
        case .stem: return "Stem"
        case .root: return "Root"
        case .flower: return "Flower"
        case .fruit: return "Fruit"
        case .seed: return "Seed"
        case .wholePlant: return "Whole Plant"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .leaf: return "पत्ती"
        case .stem: return "तना"
        case .root: return "जड़"
        case .flower: return "फूल"
        case .fruit: return "फल"
        case .seed: return "बीज"
        case .wholePlant: return "पूरा पौधा"
        }
    }

    var icon: String {
        switch self {
        case .leaf: return "leaf.fill"
        case .stem: return "arrow.up.and.down"
        case .root: return "arrow.down.to.line"
        case .flower: return "camera.macro"
        case .fruit: return "apple.logo"
        case .seed: return "circle.fill"
        case .wholePlant: return "tree.fill"
        }
    }
}

// MARK: - Treatment Model
struct Treatment: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let nameHindi: String
    let description: String
    let descriptionHindi: String
    let type: TreatmentType
    let applicationMethod: String
    let applicationMethodHindi: String
    let frequency: String
    let frequencyHindi: String
    let dosage: String
    let precautions: [String]
    let precautionsHindi: [String]
    let estimatedCost: String?

    init(
        id: UUID = UUID(),
        name: String,
        nameHindi: String,
        description: String,
        descriptionHindi: String,
        type: TreatmentType,
        applicationMethod: String,
        applicationMethodHindi: String,
        frequency: String,
        frequencyHindi: String,
        dosage: String,
        precautions: [String] = [],
        precautionsHindi: [String] = [],
        estimatedCost: String? = nil
    ) {
        self.id = id
        self.name = name
        self.nameHindi = nameHindi
        self.description = description
        self.descriptionHindi = descriptionHindi
        self.type = type
        self.applicationMethod = applicationMethod
        self.applicationMethodHindi = applicationMethodHindi
        self.frequency = frequency
        self.frequencyHindi = frequencyHindi
        self.dosage = dosage
        self.precautions = precautions
        self.precautionsHindi = precautionsHindi
        self.estimatedCost = estimatedCost
    }
}

enum TreatmentType: String, Codable, CaseIterable {
    case organic = "organic"
    case chemical = "chemical"
    case biological = "biological"
    case cultural = "cultural"
    case mechanical = "mechanical"

    var displayName: String {
        switch self {
        case .organic: return "Organic"
        case .chemical: return "Chemical"
        case .biological: return "Biological"
        case .cultural: return "Cultural Practice"
        case .mechanical: return "Mechanical"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .organic: return "जैविक"
        case .chemical: return "रासायनिक"
        case .biological: return "जैव नियंत्रण"
        case .cultural: return "सांस्कृतिक अभ्यास"
        case .mechanical: return "यांत्रिक"
        }
    }
}

// MARK: - Diagnosis Result Model
struct DiagnosisResult: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let imageData: Data?
    let imageURL: String?
    let identifiedCrop: Crop?
    let diagnosedConditions: [DiagnosedCondition]
    let overallHealthScore: Double // 0-100
    let recommendations: [Recommendation]
    let affectedAreas: [AffectedArea]
    let weatherContext: WeatherContext?
    let location: LocationData?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        imageData: Data? = nil,
        imageURL: String? = nil,
        identifiedCrop: Crop? = nil,
        diagnosedConditions: [DiagnosedCondition] = [],
        overallHealthScore: Double = 100,
        recommendations: [Recommendation] = [],
        affectedAreas: [AffectedArea] = [],
        weatherContext: WeatherContext? = nil,
        location: LocationData? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.imageData = imageData
        self.imageURL = imageURL
        self.identifiedCrop = identifiedCrop
        self.diagnosedConditions = diagnosedConditions
        self.overallHealthScore = overallHealthScore
        self.recommendations = recommendations
        self.affectedAreas = affectedAreas
        self.weatherContext = weatherContext
        self.location = location
    }

    var healthStatus: HealthStatus {
        switch overallHealthScore {
        case 80...100: return .healthy
        case 60..<80: return .mild
        case 40..<60: return .moderate
        case 20..<40: return .severe
        default: return .critical
        }
    }
}

enum HealthStatus: String, Codable {
    case healthy = "healthy"
    case mild = "mild"
    case moderate = "moderate"
    case severe = "severe"
    case critical = "critical"

    var displayName: String {
        switch self {
        case .healthy: return "Healthy"
        case .mild: return "Mildly Affected"
        case .moderate: return "Moderately Affected"
        case .severe: return "Severely Affected"
        case .critical: return "Critical"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .healthy: return "स्वस्थ"
        case .mild: return "हल्का प्रभावित"
        case .moderate: return "मध्यम प्रभावित"
        case .severe: return "गंभीर प्रभावित"
        case .critical: return "अति गंभीर"
        }
    }

    var color: Color {
        switch self {
        case .healthy: return .green
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        case .critical: return .purple
        }
    }

    var icon: String {
        switch self {
        case .healthy: return "checkmark.circle.fill"
        case .mild: return "exclamationmark.circle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .severe: return "xmark.circle.fill"
        case .critical: return "xmark.octagon.fill"
        }
    }
}

struct DiagnosedCondition: Identifiable, Codable {
    let id: UUID
    let disease: Disease?
    let conditionName: String
    let conditionNameHindi: String
    let confidence: Double // 0-1
    let severity: DiseaseSeverity
    let description: String
    let descriptionHindi: String

    init(
        id: UUID = UUID(),
        disease: Disease? = nil,
        conditionName: String,
        conditionNameHindi: String,
        confidence: Double,
        severity: DiseaseSeverity,
        description: String,
        descriptionHindi: String
    ) {
        self.id = id
        self.disease = disease
        self.conditionName = conditionName
        self.conditionNameHindi = conditionNameHindi
        self.confidence = confidence
        self.severity = severity
        self.description = description
        self.descriptionHindi = descriptionHindi
    }
}

struct AffectedArea: Identifiable, Codable {
    let id: UUID
    let boundingBox: CGRect
    let label: String
    let confidence: Double

    init(
        id: UUID = UUID(),
        boundingBox: CGRect,
        label: String,
        confidence: Double
    ) {
        self.id = id
        self.boundingBox = boundingBox
        self.label = label
        self.confidence = confidence
    }
}

struct Recommendation: Identifiable, Codable {
    let id: UUID
    let priority: Int
    let title: String
    let titleHindi: String
    let description: String
    let descriptionHindi: String
    let actionType: ActionType
    let deadline: Date?
    let treatment: Treatment?

    init(
        id: UUID = UUID(),
        priority: Int,
        title: String,
        titleHindi: String,
        description: String,
        descriptionHindi: String,
        actionType: ActionType,
        deadline: Date? = nil,
        treatment: Treatment? = nil
    ) {
        self.id = id
        self.priority = priority
        self.title = title
        self.titleHindi = titleHindi
        self.description = description
        self.descriptionHindi = descriptionHindi
        self.actionType = actionType
        self.deadline = deadline
        self.treatment = treatment
    }
}

enum ActionType: String, Codable {
    case immediate = "immediate"
    case scheduled = "scheduled"
    case monitoring = "monitoring"
    case preventive = "preventive"

    var displayName: String {
        switch self {
        case .immediate: return "Immediate Action"
        case .scheduled: return "Scheduled"
        case .monitoring: return "Monitor"
        case .preventive: return "Preventive"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .immediate: return "तुरंत कार्रवाई"
        case .scheduled: return "निर्धारित"
        case .monitoring: return "निगरानी"
        case .preventive: return "रोकथाम"
        }
    }

    var color: Color {
        switch self {
        case .immediate: return .red
        case .scheduled: return .orange
        case .monitoring: return .blue
        case .preventive: return .green
        }
    }
}

struct WeatherContext: Codable {
    let temperature: Double
    let humidity: Double
    let rainfall: Double
    let condition: String

    init(
        temperature: Double = 0,
        humidity: Double = 0,
        rainfall: Double = 0,
        condition: String = ""
    ) {
        self.temperature = temperature
        self.humidity = humidity
        self.rainfall = rainfall
        self.condition = condition
    }
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let district: String?
    let state: String?
    let region: IndianRegion?

    init(
        latitude: Double,
        longitude: Double,
        district: String? = nil,
        state: String? = nil,
        region: IndianRegion? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.district = district
        self.state = state
        self.region = region
    }
}

// MARK: - Farmer Profile Model
struct FarmerProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var phone: String?
    var village: String?
    var district: String?
    var state: String?
    var region: IndianRegion?
    var preferredLanguage: AppLanguage
    var farmSize: Double? // in acres
    var registeredCrops: [String] // Crop IDs
    var createdAt: Date
    var lastActive: Date

    // Custom initializer with default values
    init(
        id: UUID = UUID(),
        name: String,
        phone: String? = nil,
        village: String? = nil,
        district: String? = nil,
        state: String? = nil,
        region: IndianRegion? = nil,
        preferredLanguage: AppLanguage = .hindi,
        farmSize: Double? = nil,
        registeredCrops: [String] = [],
        createdAt: Date = Date(),
        lastActive: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.village = village
        self.district = district
        self.state = state
        self.region = region
        self.preferredLanguage = preferredLanguage
        self.farmSize = farmSize
        self.registeredCrops = registeredCrops
        self.createdAt = createdAt
        self.lastActive = lastActive
    }

    // Codable conformance (required because of custom init)
    enum CodingKeys: String, CodingKey {
        case id, name, phone, village, district, state, region
        case preferredLanguage, farmSize, registeredCrops, createdAt, lastActive
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        village = try container.decodeIfPresent(String.self, forKey: .village)
        district = try container.decodeIfPresent(String.self, forKey: .district)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        region = try container.decodeIfPresent(IndianRegion.self, forKey: .region)
        preferredLanguage = try container.decode(AppLanguage.self, forKey: .preferredLanguage)
        farmSize = try container.decodeIfPresent(Double.self, forKey: .farmSize)
        registeredCrops = try container.decode([String].self, forKey: .registeredCrops)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastActive = try container.decode(Date.self, forKey: .lastActive)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(village, forKey: .village)
        try container.encodeIfPresent(district, forKey: .district)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encode(preferredLanguage, forKey: .preferredLanguage)
        try container.encodeIfPresent(farmSize, forKey: .farmSize)
        try container.encode(registeredCrops, forKey: .registeredCrops)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(lastActive, forKey: .lastActive)
    }
}

// MARK: - Reminder Model
struct CropReminder: Identifiable, Codable {
    let id: UUID
    var title: String
    var titleHindi: String
    var description: String
    var descriptionHindi: String
    var scheduledDate: Date
    var repeatInterval: ReminderRepeat
    var type: ReminderType
    var cropId: String?
    var diagnosisId: String?
    var isCompleted: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        titleHindi: String,
        description: String,
        descriptionHindi: String,
        scheduledDate: Date,
        repeatInterval: ReminderRepeat = .none,
        type: ReminderType,
        cropId: String? = nil,
        diagnosisId: String? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.titleHindi = titleHindi
        self.description = description
        self.descriptionHindi = descriptionHindi
        self.scheduledDate = scheduledDate
        self.repeatInterval = repeatInterval
        self.type = type
        self.cropId = cropId
        self.diagnosisId = diagnosisId
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

enum ReminderRepeat: String, Codable, CaseIterable {
    case none = "none"
    case daily = "daily"
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"

    var displayName: String {
        switch self {
        case .none: return "Once"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biweekly: return "Every 2 Weeks"
        case .monthly: return "Monthly"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .none: return "एक बार"
        case .daily: return "रोज़ाना"
        case .weekly: return "साप्ताहिक"
        case .biweekly: return "हर 2 सप्ताह"
        case .monthly: return "मासिक"
        }
    }
}

enum ReminderType: String, Codable, CaseIterable {
    case treatment = "treatment"
    case checkup = "checkup"
    case watering = "watering"
    case fertilizing = "fertilizing"
    case spraying = "spraying"
    case harvesting = "harvesting"
    case general = "general"

    var displayName: String {
        switch self {
        case .treatment: return "Treatment"
        case .checkup: return "Check-up"
        case .watering: return "Watering"
        case .fertilizing: return "Fertilizing"
        case .spraying: return "Spraying"
        case .harvesting: return "Harvesting"
        case .general: return "General"
        }
    }

    var displayNameHindi: String {
        switch self {
        case .treatment: return "उपचार"
        case .checkup: return "जांच"
        case .watering: return "सिंचाई"
        case .fertilizing: return "खाद"
        case .spraying: return "छिड़काव"
        case .harvesting: return "कटाई"
        case .general: return "सामान्य"
        }
    }

    var icon: String {
        switch self {
        case .treatment: return "cross.case.fill"
        case .checkup: return "magnifyingglass"
        case .watering: return "drop.fill"
        case .fertilizing: return "leaf.fill"
        case .spraying: return "sprinkler.and.droplets.fill"
        case .harvesting: return "basket.fill"
        case .general: return "bell.fill"
        }
    }
}
