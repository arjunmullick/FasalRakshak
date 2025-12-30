# FasalRakshak Backend API

AI-powered crop disease detection backend using Claude (Anthropic) or OpenAI GPT-4 Vision.

## Features

- 🤖 AI-powered crop disease detection
- 📸 Image analysis using Claude 3.5 Sonnet or GPT-4 Vision
- 🌍 Multi-language support (English, Hindi, and more)
- 🔄 RESTful API for iOS app integration
- 🚀 Fast and scalable with FastAPI

## Setup

### 1. Install Dependencies

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure API Keys

Create a `.env` file from the example:

```bash
cp .env.example .env
```

Edit `.env` and add your API keys:

```env
# For Claude (Anthropic)
ANTHROPIC_API_KEY=sk-ant-xxxxx
USE_CLAUDE=true

# OR for OpenAI
OPENAI_API_KEY=sk-xxxxx
USE_CLAUDE=false
```

**Get API Keys:**
- **Claude (Recommended)**: https://console.anthropic.com/
- **OpenAI**: https://platform.openai.com/api-keys

### 3. Run the Server

```bash
# Development
python main.py

# Or with uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: `http://localhost:8000`

## API Endpoints

### Health Check
```http
GET /
```

Response:
```json
{
  "status": "healthy",
  "message": "FasalRakshak API is running",
  "version": "1.0.0",
  "ai_provider": "Claude"
}
```

### Diagnose Crop Disease
```http
POST /api/diagnose
Content-Type: multipart/form-data

Parameters:
- image: (file) Image of the crop
- crop_type: (string, optional) rice|wheat|tomato|potato|cotton
- language: (string, optional) en|hi|te|ta (default: en)
```

Response:
```json
{
  "disease_name": "Late Blight",
  "disease_name_local": "लेट ब्लाइट",
  "confidence": 92.5,
  "severity": "high",
  "affected_parts": ["leaves", "stem"],
  "description": "Late blight is a serious disease...",
  "causes": [
    "Phytophthora infestans fungus",
    "Cool, moist weather"
  ],
  "organic_treatments": [
    {
      "name": "Copper-based spray",
      "description": "Organic copper fungicide",
      "method": "Spray on affected areas",
      "frequency": "Every 7-10 days"
    }
  ],
  "chemical_treatments": [
    {
      "name": "Mancozeb",
      "description": "Contact fungicide",
      "method": "Spray application",
      "precautions": ["Wear protective gear"]
    }
  ],
  "preventive_measures": [
    "Plant resistant varieties",
    "Ensure good air circulation",
    "Remove infected plants"
  ],
  "diagnosis_id": "DIAG-20241230120000",
  "timestamp": "2024-12-30T12:00:00"
}
```

### Get Supported Crops
```http
GET /api/crops
```

Response:
```json
{
  "crops": [
    {"id": "rice", "name": "Rice", "name_hi": "धान"},
    {"id": "wheat", "name": "Wheat", "name_hi": "गेहूं"},
    ...
  ]
}
```

## Testing the API

### Using cURL

```bash
# Health check
curl http://localhost:8000/

# Diagnose crop (with image file)
curl -X POST "http://localhost:8000/api/diagnose?crop_type=tomato&language=en" \
  -F "image=@/path/to/crop_image.jpg"

# Get crops list
curl http://localhost:8000/api/crops
```

### Using Postman or Insomnia

1. Create a new POST request to `http://localhost:8000/api/diagnose`
2. Set Body type to `form-data`
3. Add field `image` with type `File` and select an image
4. Add fields `crop_type` and `language` as text
5. Send request

## Deployment

### Option 1: Railway.app (Recommended - Easy & Free)

1. Push code to GitHub
2. Go to https://railway.app
3. Click "New Project" → "Deploy from GitHub"
4. Select your repository
5. Add environment variables (ANTHROPIC_API_KEY or OPENAI_API_KEY)
6. Deploy!

### Option 2: Heroku

```bash
# Install Heroku CLI
# Create Procfile
echo "web: uvicorn main:app --host 0.0.0.0 --port \$PORT" > Procfile

# Deploy
heroku create fasalrakshak-api
heroku config:set ANTHROPIC_API_KEY=your_key
git push heroku main
```

### Option 3: AWS/GCP/Azure

Use Docker:

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build and run:
```bash
docker build -t fasalrakshak-api .
docker run -p 8000:8000 -e ANTHROPIC_API_KEY=xxx fasalrakshak-api
```

## iOS App Integration

Update `APIService.swift` in the iOS app:

```swift
private let baseURL = "http://localhost:8000"  // Development
// private let baseURL = "https://your-api.railway.app"  // Production
```

## AI Provider Comparison

### Claude 3.5 Sonnet (Recommended)
- ✅ Better at detailed analysis
- ✅ More accurate disease identification
- ✅ Better multi-language support
- ✅ Longer context window
- 💰 Cost: ~$3 per 1M input tokens

### OpenAI GPT-4 Vision
- ✅ Fast response
- ✅ Good image understanding
- ⚠️ Shorter context
- 💰 Cost: ~$10 per 1M input tokens

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `ANTHROPIC_API_KEY` | Claude API key | Yes (if using Claude) |
| `OPENAI_API_KEY` | OpenAI API key | Yes (if using OpenAI) |
| `USE_CLAUDE` | Use Claude if true, OpenAI if false | No (default: true) |
| `PORT` | Server port | No (default: 8000) |
| `HOST` | Server host | No (default: 0.0.0.0) |

## Troubleshooting

### API Key Issues
- Ensure API keys are correctly set in `.env`
- Check key permissions and quotas
- Verify the key format (starts with `sk-ant-` for Claude, `sk-` for OpenAI)

### Image Upload Errors
- Check image file size (< 5MB recommended)
- Ensure image format is supported (JPEG, PNG)
- Verify Content-Type header is set to `multipart/form-data`

### Connection Refused (iOS App)
- If testing on device, use your computer's local IP instead of localhost
- Example: `http://192.168.1.100:8000`
- Ensure firewall allows connections on port 8000

## API Documentation

Interactive API docs available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## License

MIT License - see LICENSE file for details
