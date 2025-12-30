# FasalRakshak Demo Setup Guide

Complete guide to set up and demo the FasalRakshak app with AI-powered crop disease detection.

## ✅ Recent Changes

1. **Default Language**: Changed to English
2. **Demo Images**: Added placeholder disease images for gallery
3. **API Integration**: Connected to Claude/OpenAI backend
4. **Backend Service**: Created FastAPI server with AI integration

---

## Part 1: Backend Setup

### 1. Install Backend Dependencies

```bash
cd /Users/arjunmullick/workspace/FarmerApp/FasalRakshak/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Get API Keys

**Option A: Claude (Recommended)**
1. Go to https://console.anthropic.com/
2. Create account / Sign in
3. Go to "API Keys"
4. Create new key
5. Copy the key (starts with `sk-ant-`)

**Option B: OpenAI**
1. Go to https://platform.openai.com/api-keys
2. Create account / Sign in
3. Create new secret key
4. Copy the key (starts with `sk-`)

### 3. Configure Backend

```bash
# Create .env file
cp .env.example .env

# Edit .env file
nano .env

# Add your API key:
ANTHROPIC_API_KEY=sk-ant-your-key-here
# OR
# OPENAI_API_KEY=sk-your-key-here

# Save and exit (Ctrl+X, then Y, then Enter)
```

### 4. Start Backend Server

```bash
# Make sure you're in the backend directory
cd /Users/arjunmullick/workspace/FarmerApp/FasalRakshak/backend

# Activate virtual environment
source venv/bin/activate

# Run server
python main.py
```

You should see:
```
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### 5. Test Backend

Open a new terminal and test:

```bash
# Health check
curl http://localhost:8000/

# Should return:
# {"status":"healthy","message":"FasalRakshak API is running","version":"1.0.0","ai_provider":"Claude"}

# Test with sample image (if you have one)
curl -X POST "http://localhost:8000/api/diagnose?crop_type=tomato&language=en" \
  -F "image=@/path/to/plant_image.jpg"
```

---

## Part 2: iOS App Setup

### 1. Open Xcode Project

```bash
cd /Users/arjunmullick/workspace/FarmerApp/FasalRakshak
open FasalRakshak.xcodeproj
```

### 2. Configure API Endpoint

The app is already configured to use `http://localhost:8000` for development.

**For Testing on a Physical Device:**

If you want to test on your iPhone/iPad:

1. Find your Mac's local IP:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

2. Update APIService.swift:
```swift
// Change line 26 from:
self.baseURL = "http://localhost:8000"

// To:
self.baseURL = "http://YOUR_MAC_IP:8000"  // e.g., http://192.168.1.100:8000
```

### 3. Build and Run

1. Select target device (iPhone 15 Pro simulator)
2. Press **Cmd + B** to build
3. Press **Cmd + R** to run

---

## Part 3: Demo Flow

### Demo Scenario 1: Onboarding (First Launch)

1. **Launch app** (starts in English now!)
2. **Onboarding screens**:
   - Page 1: Welcome to Crop Guardian
   - Page 2: Instant Diagnosis
   - Page 3: Offline Mode
   - Page 4: Enter your name
3. **Enter name**: "Demo Farmer"
4. **Language selector**: Try switching between Hindi and English
5. **Tap "Get Started"**
6. **Hear welcome**: "Hello Demo Farmer! Welcome to Crop Guardian..."

### Demo Scenario 2: Using Demo Images

1. **Go to Camera tab**
2. **Tap "Select from Library"**
3. The app includes 5 demo disease images:
   - Tomato Late Blight
   - Wheat Rust
   - Rice Blast
   - Potato Early Blight
   - Cotton Leaf Curl

**Note**: To use demo images in the app, you need to either:
- Add actual disease images to the Assets catalog, OR
- Use the placeholder generator (automatically creates visual representations)

### Demo Scenario 3: AI Diagnosis

1. **Take/Select an image** of a crop
2. **(Optional)** Select crop type
3. **Tap "Analyze"**
4. **Backend processes**:
   - Image sent to Claude/OpenAI
   - AI analyzes the image
   - Detects disease, severity, affected parts
   - Provides treatments
5. **Results displayed**:
   - Disease name
   - Confidence score
   - Severity level
   - Organic treatments
   - Chemical treatments
   - Prevention tips
6. **Voice feedback**: App speaks the diagnosis

### Demo Scenario 4: Language Switching

1. **Go to Profile tab**
2. **Tap "Language"**
3. **Select "हिंदी"**
4. **Observe**:
   - Tab labels change to Hindi
   - Voice says: "भाषा हिंदी में बदल गई है"
5. **Switch back to English**
6. **Voice says**: "Language changed to English"

---

## Part 4: Troubleshooting

### Backend Issues

**Problem**: `ModuleNotFoundError: No module named 'anthropic'`
```bash
# Solution: Reinstall dependencies
pip install -r requirements.txt
```

**Problem**: `ANTHROPIC_API_KEY not set`
```bash
# Solution: Check .env file
cat .env
# Make sure it contains:
# ANTHROPIC_API_KEY=sk-ant-xxxxx
```

