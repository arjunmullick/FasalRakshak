//
//  VoiceAssistantService.swift
//  FasalRakshak
//
//  Text-to-Speech service for Hindi and regional language voice assistance
//

import Foundation
import AVFoundation
import Combine

class VoiceAssistantService: NSObject, ObservableObject {
    static let shared = VoiceAssistantService()

    private let synthesizer = AVSpeechSynthesizer()
    private var audioSession: AVAudioSession?

    @Published var isSpeaking: Bool = false
    @Published var currentLanguage: AppLanguage = .hindi
    @Published var speechRate: Float = 0.45 // Slower for better comprehension
    @Published var isEnabled: Bool = true

    private var speechQueue: [String] = []
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
        loadPreferences()
    }

    // MARK: - Configuration

    private func configureAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .allowBluetooth])
            try audioSession?.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private func loadPreferences() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "voiceLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            currentLanguage = language
        }

        speechRate = UserDefaults.standard.float(forKey: "speechRate")
        if speechRate == 0 {
            speechRate = 0.45
        }

        isEnabled = UserDefaults.standard.bool(forKey: "voiceEnabled")
        if !UserDefaults.standard.bool(forKey: "voicePreferencesSet") {
            isEnabled = true
            UserDefaults.standard.set(true, forKey: "voicePreferencesSet")
        }
    }

    // MARK: - Public Methods

    /// Speak text in the current language
    func speak(_ text: String, priority: SpeechPriority = .normal) {
        guard isEnabled else { return }

        if priority == .high {
            stopSpeaking()
        }

        let utterance = createUtterance(for: text)

        if priority == .high || !isSpeaking {
            synthesizer.speak(utterance)
        } else {
            speechQueue.append(text)
        }
    }

    /// Speak text in Hindi specifically
    func speakHindi(_ text: String, priority: SpeechPriority = .normal) {
        guard isEnabled else { return }

        if priority == .high {
            stopSpeaking()
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "hi-IN")
        utterance.rate = speechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.2

        if priority == .high || !isSpeaking {
            synthesizer.speak(utterance)
        } else {
            speechQueue.append(text)
        }
    }

    /// Speak diagnosis results with proper formatting
    func speakDiagnosisResult(_ result: DiagnosisResult) {
        guard isEnabled else { return }

        var speechText = ""

        // Introduction
        speechText += "फसल स्वास्थ्य रिपोर्ट। "

        // Crop identification
        if let crop = result.identifiedCrop {
            speechText += "पहचानी गई फसल: \(crop.nameHindi)। "
        }

        // Health score
        let healthStatus = result.healthStatus
        speechText += "समग्र स्वास्थ्य: \(healthStatus.displayNameHindi)। "

        // Diagnosed conditions
        if !result.diagnosedConditions.isEmpty {
            speechText += "पाई गई समस्याएं: "
            for (index, condition) in result.diagnosedConditions.enumerated() {
                speechText += "\(index + 1). \(condition.conditionNameHindi)"
                let confidencePercent = Int(condition.confidence * 100)
                speechText += ", विश्वास स्तर \(confidencePercent) प्रतिशत। "
            }
        }

        // Recommendations
        if !result.recommendations.isEmpty {
            speechText += "सुझाव: "
            for (index, recommendation) in result.recommendations.prefix(3).enumerated() {
                speechText += "\(index + 1). \(recommendation.titleHindi)। "
            }
        }

        speak(speechText, priority: .high)
    }

    /// Speak treatment instructions step by step
    func speakTreatmentSteps(_ treatment: Treatment) {
        guard isEnabled else { return }

        var speechText = ""
        speechText += "उपचार: \(treatment.nameHindi)। "
        speechText += "\(treatment.descriptionHindi)। "
        speechText += "प्रयोग विधि: \(treatment.applicationMethodHindi)। "
        speechText += "मात्रा: \(treatment.dosage)। "
        speechText += "आवृत्ति: \(treatment.frequencyHindi)। "

        if !treatment.precautionsHindi.isEmpty {
            speechText += "सावधानियां: "
            for precaution in treatment.precautionsHindi {
                speechText += "\(precaution)। "
            }
        }

        speak(speechText)
    }

    /// Speak reminder notification
    func speakReminder(_ reminder: CropReminder) {
        guard isEnabled else { return }

        let speechText = "याद दिलाना: \(reminder.titleHindi)। \(reminder.descriptionHindi)"
        speak(speechText, priority: .high)
    }

    /// Stop all speech
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        speechQueue.removeAll()
        isSpeaking = false
    }

    /// Pause current speech
    func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .word)
    }

    /// Continue paused speech
    func continueSpeaking() {
        synthesizer.continueSpeaking()
    }

    /// Set preferred language
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "voiceLanguage")
    }

    /// Set speech rate (0.0 to 1.0)
    func setSpeechRate(_ rate: Float) {
        speechRate = max(0.1, min(rate, 1.0))
        UserDefaults.standard.set(speechRate, forKey: "speechRate")
    }

    /// Toggle voice assistance
    func toggleVoice() {
        isEnabled.toggle()
        UserDefaults.standard.set(isEnabled, forKey: "voiceEnabled")
        if !isEnabled {
            stopSpeaking()
        }
    }

    // MARK: - Private Methods

    private func createUtterance(for text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: currentLanguage.voiceIdentifier)
        utterance.rate = speechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.2
        return utterance
    }

    private func speakNextInQueue() {
        guard !speechQueue.isEmpty else {
            isSpeaking = false
            return
        }

        let nextText = speechQueue.removeFirst()
        let utterance = createUtterance(for: nextText)
        synthesizer.speak(utterance)
    }

    // MARK: - Available Voices

    func availableVoices(for language: AppLanguage) -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.starts(with: language.rawValue)
        }
    }

    func isLanguageSupported(_ language: AppLanguage) -> Bool {
        !availableVoices(for: language).isEmpty
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension VoiceAssistantService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.speakNextInQueue()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}

