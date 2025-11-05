import ollama
import json

image_path = "download.jpeg"

prompt = """
You are an AI trained to identify plant species and detect leaf diseases.
Analyze the image carefully and answer in JSON only:

{
  "plant": "name of the plant or crop",
  "disease": "exact disease name (if healthy, say 'Healthy')",
  "symptoms": "visible leaf characteristics",
  "treatment": "short recommendation"
}
"""

response = ollama.chat(
    model="ayansh03/agribot",
    messages=[
        {
            "role": "user",
            "content": prompt,
            "images": [image_path],
        }
    ],
)

output = response["message"]["content"]

# Print result
print("🪴 Raw model output:\n", output)

try:
    data_start = output.find("{")
    data_end = output.rfind("}") + 1
    json_data = json.loads(output[data_start:data_end])
    print("\n🌿 Parsed JSON Result:")
    print(json.dumps(json_data, indent=2))
except Exception:
    print("\n⚠️ Model did not return valid JSON. Raw output shown above.")
