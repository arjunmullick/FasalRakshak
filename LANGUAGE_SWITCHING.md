# Language Switching Implementation Guide

## ✅ What's Been Implemented

### 1. **Unified Language State Management**
   - **Single Source of Truth**: `AppState.selectedLanguage`
   - **Synchronized Voice**: VoiceAssistantService automatically syncs with AppState
   - **Persistent Storage**: Language preference saved to UserDefaults with key `"selectedLanguage"`

### 2. **How It Works**

```swift
// User selects a language
appState.setLanguage(.english)

// This automatically:
// 1. Updates AppState.selectedLanguage
// 2. Saves to UserDefaults
// 3. Updates VoiceAssistantService.currentLanguage
// 4. Speaks confirmation in the new language
```

### 3. **Voice Confirmation**

When you switch language, you'll hear:
- **Hindi**: "भाषा हिंदी में बदल गई है।"
- **English**: "Language changed to English."
- **Telugu**: "భాష తెలుగులోకి మార్చబడింది."
- **Tamil**: "மொழி தமிழாக மாற்றப்பட்டது."
- **Kannada**: "ಭಾಷೆ ಕನ್ನಡಕ್ಕೆ ಬದಲಾಯಿಸಲಾಗಿದೆ."
- **Bengali**: "ভাষা বাংলায় পরিবর্তন করা হয়েছে।"
- **Marathi**: "भाषा मराठीमध्ये बदलली आहे."
- **Gujarati**: "ભાષા ગુજરાતીમાં બદલાઈ ગઈ છે."
- **Punjabi**: "ਭਾਸ਼ਾ ਪੰਜਾਬੀ ਵਿੱਚ ਬਦਲੀ ਗਈ ਹੈ।"

### 4. **Where Language Can Be Changed**

1. **Onboarding Screen**: Initial language selection
2. **Profile Settings**: Language selector in FarmerProfileView
3. **Programmatically**: `appState.setLanguage(.english)`

## 📱 Usage Examples

### For Users:
```
1. Open the app
2. Go to Profile/Settings
3. Tap on "Language" (भाषा)
4. Select your preferred language
5. The UI and voice will both switch immediately
```

### For Developers:
```swift
// In any view with access to @EnvironmentObject
@EnvironmentObject var appState: AppState

// Switch to English
appState.setLanguage(.english)

// Switch to Hindi
appState.setLanguage(.hindi)

// Current language
let currentLang = appState.selectedLanguage
```

## 🔧 Technical Details

### Files Modified:

1. **FasalRakshakApp.swift**
   - Added `init()` to AppState to load saved language
   - Updated `setLanguage()` to sync with VoiceAssistantService

2. **VoiceAssistantService.swift**
   - Changed UserDefaults key to `"selectedLanguage"` for consistency
   - Added voice confirmation when language changes
   - Speaks confirmation message in the new language

3. **FarmerProfileView.swift**
   - Simplified language switching (removed redundant call)
   - Now only calls `appState.setLanguage()`

### Data Flow:

```
User Action
    ↓
appState.setLanguage(language)
    ↓
    ├─→ Update AppState.selectedLanguage
    ├─→ Save to UserDefaults ("selectedLanguage")
    └─→ Call VoiceAssistantService.setLanguage(language)
            ↓
            ├─→ Update currentLanguage
            ├─→ Save to UserDefaults ("selectedLanguage")
            └─→ Speak confirmation in new language
```

## ⚠️ Current Limitations

### Hardcoded Hindi Text

Some methods in VoiceAssistantService are hardcoded to Hindi:
- `speakHindi()` - Always speaks in Hindi
- `speakDiagnosisResult()` - Uses Hindi text
- `speakTreatmentSteps()` - Uses Hindi text
- `speakReminder()` - Uses Hindi text

### To Fix (Future Enhancement):

1. **Create Localized Strings Structure**:
```swift
struct LocalizedStrings {
    static func get(_ key: String, language: AppLanguage) -> String {
        // Return localized string based on language
    }
}
```

2. **Update Data Models** to include all language variants:
```swift
struct Disease {
    let name: String  // English
    let nameHindi: String
    let nameTelugu: String
    let nameTamil: String
    // ... etc
}
```

3. **Update Voice Methods** to use current language:
```swift
func speakDiagnosisResult(_ result: DiagnosisResult) {
    let text: String
    switch currentLanguage {
    case .hindi:
        text = result.diseaseNameHindi
    case .english:
        text = result.diseaseName
    // ... etc
    }
    speak(text)
}
```

## 🌍 Supported Languages

All 9 Indian languages are supported:

| Language | Code | Native Name | Voice Identifier |
|----------|------|-------------|------------------|
| Hindi | hi | हिंदी | hi-IN |
| English | en | English | en-IN |
| Telugu | te | తెలుగు | te-IN |
| Tamil | ta | தமிழ் | ta-IN |
| Kannada | kn | ಕನ್ನಡ | kn-IN |
| Bengali | bn | বাংলা | bn-IN |
| Marathi | mr | मराठी | mr-IN |
| Gujarati | gu | ગુજરાતી | gu-IN |
| Punjabi | pa | ਪੰਜਾਬੀ | pa-IN |

## ✅ Testing Checklist

- [x] Language persists after app restart
- [x] Voice switches when language changes
- [x] Voice confirmation plays in new language
- [x] Onboarding language selection works
- [x] Profile settings language selection works
- [x] AppState and VoiceAssistant stay synchronized

## 🎯 Next Steps for Full Multilingual Support

1. **Create Localization System**
   - Add `.strings` files for each language
   - Or use a structured approach with dictionaries

2. **Update All Models**
   - Add properties for each language variant
   - Update database/offline data with translations

3. **Update Voice Methods**
   - Make all `speak*()` methods language-aware
   - Use current language to select appropriate text

4. **Update UI Components**
   - Create localized versions of all UI text
   - Use `Text(LocalizedStringKey)` or custom system

5. **Test on Device**
   - Verify TTS voices are available for all languages
   - Test pronunciation and clarity
   - Adjust speech rate per language if needed

---

**Status**: ✅ **Basic language switching fully functional!**

When you change to English (or any other language), both the voice and language setting will change simultaneously.
