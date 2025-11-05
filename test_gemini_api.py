"""
Quick test script to verify Gemini API is working
"""
import google.generativeai as genai
from PIL import Image
import sys

# Configure API
GEMINI_API_KEY = 'AIzaSyCK_gCPQL6JnsxeqmYSKixFKR-AB6Iq3OY'
genai.configure(api_key=GEMINI_API_KEY)

print("Testing Gemini API...")
print(f"API Key: {GEMINI_API_KEY[:20]}...")

try:
    # Test with a simple text prompt first
    print("\n1. Testing text generation...")
    model = genai.GenerativeModel('gemini-1.5-flash')
    response = model.generate_content("Say hello")
    print(f"✓ Text generation works: {response.text[:50]}...")
    
    # Test with image if provided
    if len(sys.argv) > 1:
        print(f"\n2. Testing image analysis with: {sys.argv[1]}")
        img = Image.open(sys.argv[1])
        print(f"   Image loaded: {img.size}")
        
        prompt = "Describe this image briefly."
        response = model.generate_content([prompt, img])
        print(f"✓ Image analysis works!")
        print(f"   Response: {response.text[:100]}...")
    else:
        print("\n2. Skipping image test (no image provided)")
        print("   Usage: python test_gemini_api.py <image_path>")
    
    print("\n✓ All tests passed! Gemini API is working correctly.")
    
except Exception as e:
    print(f"\n✗ Error: {type(e).__name__}: {str(e)}")
    import traceback
    traceback.print_exc()
