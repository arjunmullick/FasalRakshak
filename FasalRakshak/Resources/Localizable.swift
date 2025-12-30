//
//  Localizable.swift
//  FasalRakshak
//
//  Centralized localization for all app text
//

import Foundation

/// Localization helper that provides text based on selected language
struct Localizable {

    // MARK: - Common Terms
    static func welcome(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "स्वागत है"
        case .english: return "Welcome"
        case .telugu: return "స్వాగతం"
        case .tamil: return "வரவேற்பு"
        case .kannada: return "ಸ್ವಾಗತ"
        case .bengali: return "স্বাগতম"
        case .marathi: return "स्वागत आहे"
        case .gujarati: return "સ્વાગત છે"
        case .punjabi: return "ਸੁਆਗਤ ਹੈ"
        }
    }

    static func appName(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "फसल रक्षक"
        case .english: return "Crop Guardian"
        default: return "फसल रक्षक" // Use Hindi for other languages
        }
    }

    static func getStarted(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "शुरू करें"
        case .english: return "Get Started"
        case .telugu: return "ప్రారంభించండి"
        case .tamil: return "தொடங்குங்கள்"
        case .kannada: return "ಪ್ರಾರಂಭಿಸಿ"
        case .bengali: return "শুরু করুন"
        case .marathi: return "सुरू करा"
        case .gujarati: return "શરૂ કરો"
        case .punjabi: return "ਸ਼ੁਰੂ ਕਰੋ"
        }
    }

    static func next(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "अगला"
        case .english: return "Next"
        case .telugu: return "తదుపరి"
        case .tamil: return "அடுத்தது"
        case .kannada: return "ಮುಂದೆ"
        case .bengali: return "পরবর্তী"
        case .marathi: return "पुढे"
        case .gujarati: return "આગળ"
        case .punjabi: return "ਅੱਗੇ"
        }
    }

    static func back(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "पीछे"
        case .english: return "Back"
        case .telugu: return "వెనుకకు"
        case .tamil: return "பின்"
        case .kannada: return "ಹಿಂದೆ"
        case .bengali: return "পিছনে"
        case .marathi: return "मागे"
        case .gujarati: return "પાછળ"
        case .punjabi: return "ਪਿੱਛੇ"
        }
    }

    static func skip(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "छोड़ें"
        case .english: return "Skip"
        case .telugu: return "దాటవేయండి"
        case .tamil: return "தவிர்"
        case .kannada: return "ಬಿಟ್ಟುಬಿಡಿ"
        case .bengali: return "এড়িয়ে যান"
        case .marathi: return "वगळा"
        case .gujarati: return "છોડો"
        case .punjabi: return "ਛੱਡੋ"
        }
    }

    static func done(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "पूर्ण"
        case .english: return "Done"
        case .telugu: return "పూర్తి"
        case .tamil: return "முடிந்தது"
        case .kannada: return "ಮುಗಿದಿದೆ"
        case .bengali: return "সম্পন্ন"
        case .marathi: return "पूर्ण"
        case .gujarati: return "પૂર્ણ"
        case .punjabi: return "ਪੂਰਾ"
        }
    }

    // MARK: - Onboarding
    static func onboardingTitle1(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "फसल रक्षक में आपका स्वागत है"
        case .english: return "Welcome to Crop Guardian"
        case .telugu: return "క్రాప్ గార్డియన్‌కు స్వాగతం"
        case .tamil: return "பயிர் பாதுகாவலருக்கு வரவேற்பு"
        case .kannada: return "ಕ್ರಾಪ್ ಗಾರ್ಡಿಯನ್‌ಗೆ ಸ್ವಾಗತ"
        case .bengali: return "ক্রপ গার্ডিয়ানে স্বাগতম"
        case .marathi: return "क्रॉप गार्डियनमध्ये आपले स्वागत आहे"
        case .gujarati: return "ક્રોપ ગાર્ડિયનમાં આપનું સ્વાગત છે"
        case .punjabi: return "ਕ੍ਰੌਪ ਗਾਰਡੀਅਨ ਵਿੱਚ ਤੁਹਾਡਾ ਸੁਆਗਤ ਹੈ"
        }
    }

    static func onboardingDesc1(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "भारतीय किसानों के लिए AI-संचालित फसल स्वास्थ्य निदान ऐप"
        case .english: return "AI-powered crop health diagnosis app for Indian farmers"
        case .telugu: return "భారతీయ రైతుల కోసం AI-ఆధారిత పంట ఆరోగ్య నిర్ధారణ యాప్"
        case .tamil: return "இந்திய விவசாயிகளுக்கான AI-இயங்கும் பயிர் சுகாதார கண்டறிதல் பயன்பாடு"
        case .kannada: return "ಭಾರತೀಯ ರೈತರಿಗಾಗಿ AI-ಚಾಲಿತ ಬೆಳೆ ಆರೋಗ್ಯ ರೋಗನಿರ್ಣಯ ಅಪ್ಲಿಕೇಶನ್"
        case .bengali: return "ভারতীয় কৃষকদের জন্য AI-চালিত ফসল স্বাস্থ্য নির্ণয় অ্যাপ"
        case .marathi: return "भारतीय शेतकऱ्यांसाठी AI-संचालित पीक आरोग्य निदान अॅप"
        case .gujarati: return "ભારતીય ખેડૂતો માટે AI-સંચાલિત પાક સ્વાસ્થ્ય નિદાન એપ્લિકેશન"
        case .punjabi: return "ਭਾਰਤੀ ਕਿਸਾਨਾਂ ਲਈ AI-ਸੰਚਾਲਿਤ ਫਸਲ ਸਿਹਤ ਨਿਦਾਨ ਐਪ"
        }
    }

    static func onboardingTitle2(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "तुरंत निदान"
        case .english: return "Instant Diagnosis"
        case .telugu: return "తక్షణ నిర్ధారణ"
        case .tamil: return "உடனடி கண்டறிதல்"
        case .kannada: return "ತಕ್ಷಣದ ರೋಗನಿರ್ಣಯ"
        case .bengali: return "তাত্ক্ষণিক নির্ণয়"
        case .marathi: return "त्वरित निदान"
        case .gujarati: return "તાત્કાલિક નિદાન"
        case .punjabi: return "ਤੁਰੰਤ ਨਿਦਾਨ"
        }
    }

    static func onboardingDesc2(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "अपनी फसल की तस्वीर लें और AI से रोग की पहचान कराएं"
        case .english: return "Take a photo of your crop and get AI-powered disease identification"
        case .telugu: return "మీ పంట యొక్క ఫోటో తీసి AI ద్వారా వ్యాధిని గుర్తించండి"
        case .tamil: return "உங்கள் பயிரின் புகைப்படத்தை எடுத்து AI மூலம் நோயைக் கண்டறியுங்கள்"
        case .kannada: return "ನಿಮ್ಮ ಬೆಳೆಯ ಫೋಟೋ ತೆಗೆದುಕೊಳ್ಳಿ ಮತ್ತು AI ಮೂಲಕ ರೋಗವನ್ನು ಗುರುತಿಸಿ"
        case .bengali: return "আপনার ফসলের ছবি তুলুন এবং AI দিয়ে রোগ শনাক্ত করুন"
        case .marathi: return "तुमच्या पिकाचा फोटो घ्या आणि AI द्वारे रोग ओळखा"
        case .gujarati: return "તમારા પાકનો ફોટો લો અને AI દ્વારા રોગ ઓળખો"
        case .punjabi: return "ਆਪਣੀ ਫਸਲ ਦੀ ਫੋਟੋ ਲਓ ਅਤੇ AI ਨਾਲ ਬਿਮਾਰੀ ਦੀ ਪਛਾਣ ਕਰੋ"
        }
    }

    static func onboardingTitle3(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "ऑफलाइन मोड"
        case .english: return "Offline Mode"
        case .telugu: return "ఆఫ్‌లైన్ మోడ్"
        case .tamil: return "ஆஃப்லைன் பயன்முறை"
        case .kannada: return "ಆಫ್‌ಲೈನ್ ಮೋಡ್"
        case .bengali: return "অফলাইন মোড"
        case .marathi: return "ऑफलाइन मोड"
        case .gujarati: return "ઓફલાઇન મોડ"
        case .punjabi: return "ਆਫਲਾਈਨ ਮੋਡ"
        }
    }

    static func onboardingDesc3(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "इंटरनेट के बिना भी काम करता है - ग्रामीण क्षेत्रों के लिए एकदम सही"
        case .english: return "Works without internet - perfect for rural areas"
        case .telugu: return "ఇంటర్నెట్ లేకుండా పనిచేస్తుంది - గ్రామీణ ప్రాంతాలకు సరైనది"
        case .tamil: return "இணையம் இல்லாமல் செயல்படும் - கிராமப்புற பகுதிகளுக்கு சரியானது"
        case .kannada: return "ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆಯೇ ಕೆಲಸ ಮಾಡುತ್ತದೆ - ಗ್ರಾಮೀಣ ಪ್ರದೇಶಗಳಿಗೆ ಸೂಕ್ತವಾಗಿದೆ"
        case .bengali: return "ইন্টারনেট ছাড়াই কাজ করে - গ্রামীণ এলাকার জন্য উপযুক্ত"
        case .marathi: return "इंटरनेटशिवाय कार्य करते - ग्रामीण भागांसाठी योग्य"
        case .gujarati: return "ઇન્ટરનેટ વિના કામ કરે છે - ગ્રામીણ વિસ્તારો માટે યોગ્ય"
        case .punjabi: return "ਇੰਟਰਨੈੱਟ ਤੋਂ ਬਿਨਾਂ ਕੰਮ ਕਰਦਾ ਹੈ - ਪੇਂਡੂ ਖੇਤਰਾਂ ਲਈ ਸਹੀ"
        }
    }

    static func yourName(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "आपका नाम"
        case .english: return "Your Name"
        case .telugu: return "మీ పేరు"
        case .tamil: return "உங்கள் பெயர்"
        case .kannada: return "ನಿಮ್ಮ ಹೆಸರು"
        case .bengali: return "আপনার নাম"
        case .marathi: return "तुमचे नाव"
        case .gujarati: return "તમારું નામ"
        case .punjabi: return "ਤੁਹਾਡਾ ਨਾਮ"
        }
    }

    static func enterName(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "अपना नाम दर्ज करें"
        case .english: return "Enter your name"
        case .telugu: return "మీ పేరు నమోదు చేయండి"
        case .tamil: return "உங்கள் பெயரை உள்ளிடவும்"
        case .kannada: return "ನಿಮ್ಮ ಹೆಸರನ್ನು ನಮೂದಿಸಿ"
        case .bengali: return "আপনার নাম লিখুন"
        case .marathi: return "तुमचे नाव प्रविष्ट करा"
        case .gujarati: return "તમારું નામ દાખલ કરો"
        case .punjabi: return "ਆਪਣਾ ਨਾਮ ਦਰਜ ਕਰੋ"
        }
    }

    static func selectLanguage(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "भाषा चुनें"
        case .english: return "Select Language"
        case .telugu: return "భాష ఎంచుకోండి"
        case .tamil: return "மொழியைத் தேர்ந்தெடுக்கவும்"
        case .kannada: return "ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ"
        case .bengali: return "ভাষা নির্বাচন করুন"
        case .marathi: return "भाषा निवडा"
        case .gujarati: return "ભાષા પસંદ કરો"
        case .punjabi: return "ਭਾਸ਼ਾ ਚੁਣੋ"
        }
    }

    // MARK: - Home Screen
    static func home(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "होम"
        case .english: return "Home"
        case .telugu: return "హోమ్"
        case .tamil: return "முகப்பு"
        case .kannada: return "ಮುಖಪುಟ"
        case .bengali: return "হোম"
        case .marathi: return "होम"
        case .gujarati: return "હોમ"
        case .punjabi: return "ਹੋਮ"
        }
    }

    static func diagnose(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "निदान करें"
        case .english: return "Diagnose"
        case .telugu: return "నిర్ధారించు"
        case .tamil: return "கண்டறி"
        case .kannada: return "ರೋಗನಿರ್ಣಯ"
        case .bengali: return "নির্ণয়"
        case .marathi: return "निदान करा"
        case .gujarati: return "નિદાન કરો"
        case .punjabi: return "ਨਿਦਾਨ ਕਰੋ"
        }
    }

    static func history(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "इतिहास"
        case .english: return "History"
        case .telugu: return "చరిత్ర"
        case .tamil: return "வரலாறு"
        case .kannada: return "ಇತಿಹಾಸ"
        case .bengali: return "ইতিহাস"
        case .marathi: return "इतिहास"
        case .gujarati: return "ઇતિહાસ"
        case .punjabi: return "ਇਤਿਹਾਸ"
        }
    }

    static func profile(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "प्रोफाइल"
        case .english: return "Profile"
        case .telugu: return "ప్రొఫైల్"
        case .tamil: return "சுயவிவரம்"
        case .kannada: return "ಪ್ರೊಫೈಲ್"
        case .bengali: return "প্রোফাইল"
        case .marathi: return "प्रोफाईल"
        case .gujarati: return "પ્રોફાઇલ"
        case .punjabi: return "ਪ੍ਰੋਫਾਈਲ"
        }
    }

    static func camera(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "कैमरा"
        case .english: return "Camera"
        case .telugu: return "కెమెరా"
        case .tamil: return "கேமரா"
        case .kannada: return "ಕ್ಯಾಮೆರಾ"
        case .bengali: return "ক্যামেরা"
        case .marathi: return "कॅमेरा"
        case .gujarati: return "કેમેરા"
        case .punjabi: return "ਕੈਮਰਾ"
        }
    }

    static func crops(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "फसलें"
        case .english: return "Crops"
        case .telugu: return "పంటలు"
        case .tamil: return "பயிர்கள்"
        case .kannada: return "ಬೆಳೆಗಳು"
        case .bengali: return "ফসল"
        case .marathi: return "पिके"
        case .gujarati: return "પાકો"
        case .punjabi: return "ਫਸਲਾਂ"
        }
    }

    // MARK: - Settings/Profile
    static func settings(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "सेटिंग्स"
        case .english: return "Settings"
        case .telugu: return "సెట్టింగ్‌లు"
        case .tamil: return "அமைப்புகள்"
        case .kannada: return "ಸೆಟ್ಟಿಂಗ್‌ಗಳು"
        case .bengali: return "সেটিংস"
        case .marathi: return "सेटिंग्ज"
        case .gujarati: return "સેટિંગ્સ"
        case .punjabi: return "ਸੈਟਿੰਗਾਂ"
        }
    }

    static func language(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "भाषा"
        case .english: return "Language"
        case .telugu: return "భాష"
        case .tamil: return "மொழி"
        case .kannada: return "ಭಾಷೆ"
        case .bengali: return "ভাষা"
        case .marathi: return "भाषा"
        case .gujarati: return "ભાષા"
        case .punjabi: return "ਭਾਸ਼ਾ"
        }
    }

    static func save(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "सहेजें"
        case .english: return "Save"
        case .telugu: return "సేవ్ చేయండి"
        case .tamil: return "சேமி"
        case .kannada: return "ಉಳಿಸು"
        case .bengali: return "সংরক্ষণ করুন"
        case .marathi: return "जतन करा"
        case .gujarati: return "સાચવો"
        case .punjabi: return "ਸੰਭਾਲੋ"
        }
    }

    static func cancel(_ lang: AppLanguage) -> String {
        switch lang {
        case .hindi: return "रद्द करें"
        case .english: return "Cancel"
        case .telugu: return "రద్దు చేయండి"
        case .tamil: return "ரத்துசெய்"
        case .kannada: return "ರದ್ದುಮಾಡಿ"
        case .bengali: return "বাতিল করুন"
        case .marathi: return "रद्द करा"
        case .gujarati: return "રદ કરો"
        case .punjabi: return "ਰੱਦ ਕਰੋ"
        }
    }
}