// MARK: - Speech Priority

enum SpeechPriority {
    case low
    case normal
    case high
}

// MARK: - Predefined Voice Messages

extension VoiceAssistantService {
    struct VoiceMessages {
        // Welcome messages
        static let welcomeHindi = "फसल रक्षक में आपका स्वागत है। अपनी फसल की फोटो लें और तुरंत समस्या की पहचान करें।"
        static let welcomeEnglish = "Welcome to Fasal Rakshak. Take a photo of your crop to identify problems instantly."

        // Camera instructions
        static let cameraInstructionHindi = "कृपया प्रभावित पत्ती या पौधे के हिस्से की स्पष्ट फोटो लें। अच्छी रोशनी में फोटो लें।"
        static let cameraInstructionEnglish = "Please take a clear photo of the affected leaf or plant part. Take the photo in good lighting."

        // Processing messages
        static let processingHindi = "फोटो का विश्लेषण हो रहा है। कृपया प्रतीक्षा करें।"
        static let processingEnglish = "Analyzing the photo. Please wait."

        // Success messages
        static let analysisCompleteHindi = "विश्लेषण पूर्ण। परिणाम देखें।"
        static let analysisCompleteEnglish = "Analysis complete. View results."

        // Error messages
        static let errorHindi = "कुछ गलत हो गया। कृपया पुनः प्रयास करें।"
        static let errorEnglish = "Something went wrong. Please try again."

        // No issue found
        static let healthyPlantHindi = "आपकी फसल स्वस्थ दिखती है। कोई बड़ी समस्या नहीं मिली।"
        static let healthyPlantEnglish = "Your crop looks healthy. No major issues found."

        // Offline mode
        static let offlineModeHindi = "ऑफलाइन मोड चालू है। कुछ सुविधाएं उपलब्ध नहीं होंगी।"
        static let offlineModeEnglish = "Offline mode is active. Some features may not be available."
    }
}
