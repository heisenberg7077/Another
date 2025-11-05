# 🌿 Gemini AI Plant Disease Detection

## Overview
Advanced plant disease detection system powered by Google Gemini AI. Upload a plant image and get instant, detailed disease diagnosis with treatment recommendations.

## ⚡ Quick Start

### 1. Install
```bash
pip install google-generativeai Pillow
```

### 2. Configure
```bash
# Get API key from: https://makersuite.google.com/app/apikey
export GEMINI_API_KEY="your-api-key-here"
```

### 3. Run
```bash
python app.py
```

### 4. Test
Open: `http://localhost:5050/test_gemini_disease_detection.html`

## 🎯 Features

- 🔍 **Plant Identification** - Automatic species recognition
- 🦠 **Disease Detection** - Identifies specific diseases
- 📊 **Confidence Scores** - AI confidence levels
- 💊 **Treatment Plans** - Chemical & organic solutions
- 🛡️ **Prevention Tips** - Avoid future issues
- 📈 **Severity Analysis** - Mild/Moderate/Severe

## 📡 API Endpoint

```http
POST /api/chatbot/detect-disease-gemini
Content-Type: multipart/form-data

image: [File]
```

**Response:**
```json
{
  "success": true,
  "analysis": "Detailed analysis...",
  "structured_data": {
    "plant_name": "Tomato",
    "disease_name": "Early Blight",
    "confidence": "High"
  }
}
```

## 📚 Documentation

- 📖 [Complete Setup Guide](GEMINI_SETUP.md)
- ⚡ [Quick Start Guide](QUICKSTART_GEMINI.md)
- 📋 [Integration Summary](GEMINI_INTEGRATION_SUMMARY.md)
- 🧪 [Test Interface](test_gemini_disease_detection.html)

## 🔧 Integration Examples

### JavaScript
```javascript
const formData = new FormData();
formData.append('image', imageFile);

fetch('/api/chatbot/detect-disease-gemini', {
    method: 'POST',
    body: formData
})
.then(res => res.json())
.then(data => console.log(data.analysis));
```

### Python
```python
import requests

url = "http://localhost:5050/api/chatbot/detect-disease-gemini"
files = {"image": open("plant.jpg", "rb")}
response = requests.post(url, files=files)
print(response.json())
```

### cURL
```bash
curl -X POST http://localhost:5050/api/chatbot/detect-disease-gemini \
  -F "image=@plant.jpg"
```

## 🛡️ Security

- ✅ Rate limiting (10 req/min)
- ✅ File type validation
- ✅ Environment variables
- ✅ Error handling
- ✅ Secure file cleanup

## 💰 Pricing

- **Free Tier:** Available for testing
- **Details:** https://ai.google.dev/pricing

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| API not configured | Set `GEMINI_API_KEY` environment variable |
| No response | Check internet & API key validity |
| Invalid file | Use PNG, JPG, JPEG, GIF, BMP, WEBP |
| Rate limit | Wait 1 minute |

## 📦 Files Included

```
├── app.py                                  # Main Flask app (updated)
├── .env.example                           # Environment template
├── requirements_gemini.txt                # Dependencies
├── test_gemini_disease_detection.html     # Test interface
├── GEMINI_SETUP.md                        # Detailed setup
├── QUICKSTART_GEMINI.md                   # Quick guide
├── GEMINI_INTEGRATION_SUMMARY.md          # Summary
└── README_GEMINI.md                       # This file
```

## 🚀 What's New

- ✨ Google Gemini 1.5 Flash integration
- 🎨 Beautiful test interface
- 📊 Structured data extraction
- 🔒 Enhanced security
- 📝 Comprehensive documentation

## 🤝 Support

- **Google AI Docs:** https://ai.google.dev/docs
- **API Reference:** https://ai.google.dev/api/python
- **Get API Key:** https://makersuite.google.com/app/apikey

## ⚠️ Important Notes

1. **Never commit API keys to Git!**
2. Add `.env` to `.gitignore`
3. Use environment variables in production
4. Rotate keys regularly

## 📄 License

Part of your agricultural management system.

---

**Ready to detect plant diseases with AI! 🌱🔬**

For detailed information, see [GEMINI_SETUP.md](GEMINI_SETUP.md)
