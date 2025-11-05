import google.generativeai as genai

API_KEY = "AIzaSyCK_gCPQL6JnsxeqmYSKixFKR-AB6Iq3OY"
genai.configure(api_key=API_KEY)

model = genai.GenerativeModel("models/gemini-2.5-flash")

# Path to your local image
image_path = "download.jpeg"  # or the full path if needed

# Open the image
with open(image_path, "rb") as img:
    image_data = img.read()

# Send both text + image input
response = model.generate_content(
    [
        "Identify the plant disease in this leaf and suggest treatment steps.",
        {"mime_type": "image/jpeg", "data": image_data}
    ]
)

print(response.text)
