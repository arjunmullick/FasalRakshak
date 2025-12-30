//
//  OfflineDataManager.swift
//  FasalRakshak
//
//  Manages offline data storage and caching for rural connectivity
//

import Foundation
import UIKit

class OfflineDataManager: ObservableObject {
    static let shared = OfflineDataManager()

    @Published var isInitialized: Bool = false
    @Published var lastSyncDate: Date?
    @Published var offlineDataSize: Int64 = 0

    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard

    // Storage paths
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    private var cropsDataURL: URL {
        documentsDirectory.appendingPathComponent("crops.json")
    }

    private var diseasesDataURL: URL {
        documentsDirectory.appendingPathComponent("diseases.json")
    }

    private var symptomsDataURL: URL {
        documentsDirectory.appendingPathComponent("symptoms.json")
    }

    private var diagnosisHistoryURL: URL {
        documentsDirectory.appendingPathComponent("diagnosis_history.json")
    }

    private var remindersURL: URL {
        documentsDirectory.appendingPathComponent("reminders.json")
    }

    // MARK: - Initialization

    func initializeOfflineData() async {
        // Check if we have local data
        if !fileManager.fileExists(atPath: cropsDataURL.path) {
            // Load bundled default data
            await loadBundledData()
        }

        // Calculate storage size
        calculateOfflineDataSize()

        // Load last sync date
        if let syncTimestamp = userDefaults.object(forKey: "lastSyncTimestamp") as? Double {
            lastSyncDate = Date(timeIntervalSince1970: syncTimestamp)
        }

        DispatchQueue.main.async {
            self.isInitialized = true
        }
    }

    // MARK: - Crops Data

    func getAllCrops() -> [Crop] {
        guard let data = try? Data(contentsOf: cropsDataURL),
              let crops = try? JSONDecoder().decode([Crop].self, from: data) else {
            return getDefaultCrops()
        }
        return crops
    }

    func getCrop(id: String) -> Crop? {
        getAllCrops().first { $0.id.uuidString == id }
    }

    func getCropsByCategory(_ category: CropCategory) -> [Crop] {
        getAllCrops().filter { $0.category == category }
    }

    func getCropsByRegion(_ region: IndianRegion) -> [Crop] {
        getAllCrops().filter { $0.regions.contains(region) }
    }

    func saveCrops(_ crops: [Crop]) throws {
        let data = try JSONEncoder().encode(crops)
        try data.write(to: cropsDataURL)
    }

    // MARK: - Diseases Data

    func getAllDiseases() -> [Disease] {
        guard let data = try? Data(contentsOf: diseasesDataURL),
              let diseases = try? JSONDecoder().decode([Disease].self, from: data) else {
            return getDefaultDiseases()
        }
        return diseases
    }

    func getDisease(id: String) -> Disease? {
        getAllDiseases().first { $0.id.uuidString == id }
    }

    func getDiseasesByType(_ type: DiseaseType) -> [Disease] {
        getAllDiseases().filter { $0.type == type }
    }

    func getDiseasesForCrop(_ cropId: String) -> [Disease] {
        getAllDiseases().filter { $0.affectedCrops.contains(cropId) }
    }

    func saveDiseases(_ diseases: [Disease]) throws {
        let data = try JSONEncoder().encode(diseases)
        try data.write(to: diseasesDataURL)
    }

    // MARK: - Symptoms Data

    func getAllSymptoms() -> [Symptom] {
        guard let data = try? Data(contentsOf: symptomsDataURL),
              let symptoms = try? JSONDecoder().decode([Symptom].self, from: data) else {
            return getDefaultSymptoms()
        }
        return symptoms
    }

    func getSymptomsByPlantPart(_ part: PlantPart) -> [Symptom] {
        getAllSymptoms().filter { $0.affectedPart == part }
    }

    func saveSymptoms(_ symptoms: [Symptom]) throws {
        let data = try JSONEncoder().encode(symptoms)
        try data.write(to: symptomsDataURL)
    }

    // MARK: - Diagnosis History

    func getDiagnosisHistory() -> [DiagnosisResult] {
        guard let data = try? Data(contentsOf: diagnosisHistoryURL),
              let history = try? JSONDecoder().decode([DiagnosisResult].self, from: data) else {
            return []
        }
        return history.sorted { $0.timestamp > $1.timestamp }
    }

    func cacheDiagnosisResult(_ result: DiagnosisResult) async throws {
        var history = getDiagnosisHistory()
        history.insert(result, at: 0)

        // Keep only last 100 results
        if history.count > 100 {
            history = Array(history.prefix(100))
        }

        let data = try JSONEncoder().encode(history)
        try data.write(to: diagnosisHistoryURL)
    }

