"""Test Gemini API with correct model"""
import google.generativeai as genai

GEMINI_API_KEY = 'AIzaSyCK_gCPQL6JnsxeqmYSKixFKR-AB6Iq3OY'
genai.configure(api_key=GEMINI_API_KEY)

print("Testing Gemini API with gemini-pro-latest...")

try:
    model = genai.GenerativeModel('gemini-pro-latest')
    response = model.generate_content("Say hello in one sentence")
    print(f"Success! Response: {response.text}")
    print("\nGemini API is working correctly!")
    print("Your Flask app should now work. Restart it with: python app.py")
    
except Exception as e:
    print(f"Error: {type(e).__name__}: {str(e)}")
