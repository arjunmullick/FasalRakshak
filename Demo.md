# FasalRakshak Demo Guide

## How to Demo the iOS App

This guide provides step-by-step instructions for setting up and demonstrating the FasalRakshak crop health diagnosis app.

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| **macOS** | Required for iOS development |
| **Xcode 15+** | Download from Mac App Store |
| **iOS Simulator** | Included with Xcode |
| **Physical iPhone** | Optional, iOS 16+ for full camera testing |

---

## Option 1: Run in Xcode Simulator (Recommended)

### Step 1: Clone the Repository

```bash
git clone https://github.com/arjunmullick/FasalRakshak.git
cd FasalRakshak
git checkout claude/ios-crop-health-app-aDjok
```

### Step 2: Create Xcode Project

Since we have a Swift Package structure, create a new Xcode project:

```bash
# Open Xcode
open -a Xcode
```

Then in Xcode:

1. **File → New → Project**
2. Select **iOS → App**
3. Configure the project:
   - **Product Name:** `FasalRakshak`
   - **Team:** Your Apple Developer account (or None for simulator)
   - **Organization Identifier:** `com.yourname`
   - **Interface:** `SwiftUI`
   - **Language:** `Swift`
4. Click **Next** and save in a temporary location
5. In the project navigator, delete the auto-generated `ContentView.swift` and `FasalRakshakApp.swift`
6. Right-click on the project → **Add Files to "FasalRakshak"**
7. Navigate to the cloned repository and add:
   - All files from `FasalRakshak/` folder
   - Select "Copy items if needed"
   - Select "Create groups"
8. Add `Info.plist` entries or replace the generated one

### Step 3: Configure Build Settings

1. Select the project in navigator
2. Go to **Signing & Capabilities**
3. Add capabilities:
   - **Camera**
   - **Push Notifications** (optional)
   - **Background Modes** → Audio

### Step 4: Run the App

1. Select **iPhone 15 Pro** (or any iPhone) from the device dropdown
2. Press **⌘R** (Command + R) to build and run
3. The app will launch in the iOS Simulator

---

## Option 2: Swift Package Manager (Command Line)

```bash
# Clone and navigate
git clone https://github.com/arjunmullick/FasalRakshak.git
cd FasalRakshak

# Build with SPM
swift build

# Note: This builds the library but won't run the app
# Use Xcode for running the actual iOS app
```

---

## Option 3: Quick Demo with Swift Playgrounds (iPad)

If you have an iPad with Swift Playgrounds:

1. Transfer the Swift files to Swift Playgrounds
2. Create a new App project
3. Copy the Views and Models
4. Run individual views to see the UI

---

## Demo Flow (What to Show)

### 🏠 1. Onboarding (First Launch)

| Step | Action | What Happens |
|------|--------|--------------|
| 1 | App launches | Welcome screen appears in Hindi |
| 2 | Swipe right | Feature highlights (Camera, Voice, Offline) |
| 3 | Final screen | Name input and language selection |
| 4 | Tap "शुरू करें" | Enters main app with voice welcome |

**Demo Script:**
> "When a farmer opens the app for the first time, they see a simple onboarding in Hindi. They can enter their name and choose their preferred language."

### 📸 2. Home Screen & Camera

| Step | Action | What Happens |
|------|--------|--------------|
| 1 | View home screen | Dashboard with quick action buttons |
| 2 | Tap "फोटो लें" | Camera opens with guide overlay |
| 3 | Show guide frame | Instructions in Hindi for positioning |
| 4 | Tap capture button | Photo is taken |
| 5 | Tap "विश्लेषण करें" | AI analysis begins |

**Demo Script:**
> "The home screen has large, easy-to-tap buttons. The farmer taps 'Take Photo' and sees guides for how to position their crop. The app uses AI to analyze the image."

### 🔍 3. Symptom Checker

