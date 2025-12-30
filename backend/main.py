"""
FasalRakshak Backend API
AI-powered crop disease detection using Claude/OpenAI
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional, List
import base64
import os
from datetime import datetime
import anthropic
import openai
from PIL import Image
import io

app = FastAPI(
    title="FasalRakshak API",
    description="AI-powered crop disease detection for Indian farmers",
    version="1.0.0"
)

# CORS middleware to allow iOS app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your iOS app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration - set via environment variables
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
USE_CLAUDE = os.getenv("USE_CLAUDE", "true").lower() == "true"

# Initialize AI clients
if USE_CLAUDE and ANTHROPIC_API_KEY:
    claude_client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
elif OPENAI_API_KEY:
    openai.api_key = OPENAI_API_KEY

# Models
class DiagnosisRequest(BaseModel):
    crop_type: Optional[str] = None
    location: Optional[str] = None
    symptoms: Optional[List[str]] = []
    language: str = "en"

class DiagnosisResponse(BaseModel):
    disease_name: str
    disease_name_local: str
    confidence: float
    severity: str
    affected_parts: List[str]
    description: str
    causes: List[str]
    organic_treatments: List[dict]
    chemical_treatments: List[dict]
    preventive_measures: List[str]
    diagnosis_id: str
    timestamp: str

class HealthStatus(BaseModel):
    status: str
    message: str
    version: str
    ai_provider: str

# Routes
@app.get("/", response_model=HealthStatus)
async def root():
    """Health check endpoint"""
    return HealthStatus(
        status="healthy",
        message="FasalRakshak API is running",
        version="1.0.0",
        ai_provider="Claude" if USE_CLAUDE else "OpenAI"
    )

@app.post("/api/diagnose", response_model=DiagnosisResponse)
async def diagnose_crop(
    image: UploadFile = File(...),
    crop_type: Optional[str] = None,
    language: str = "en"
):
    """
    Diagnose crop disease from image using AI

    Parameters:
    - image: Uploaded image of the crop
    - crop_type: Optional crop type (rice, wheat, tomato, etc.)
    - language: Language for response (en, hi, te, ta, etc.)

    Returns:
    - Detailed diagnosis with treatment recommendations
    """
    try:
        # Read and validate image
        image_data = await image.read()

        # Validate image
        try:
            img = Image.open(io.BytesIO(image_data))
            # Resize if too large
            if img.width > 2048 or img.height > 2048:
                img.thumbnail((2048, 2048))
                buffer = io.BytesIO()
                img.save(buffer, format='JPEG')
                image_data = buffer.getvalue()
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid image: {str(e)}")

        # Encode image to base64
        image_base64 = base64.b64encode(image_data).decode('utf-8')

        # Get diagnosis from AI
        if USE_CLAUDE and ANTHROPIC_API_KEY:
            diagnosis = await diagnose_with_claude(image_base64, crop_type, language)
        elif OPENAI_API_KEY:
            diagnosis = await diagnose_with_openai(image_base64, crop_type, language)
        else:
            raise HTTPException(
                status_code=500,
                detail="No AI API key configured. Please set ANTHROPIC_API_KEY or OPENAI_API_KEY"
            )

        return diagnosis

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Diagnosis failed: {str(e)}")


async def diagnose_with_claude(image_base64: str, crop_type: Optional[str], language: str) -> DiagnosisResponse:
    """Diagnose crop disease using Claude (Anthropic)"""

    # Build prompt based on language
    if language == "hi":
        system_prompt = """आप एक विशेषज्ञ कृषि वैज्ञानिक हैं जो फसलों की बीमारियों की पहचान में विशेषज्ञ हैं।
        फसल की तस्वीर का विश्लेषण करें और विस्तृत निदान प्रदान करें।"""

        user_prompt = f"""इस फसल की तस्वीर का विश्लेषण करें और निम्नलिखित विवरण JSON प्रारूप में प्रदान करें:

फसल प्रकार: {crop_type if crop_type else 'अज्ञात'}

