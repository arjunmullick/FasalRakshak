# FasalRakshak (फसल रक्षक) - Setup Guide

## Project Overview
FasalRakshak is an iOS crop health diagnosis app for Indian farmers with multilingual support (Hindi and 8 regional languages).

---

## Prerequisites

### 1. System Requirements
- **macOS**: 15.0 or later (you have 15.6 ✅)
- **Xcode**: 15.0 or later
- **iOS Deployment Target**: iOS 17.0+
- **Apple Developer Account**: Optional (for device testing; not needed for simulator)

### 2. Install/Configure Xcode

Your system currently has only Command Line Tools installed. You need full Xcode:

```bash
# Check current Xcode setup
xcode-select -p

# If it shows "/Library/Developer/CommandLineTools", you need to:
# 1. Install Xcode from Mac App Store
# 2. After installation, set the correct path:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Verify Xcode is installed
xcodebuild -version
```

---

## Project Structure

```
FasalRakshak/
├── FasalRakshak.xcodeproj          # Xcode project file
├── Info.plist                       # App configuration (IMPORTANT!)
├── FasalRakshak/
│   ├── FasalRakshakApp.swift       # App entry point
│   ├── Models/                      # Data models
│   │   └── CropModels.swift
│   ├── Views/                       # UI Views
│   │   ├── ContentView.swift       # Main view
│   │   ├── HomeView.swift
│   │   ├── CameraCaptureView.swift
│   │   ├── CropViews.swift
│   │   ├── DiagnosisDetailView.swift
│   │   ├── DiagnosisHistoryView.swift
│   │   ├── DiseaseDetailView.swift
│   │   ├── FarmerProfileView.swift
│   │   ├── OnboardingView.swift
│   │   └── SymptomCheckerView.swift
│   ├── Services/                    # Business logic
│   │   ├── APIService.swift
│   │   ├── AnalyticsService.swift
│   │   ├── CropDiagnosisService.swift
│   │   ├── NetworkMonitor.swift
│   │   ├── NotificationManager.swift
│   │   ├── OfflineDataManager.swift
│   │   └── VoiceAssistantService.swift
│   ├── Resources/                   # Assets and resources
│   └── Assets.xcassets/            # App icons and images
├── FasalRakshakTests/              # Unit tests
└── FasalRakshakUITests/            # UI tests
```

---

## Step-by-Step Setup

### Step 1: Configure Info.plist

The `Info.plist` file is **already present** at the project root with all required configurations:

**Current Location**: `/Users/arjunmullick/workspace/FarmerApp/FasalRakshak/Info.plist`

**Important Configurations Already Set**:
- ✅ Camera usage description (Hindi)
- ✅ Photo library access description
- ✅ Location access description
- ✅ Speech recognition description
- ✅ Microphone access description
- ✅ Multilingual support (9 languages)
- ✅ Background modes (audio, fetch, processing)
- ✅ App display name: "फसल रक्षक"

**Verify Info.plist is linked in Xcode**:
1. Open Xcode project
2. Select the **FasalRakshak** target in the project navigator
3. Go to **Build Settings** tab
4. Search for "Info.plist"
5. Ensure **Info.plist File** path is set to: `Info.plist`

### Step 2: Open Project in Xcode

```bash
# Navigate to project directory
cd /Users/arjunmullick/workspace/FarmerApp/FasalRakshak

# Open in Xcode (method 1 - command line)
open FasalRakshak.xcodeproj

# OR (method 2 - Finder)
# Double-click on FasalRakshak.xcodeproj in Finder
```

### Step 3: Configure Project Settings

Once Xcode opens:

#### A. Select Target Device
1. In the top toolbar, next to the Run/Stop buttons
2. Select a simulator: **iPhone 15 Pro** or **iPhone 15**
3. Or select your physical device if connected

#### B. Configure Signing & Capabilities
1. Select **FasalRakshak** project in Navigator
2. Select **FasalRakshak** target
3. Go to **Signing & Capabilities** tab
4. Set **Team**:
   - If you have Apple Developer account: Select your team
   - For simulator testing: Select "None" or use automatic signing
5. **Bundle Identifier**: Should be unique (e.g., `com.yourname.fasalrakshak`)

#### C. Verify Build Settings
1. Go to **Build Settings** tab
2. Search for these settings and verify:
   - **iOS Deployment Target**: iOS 17.0 (or your minimum version)
   - **Swift Language Version**: Swift 5.0
   - **Info.plist File**: `Info.plist`

### Step 4: Resolve Any Build Issues

The project has been updated with all necessary imports. Verify these files have `import Combine`:

- ✅ OfflineDataManager.swift
- ✅ NotificationManager.swift
- ✅ AnalyticsService.swift
- ✅ APIService.swift
- ✅ CameraCaptureView.swift
- ✅ FasalRakshakApp.swift