| Step | Action | What Happens |
|------|--------|--------------|
| 1 | Tap "लक्षण" tab | Symptom checker opens |
| 2 | Select crop (e.g., धान/Rice) | Crop is highlighted |
| 3 | Tap "आगे" | Move to plant part selection |
| 4 | Select "पत्ती" (Leaf) | Plant part selected |
| 5 | Tap "आगे" | Move to symptom selection |
| 6 | Select symptoms | Multiple symptoms can be chosen |
| 7 | Tap "परिणाम देखें" | View diagnosis results |

**Demo Script:**
> "If a farmer doesn't have a camera or wants to describe their problem manually, they use the symptom checker. They select their crop, which part is affected, and what symptoms they see."

### 📊 4. Diagnosis Results

| Element | Description |
|---------|-------------|
| Health Score | Circular indicator showing 0-100% |
| Identified Issues | List of diseases/problems with confidence |
| Severity Badge | Color-coded severity level |
| Treatment Options | Organic and chemical solutions |
| Voice Button | Reads entire diagnosis aloud |

**Demo Script:**
> "The results show a health score and identified problems. Each issue has a confidence percentage and severity level. The farmer can tap the speaker icon to hear everything in Hindi."

### 💊 5. Treatment Details

| Step | Action | What Happens |
|------|--------|--------------|
| 1 | Tap on a condition | Expands to show details |
| 2 | View treatment tabs | Organic, Chemical, Prevention |
| 3 | Tap on treatment | Shows application method, dosage |
| 4 | Tap speaker icon | Reads treatment steps aloud |
| 5 | Tap "याद दिलाना" | Sets reminder for treatment |

**Demo Script:**
> "For each problem, we show both organic and chemical treatment options. The farmer can hear the instructions spoken in Hindi and set a reminder to apply the treatment."

### 📅 6. Reminders

| Feature | Description |
|---------|-------------|
| Calendar integration | Schedule follow-up checks |
| Repeat options | Daily, Weekly, Monthly |
| Audio notifications | Hindi voice reminders |
| Treatment tracking | Mark as complete |

**Demo Script:**
> "Farmers can set reminders for spraying, watering, or follow-up checks. The app sends notifications with audio in Hindi."

### 📈 7. History & Dashboard

| Step | Action | What Happens |
|------|--------|--------------|
| 1 | Tap "इतिहास" tab | Shows past diagnoses |
| 2 | View statistics | Total scans, healthy %, affected % |
| 3 | Filter by date/status | Filter chips for quick filtering |
| 4 | Tap on past diagnosis | View full details again |
| 5 | Tap export button | Share or save report |

**Demo Script:**
> "The history tab shows all past diagnoses. Farmers can track how their crops have improved over time and share reports with agricultural officers."

### 👤 8. Profile & Settings

| Setting | Function |
|---------|----------|
| आवाज सहायता | Toggle voice ON/OFF |
| भाषा | Change language |
| याद दिलाना | Manage reminders |
| ऑफलाइन डेटा | View cached data size |
| विशेषज्ञ सलाह | Request expert help |

**Demo Script:**
> "In settings, farmers can enable or disable voice, change language, and manage their reminders. The app also shows how much data is saved for offline use."

---

## Voice Assistance Demo

To specifically demonstrate the voice feature:

1. **Enable Voice:**
   - Go to Profile → आवाज सहायता → Toggle ON

2. **Navigate the App:**
   - Each screen will be read aloud automatically
   - Buttons announce their function when tapped

3. **Diagnosis Readout:**
   - After any diagnosis, the full result is spoken
   - Treatment steps are read step-by-step

4. **Supported Languages:**
   ```
   Hindi (hi-IN) - Primary
   English (en-IN)
   Telugu (te-IN)
   Tamil (ta-IN)
   Kannada (kn-IN)
   Bengali (bn-IN)
   Marathi (mr-IN)
   Gujarati (gu-IN)
   Punjabi (pa-IN)
   ```

---

## Test Data for Demo

The app includes bundled offline data for these crops and diseases:

### Crops (फसलें)

