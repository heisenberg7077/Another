# Quick Start: Gemini Plant Disease Detection

## 🚀 Quick Setup (5 minutes)

### Step 1: Install Dependencies
```bash
pip install google-generativeai Pillow python-dotenv
```

### Step 2: Get Your Gemini API Key
1. Go to https://makersuite.google.com/app/apikey
2. Sign in with Google
3. Click "Create API Key"
4. Copy your key (starts with `AIzaSy...`)

### Step 3: Set Environment Variable

**Windows PowerShell:**
```powershell
$env:GEMINI_API_KEY="AIzaSy...your-key-here"
```

**Windows CMD:**
```cmd
set GEMINI_API_KEY=AIzaSy...your-key-here
```

**Linux/Mac:**
```bash
export GEMINI_API_KEY="AIzaSy...your-key-here"
```

### Step 4: Start Your Flask App
```bash
python app.py
```

### Step 5: Test the API

**Option A: Use the Test Page**
1. Open browser: `http://localhost:5050/test_gemini_disease_detection.html`
2. Upload a plant image
3. Click "Analyze Plant Disease"
4. View results!

**Option B: Use cURL**
```bash
curl -X POST http://localhost:5050/api/chatbot/detect-disease-gemini \
  -F "image=@plant_leaf.jpg"
```

**Option C: Use Python**
```python
import requests

url = "http://localhost:5050/api/chatbot/detect-disease-gemini"
files = {"image": open("plant_leaf.jpg", "rb")}
response = requests.post(url, files=files)
print(response.json())
```

## 📋 API Endpoint

**URL:** `/api/chatbot/detect-disease-gemini`  
**Method:** POST  
**Content-Type:** multipart/form-data  
**Rate Limit:** 10 requests/minute

### Request
```javascript
FormData:
  image: [File] (PNG, JPG, JPEG, GIF, BMP, WEBP)
```

### Response
```json
{
  "success": true,
  "analysis": "Full detailed analysis text...",
  "structured_data": {
    "plant_name": "Tomato",
    "disease_status": "Diseased",
    "disease_name": "Early Blight",
    "confidence": "High"
  },
  "model": "gemini-1.5-flash",
  "timestamp": "2024-01-01T12:00:00"
}
```

## 🎯 What You Get

✅ **Plant Identification** - Automatic crop/plant recognition  
✅ **Disease Detection** - Identifies specific diseases  
✅ **Symptom Analysis** - Detailed symptom descriptions  
✅ **Treatment Plans** - Chemical & organic solutions  
✅ **Prevention Tips** - How to avoid future issues  
✅ **Confidence Scores** - AI confidence in diagnosis  

## 🔧 Integration Examples

### JavaScript (Frontend)
```javascript
async function analyzePlant(imageFile) {
    const formData = new FormData();
    formData.append('image', imageFile);
    
    const response = await fetch('/api/chatbot/detect-disease-gemini', {
        method: 'POST',
        body: formData
    });
    
    const result = await response.json();
    console.log('Disease:', result.structured_data.disease_name);
    console.log('Analysis:', result.analysis);
}
```

### React Component
```jsx
function PlantDiseaseDetector() {
    const [result, setResult] = useState(null);
    
    const handleUpload = async (e) => {
        const file = e.target.files[0];
        const formData = new FormData();
        formData.append('image', file);
        
        const response = await fetch('/api/chatbot/detect-disease-gemini', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        setResult(data);
    };
    
    return (
        <div>
            <input type="file" onChange={handleUpload} accept="image/*" />
            {result && (
                <div>
                    <h3>{result.structured_data.plant_name}</h3>
                    <p>{result.structured_data.disease_name}</p>
                    <pre>{result.analysis}</pre>
                </div>
            )}
        </div>
    );
}
```

### PHP Integration
```php
<?php
$url = 'http://localhost:5050/api/chatbot/detect-disease-gemini';
$file = new CURLFile('plant_image.jpg', 'image/jpeg', 'image');

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, ['image' => $file]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$result = json_decode($response, true);

echo "Disease: " . $result['structured_data']['disease_name'];
curl_close($ch);
?>
```

## 🛠️ Troubleshooting

### "Gemini API not configured"
➡️ Set the `GEMINI_API_KEY` environment variable

### "No response from Gemini API"
➡️ Check internet connection and API key validity

### "Invalid file type"
➡️ Use PNG, JPG, JPEG, GIF, BMP, or WEBP format

### "Rate limit exceeded"
➡️ Wait 1 minute before trying again

## 💰 Pricing

- **Free Tier:** Available for testing
- **Paid Plans:** Check https://ai.google.dev/pricing

## 📚 Documentation

- Full Setup Guide: `GEMINI_SETUP.md`
- Test Page: `test_gemini_disease_detection.html`
- Environment Example: `.env.example`

## 🔒 Security Notes

⚠️ **Never commit your API key to Git!**
- Add `.env` to `.gitignore`
- Use environment variables in production
- Rotate keys regularly

## 🆘 Support

Need help? Check:
- Google AI Docs: https://ai.google.dev/docs
- Gemini API Reference: https://ai.google.dev/api/python

---

**Ready to detect plant diseases with AI! 🌱🔬**
