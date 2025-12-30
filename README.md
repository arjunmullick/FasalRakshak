# FasalRakshak (फसल रक्षक)

**AI-Powered Crop Health Diagnosis App for Indian Farmers**

*भारतीय किसानों के लिए AI-संचालित फसल स्वास्थ्य निदान ऐप*

---

## Overview

FasalRakshak is a comprehensive iOS mobile application designed specifically for Indian farmers to identify and diagnose crop health issues including diseases, pests, nutrient deficiencies, and other stress conditions using AI and computer vision. The app is built with modern iOS technologies (Swift + SwiftUI) and optimized for use in rural areas with offline-capable features.

## Key Features

### 1. Image Capture & AI Analysis
- Take or upload photos of crops
- AI/ML powered disease detection (fungal, bacterial, viral)
- Pest infestation identification
- Nutrient deficiency detection
- Water stress analysis
- Confidence scores for diagnoses
- Visual markup showing affected areas

### 2. Voice Assistance (आवाज सहायता)
- Text-to-Speech in Hindi (default) and regional languages
- Read-aloud feature for all diagnosis results and instructions
- Voice-enabled navigation for low-literacy users
- Support for: Hindi, English, Telugu, Tamil, Kannada, Bengali, Marathi, Gujarati, Punjabi

### 3. Symptom Checker (लक्षण जांच)
- Guided interface for visual symptom selection
- Common symptoms: leaf spots, yellowing, wilting, holes
- Intelligent matching to likely causes
- Step-by-step diagnosis flow

### 4. Detailed Care Guides (देखभाल गाइड)
- Causes explained in simple Hindi
- Organic and chemical treatment options
- Preventive measures
- Step-by-step action plans
- Precautions and safety guidelines

### 5. Reminders & Alerts (याद दिलाना)
- Custom calendar reminders for treatments
- Follow-up checks scheduling
- Crop care routines
- Push notifications with Hindi audio

### 6. Offline Mode (ऑफलाइन मोड)
- Comprehensive crop database stored locally
- Cached diagnosis history
- Works in low-connectivity rural areas
- Automatic sync when online

### 7. Crop Database (फसल डेटाबेस)
Major Indian crops covered:
- **Cereals**: Rice (धान), Wheat (गेहूं), Maize (मक्का)
- **Pulses**: Chickpea (चना), Pigeon Pea (अरहर)
- **Vegetables**: Tomato (टमाटर), Potato (आलू), Onion (प्याज), Brinjal (बैंगन)
- **Fruits**: Mango (आम), Banana (केला)
- **Oilseeds**: Groundnut (मूंगफली), Mustard (सरसों)
- **Cash Crops**: Cotton (कपास), Sugarcane (गन्ना)

### 8. Farmer Dashboard (किसान डैशबोर्ड)
- Timeline of past diagnoses
- Treatment success tracking
- Health trend visualization
- Export and share reports

### 9. Expert Consultation (विशेषज्ञ सलाह)
- Connect with agricultural experts
- Text or voice support options
- Tiered service levels

## Technical Architecture

### iOS App
```
FasalRakshak/
├── FasalRakshakApp.swift          # App entry point
├── Models/
│   └── CropModels.swift           # Data models (Crop, Disease, Diagnosis, etc.)
├── Views/
│   ├── ContentView.swift          # Main navigation
│   ├── HomeView.swift             # Home dashboard
│   ├── CameraCaptureView.swift    # Camera interface
│   ├── SymptomCheckerView.swift   # Symptom checker
│   ├── DiagnosisHistoryView.swift # History view
│   ├── DiagnosisDetailView.swift  # Detailed results
│   ├── DiseaseDetailView.swift    # Disease information
│   ├── FarmerProfileView.swift    # User profile & settings
│   ├── OnboardingView.swift       # First-time user flow
│   └── CropViews.swift            # Crop selection & details
├── Services/
│   ├── VoiceAssistantService.swift    # TTS using AVSpeechSynthesizer
│   ├── CropDiagnosisService.swift     # AI/Vision analysis
│   ├── APIService.swift               # Backend REST API
│   ├── OfflineDataManager.swift       # Local storage & caching
│   ├── NotificationManager.swift      # Push notifications
│   ├── NetworkMonitor.swift           # Connectivity detection
│   └── AnalyticsService.swift         # Usage tracking
├── Resources/
│   └── Localizable.xcstrings      # Multi-language strings
└── Assets.xcassets/               # App icons & colors
```

### Technologies Used
- **Swift 5.9+** - Modern Swift language features
- **SwiftUI** - Declarative UI framework
- **AVFoundation** - Camera capture and TTS
- **Vision Framework** - On-device image classification
- **CoreML** - Machine learning inference
- **UserNotifications** - Push notifications
- **Network Framework** - Connectivity monitoring

### Backend Integration
- RESTful API for image analysis
- Scalable ML inference engine
- Analytics collection
- Expert consultation system

## UI/UX Design Principles

- **Simple, large icons & illustrations** - Easy to understand visuals
- **Minimal text with voice instructions** - Accessibility for low-literacy users
- **Quick access camera launch** - One-tap photo capture
- **High-contrast buttons** - Visibility in outdoor conditions
- **Hindi-first interface** - Primary language is Hindi with English support

## Getting Started

### Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/arjunmullick/FasalRakshak.git
cd FasalRakshak
```

2. Open in Xcode:
```bash
open FasalRakshak.xcodeproj
```
Or build with Swift Package Manager:
```bash
swift build
```

3. Configure API keys (optional):
Set environment variables for backend services:
```bash
export API_BASE_URL="https://api.fasalrakshak.in/v1"
export API_KEY="your-api-key"
```

4. Build and run on device or simulator.

## Supported Languages

| Language | Code | Status |
|----------|------|--------|
| Hindi | hi | ✅ Full Support |
| English | en | ✅ Full Support |
| Telugu | te | 🔄 Coming Soon |
| Tamil | ta | 🔄 Coming Soon |
| Kannada | kn | 🔄 Coming Soon |
| Bengali | bn | 🔄 Coming Soon |
| Marathi | mr | 🔄 Coming Soon |
| Gujarati | gu | 🔄 Coming Soon |
| Punjabi | pa | 🔄 Coming Soon |

## Disease Coverage

The app can identify common diseases and issues for major Indian crops:

### Fungal Diseases
- Rice Blast (धान का ब्लास्ट)
- Wheat Rust (गेहूं का रतुआ)
- Early Blight (अगेती अंगमारी)
- Late Blight (पछेती अंगमारी)
- Powdery Mildew

### Bacterial Diseases
- Bacterial Wilt
- Bacterial Blight
- Soft Rot

### Viral Diseases
- Leaf Curl
- Mosaic Virus
- Yellow Vein Mosaic

### Nutrient Deficiencies
- Nitrogen (नाइट्रोजन की कमी)
- Phosphorus
- Potassium
- Iron

### Pest Infestations
- Aphids (माहू)
- Bollworm
- Stem Borer
- Whitefly

## Privacy & Security

- Secure photo and user data storage
- Anonymized usage analytics
- Clear privacy policy in Hindi
- Data encrypted in transit and at rest
- No selling of farmer data to third parties

## Contributing

We welcome contributions! Please see our contributing guidelines.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Indian agricultural research institutions
- Farming communities across India
- Open-source ML models for plant disease detection

---

**Made with ❤️ for Indian Farmers**

*किसानों के लिए, प्यार से बनाया गया* 🇮🇳