| Category | Crops |
|----------|-------|
| Cereals (अनाज) | Rice (धान), Wheat (गेहूं), Maize (मक्का) |
| Pulses (दालें) | Chickpea (चना), Pigeon Pea (अरहर) |
| Vegetables (सब्जियां) | Tomato (टमाटर), Potato (आलू), Onion (प्याज), Brinjal (बैंगन) |
| Fruits (फल) | Mango (आम), Banana (केला) |
| Oilseeds (तिलहन) | Groundnut (मूंगफली), Mustard (सरसों) |
| Cash Crops | Cotton (कपास), Sugarcane (गन्ना) |

### Diseases for Testing

| Disease | Type | Crop |
|---------|------|------|
| Rice Blast (धान का ब्लास्ट) | Fungal | Rice |
| Wheat Rust (गेहूं का रतुआ) | Fungal | Wheat |
| Early Blight (अगेती अंगमारी) | Fungal | Tomato |
| Nitrogen Deficiency | Nutrient | All |
| Aphid Infestation (माहू) | Pest | Multiple |

---

## Sample Demo Script (3-5 Minutes)

```
[Slide 1 - Introduction]
"This is FasalRakshak, which means 'Crop Protector' in Hindi.
It's an AI-powered app designed specifically for Indian farmers."

[Show Home Screen]
"Notice the interface is in Hindi with large, easy-to-tap icons.
This is important because many farmers have limited literacy."

[Enable Voice]
"A key feature is voice assistance. When I enable it,
the app speaks everything in Hindi."
[App speaks: "फसल रक्षक में आपका स्वागत है"]

[Open Camera]
"Farmers simply take a photo of their crop.
The app shows guides for proper positioning."

[Show Symptom Checker]
"Alternatively, they can describe symptoms manually
by selecting from visual icons."

[Show Results]
"The AI identifies the problem with a confidence score.
Here we see [Disease Name] with 85% confidence."

[Show Treatment]
"For each problem, we show both organic and chemical treatments.
The farmer can hear the instructions read aloud."
[Tap speaker - app reads treatment]

[Show Reminders]
"They can set reminders for when to apply treatments.
The app sends Hindi voice notifications."

[Show Offline]
"Importantly, this works offline - critical for rural India
where internet connectivity is unreliable."

[Conclusion]
"FasalRakshak empowers farmers to diagnose and treat
crop diseases independently, improving yields and livelihoods."
```

---

## Simulator Limitations

When using the iOS Simulator, note these limitations:

| Feature | Simulator | Physical Device |
|---------|-----------|-----------------|
| Camera | ❌ Use photo picker | ✅ Full camera |
| Voice/TTS | ✅ Works (may sound robotic) | ✅ Natural voice |
| Push Notifications | ⚠️ Limited | ✅ Full support |
| Location | ✅ Can simulate | ✅ Real GPS |
| Offline Mode | ✅ Works | ✅ Works |

### Using Photos in Simulator

Since the camera doesn't work in the simulator:

1. In the Camera view, tap **"गैलरी"** (Gallery)
2. Select a test image from the photo library
3. The analysis will proceed normally

To add test images to the simulator:
```bash
# Drag and drop images onto the simulator window
# Or use: xcrun simctl addmedia booted /path/to/image.jpg
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build errors | Ensure iOS 16.0+ deployment target |
| Missing frameworks | Add AVFoundation, Vision, UserNotifications |
| Voice not working | Check device audio, try physical device |
| Crashes on launch | Check Info.plist privacy descriptions |

### Required Info.plist Keys

```xml
<key>NSCameraUsageDescription</key>
<string>फसल की फोटो लेने के लिए कैमरा एक्सेस की आवश्यकता है।</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>गैलरी से फोटो चुनने के लिए फोटो लाइब्रेरी एक्सेस की आवश्यकता है।</string>
```

---

## Additional Resources

- **README.md** - Full project documentation
- **FasalRakshak/** - Source code directory
- **FasalRakshakTests/** - Unit tests

---

## Contact

For demo assistance or questions, refer to the repository issues page.

---

*Last Updated: December 2024*