कृपया निम्नलिखित जानकारी प्रदान करें:
1. बीमारी का नाम (अंग्रेजी और हिंदी दोनों में)
2. निदान में आत्मविश्वास (0-100%)
3. गंभीरता (low, moderate, high)
4. प्रभावित भाग (पत्तियां, तना, फल, आदि)
5. विस्तृत विवरण
6. कारण
7. जैविक उपचार (नाम, विवरण, विधि)
8. रासायनिक उपचार (नाम, विवरण, विधि, सावधानियां)
9. रोकथाम के उपाय"""
    else:
        system_prompt = """You are an expert agricultural scientist specializing in crop disease identification.
        Analyze the crop image and provide detailed diagnosis."""

        user_prompt = f"""Analyze this crop image and provide detailed diagnosis in JSON format.

Crop type: {crop_type if crop_type else 'Unknown'}

Please provide:
1. Disease name (in English and local language)
2. Confidence level (0-100%)
3. Severity (low, moderate, high)
4. Affected parts (leaves, stem, fruit, etc.)
5. Detailed description
6. Causes
7. Organic treatments (name, description, method)
8. Chemical treatments (name, description, method, precautions)
9. Preventive measures"""

    try:
        message = claude_client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=2048,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": image_base64,
                            },
                        },
                        {
                            "type": "text",
                            "text": user_prompt
                        }
                    ],
                }
            ],
            system=system_prompt
        )

        # Parse response
        response_text = message.content[0].text

        # Extract diagnosis from response (Claude will provide structured analysis)
        diagnosis = parse_ai_response(response_text, language)
        return diagnosis

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Claude API error: {str(e)}")


async def diagnose_with_openai(image_base64: str, crop_type: Optional[str], language: str) -> DiagnosisResponse:
    """Diagnose crop disease using OpenAI GPT-4 Vision"""

    if language == "hi":
        prompt = f"""इस फसल की तस्वीर का विश्लेषण करें।
फसल प्रकार: {crop_type if crop_type else 'अज्ञात'}

विस्तृत निदान प्रदान करें:
- बीमारी का नाम
- गंभीरता
- कारण
- उपचार"""
    else:
        prompt = f"""Analyze this crop image.
Crop type: {crop_type if crop_type else 'Unknown'}

Provide detailed diagnosis:
- Disease name
- Severity
- Causes
- Treatments (organic and chemical)
- Prevention measures"""

    try:
        response = openai.ChatCompletion.create(
            model="gpt-4-vision-preview",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": prompt
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{image_base64}"
                            }
                        }
                    ],
                }
            ],
            max_tokens=2000,
        )

        response_text = response.choices[0].message.content
        diagnosis = parse_ai_response(response_text, language)
        return diagnosis

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {str(e)}")


def parse_ai_response(response_text: str, language: str) -> DiagnosisResponse:
    """Parse AI response and structure it"""

    # This is a simplified parser - in production, you'd want more robust parsing
    # or ask the AI to return JSON directly

    return DiagnosisResponse(
        disease_name="Detected Disease",  # Extract from response
        disease_name_local="पहचानी गई बीमारी" if language == "hi" else "Detected Disease",
        confidence=85.0,  # Extract from response
        severity="moderate",  # Extract from response
        affected_parts=["leaves"],  # Extract from response
        description=response_text[:500],  # Use AI response
        causes=["Fungal infection", "High humidity"],  # Extract from response
        organic_treatments=[
            {
                "name": "Neem Oil Spray",
                "description": "Natural fungicide",
                "method": "Spray on affected areas",
                "frequency": "Every 7 days"
            }
        ],
        chemical_treatments=[
            {
                "name": "Fungicide",
                "description": "Chemical treatment",
                "method": "Follow label instructions",
                "precautions": ["Wear protective gear"]
            }
        ],
        preventive_measures=["Proper drainage", "Crop rotation"],  # Extract from response
        diagnosis_id=f"DIAG-{datetime.now().strftime('%Y%m%d%H%M%S')}",
        timestamp=datetime.now().isoformat()
    )


@app.get("/api/crops")
async def get_crops():
    """Get list of supported crops"""
    return {
        "crops": [
            {"id": "rice", "name": "Rice", "name_hi": "धान"},
            {"id": "wheat", "name": "Wheat", "name_hi": "गेहूं"},
            {"id": "tomato", "name": "Tomato", "name_hi": "टमाटर"},
            {"id": "potato", "name": "Potato", "name_hi": "आलू"},
            {"id": "cotton", "name": "Cotton", "name_hi": "कपास"},
        ]
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