    func deleteDiagnosisResult(id: UUID) throws {
        var history = getDiagnosisHistory()
        history.removeAll { $0.id == id }

        let data = try JSONEncoder().encode(history)
        try data.write(to: diagnosisHistoryURL)
    }

    // MARK: - Reminders

    func getAllReminders() -> [CropReminder] {
        guard let data = try? Data(contentsOf: remindersURL),
              let reminders = try? JSONDecoder().decode([CropReminder].self, from: data) else {
            return []
        }
        return reminders.sorted { $0.scheduledDate < $1.scheduledDate }
    }

    func saveReminder(_ reminder: CropReminder) throws {
        var reminders = getAllReminders()
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        } else {
            reminders.append(reminder)
        }

        let data = try JSONEncoder().encode(reminders)
        try data.write(to: remindersURL)
    }

    func deleteReminder(id: UUID) throws {
        var reminders = getAllReminders()
        reminders.removeAll { $0.id == id }

        let data = try JSONEncoder().encode(reminders)
        try data.write(to: remindersURL)
    }

    func getUpcomingReminders(days: Int = 7) -> [CropReminder] {
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: Date())!
        return getAllReminders().filter { $0.scheduledDate <= endDate && !$0.isCompleted }
    }

    // MARK: - Image Cache

    func cacheImage(_ image: UIImage, for key: String) throws {
        let imagesDirectory = cacheDirectory.appendingPathComponent("images")
        try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)

        let imagePath = imagesDirectory.appendingPathComponent("\(key).jpg")
        if let data = image.jpegData(compressionQuality: 0.7) {
            try data.write(to: imagePath)
        }
    }

    func getCachedImage(for key: String) -> UIImage? {
        let imagePath = cacheDirectory.appendingPathComponent("images/\(key).jpg")
        guard let data = try? Data(contentsOf: imagePath) else {
            return nil
        }
        return UIImage(data: data)
    }

    func clearImageCache() throws {
        let imagesDirectory = cacheDirectory.appendingPathComponent("images")
        try fileManager.removeItem(at: imagesDirectory)
    }

    // MARK: - Sync Management

    func syncWithServer() async throws {
        guard await NetworkMonitor.shared.isConnected else {
            throw OfflineError.noConnection
        }

        let apiService = APIService.shared

        // Sync crops
        let crops = try await apiService.fetchCropDatabase()
        try saveCrops(crops)

        // Sync diseases
        let diseases = try await apiService.fetchDiseaseDatabase()
        try saveDiseases(diseases)

        // Update sync timestamp
        let now = Date()
        lastSyncDate = now
        userDefaults.set(now.timeIntervalSince1970, forKey: "lastSyncTimestamp")

        // Recalculate storage
        calculateOfflineDataSize()
    }

    func needsSync() -> Bool {
        guard let lastSync = lastSyncDate else {
            return true
        }

        // Sync if data is older than 7 days
        let daysSinceSync = Calendar.current.dateComponents([.day], from: lastSync, to: Date()).day ?? 0
        return daysSinceSync >= 7
    }

    // MARK: - Storage Management

    func calculateOfflineDataSize() {
        var totalSize: Int64 = 0

        let files = [cropsDataURL, diseasesDataURL, symptomsDataURL, diagnosisHistoryURL, remindersURL]
        for file in files {
            if let attributes = try? fileManager.attributesOfItem(atPath: file.path),
               let size = attributes[.size] as? Int64 {
                totalSize += size
            }
        }

        // Add images cache
        let imagesDirectory = cacheDirectory.appendingPathComponent("images")
        if let enumerator = fileManager.enumerator(at: imagesDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            while let fileURL = enumerator.nextObject() as? URL {
                if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                   let size = attributes[.size] as? Int64 {
                    totalSize += size
                }
            }
        }

        DispatchQueue.main.async {
            self.offlineDataSize = totalSize
        }
    }

    func clearAllOfflineData() throws {
        let files = [cropsDataURL, diseasesDataURL, symptomsDataURL, diagnosisHistoryURL, remindersURL]
        for file in files {
            try? fileManager.removeItem(at: file)
        }
        try? clearImageCache()
        userDefaults.removeObject(forKey: "lastSyncTimestamp")
        lastSyncDate = nil
        offlineDataSize = 0
    }

    // MARK: - Bundled Data

    private func loadBundledData() async {
        // Load default crops
        let crops = getDefaultCrops()
        try? saveCrops(crops)

        // Load default diseases
        let diseases = getDefaultDiseases()
        try? saveDiseases(diseases)

        // Load default symptoms
        let symptoms = getDefaultSymptoms()
        try? saveSymptoms(symptoms)
    }

    // MARK: - Default Data (Bundled for Offline Use)

    private func getDefaultCrops() -> [Crop] {
        [
            // Cereals
            Crop(
                name: "Rice",
                nameHindi: "धान / चावल",
                scientificName: "Oryza sativa",
                category: .cereals,
                season: [.kharif],
                regions: [.northIndia, .eastIndia, .southIndia],
                description: "Staple cereal crop of India, grows in flooded fields",
                descriptionHindi: "भारत की मुख्य अनाज फसल, जलमग्न खेतों में उगती है",
                commonDiseases: ["rice_blast", "bacterial_blight", "brown_spot"],
                waterRequirement: .veryHigh,
                soilType: [.alluvial, .clayey]
            ),
            Crop(
                name: "Wheat",
                nameHindi: "गेहूं",
                scientificName: "Triticum aestivum",
                category: .cereals,
                season: [.rabi],
                regions: [.northIndia, .centralIndia],
                description: "Major rabi crop grown in winter season",
                descriptionHindi: "सर्दी के मौसम में उगाई जाने वाली प्रमुख रबी फसल",
                commonDiseases: ["wheat_rust", "powdery_mildew", "karnal_bunt"],
                waterRequirement: .moderate,
                soilType: [.loamy, .alluvial]
            ),
            Crop(
                name: "Maize",
                nameHindi: "मक्का",
                scientificName: "Zea mays",
                category: .cereals,
                season: [.kharif, .rabi],
                regions: IndianRegion.allCases,
                description: "Versatile cereal crop grown across India",
                descriptionHindi: "भारत भर में उगाई जाने वाली बहुमुखी अनाज फसल",
                commonDiseases: ["maize_streak", "northern_blight", "stem_borer"],
                waterRequirement: .moderate,
                soilType: [.loamy, .sandy]
            ),

            // Pulses
            Crop(
                name: "Chickpea",
                nameHindi: "चना",
                scientificName: "Cicer arietinum",
                category: .pulses,
                season: [.rabi],
                regions: [.centralIndia, .northIndia],
                description: "Important pulse crop rich in protein",
                descriptionHindi: "प्रोटीन से भरपूर महत्वपूर्ण दाल फसल",
                commonDiseases: ["wilt", "root_rot", "ascochyta_blight"],
                waterRequirement: .low,
                soilType: [.loamy, .black]
            ),
            Crop(
                name: "Pigeon Pea",
                nameHindi: "अरहर / तुअर",
                scientificName: "Cajanus cajan",
                category: .pulses,
                season: [.kharif],
                regions: [.centralIndia, .southIndia],
                description: "Popular dal crop in India",
                descriptionHindi: "भारत में लोकप्रिय दाल फसल",
                commonDiseases: ["wilt", "sterility_mosaic", "pod_borer"],
                waterRequirement: .moderate,
                soilType: [.loamy, .red]
            ),

            // Vegetables
            Crop(
                name: "Tomato",
                nameHindi: "टमाटर",
                scientificName: "Solanum lycopersicum",
                category: .vegetables,
                season: [.rabi, .kharif],
                regions: IndianRegion.allCases,
                description: "Widely cultivated vegetable crop",
                descriptionHindi: "व्यापक रूप से उगाई जाने वाली सब्जी",
                commonDiseases: ["early_blight", "late_blight", "leaf_curl", "bacterial_wilt"],
                waterRequirement: .moderate,
                soilType: [.loamy, .sandy]
            ),
            Crop(
                name: "Potato",
                nameHindi: "आलू",
                scientificName: "Solanum tuberosum",
                category: .vegetables,
                season: [.rabi],
                regions: [.northIndia, .eastIndia],
                description: "Major tuber crop grown in winter",
                descriptionHindi: "सर्दियों में उगाई जाने वाली प्रमुख कंद फसल",
                commonDiseases: ["late_blight", "early_blight", "black_scurf"],
                waterRequirement: .moderate,
                soilType: [.loamy, .sandy]
            ),
            Crop(
                name: "Onion",
                nameHindi: "प्याज",
                scientificName: "Allium cepa",
                category: .vegetables,
                season: [.rabi, .kharif],
                regions: [.westIndia, .centralIndia, .southIndia],
                description: "Important bulb vegetable crop",
                descriptionHindi: "महत्वपूर्ण कंद सब्जी फसल",
                commonDiseases: ["purple_blotch", "stemphylium_blight", "thrips"],
                waterRequirement: .moderate,
                soilType: [.loamy, .alluvial]
            ),
            Crop(
                name: "Brinjal",
                nameHindi: "बैंगन",
                scientificName: "Solanum melongena",
                category: .vegetables,
                season: [.kharif, .rabi],
                regions: IndianRegion.allCases,
                description: "Popular vegetable across India",
                descriptionHindi: "पूरे भारत में लोकप्रिय सब्जी",
                commonDiseases: ["bacterial_wilt", "fruit_borer", "phomopsis_blight"],
                waterRequirement: .moderate,
                soilType: [.loamy, .sandy]
            ),

            // Fruits
            Crop(
                name: "Mango",
                nameHindi: "आम",
                scientificName: "Mangifera indica",
                category: .fruits,
                season: [.perennial],
                regions: IndianRegion.allCases,
                description: "King of fruits, national fruit of India",
                descriptionHindi: "फलों का राजा, भारत का राष्ट्रीय फल",
                commonDiseases: ["anthracnose", "powdery_mildew", "mango_malformation"],
                waterRequirement: .moderate,
                soilType: [.alluvial, .laterite, .red]
            ),
            Crop(
                name: "Banana",
                nameHindi: "केला",
                scientificName: "Musa",
                category: .fruits,
                season: [.perennial],
                regions: [.southIndia, .westIndia, .eastIndia],
                description: "Major fruit crop of tropical India",
                descriptionHindi: "उष्णकटिबंधीय भारत की प्रमुख फल फसल",
                commonDiseases: ["panama_disease", "sigatoka", "bunchy_top"],
                waterRequirement: .high,
                soilType: [.loamy, .alluvial]
            ),

            // Oilseeds
            Crop(
                name: "Groundnut",
                nameHindi: "मूंगफली",
                scientificName: "Arachis hypogaea",
                category: .oilseeds,
                season: [.kharif],
                regions: [.westIndia, .southIndia],
                description: "Major oilseed crop of India",
                descriptionHindi: "भारत की प्रमुख तिलहन फसल",
                commonDiseases: ["tikka_disease", "collar_rot", "rust"],
                waterRequirement: .low,
                soilType: [.sandy, .loamy]
            ),
            Crop(
                name: "Mustard",
                nameHindi: "सरसों",
                scientificName: "Brassica juncea",
                category: .oilseeds,
                season: [.rabi],
                regions: [.northIndia, .centralIndia],
                description: "Important winter oilseed crop",
                descriptionHindi: "महत्वपूर्ण सर्दी की तिलहन फसल",
                commonDiseases: ["alternaria_blight", "white_rust", "aphids"],
                waterRequirement: .low,
                soilType: [.loamy, .sandy]
            ),

            // Cash Crops
            Crop(
                name: "Cotton",
                nameHindi: "कपास",
                scientificName: "Gossypium",
                category: .fibers,
                season: [.kharif],
                regions: [.westIndia, .centralIndia, .southIndia],
                description: "White gold of Indian agriculture",
                descriptionHindi: "भारतीय कृषि का सफेद सोना",
                commonDiseases: ["bollworm", "whitefly", "bacterial_blight", "fusarium_wilt"],
                waterRequirement: .moderate,
                soilType: [.black, .alluvial]
            ),
            Crop(
                name: "Sugarcane",
                nameHindi: "गन्ना",
                scientificName: "Saccharum officinarum",
                category: .sugarcane,
                season: [.perennial],
                regions: [.northIndia, .southIndia, .westIndia],
                description: "Major sugar-producing crop",
                descriptionHindi: "प्रमुख चीनी उत्पादक फसल",
                commonDiseases: ["red_rot", "smut", "grassy_shoot"],
                waterRequirement: .veryHigh,
                soilType: [.loamy, .alluvial]
            )
        ]
    }

    private func getDefaultDiseases() -> [Disease] {
        [
            // Rice Diseases
            Disease(
                name: "Rice Blast",
                nameHindi: "धान का ब्लास्ट",
                type: .fungal,
                symptoms: [
                    Symptom(
                        name: "Leaf spots",
                        nameHindi: "पत्ती पर धब्बे",
                        description: "Diamond-shaped spots with gray centers",
                        descriptionHindi: "हीरे के आकार के धब्बे जिनके बीच में भूरा रंग",
                        affectedPart: .leaf,
                        icon: "circle.dotted"
                    )
                ],
                causes: ["Fungus Magnaporthe oryzae", "High humidity", "Excessive nitrogen"],
                causesHindi: ["फफूंद मैग्नापोर्थ ओराइजी", "उच्च आर्द्रता", "अधिक नाइट्रोजन"],
                preventiveMeasures: ["Use resistant varieties", "Balanced fertilization", "Proper water management"],
                preventiveMeasuresHindi: ["प्रतिरोधी किस्मों का उपयोग करें", "संतुलित उर्वरक", "उचित जल प्रबंधन"],
                organicTreatments: [
                    Treatment(
                        name: "Trichoderma spray",
                        nameHindi: "ट्राइकोडर्मा स्प्रे",
                        description: "Apply Trichoderma viride fungal spray",
                        descriptionHindi: "ट्राइकोडर्मा विरिडी फफूंद स्प्रे लगाएं",
                        type: .biological,
                        applicationMethod: "Foliar spray",
                        applicationMethodHindi: "पत्तियों पर छिड़काव",
                        frequency: "Every 10-15 days",
                        frequencyHindi: "हर 10-15 दिन",
                        dosage: "4g per liter water"
                    )
                ],
                chemicalTreatments: [
                    Treatment(
                        name: "Tricyclazole",
                        nameHindi: "ट्राइसाइक्लाज़ोल",
                        description: "Systemic fungicide for blast control",
                        descriptionHindi: "ब्लास्ट नियंत्रण के लिए प्रणालीगत कवकनाशी",
                        type: .chemical,
                        applicationMethod: "Foliar spray",
                        applicationMethodHindi: "पत्तियों पर छिड़काव",
                        frequency: "2-3 sprays at 10-day intervals",
                        frequencyHindi: "10 दिन के अंतराल पर 2-3 छिड़काव",
                        dosage: "0.6g per liter water",
                        precautions: ["Wear protective gear", "Avoid spraying in wind"],
                        precautionsHindi: ["सुरक्षात्मक उपकरण पहनें", "हवा में छिड़काव न करें"]
                    )
                ],
                severity: .high,
                spreadMechanism: "Wind-borne spores spread rapidly in humid conditions",
                spreadMechanismHindi: "हवा से फैलने वाले बीजाणु नम स्थितियों में तेजी से फैलते हैं"
            ),

            // Wheat Diseases
            Disease(
                name: "Wheat Rust",
                nameHindi: "गेहूं का रतुआ",
                type: .fungal,
                symptoms: [
                    Symptom(
                        name: "Orange pustules",
                        nameHindi: "नारंगी फुंसी",
                        description: "Orange-brown powdery pustules on leaves",
                        descriptionHindi: "पत्तियों पर नारंगी-भूरी पाउडर जैसी फुंसी",
                        affectedPart: .leaf,
                        icon: "dot.radiowaves.left.and.right"
                    )
                ],
                causes: ["Puccinia fungi", "Cool and humid weather", "Susceptible varieties"],
                causesHindi: ["पक्सीनिया फफूंद", "ठंडा और नम मौसम", "संवेदनशील किस्में"],
                preventiveMeasures: ["Grow resistant varieties", "Early sowing", "Remove volunteer plants"],
                preventiveMeasuresHindi: ["प्रतिरोधी किस्में उगाएं", "जल्दी बुवाई", "स्वयंसेवी पौधे हटाएं"],
                organicTreatments: [
                    Treatment(
                        name: "Neem oil spray",
                        nameHindi: "नीम तेल स्प्रे",
                        description: "Apply neem oil as preventive measure",
                        descriptionHindi: "रोकथाम के लिए नीम का तेल लगाएं",
                        type: .organic,
                        applicationMethod: "Foliar spray",
                        applicationMethodHindi: "पत्तियों पर छिड़काव",
                        frequency: "Weekly during disease-prone period",
                        frequencyHindi: "रोग प्रवण अवधि में साप्ताहिक",
                        dosage: "5ml per liter water"
                    )
                ],
                chemicalTreatments: [
                    Treatment(
                        name: "Propiconazole",
                        nameHindi: "प्रोपिकोनाज़ोल",
                        description: "Effective systemic fungicide for rust",
                        descriptionHindi: "रतुआ के लिए प्रभावी प्रणालीगत कवकनाशी",
                        type: .chemical,
                        applicationMethod: "Foliar spray",
                        applicationMethodHindi: "पत्तियों पर छिड़काव",
                        frequency: "At disease appearance, repeat after 15 days",
                        frequencyHindi: "रोग दिखने पर, 15 दिन बाद दोहराएं",
                        dosage: "1ml per liter water",
                        precautions: ["Apply in evening", "Do not apply near harvest"],
                        precautionsHindi: ["शाम को लगाएं", "कटाई के पास न लगाएं"]
                    )
                ],
                severity: .high,
                spreadMechanism: "Wind-dispersed spores can travel long distances",
                spreadMechanismHindi: "हवा से फैलने वाले बीजाणु लंबी दूरी तक जा सकते हैं"
            ),

            // Tomato Diseases
            Disease(
                name: "Early Blight",
                nameHindi: "अगेती अंगमारी",
                type: .fungal,
                symptoms: [
                    Symptom(
                        name: "Target-shaped spots",
                        nameHindi: "लक्ष्य के आकार के धब्बे",
                        description: "Concentric ring patterns on lower leaves",
                        descriptionHindi: "निचली पत्तियों पर संकेंद्रित वलय पैटर्न",
                        affectedPart: .leaf,
                        icon: "target"
                    )
                ],
                causes: ["Alternaria solani fungus", "Warm and humid weather", "Poor air circulation"],
                causesHindi: ["अल्टरनेरिया सोलानी फफूंद", "गर्म और नम मौसम", "खराब वायु परिसंचरण"],
                preventiveMeasures: ["Crop rotation", "Remove infected debris", "Mulching"],
                preventiveMeasuresHindi: ["फसल चक्र", "संक्रमित अवशेष हटाएं", "मल्चिंग"],
                organicTreatments: [
                    Treatment(
                        name: "Copper fungicide",
                        nameHindi: "तांबा कवकनाशी",
                        description: "Bordeaux mixture application",
                        descriptionHindi: "बोर्डो मिश्रण का प्रयोग",
                        type: .organic,
                        applicationMethod: "Foliar spray",
                        applicationMethodHindi: "पत्तियों पर छिड़काव",
                        frequency: "Every 7-10 days",
                        frequencyHindi: "हर 7-10 दिन",
                        dosage: "1% solution"
                    )
                ],
                chemicalTreatments: [
                    Treatment(
                        name: "Mancozeb",
                        nameHindi: "मैनकोज़ेब",
                        description: "Broad-spectrum protective fungicide",
                        descriptionHindi: "व्यापक स्पेक्ट्रम सुरक्षात्मक कवकनाशी",
                        type: .chemical,
                        applicationMethod: "Foliar spray",
                        applicationMethodHindi: "पत्तियों पर छिड़काव",
                        frequency: "Every 10-14 days",
                        frequencyHindi: "हर 10-14 दिन",
                        dosage: "2.5g per liter water",
                        precautions: ["Wear mask", "Maintain safety interval before harvest"],
                        precautionsHindi: ["मास्क पहनें", "कटाई से पहले सुरक्षा अंतराल बनाए रखें"]
                    )
                ],
                severity: .moderate,
                spreadMechanism: "Spreads through infected plant debris and rain splash",
                spreadMechanismHindi: "संक्रमित पौधे के अवशेषों और बारिश की बौछार से फैलता है"
            ),

            // Nutrient Deficiency
            Disease(
                name: "Nitrogen Deficiency",
                nameHindi: "नाइट्रोजन की कमी",
                type: .nutrientDeficiency,
                symptoms: [
                    Symptom(
                        name: "Yellowing of older leaves",
                        nameHindi: "पुरानी पत्तियों का पीलापन",
                        description: "Uniform yellowing starting from lower leaves",
                        descriptionHindi: "निचली पत्तियों से शुरू होने वाला समान पीलापन",
                        affectedPart: .leaf,
                        icon: "leaf"
                    ),
                    Symptom(
                        name: "Stunted growth",
                        nameHindi: "बौना विकास",
                        description: "Overall reduced plant growth",
                        descriptionHindi: "समग्र पौधे का विकास कम",
                        affectedPart: .wholePlant,
                        icon: "arrow.up.and.down"
                    )
                ],
                causes: ["Insufficient nitrogen in soil", "Leaching due to heavy rain", "Poor organic matter"],
                causesHindi: ["मिट्टी में अपर्याप्त नाइट्रोजन", "भारी बारिश के कारण रिसाव", "खराब कार्बनिक पदार्थ"],
                preventiveMeasures: ["Regular soil testing", "Organic matter addition", "Split fertilizer application"],
                preventiveMeasuresHindi: ["नियमित मिट्टी परीक्षण", "जैविक पदार्थ मिलाना", "विभाजित उर्वरक प्रयोग"],
                organicTreatments: [
                    Treatment(
                        name: "Vermicompost",
                        nameHindi: "वर्मीकम्पोस्ट",
                        description: "Apply vermicompost for slow nitrogen release",
                        descriptionHindi: "धीमी नाइट्रोजन रिलीज के लिए वर्मीकम्पोस्ट लगाएं",
                        type: .organic,
                        applicationMethod: "Soil application",
                        applicationMethodHindi: "मिट्टी में प्रयोग",
                        frequency: "Before sowing and as top dressing",
                        frequencyHindi: "बुवाई से पहले और टॉप ड्रेसिंग के रूप में",
                        dosage: "2-3 tons per acre"
                    )
                ],
                chemicalTreatments: [
                    Treatment(
                        name: "Urea",
                        nameHindi: "यूरिया",
                        description: "Quick-release nitrogen fertilizer",
                        descriptionHindi: "त्वरित-रिलीज नाइट्रोजन उर्वरक",
                        type: .chemical,
                        applicationMethod: "Broadcasting or foliar spray",
                        applicationMethodHindi: "छिटककर या पत्तियों पर छिड़काव",
                        frequency: "Split application",
                        frequencyHindi: "विभाजित प्रयोग",
                        dosage: "Based on soil test recommendations",
                        precautions: ["Avoid over-application", "Apply before irrigation"],
                        precautionsHindi: ["अधिक प्रयोग से बचें", "सिंचाई से पहले लगाएं"]
                    )
                ],
                severity: .moderate,
                spreadMechanism: "Not contagious - environmental deficiency",
                spreadMechanismHindi: "संक्रामक नहीं - पर्यावरणीय कमी"
            ),

            // Pest
            Disease(
                name: "Aphid Infestation",
                nameHindi: "माहू प्रकोप",
                type: .pest,
                symptoms: [
                    Symptom(
                        name: "Curled leaves",
                        nameHindi: "मुड़ी हुई पत्तियां",
                        description: "Young leaves curl and distort",
                        descriptionHindi: "युवा पत्तियां मुड़ जाती हैं और विकृत हो जाती हैं",
                        affectedPart: .leaf,
                        icon: "leaf.arrow.triangle.circlepath"
                    ),
                    Symptom(
                        name: "Sticky honeydew",
                        nameHindi: "चिपचिपा मधु",
                        description: "Shiny, sticky substance on leaves",
                        descriptionHindi: "पत्तियों पर चमकदार, चिपचिपा पदार्थ",
                        affectedPart: .leaf,
                        icon: "drop.fill"
                    )
                ],
                causes: ["Aphid insects", "Warm weather", "Lack of natural predators"],
                causesHindi: ["माहू कीट", "गर्म मौसम", "प्राकृतिक शिकारियों की कमी"],
                preventiveMeasures: ["Encourage beneficial insects", "Remove weeds", "Avoid excess nitrogen"],
                preventiveMeasuresHindi: ["लाभकारी कीड़ों को प्रोत्साहित करें", "खरपतवार हटाएं", "अधिक नाइट्रोजन से बचें"],
                organicTreatments: [
                    Treatment(
                        name: "Neem oil spray",
                        nameHindi: "नीम तेल स्प्रे",
                        description: "Natural insecticide from neem",
                        descriptionHindi: "नीम से प्राकृतिक कीटनाशक",
                        type: .organic,
                        applicationMethod: "Foliar spray",
                        applicationMethodHindi: "पत्तियों पर छिड़काव",
                        frequency: "Every 5-7 days until controlled",
                        frequencyHindi: "नियंत्रण होने तक हर 5-7 दिन",
                        dosage: "5ml per liter water with soap"
                    )
                ],
                chemicalTreatments: [
                    Treatment(
                        name: "Imidacloprid",
                        nameHindi: "इमिडाक्लोप्रिड",
                        description: "Systemic insecticide for sucking pests",
                        descriptionHindi: "चूसने वाले कीटों के लिए प्रणालीगत कीटनाशक",
                        type: .chemical,
                        applicationMethod: "Foliar spray or soil drench",
                        applicationMethodHindi: "पत्तियों पर छिड़काव या मिट्टी में",
                        frequency: "Once or twice as needed",
                        frequencyHindi: "आवश्यकतानुसार एक या दो बार",
                        dosage: "0.3ml per liter water",
                        precautions: ["Harmful to bees", "Apply in evening", "Maintain safety period"],
                        precautionsHindi: ["मधुमक्खियों के लिए हानिकारक", "शाम को लगाएं", "सुरक्षा अवधि बनाए रखें"]
                    )
                ],
                severity: .moderate,
                spreadMechanism: "Winged aphids fly to new plants, also spread by ants",
                spreadMechanismHindi: "पंखों वाले माहू नए पौधों पर उड़ते हैं, चींटियों द्वारा भी फैलते हैं"
            )
        ]
    }

    private func getDefaultSymptoms() -> [Symptom] {
        [
            // Leaf Symptoms
            Symptom(
                name: "Yellowing leaves",
                nameHindi: "पत्तियों का पीला पड़ना",
                description: "Leaves turning yellow, may indicate nutrient deficiency or disease",
                descriptionHindi: "पत्तियां पीली पड़ रही हैं, पोषक तत्वों की कमी या बीमारी का संकेत हो सकता है",
                affectedPart: .leaf,
                visualIndicators: ["chlorosis", "yellow", "pale"],
                icon: "leaf.fill"
            ),
            Symptom(
                name: "Leaf spots",
                nameHindi: "पत्तियों पर धब्बे",
                description: "Spots on leaves of various colors and shapes",
                descriptionHindi: "विभिन्न रंगों और आकारों के धब्बे पत्तियों पर",
                affectedPart: .leaf,
                visualIndicators: ["spot", "lesion", "circle", "ring"],
                icon: "circle.dotted"
            ),
            Symptom(
                name: "Wilting",
                nameHindi: "मुरझाना",
                description: "Drooping or wilting of leaves and stems",
                descriptionHindi: "पत्तियों और तनों का झुकना या मुरझाना",
                affectedPart: .wholePlant,
                visualIndicators: ["droop", "wilt", "limp"],
                icon: "leaf.arrow.triangle.circlepath"
            ),
            Symptom(
                name: "Holes in leaves",
                nameHindi: "पत्तियों में छेद",
                description: "Small to large holes caused by insects",
                descriptionHindi: "कीड़ों द्वारा बनाए गए छोटे से बड़े छेद",
                affectedPart: .leaf,
                visualIndicators: ["hole", "eaten", "chewed"],
                icon: "circle.slash"
            ),
            Symptom(
                name: "Powdery coating",
                nameHindi: "पाउडर जैसी परत",
                description: "White powdery substance on leaf surface",
                descriptionHindi: "पत्ती की सतह पर सफेद पाउडर जैसा पदार्थ",
                affectedPart: .leaf,
                visualIndicators: ["powder", "white", "mildew"],
                icon: "sparkles"
            ),
            Symptom(
                name: "Curling leaves",
                nameHindi: "पत्तियों का मुड़ना",
                description: "Leaves curling inward or outward",
                descriptionHindi: "पत्तियां अंदर या बाहर की ओर मुड़ना",
                affectedPart: .leaf,
                visualIndicators: ["curl", "roll", "twist"],
                icon: "arrow.triangle.2.circlepath"
            ),

            // Stem Symptoms
            Symptom(
                name: "Stem rot",
                nameHindi: "तना सड़न",
                description: "Soft, discolored rotting of stem",
                descriptionHindi: "तने का नरम, रंग बदला हुआ सड़ना",
                affectedPart: .stem,
                visualIndicators: ["rot", "soft", "brown stem"],
                icon: "arrow.up.and.down"
            ),
            Symptom(
                name: "Stem lesions",
                nameHindi: "तने पर घाव",
                description: "Wounds or cankers on stem",
                descriptionHindi: "तने पर घाव या कैंकर",
                affectedPart: .stem,
                visualIndicators: ["canker", "wound", "lesion stem"],
                icon: "bandage"
            ),

            // Fruit Symptoms
            Symptom(
                name: "Fruit rot",
                nameHindi: "फल सड़न",
                description: "Rotting or decay of fruits",
                descriptionHindi: "फलों का सड़ना या क्षय",
                affectedPart: .fruit,
                visualIndicators: ["rot fruit", "decay", "moldy"],
                icon: "apple.logo"
            ),
            Symptom(
                name: "Fruit deformation",
                nameHindi: "फल विकृति",
                description: "Abnormal shape or growth of fruits",
                descriptionHindi: "फलों का असामान्य आकार या वृद्धि",
                affectedPart: .fruit,
                visualIndicators: ["deformed", "misshapen", "abnormal fruit"],
                icon: "exclamationmark.triangle"
            ),

            // Root Symptoms
            Symptom(
                name: "Root rot",
                nameHindi: "जड़ सड़न",
                description: "Dark, mushy roots with foul smell",
                descriptionHindi: "गहरे रंग की, गीली जड़ें जिनमें बदबू आती है",
                affectedPart: .root,
                visualIndicators: ["root rot", "brown root", "mushy root"],
                icon: "arrow.down.to.line"
            ),

            // General Symptoms
            Symptom(
                name: "Stunted growth",
                nameHindi: "बौना विकास",
                description: "Plant smaller than normal",
                descriptionHindi: "पौधा सामान्य से छोटा",
                affectedPart: .wholePlant,
                visualIndicators: ["small", "stunted", "dwarf"],
                icon: "arrow.down"
            ),
            Symptom(
                name: "Drying/Browning",
                nameHindi: "सूखना/भूरा होना",
                description: "Leaves or plant parts turning brown and dry",
                descriptionHindi: "पत्तियां या पौधे के हिस्से भूरे और सूखे हो रहे हैं",
                affectedPart: .wholePlant,
                visualIndicators: ["dry", "brown", "dead", "necrosis"],
                icon: "flame"
            )
        ]
    }
}

// MARK: - Offline Errors

enum OfflineError: Error, LocalizedError {
    case noConnection
    case dataNotFound
    case storageError

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .dataNotFound:
            return "Data not found"
        case .storageError:
            return "Storage error"
        }
    }

    var errorDescriptionHindi: String {
        switch self {
        case .noConnection:
            return "इंटरनेट कनेक्शन नहीं है"
        case .dataNotFound:
            return "डेटा नहीं मिला"
        case .storageError:
            return "स्टोरेज त्रुटि"
        }
    }
}
