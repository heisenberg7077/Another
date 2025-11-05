# Gemini API Setup Guide for Plant Disease Detection

## Overview
This guide explains how to set up Google Gemini API for plant disease detection in your agricultural chatbot.

## Prerequisites
- Python 3.8 or higher
- Flask application running
- Google account

## Step 1: Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click on "Get API Key" or "Create API Key"
4. Copy your API key (it will look like: `AIzaSy...`)

## Step 2: Install Required Dependencies

Add the following packages to your `requirements.txt`:

```txt
google-generativeai>=0.3.0
Pillow>=10.0.0
```

Install them using:
```bash
pip install google-generativeai Pillow
```

## Step 3: Configure API Key

### Option 1: Environment Variable (Recommended)
Set the environment variable in your system:

**Windows (PowerShell):**
```powershell
$env:GEMINI_API_KEY="YOUR_ACTUAL_API_KEY_HERE"
```

**Windows (Command Prompt):**
```cmd
set GEMINI_API_KEY=YOUR_ACTUAL_API_KEY_HERE
```

**Linux/Mac:**
```bash
export GEMINI_API_KEY="YOUR_ACTUAL_API_KEY_HERE"
```

### Option 2: .env File
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and replace the placeholder:
   ```
   GEMINI_API_KEY=AIzaSy...your-actual-key-here
   ```

3. Install python-dotenv if not already installed:
   ```bash
   pip install python-dotenv
   ```

4. Add to your `app.py` (if not already present):
   ```python
   from dotenv import load_dotenv
   load_dotenv()
   ```

## Step 4: Test the API

### Using cURL:
```bash
curl -X POST http://localhost:5050/api/chatbot/detect-disease-gemini \
  -F "image=@/path/to/plant_image.jpg"
```

### Using Python:
```python
import requests

url = "http://localhost:5050/api/chatbot/detect-disease-gemini"
files = {"image": open("plant_image.jpg", "rb")}
response = requests.post(url, files=files)
print(response.json())
```

### Using JavaScript (Frontend):
```javascript
const formData = new FormData();
formData.append('image', imageFile);

fetch('/api/chatbot/detect-disease-gemini', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => {
    console.log('Disease Analysis:', data.analysis);
    console.log('Structured Data:', data.structured_data);
})
.catch(error => console.error('Error:', error));
```

## API Endpoint Details

### Endpoint: `/api/chatbot/detect-disease-gemini`
- **Method:** POST
- **Content-Type:** multipart/form-data
- **Rate Limit:** 10 requests per minute

### Request Parameters:
- `image` (file, required): Plant/crop image file
  - Supported formats: PNG, JPG, JPEG, GIF, BMP, WEBP
  - Recommended size: < 5MB

### Response Format:
```json
{
    "success": true,
    "analysis": "Detailed text analysis...",
    "structured_data": {
        "plant_name": "Tomato",
        "disease_status": "Diseased",
        "disease_name": "Early Blight",
        "confidence": "High",
        "symptoms": [],
        "treatment": [],
        "prevention": []
    },
    "model": "gemini-1.5-flash",
    "timestamp": "2024-01-01T12:00:00"
}
```

### Error Responses:
```json
{
    "error": "Gemini API not configured",
    "message": "Please set GEMINI_API_KEY environment variable"
}
```

## Features

The Gemini-powered disease detection provides:

1. **Plant Identification**
   - Accurate crop/plant species recognition
   - Identification of plant part (leaf, stem, fruit, etc.)

2. **Disease Analysis**
   - Disease status (Healthy/Diseased)
   - Specific disease name
   - Confidence level assessment

3. **Symptom Detection**
   - Visible symptoms (spots, discoloration, wilting, etc.)
   - Pattern and severity description

4. **Treatment Recommendations**
   - Immediate action steps
   - Chemical treatment options (fungicides/pesticides)
   - Organic/natural alternatives
   - Cultural practices to prevent spread

5. **Prevention Measures**
   - Future prevention strategies
   - Best practices for crop health

6. **Additional Information**
   - Severity level (Mild/Moderate/Severe)
   - Treatment urgency
   - Expected recovery time

## Troubleshooting

### Issue: "Gemini API not configured"
**Solution:** Ensure GEMINI_API_KEY environment variable is set correctly.

### Issue: "No response from Gemini API"
**Solution:** 
- Check your internet connection
- Verify API key is valid
- Check Gemini API quota/limits

### Issue: "Invalid file type"
**Solution:** Use supported image formats (PNG, JPG, JPEG, GIF, BMP, WEBP)

### Issue: Rate limit exceeded
**Solution:** Wait for the rate limit window to reset (1 minute)

## API Costs

Google Gemini API pricing (as of 2024):
- **gemini-1.5-flash**: Free tier available
- Check current pricing at: https://ai.google.dev/pricing

## Security Best Practices

1. **Never commit API keys to version control**
   - Add `.env` to `.gitignore`
   - Use environment variables in production

2. **Rotate API keys regularly**
   - Generate new keys periodically
   - Revoke old keys after rotation

3. **Implement rate limiting**
   - Already configured: 10 requests/minute
   - Adjust based on your needs

4. **Validate user input**
   - File type validation implemented
   - Consider adding file size limits

## Support

For issues or questions:
- Google AI Documentation: https://ai.google.dev/docs
- Gemini API Reference: https://ai.google.dev/api/python/google/generativeai

## License

This implementation is part of your agricultural management system.