**Problem**: Backend not accessible from iOS app
```bash
# Solution 1: Check backend is running
curl http://localhost:8000/

# Solution 2: Check firewall allows connections on port 8000
# On Mac: System Preferences → Security & Privacy → Firewall
```

### iOS App Issues

**Problem**: "Invalid API URL" error
- Solution: Check APIService.swift baseURL is correct
- For simulator: use `localhost:8000`
- For device: use your Mac's IP (e.g., `192.168.1.100:8000`)

**Problem**: Image upload fails
- Solution: Ensure image is < 5MB
- Solution: Check image format (JPG/PNG)
- Solution: Verify backend is running

**Problem**: "Cannot find type 'BackendDiagnosisResponse'"
- Solution: Clean and rebuild (Cmd + Shift + K, then Cmd + B)

### Demo Image Issues

**Problem**: No demo images in gallery
- Solution: The app uses placeholder generation
- Or: Add actual images to Assets.xcassets

---

## Part 5: Advanced Features

### Adding Real Disease Images

1. Find crop disease images online (royalty-free)
2. Add to Xcode:
   - Open Assets.xcassets
   - Right-click → New Image Set
   - Name it (e.g., "demo_tomato_late_blight")
   - Drag image file into the 1x slot

3. Update DemoImages.swift:
```swift
// Images will now load from assets automatically
```

### Deploying Backend to Production

**Option 1: Railway.app (Free tier available)**

```bash
# Push to GitHub first
git add backend/
git commit -m "Add backend"
git push

# Then:
# 1. Go to railway.app
# 2. "New Project" → "Deploy from GitHub"
# 3. Select your repo
# 4. Set environment variables:
#    ANTHROPIC_API_KEY = your-key
# 5. Deploy!

# Update iOS app:
// APIService.swift line 26
self.baseURL = "https://your-app.railway.app"
```

**Option 2: Heroku**

```bash
cd backend
echo "web: uvicorn main:app --host 0.0.0.0 --port \$PORT" > Procfile
heroku create fasalrakshak-api
heroku config:set ANTHROPIC_API_KEY=your-key
git push heroku main
```

### Using with Real Crop Images

The AI backend works with real crop images! Just:
1. Take a photo of a diseased plant
2. Upload via the app
3. AI will analyze and provide real diagnosis

**Tips for best results:**
- Take photos in good lighting
- Focus on affected areas (leaves, stem, fruit)
- Include multiple angles if possible
- Mention crop type for better accuracy

---

## Part 6: Demo Script

### 5-Minute Demo

```
[1. Introduction - 30s]
"FasalRakshak is an AI-powered crop disease detection app for Indian farmers.
It works offline and supports 9 Indian languages."

[2. Onboarding - 1min]
- Launch app
- Show English onboarding
- Switch to Hindi on registration
- Show instant UI update
- Complete registration

[3. Language Features - 1min]
- Show language switcher
- Toggle between English and Hindi
- Demonstrate voice feedback in both languages

[4. AI Diagnosis - 2min]
- Select a demo disease image
- Send to backend
- Show AI analysis happening
- Display results:
  * Disease name
  * Confidence score
  * Treatments (organic + chemical)
  * Prevention measures
- Demonstrate voice reading results

[5. Offline Mode - 30s]
- Show offline data storage
- Explain works without internet for basic features

[Conclusion]
"The app combines AI vision, multilingual support, and offline capabilities
to help farmers identify and treat crop diseases quickly."
```

---

## Part 7: Cost Estimation

### API Costs

**Claude 3.5 Sonnet:**
- Input: $3 per 1M tokens
- Output: $15 per 1M tokens
- Average diagnosis: ~1000 tokens = $0.003-0.015 per diagnosis

**OpenAI GPT-4 Vision:**
- $10 per 1M tokens (input)
- Average diagnosis: ~$0.01-0.02 per diagnosis

**For Demo**: ~100 diagnoses = $1-2
**For Production**: 10,000 diagnoses/month = $30-200/month

---

## Summary Checklist

### Before Demo:

- [ ] Backend running on `http://localhost:8000`
- [ ] API keys configured in `.env`
- [ ] iOS app builds successfully
- [ ] Test diagnosis with sample image
- [ ] Voice enabled and working
- [ ] Language switching tested

### During Demo:

- [ ] Show English UI (new default!)
- [ ] Demonstrate language switching
- [ ] Show AI diagnosis with real results
- [ ] Highlight voice features
- [ ] Mention offline capability

### After Demo:

- [ ] Stop backend server (Ctrl+C)
- [ ] Deactivate virtual environment (`deactivate`)

---

## Quick Reference

```bash
# Start Backend
cd /Users/arjunmullick/workspace/FarmerApp/FasalRakshak/backend
source venv/bin/activate
python main.py

# Test Backend
curl http://localhost:8000/

# Open iOS Project
open /Users/arjunmullick/workspace/FarmerApp/FasalRakshak/FasalRakshak.xcodeproj

# Build & Run in Xcode
Cmd + R
```

**API Endpoint**: `http://localhost:8000/api/diagnose`

**Supported Languages**: en, hi, te, ta, kn, bn, mr, gu, pa

---

Good luck with your demo! 🚀🌾
