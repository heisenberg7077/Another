import ollama
import ollama

def ask_agri_bot(question, model=None):
    system_prompt = (
        "You are AgriBot, an expert agriculture assistant. "
        "You answer questions about crops, fertilizers, soil health, "
        "irrigation, pest control, and weather-based farming. Be concise and practical."
    )
    try:
        response = ollama.chat(
            model=(model or "phi3"),
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": question}
            ]
        )
    except Exception:
        raise

    # Ollama's chat return can be a mapping-like ChatResponse or dict-like object.
    # Try to extract common fields reliably and fall back to str(response).
    try:
        if isinstance(response, dict):
            # new-style: {'message': {'role': 'assistant','content': '...'}}
            return response.get('message', {}).get('content') or response.get('content') or response.get('output') or str(response)
        # Some ChatResponse objects implement attribute access
        if hasattr(response, 'message'):
            msg = getattr(response, 'message')
            if isinstance(msg, dict):
                return msg.get('content') or str(response)
            if hasattr(msg, 'content'):
                return getattr(msg, 'content')
        # fallback
        return str(response)
    except Exception:
        return str(response)


if __name__ == "__main__":
    while True:
        query = input("Ask AgriBot: ")
        if query.lower() in ["exit", "quit"]:
            break
        print(ask_agri_bot(query))