### Step 5: Build the Project

```bash
# From command line (after fixing xcode-select):
cd /Users/arjunmullick/workspace/FarmerApp/FasalRakshak
xcodebuild -project FasalRakshak.xcodeproj -scheme FasalRakshak -configuration Debug clean build

# OR in Xcode:
# Press Cmd + B (Build)
```

### Step 6: Run the Project

**In Xcode**:
1. Select your target device/simulator (top toolbar)
2. Press **Cmd + R** (Run) or click the ▶️ Play button
3. Wait for build to complete
4. App will launch in simulator/device

**Expected Behavior**:
- App launches with onboarding screen (first launch)
- Hindi language interface
- Requests for permissions:
  - Camera access
  - Photo library access
  - Location access
  - Microphone access
  - Notifications

---

## Troubleshooting

### Issue 1: "xcodebuild requires Xcode" Error

```bash
# Fix developer tools path
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcode-select --install  # If needed
```

### Issue 2: Info.plist Not Found

If Xcode shows "Info.plist not found":

1. In Xcode, select **FasalRakshak** target
2. **Build Settings** → Search "Info.plist File"
3. Set the path to: `Info.plist` (relative to project root)
4. Or set absolute path: `$(SRCROOT)/Info.plist`

### Issue 3: Missing ContentView

The ContentView.swift has been moved to `FasalRakshak/Views/ContentView.swift`.
Ensure the file reference is correct in Xcode project navigator.

### Issue 4: Simulator Not Available

```bash
# List available simulators
xcrun simctl list devices

# Boot a specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Or create new simulator in Xcode:
# Xcode → Window → Devices and Simulators → Simulators → +
```

### Issue 5: Code Signing Errors

For **Simulator Testing** (no device):
- Team: None
- Signing: Automatically manage signing (unchecked)
- Provisioning Profile: None needed

For **Device Testing**:
- Need Apple Developer account
- Set Team to your developer team
- Enable "Automatically manage signing"

### Issue 6: Build Errors - Missing Modules

If you see "No such module 'Combine'" or similar:
- All files should already have `import Combine` added
- Clean build folder: **Cmd + Shift + K**
- Rebuild: **Cmd + B**

### Issue 7: Runtime Permission Crashes

If app crashes when accessing camera/microphone:
- Check Info.plist has all usage descriptions (already configured ✅)
- On simulator, permissions are auto-granted
- On device, user must grant permissions

---

## Testing Features

### 1. Camera Functionality
- Go to Camera tab
- Take photo or select from gallery
- Requires camera/photo permissions

### 2. Voice Assistant
- Hindi text-to-speech throughout app
- Speaks instructions and results
- Requires microphone permission

### 3. Offline Mode
- App works without internet
- Local database of crops and diseases
- Sync when internet available

### 4. Multilingual Support
- Default: Hindi (हिंदी)
- Supported: English, Telugu, Tamil, Kannada, Bengali, Marathi, Gujarati, Punjabi
- Change in settings

---

## Quick Start Commands

```bash
# 1. Navigate to project
cd /Users/arjunmullick/workspace/FarmerApp/FasalRakshak

# 2. Open in Xcode
open FasalRakshak.xcodeproj

# 3. In Xcode:
#    - Select iPhone 15 Pro simulator
#    - Press Cmd + R to run

# 4. Build from command line (after Xcode setup):
xcodebuild -project FasalRakshak.xcodeproj \
  -scheme FasalRakshak \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  clean build
```

---

## Project Status

### ✅ Completed
- All Swift files created (19 files)
- All necessary imports added (Combine framework)
- Info.plist configured with all permissions
- Project structure organized
- Multilingual support setup

### ⚠️ Required Actions
1. **Install full Xcode** (if not already)
2. **Configure Xcode developer path**
3. **Set bundle identifier** in project settings
4. **Select development team** (if deploying to device)

### 📝 Next Steps After First Run
- Test all features on simulator
- Configure API endpoints (if needed)
- Test on physical device
- Add app icons and assets
- Configure push notifications (if needed)

---

## Support

### Common Xcode Shortcuts
- **Cmd + B**: Build
- **Cmd + R**: Run
- **Cmd + .**: Stop
- **Cmd + Shift + K**: Clean Build Folder
- **Cmd + Shift + O**: Open Quickly (find files)

### Resources
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Xcode User Guide](https://developer.apple.com/documentation/xcode)

---

## Notes

- **Bundle ID**: Remember to change from default to your own
- **API Keys**: If using external APIs, add keys to APIService.swift
- **Privacy**: All permission descriptions are in Hindi for target audience
- **Deployment Target**: iOS 17.0+ (uses latest SwiftUI features)
- **No External Dependencies**: Project uses only native iOS frameworks

---

**Ready to Run!** 🚀

Follow the steps above, and your FasalRakshak app should build and run successfully.
