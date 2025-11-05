"""
Test the Gemini endpoint directly to see the actual error
"""
import requests
import sys
import os

# Create a simple test image if none provided
def create_test_image():
    from PIL import Image
    img = Image.new('RGB', (100, 100), color='green')
    img.save('test_plant.jpg')
    return 'test_plant.jpg'

# Get image path
if len(sys.argv) > 1:
    image_path = sys.argv[1]
else:
    print("No image provided, creating test image...")
    image_path = create_test_image()

if not os.path.exists(image_path):
    print(f"Error: Image file not found: {image_path}")
    sys.exit(1)

print(f"Testing endpoint with image: {image_path}")
print("-" * 60)

url = "http://127.0.0.1:5050/api/chatbot/detect-disease-gemini"

try:
    with open(image_path, 'rb') as f:
        files = {'image': f}
        print(f"Sending POST request to: {url}")
        response = requests.post(url, files=files, timeout=30)
        
    print(f"Status Code: {response.status_code}")
    print(f"Response Headers: {dict(response.headers)}")
    print("\nResponse Body:")
    print("-" * 60)
    
    try:
        data = response.json()
        import json
        print(json.dumps(data, indent=2))
    except:
        print(response.text)
        
except requests.exceptions.ConnectionError:
    print("ERROR: Cannot connect to Flask server!")
    print("Make sure Flask is running: python app.py")
except Exception as e:
    print(f"ERROR: {type(e).__name__}: {str(e)}")
    import traceback
    traceback.print_exc()
