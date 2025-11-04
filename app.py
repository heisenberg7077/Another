from flask import Flask, jsonify, send_from_directory, request, session
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text, or_
from sqlalchemy.exc import SQLAlchemyError
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_caching import Cache
import os
import logging
import requests
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash

from functools import wraps
from datetime import datetime
import ollama
try:
    from agricheck import ask_agri_bot  # type: ignore
except Exception:
    # Keep symbol available even if agricheck is missing
    def ask_agri_bot(prompt: str, model: str = "phi3") -> str:  # type: ignore
        try:
            res = ollama.chat(model=model, messages=[{"role": "user", "content": prompt}])
            if isinstance(res, dict):
                msg = res.get("message") or {}
                content = msg.get("content") if isinstance(msg, dict) else None
                if content:
                    return content
            res2 = ollama.generate(model=model, prompt=prompt)
            if isinstance(res2, dict):
                return str(res2.get("response", "")).strip()
            return str(res2)
        except Exception as e:
            return "Agribot is not working"

# Strict, domain-focused system prompt to reduce unwanted/off-topic answers
STRICT_AGRI_SYSTEM_PROMPT = (
    "You are AgriBot, a professional agriculture advisor. "
    "Only answer agriculture-related questions: crop suitability, soil health, irrigation, "
    "pests/diseases, climate impacts, sustainable practices. Be concise, practical, and cite "
    "assumptions. If asked outside this scope, politely refuse and redirect to agriculture. "
    "Avoid medical/legal/financial advice. Prefer low-environmental-impact guidance, integrated "
    "pest management, and nutrient stewardship (4R: right source, rate, time, place). Ask for "
    "missing context briefly when needed. "
    "Do not include greetings, preambles, or meta text. Answer directly in 1-6 sentences unless otherwise requested."
)

def _extract_text_from_ollama_result(result) -> str:
    """Extract plain text content from various Ollama client return shapes (dict or object)."""
    try:
        # Dict response from ollama.chat: {"message": {"role": "assistant", "content": "..."}}
        if isinstance(result, dict):
            message = result.get("message")
            if isinstance(message, dict):
                content = message.get("content")
                if isinstance(content, str) and content.strip():
                    return content.strip()
            # Dict response from ollama.generate: {"response": "..."}
            response_field = result.get("response")
            if isinstance(response_field, str) and response_field.strip():
                return response_field.strip()
        # Object-style responses (possible SDK variants)
        message_obj = getattr(result, "message", None)
        if message_obj is not None:
            # message may be an object with .content or a dict-like
            content_attr = getattr(message_obj, "content", None)
            if isinstance(content_attr, str) and content_attr.strip():
                return content_attr.strip()
            if isinstance(message_obj, dict):
                content = message_obj.get("content")
                if isinstance(content, str) and content.strip():
                    return content.strip()
        response_attr = getattr(result, "response", None)
        if isinstance(response_attr, str) and response_attr.strip():
            return response_attr.strip()
    except Exception:
        pass
    return ""


def generate_agri_response(messages, model: str = "phi3") -> str:
    """Generate an agriculture-focused response with safe decoding and a strict system prompt."""
    try:
        safe_options = {
            "temperature": float(os.environ.get("OLLAMA_TEMPERATURE", "0.2")),
            "top_p": float(os.environ.get("OLLAMA_TOP_P", "0.9")),
            "repeat_penalty": float(os.environ.get("OLLAMA_REPEAT_PENALTY", "1.1")),
            "num_ctx": int(os.environ.get("OLLAMA_NUM_CTX", "4096")),
        }

        # Ensure a strict system message is present at index 0
        prepared_messages = []
        if isinstance(messages, list) and messages:
            first = messages[0]
            if isinstance(first, dict) and first.get("role") == "system":
                prepared_messages = messages[:]
                prepared_messages[0] = {"role": "system", "content": STRICT_AGRI_SYSTEM_PROMPT}
            else:
                prepared_messages = [{"role": "system", "content": STRICT_AGRI_SYSTEM_PROMPT}] + messages
        else:
            prepared_messages = [{"role": "system", "content": STRICT_AGRI_SYSTEM_PROMPT}]

        res = ollama.chat(model=model, messages=prepared_messages, options=safe_options)
        content = _extract_text_from_ollama_result(res)
        if content:
            return content
        # Fallback to single prompt mode
        user_text = ""
        for m in prepared_messages:
            if isinstance(m, dict) and m.get("role") == "user":
                user_text = m.get("content", "")
        prompt = (
            STRICT_AGRI_SYSTEM_PROMPT + "\n\nUser question:\n" + user_text + "\n\nAnswer:"
        )
        res2 = ollama.generate(model=model, prompt=prompt, options=safe_options)
        content2 = _extract_text_from_ollama_result(res2)
        if content2:
            return content2
        return ""
    except Exception as e:
        logging.error("Ollama chat error: %s", str(e))
        return "Agribot is not working"


# ================= Flask Setup =================
app = Flask(__name__, static_folder='.', static_url_path='')
# Allow API access from any local/LAN origin during development
CORS(app, resources={r"/api/*": {"origins": "*"}}, supports_credentials=True)
# Secret key from environment, fallback only for local dev
app.secret_key = os.environ.get("FLASK_SECRET_KEY", "dev-secret-change-me")

# Initialize rate limiter
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://"
)

# Initialize cache
cache = Cache(app, config={
    'CACHE_TYPE': 'simple',
    'CACHE_DEFAULT_TIMEOUT': 300
})

# ================= Global Error Handlers =================
@app.errorhandler(400)
def bad_request_error(error):
    return jsonify({
        "error": "Bad Request",
        "message": str(error),
        "status_code": 400
    }), 400

@app.errorhandler(401)
def unauthorized_error(error):
    return jsonify({
        "error": "Unauthorized",
        "message": "Authentication required",
        "status_code": 401
    }), 401

@app.errorhandler(403)
def forbidden_error(error):
    return jsonify({
        "error": "Forbidden",
        "message": "You don't have permission to access this resource",
        "status_code": 403
    }), 403

@app.errorhandler(404)
def not_found_error(error):
    return jsonify({
        "error": "Not Found",
        "message": "The requested resource was not found",
        "status_code": 404
    }), 404

@app.errorhandler(500)
def internal_error(error):
    # Log the error for debugging
    logging.error(f"Internal Server Error: {str(error)}")
    return jsonify({
        "error": "Internal Server Error",
        "message": "An unexpected error occurred",
        "status_code": 500
    }), 500

@app.errorhandler(SQLAlchemyError)
def database_error(error):
    # Log the database error
    logging.error(f"Database Error: {str(error)}")
    return jsonify({
        "error": "Database Error",
        "message": "A database error occurred",
        "status_code": 500
    }), 500

# Custom error handler for validation errors
class ValidationError(Exception):
    pass

@app.errorhandler(ValidationError)
def validation_error(error):
    return jsonify({
        "error": "Validation Error",
        "message": str(error),
        "status_code": 422
    }), 422

# Rate limit error handler
@app.errorhandler(429)
def ratelimit_handler(error):
    return jsonify({
        "error": "Too Many Requests",
        "message": "Rate limit exceeded. Please try again later.",
        "status_code": 429
    }), 429
 

# Configure Text Generation API (OpenAI-compatible)
TEXTGEN_API_BASE = os.environ.get('TEXTGEN_API_BASE', 'http://127.0.0.1:5001/v1')
TEXTGEN_API_KEY = os.environ.get('TEXTGEN_API_KEY', None)

# Flask runtime configuration via environment variables
FLASK_HOST = os.environ.get('FLASK_HOST', '0.0.0.0')
FLASK_PORT = int(os.environ.get('FLASK_PORT', '5050'))
FLASK_DEBUG = os.environ.get('FLASK_DEBUG', 'true').lower() in {'1','true','yes','on'}
FLASK_USE_RELOADER = os.environ.get('FLASK_USE_RELOADER', 'false').lower() in {'1','true','yes','on'}

# Prevent CSS caching during dev
@app.after_request
def add_no_cache_headers(response):
    try:
        if FLASK_DEBUG:
            response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
            response.headers['Pragma'] = 'no-cache'
        return response
    except Exception:
        return response


def _derive_youtube_thumbnail(url: str) -> str:
    """Return a YouTube thumbnail URL derived from a video URL; empty string if not derivable.

    Supports URLs like:
      - https://www.youtube.com/watch?v=VIDEO_ID
      - https://youtu.be/VIDEO_ID
      - https://www.youtube.com/embed/VIDEO_ID
    """
    try:
        if not isinstance(url, str) or not url:
            return ""
        video_id = ""
        if "youtu.be/" in url:
            video_id = url.split("youtu.be/")[1].split("?")[0].split("/")[0]
        elif "youtube.com/watch" in url and "v=" in url:
            video_id = url.split("v=")[1].split("&")[0]
        elif "youtube.com/embed/" in url:
            video_id = url.split("youtube.com/embed/")[1].split("?")[0].split("/")[0]
        if video_id:
            return f"https://img.youtube.com/vi/{video_id}/maxresdefault.jpg"
    except Exception:
        pass
    return ""


@app.route('/api/placeholder/<int:w>/<int:h>')
def placeholder(w: int, h: int):
    # Lightweight SVG placeholder
    text = f"{w}×{h}"
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">
  <rect width="100%" height="100%" fill="#e9ecef"/>
  <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="#6c757d" font-family="Arial, sans-serif" font-size="{max(10, min(w, h)//6)}">{text}</text>
</svg>'''
    return svg, 200, {"Content-Type": "image/svg+xml"}

@app.route("/api/chatbot", methods=["POST"])
@limiter.limit("30 per minute")  # Limit chatbot requests
def chatbot():
    """
    Chatbot endpoint: Proxies to local Text Generation WebUI OpenAI-compatible API.
    Accepts JSON {"message": "..."} and returns assistant response string.
    """
    try:
        data = request.get_json() or {}

        # Accept either a simple string message, or an OpenAI-style messages array
        user_message = (data.get("message") or "").strip() if isinstance(data.get("message"), str) else ""
        messages = data.get("messages") if isinstance(data.get("messages"), list) else None
        if not messages:
            if not user_message:
                return jsonify({"error": "No message provided. Send 'message' or 'messages'[]."}), 400
            messages = [{"role": "user", "content": user_message}]

        model = os.environ.get("OLLAMA_MODEL", "phi3")

        try:
            # Use robust chat helper with strict system prompt and safe decoding
            assistant_text = generate_agri_response(messages, model=model)
        except Exception as oe:
            logging.error("Ollama/AgriBot error: %s", str(oe))
            return jsonify({"error": "AgriBot chat failed", "details": str(oe)}), 502

        if not isinstance(assistant_text, str):
            assistant_text = str(assistant_text or "")

        if not assistant_text:
            return jsonify({"error": "Empty response from AgriBot", "raw": assistant_text}), 502

        return jsonify({"response": assistant_text})
    except Exception as e:
        logging.error("Chatbot error: %s", str(e))
        return jsonify({"error": str(e)}), 500

 

# Removed duplicate /api/detect-disease route (Gemini) to avoid conflict with CNN-based endpoint below
# ================= Database Config =================
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost:3306/agri_v'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# ================= Logging =================
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# ================= Security: Disable Caching of Sensitive Pages =================
@app.after_request
def add_no_cache_headers(response):
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    return response

 

# ================= Database Models =================
class Crop(db.Model):
    __tablename__ = "crops"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
    season = db.Column(db.String(100))
    ec_range = db.Column(db.String(50))
    land_size_min = db.Column(db.Numeric(10, 2))
    land_size_max = db.Column(db.Numeric(10, 2))
    soil_types = db.Column(db.Text)
    crop_category = db.Column(db.String(50))
    fertilizers = db.relationship("Fertilizer", backref="crop", lazy=True)
    pesticides = db.relationship("Pesticide", backref="crop", lazy=True)
    guide = db.relationship("CropGuide", backref="crop", uselist=False, lazy=True)
    stages = db.relationship("CropStage", backref="crop", lazy=True, order_by="CropStage.stage_number")

class Fertilizer(db.Model):
    __tablename__ = "fertilizers"
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    week = db.Column(db.String(50))
    name = db.Column(db.String(100))
    quantity = db.Column(db.String(50))
    price = db.Column(db.String(50))
    gap_days = db.Column(db.Integer)

class Pesticide(db.Model):
    __tablename__ = "pesticides"
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    week = db.Column(db.String(50))
    name = db.Column(db.String(100))
    application = db.Column(db.String(100))
    quantity = db.Column(db.String(50))
    price = db.Column(db.String(50))

class CropGuide(db.Model):
    __tablename__ = "crop_guides"
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False, unique=True)
    overview = db.Column(db.Text)
    climate = db.Column(db.Text)
    soil = db.Column(db.Text)
    land_preparation = db.Column(db.Text)
    sowing = db.Column(db.Text)
    irrigation = db.Column(db.Text)
    nutrient_management = db.Column(db.Text)
    weed_management = db.Column(db.Text)
    pests_diseases = db.Column(db.Text)
    harvesting = db.Column(db.Text)
    yield_info = db.Column(db.Text)

class CropStage(db.Model):
    __tablename__ = "crop_stages"
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    stage_number = db.Column(db.Integer, nullable=False)
    title = db.Column(db.String(100), nullable=False)
    start_week = db.Column(db.Integer, nullable=False)
    end_week = db.Column(db.Integer, nullable=False)
    tasks = db.Column(db.Text, nullable=False)
    video_url = db.Column(db.String(255))
    detailed_description = db.Column(db.Text)
    equipment_needed = db.Column(db.Text)
    time_required = db.Column(db.String(50))
    difficulty_level = db.Column(db.String(20))

class WeeklyTask(db.Model):
    __tablename__ = "weekly_tasks"
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    week_number = db.Column(db.Integer, nullable=False)
    task_title = db.Column(db.String(200), nullable=False)
    task_description = db.Column(db.Text, nullable=False)
    task_type = db.Column(db.String(20), nullable=False)
    priority = db.Column(db.String(20), nullable=False)
    estimated_duration = db.Column(db.String(50))
    equipment_needed = db.Column(db.Text)
    materials_needed = db.Column(db.Text)
    video_url = db.Column(db.String(255))
    image_url = db.Column(db.String(255))
    step_by_step_instructions = db.Column(db.Text)
    tips_and_notes = db.Column(db.Text)
    weather_conditions = db.Column(db.Text)
    safety_precautions = db.Column(db.Text)
    expected_outcome = db.Column(db.Text)

class CropVideo(db.Model):
    __tablename__ = "crop_videos"
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    week_number = db.Column(db.Integer)
    video_title = db.Column(db.String(200), nullable=False)
    video_url = db.Column(db.String(500), nullable=False)
    video_type = db.Column(db.String(20), nullable=False)
    duration_minutes = db.Column(db.Integer)
    description = db.Column(db.Text)
    thumbnail_url = db.Column(db.String(500))
    is_featured = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.now)

class ProcessVideo(db.Model):
    __tablename__ = "process_videos"
    id = db.Column(db.Integer, primary_key=True)
    process_category = db.Column(db.Enum('land_preparation','sowing','planting','applying_fertilizer','applying_pesticide','harvesting'), nullable=False)
    process_type = db.Column(db.String(100))
    video_title = db.Column(db.String(200), nullable=False)
    video_url = db.Column(db.String(500), nullable=False)
    duration_minutes = db.Column(db.Integer)
    description = db.Column(db.Text)
    thumbnail_url = db.Column(db.String(500))
    is_featured = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.now)

class CropProgressTracking(db.Model):
    __tablename__ = "crop_progress_tracking"
    id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.Integer, db.ForeignKey('crop_monitoring_sessions.id'), nullable=False)
    week_number = db.Column(db.Integer, nullable=False)
    task_id = db.Column(db.Integer, db.ForeignKey('weekly_tasks.id'))
    completion_status = db.Column(db.String(20), default='not_started')
    completion_date = db.Column(db.DateTime)
    notes = db.Column(db.Text)
    photos_urls = db.Column(db.Text)
    rating = db.Column(db.Integer)
    feedback = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)

class SoilType(db.Model):
    __tablename__ = 'soil_types'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    description = db.Column(db.Text)
    ph_range = db.Column(db.String(50))
    drainage = db.Column(db.String(50))
    water_retention = db.Column(db.String(50))
    fertility_level = db.Column(db.String(50))
    suitable_crops = db.Column(db.Text)

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column('user_id', db.Integer, primary_key=True)  # Maps to user_id in database
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column('password_hash', db.String(255), nullable=False)

class CropMonitoringSession(db.Model):
    __tablename__ = 'crop_monitoring_sessions'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), nullable=False)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    crop_name = db.Column(db.String(100), nullable=False)
    land_size = db.Column(db.Float, nullable=True)
    soil_type = db.Column(db.String(100), nullable=False)
    start_date = db.Column(db.DateTime, nullable=False)
    current_week = db.Column(db.Integer, default=1)
    status = db.Column(db.String(20), default='active')
    total_weeks = db.Column(db.Integer, default=20)
    created_at = db.Column(db.DateTime, default=datetime.now)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)

class TaskCompletion(db.Model):
    __tablename__ = 'task_completions'
    id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.Integer, db.ForeignKey('crop_monitoring_sessions.id'), nullable=False)
    task_type = db.Column(db.String(20), nullable=False)
    task_name = db.Column(db.String(200), nullable=False)
    week_number = db.Column(db.Integer, nullable=False)
    completed_at = db.Column(db.DateTime, default=datetime.now)
    notes = db.Column(db.Text)

class CropPlaylist(db.Model):
    __tablename__ = 'crop_playlists'
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    cover_image_url = db.Column(db.String(500))
    is_featured = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.now)

class CropPlaylistItem(db.Model):
    __tablename__ = 'crop_playlist_items'
    id = db.Column(db.Integer, primary_key=True)
    playlist_id = db.Column(db.Integer, db.ForeignKey('crop_playlists.id'), nullable=False)
    video_id = db.Column(db.Integer, db.ForeignKey('crop_videos.id'), nullable=False)
    position = db.Column(db.Integer, default=0)
    added_at = db.Column(db.DateTime, default=datetime.now)

class WeeklyProgress(db.Model):
    __tablename__ = 'weekly_progress'
    id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.Integer, db.ForeignKey('crop_monitoring_sessions.id'), nullable=False)
    week_number = db.Column(db.Integer, nullable=False)
    status = db.Column(db.String(20), default='pending')
    tasks_completed = db.Column(db.Integer, default=0)
    total_tasks = db.Column(db.Integer, default=0)
    notes = db.Column(db.Text)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)

class TaskDependency(db.Model):
    __tablename__ = 'task_dependencies'
    id = db.Column(db.Integer, primary_key=True)
    task_id = db.Column(db.Integer, db.ForeignKey('weekly_tasks.id'), nullable=False)
    depends_on_task_id = db.Column(db.Integer, db.ForeignKey('weekly_tasks.id'), nullable=False)
    dependency_type = db.Column(db.Enum('prerequisite', 'recommended', 'alternative'), default='prerequisite')
    created_at = db.Column(db.DateTime, default=datetime.now)

class CropTip(db.Model):
    __tablename__ = 'crop_tips'
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    week_number = db.Column(db.Integer)
    tip_category = db.Column(db.Enum('general', 'fertilizer', 'pest_control', 'irrigation', 'harvesting', 'troubleshooting'), default='general')
    tip_title = db.Column(db.String(200), nullable=False)
    tip_description = db.Column(db.Text, nullable=False)
    tip_image_url = db.Column(db.String(500))
    is_featured = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.now)

class WeatherRecommendation(db.Model):
    __tablename__ = 'weather_recommendations'
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    week_number = db.Column(db.Integer)
    weather_condition = db.Column(db.Enum('sunny', 'rainy', 'cloudy', 'hot', 'cold', 'windy'), nullable=False)
    recommendation = db.Column(db.Text, nullable=False)
    priority = db.Column(db.Enum('Low', 'Medium', 'High', 'Critical'), default='Medium')
    created_at = db.Column(db.DateTime, default=datetime.now)

# ================= Additional Feature Models =================
class AnalyticsMetric(db.Model):
    __tablename__ = 'analytics_metrics'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'))
    metric_type = db.Column(db.Enum('yield', 'cost', 'water_usage', 'fertilizer_efficiency', name='metric_type'))
    value = db.Column(db.Numeric(10, 2))
    recorded_date = db.Column(db.Date)

class IrrigationLog(db.Model):
    __tablename__ = 'irrigation_logs'
    id = db.Column(db.Integer, primary_key=True)
    crop_monitoring_session_id = db.Column(db.Integer, db.ForeignKey('crop_monitoring_sessions.id'))
    water_amount = db.Column(db.Numeric(10, 2))
    soil_moisture = db.Column(db.Numeric(5, 2))
    irrigation_date = db.Column(db.DateTime)
    weather_condition = db.Column(db.String(50))

class YieldPrediction(db.Model):
    __tablename__ = 'yield_predictions'
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'))
    predicted_yield = db.Column(db.Numeric(10, 2))
    confidence_score = db.Column(db.Numeric(5, 2))
    factors_considered = db.Column(db.JSON)
    prediction_date = db.Column(db.Date)

class CommunityPost(db.Model):
    __tablename__ = 'community_posts'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    title = db.Column(db.String(200))
    content = db.Column(db.Text)
    post_type = db.Column(db.Enum('success_story', 'question', 'tip', 'problem', name='post_type'))
    created_at = db.Column(db.DateTime, default=datetime.now)
    likes = db.Column(db.Integer, default=0)

class ArchivedMonitoringData(db.Model):
    __tablename__ = 'archived_monitoring_data'
    id = db.Column(db.Integer, primary_key=True)
    original_data_id = db.Column(db.Integer)
    data_type = db.Column(db.String(50))
    archived_date = db.Column(db.Date)
    data_json = db.Column(db.JSON)

class AuditLog(db.Model):
    __tablename__ = 'audit_logs'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), nullable=True)  # Allow NULL for failed login attempts
    action = db.Column(db.String(100), nullable=False)
    resource_type = db.Column(db.String(50), nullable=False)
    resource_id = db.Column(db.Integer)
    details = db.Column(db.JSON)
    ip_address = db.Column(db.String(45))
    timestamp = db.Column(db.DateTime, default=datetime.now)
    status = db.Column(db.String(20))  # success, failure, error

# ================= Auth Helpers =================
def auth_required(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        if not session.get('user_id'):
            return jsonify({"success": False, "error": "Unauthorized"}), 401
        return f(*args, **kwargs)
    return wrapper

def is_admin_user(username: str) -> bool:
    admins_csv = os.environ.get('ADMIN_USERS', '')
    admin_usernames = {u.strip().lower() for u in admins_csv.split(',') if u.strip()}
    if not admin_usernames:
        admin_usernames = {"admin"}
    return (username or '').lower() in admin_usernames

def admin_required(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        if not session.get('user_id'):
            return jsonify({"success": False, "error": "Unauthorized"}), 401
        if not session.get('is_admin'):
            return jsonify({"success": False, "error": "Forbidden"}), 403
        return f(*args, **kwargs)
    return wrapper

def clear_cache():
    """Clear the cache after admin modifications"""
    with app.app_context():
        cache.clear()

def log_audit(action, resource_type, resource_id=None, details=None, status="success"):
    """Log an audit event"""
    try:
        if not session.get('user_id'):
            return
        
        audit_log = AuditLog(
            user_id=session['user_id'],
            action=action,
            resource_type=resource_type,
            resource_id=resource_id,
            details=details,
            ip_address=request.remote_addr,
            status=status
        )
        db.session.add(audit_log)
        db.session.commit()
    except Exception as e:
        logging.error(f"Failed to create audit log: {str(e)}")
        db.session.rollback()

# ================= API Routes =================
@app.route("/api/crops", methods=["GET"])
@cache.cached(timeout=300, query_string=True)  # Cache for 5 minutes, consider query parameters
def get_crops():
    """
    Get all crops with optional filtering
    Query parameters:
    - category: Filter by crop category (e.g., Vegetable, Cereal)
    - soil: Filter by soil type (partial match)
    - difficulty: Filter by difficulty (Easy, Medium, Hard)
    - season: Filter by season (partial match)
    - search: Search in crop name or description
    """
    # Start with base query
    query = Crop.query
    
    # Apply filters based on query parameters
    category = request.args.get('category')
    soil = request.args.get('soil')
    difficulty = request.args.get('difficulty')
    season = request.args.get('season')
    search = request.args.get('search')
    
    if category:
        query = query.filter(Crop.crop_category == category)
    
    if soil:
        query = query.filter(Crop.soil_types.like(f'%{soil}%'))
    
    if difficulty:
        query = query.filter(Crop.difficulty == difficulty)
    
    if season:
        query = query.filter(Crop.season.like(f'%{season}%'))
    
    if search:
        # Only include fields that exist on the model
        or_clauses = [Crop.name.like(f'%{search}%')]
        if hasattr(Crop, 'description'):
            or_clauses.append(Crop.description.like(f'%{search}%'))
        query = query.filter(or_(*or_clauses))
    
    crops = query.all()
    
    result = []
    for c in crops:
        item = {
            "id": c.id,
            "name": c.name,
            "season": c.season,
            "ec": c.ec_range,
            "land_size_min": float(c.land_size_min) if c.land_size_min else None,
            "land_size_max": float(c.land_size_max) if c.land_size_max else None,
            "soil_types": c.soil_types,
            "crop_category": c.crop_category,
        }
        # Safely include optional fields if present in current schema
        if hasattr(c, 'image_url'):
            item["image_url"] = getattr(c, 'image_url')
        if hasattr(c, 'description'):
            item["description"] = getattr(c, 'description')
        if hasattr(c, 'average_duration_weeks'):
            item["average_duration_weeks"] = getattr(c, 'average_duration_weeks')
        if hasattr(c, 'difficulty'):
            item["difficulty"] = getattr(c, 'difficulty')
        result.append(item)
    return jsonify(result)

# ================= Auth Routes =================
@app.route('/api/register', methods=['POST'])
@limiter.limit("5 per minute")  # Limit registration attempts
def register():
    data = request.get_json(force=True) or {}
    username = (data.get('username') or '').strip()
    password = data.get('password') or ''
    if not username or not password:
        return jsonify({"success": False, "error": "Username and password are required"}), 400
    if User.query.filter_by(username=username).first():
        log_audit("user_registration_attempt", "user", details={"username": username}, status="failure")
        return jsonify({"success": False, "error": "Username already exists"}), 400
    try:
        hashed_password = generate_password_hash(password, method='pbkdf2:sha256')
        user = User(username=username, password=hashed_password)
        db.session.add(user)
        db.session.commit()
        log_audit("user_registration", "user", user.id, {"username": username})
        return jsonify({"success": True})
    except Exception as e:
        log_audit("user_registration_attempt", "user", details={"username": username, "error": str(e)}, status="error")
        db.session.rollback()
        raise

@app.route('/api/login', methods=['POST'])
@limiter.limit("10 per minute")  # Limit login attempts
def login():
    data = request.get_json(force=True) or {}
    username = (data.get('username') or '').strip()
    password = data.get('password') or ''
    user = User.query.filter_by(username=username).first()
    if not user:
        log_audit("user_login_attempt", "user", details={"username": username}, status="failure")
        return jsonify({"success": False, "error": "Invalid credentials"}), 401
    
    try:
        # First try password hash verification
        if check_password_hash(user.password, password):
            is_valid = True
        else:
            # Legacy plaintext comparison (for transition period)
            is_valid = (user.password == password)
            if is_valid:
                # Update to hashed password if login successful with plaintext
                user.password = generate_password_hash(password, method='pbkdf2:sha256')
                db.session.commit()
                log_audit("password_hash_update", "user", user.id, {"username": username})
        
        if not is_valid:
            log_audit("user_login_attempt", "user", user.id, {"username": username}, status="failure")
            return jsonify({"success": False, "error": "Invalid credentials"}), 401
        
        session['user_id'] = user.id
        session['username'] = user.username
        session['is_admin'] = is_admin_user(user.username)
        log_audit("user_login", "user", user.id, {"username": username})
        return jsonify({"success": True, "is_admin": bool(session['is_admin'])})
    except Exception as e:
        log_audit("user_login_attempt", "user", user.id if user else None, {"username": username, "error": str(e)}, status="error")
        db.session.rollback()
        raise

@app.route('/api/me', methods=['GET'])
def me():
    uid = session.get('user_id')
    if not uid:
        return jsonify({"authenticated": False})
    return jsonify({
        "authenticated": True,
        "user_id": uid,
        "id": uid,  # compatibility for frontend expecting `id`
        "username": session.get('username'),
        "is_admin": bool(session.get('is_admin'))
    })

@app.route('/api/logout', methods=['POST'])
def logout():
    if 'user_id' in session:
        user_id = session.get('user_id')
        username = session.get('username')
        log_audit("user_logout", "user", user_id, {"username": username})
    session.clear()
    return jsonify({"success": True})

@app.route("/api/crops/<int:crop_id>", methods=["GET"])
@cache.cached(timeout=300, query_string=True)  # Cache for 5 minutes, consider query parameters
def get_crop_details(crop_id):
    crop = Crop.query.get_or_404(crop_id)
    guide = crop.guide
    stages = sorted(crop.stages, key=lambda s: s.stage_number)

    return jsonify({
        "name": crop.name,
        "season": crop.season,
        "ec": crop.ec_range,
        "guide": None if not guide else {
            "overview": guide.overview,
            "climate": guide.climate,
            "soil": guide.soil,
            "landPreparation": guide.land_preparation,
            "sowing": guide.sowing,
            "irrigation": guide.irrigation,
            "nutrientManagement": guide.nutrient_management,
            "weedManagement": guide.weed_management,
            "pestsDiseases": guide.pests_diseases,
            "harvesting": guide.harvesting,
            "yieldInfo": guide.yield_info
        },
        "stages": [{
            "stage": s.stage_number,
            "title": s.title,
            "startWeek": s.start_week,
            "endWeek": s.end_week,
            "tasks": s.tasks
        } for s in stages],
        "fertilizers": [{"week": f.week, "name": f.name, "quantity": f.quantity, "price": f.price, "gapDays": f.gap_days} for f in crop.fertilizers],
        "pesticides": [{"week": p.week, "name": p.name, "usage": p.application, "quantity": p.quantity, "price": p.price} for p in crop.pesticides]
    })

@app.route("/api/crops/<int:crop_id>/week/<int:week>", methods=["GET"])
def get_week_tasks(crop_id, week):
    stages = CropStage.query.filter(
        CropStage.crop_id == crop_id,
        CropStage.start_week <= week,
        CropStage.end_week >= week
    ).order_by(CropStage.stage_number).all()

    return jsonify([{
        "stage": s.stage_number,
        "title": s.title,
        "range": f"W{s.start_week}–W{s.end_week}",
        "tasks": s.tasks
    } for s in stages])

@app.route("/fetch-values")
def fetch_values():
    result = db.session.execute(text('SELECT name FROM crops')).fetchall()
    values = [row[0] for row in result]
    return jsonify(values)


def get_weather_advice(weather_code, temperature):
    # Lightweight mapping for frontend advice (similar to index.html heuristics)
    try:
        if 61 <= int(weather_code) <= 82:
            return "🌧️ <strong>Rainy conditions:</strong> Avoid field work. Good for irrigation planning."
        if 95 <= int(weather_code) <= 99:
            return "⛈️ <strong>Storm warning:</strong> Secure equipment and protect crops from wind damage."
    except Exception:
        pass
    if temperature is not None:
        try:
            t = float(temperature)
            if t > 35:
                return "🌡️ <strong>Hot weather:</strong> Increase irrigation frequency. Consider shade for sensitive crops."
            if t < 15:
                return "❄️ <strong>Cool weather:</strong> Good for root development. Reduce irrigation frequency."
        except Exception:
            pass
    return "🌤️ <strong>Good conditions:</strong> Ideal for field work and crop management activities."


@app.route('/api/weather', methods=['GET'])
def get_weather():
    # Shape aligned to frontend expectations in index.html
    temperature = 30
    weather_code = 0  # 0 = clear in our stub mapping
    description = "Sunny"
    wind_speed = 10
    location = "Coimbatore"
    return jsonify({
        "success": True,
        "location": location,
        "temperature": temperature,
        "description": description,
        "wind_speed": wind_speed,
        "weather_code": weather_code,
        "advice": get_weather_advice(weather_code, temperature)
    })

@app.route("/api/soil-types", methods=["GET"])
def get_soil_types():
    soil_types = SoilType.query.all()
    return jsonify([{
        "id": s.id,
        "name": s.name,
        "description": s.description,
        "ph_range": s.ph_range,
        "drainage": s.drainage,
        "water_retention": s.water_retention,
        "fertility_level": s.fertility_level,
        "suitable_crops": s.suitable_crops
    } for s in soil_types])

@app.route("/api/crop-suggestions", methods=["POST"])
def get_crop_suggestions():
    data = request.get_json() or {}
    land_size = data.get('land_size')
    soil_type = data.get('soil_type')
    
    if not soil_type:
        return jsonify({"error": "Soil type is required"}), 400
    
    # Convert land_size to float if provided, otherwise set to None
    if land_size:
        try:
            land_size = float(land_size)
        except (ValueError, TypeError):
            return jsonify({"error": "Invalid land size"}), 400
    else:
        land_size = None
    
    # Find crops suitable for the soil type and land size
    suitable_crops = []
    crops = Crop.query.all()
    
    for crop in crops:
        # Check if soil type matches
        if crop.soil_types and soil_type.lower() in crop.soil_types.lower():
            # If no land size provided, include all crops suitable for the soil type
            if land_size is None:
                is_suitable = True
            else:
                # More flexible land size matching
                land_size_min = float(crop.land_size_min) if crop.land_size_min else 0
                land_size_max = float(crop.land_size_max) if crop.land_size_max else float('inf')
                
                # Allow crops if land size is within 20% of the range or if no range is specified
                min_threshold = land_size_min * 0.8 if land_size_min > 0 else 0
                max_threshold = land_size_max * 1.2 if land_size_max < float('inf') else float('inf')
                
                # Also allow very small plots (0.1+ acres) for most crops, and very large plots for appropriate crops
                is_suitable = (
                    (land_size >= min_threshold and land_size <= max_threshold) or
                    (land_size >= 0.1 and land_size <= 1.0 and land_size_min <= 1.0) or  # Small plots
                    (land_size >= 50 and land_size_max >= 50)  # Large plots for appropriate crops
                )
            
            if is_suitable:
                suitable_crops.append({
                    "id": crop.id,
                    "name": crop.name,
                    "season": crop.season,
                    "ec_range": crop.ec_range,
                    "crop_category": crop.crop_category,
                    "land_size_min": float(crop.land_size_min) if crop.land_size_min else None,
                    "land_size_max": float(crop.land_size_max) if crop.land_size_max else None,
                    "soil_types": crop.soil_types,
                    "suitability_score": calculate_suitability_score(land_size, land_size_min, land_size_max) if land_size else 80
                })
    
    # Sort by crop category and name
    suitable_crops.sort(key=lambda x: (x['crop_category'] or '', x['name']))
    
    # Sort by suitability score (higher is better) and then by category
    suitable_crops.sort(key=lambda x: (-x['suitability_score'], x['crop_category'] or '', x['name']))
    
    return jsonify({
        "land_size": land_size,
        "soil_type": soil_type,
        "suggested_crops": suitable_crops,
        "total_suggestions": len(suitable_crops)
    })

def calculate_suitability_score(land_size, land_size_min, land_size_max):
    """Calculate how suitable a crop is for the given land size (0-100 scale)"""
    if land_size_min is None and land_size_max is None:
        return 80  # Good score for crops with no size restrictions
    
    if land_size_min is None:
        land_size_min = 0
    if land_size_max is None:
        land_size_max = float('inf')
    
    # Perfect match gets 100
    if land_size_min <= land_size <= land_size_max:
        return 100
    
    # Calculate penalty for being outside range
    if land_size < land_size_min:
        penalty = (land_size_min - land_size) / land_size_min * 50
        return max(20, 100 - penalty)
    else:  # land_size > land_size_max
        if land_size_max == float('inf'):
            return 80
        penalty = (land_size - land_size_max) / land_size_max * 30
        return max(20, 100 - penalty)

@app.route("/api/land-calculations", methods=["POST"])
def get_land_calculations():
    """Calculate fertilizer, pesticide, and irrigation requirements based on land size"""
    data = request.get_json() or {}
    land_size = data.get('land_size')
    soil_type = data.get('soil_type')
    irrigation_type = data.get('irrigation_type', 'drip')
    
    if not land_size:
        return jsonify({"error": "Land size is required"}), 400
    
    try:
        land_size = float(land_size)
    except (ValueError, TypeError):
        return jsonify({"error": "Invalid land size"}), 400
    
    # Calculate fertilizer recommendations
    fertilizer_recommendations = calculate_fertilizer_requirements(land_size, soil_type)
    
    # Calculate pesticide recommendations
    pesticide_recommendations = calculate_pesticide_requirements(land_size, soil_type)
    
    # Calculate irrigation requirements
    irrigation_recommendations = calculate_irrigation_requirements(land_size, irrigation_type)
    
    # Calculate cost estimates
    cost_estimates = calculate_cost_estimates(land_size, fertilizer_recommendations, pesticide_recommendations, irrigation_recommendations)
    
    return jsonify({
        "land_size": land_size,
        "soil_type": soil_type,
        "irrigation_type": irrigation_type,
        "fertilizer_recommendations": fertilizer_recommendations,
        "pesticide_recommendations": pesticide_recommendations,
        "irrigation_recommendations": irrigation_recommendations,
        "cost_estimates": cost_estimates
    })

def calculate_fertilizer_requirements(land_size, soil_type):
    """Calculate fertilizer requirements based on land size and soil type"""
    # Base fertilizer requirements per acre (kg)
    base_fertilizers = {
        'urea': 100,        # Nitrogen
        'dap': 50,          # Phosphorus (Diammonium Phosphate)
        'mop': 50,          # Potassium (Muriate of Potash)
        'fym': 1000,        # Farm Yard Manure
        'compost': 500,     # Compost
        'vermicompost': 200 # Vermicompost
    }
    
    # Soil type adjustments
    soil_adjustments = {
        'clay': 1.2,        # Clay soil needs more nutrients
        'sandy': 0.8,        # Sandy soil needs less
        'loamy': 1.0,        # Loamy soil is standard
        'silty': 1.1,        # Silty soil needs slightly more
        'black_cotton': 1.3, # Black cotton soil needs more
        'red_soil': 0.9,     # Red soil needs slightly less
        'alluvial': 1.0,     # Alluvial soil is standard
        'laterite': 0.8     # Laterite soil needs less
    }
    
    adjustment_factor = soil_adjustments.get(soil_type, 1.0)
    
    recommendations = {}
    for fertilizer, base_amount in base_fertilizers.items():
        adjusted_amount = base_amount * adjustment_factor
        total_amount = round(adjusted_amount * land_size)
        cost_per_kg = get_fertilizer_cost(fertilizer)
        total_cost = round(total_amount * cost_per_kg)
        
        recommendations[fertilizer] = {
            "amount": total_amount,
            "unit": "kg",
            "cost": total_cost,
            "cost_per_unit": cost_per_kg,
            "application": get_fertilizer_application(fertilizer),
            "timing": get_fertilizer_timing(fertilizer)
        }
    
    return recommendations

def calculate_pesticide_requirements(land_size, soil_type):
    """Calculate pesticide requirements based on land size and soil type"""
    # Base pesticide requirements per acre (ml)
    base_pesticides = {
        'insecticide': 500,     # General insecticide
        'fungicide': 300,       # Fungicide for disease control
        'herbicide': 200,       # Herbicide for weed control
        'bio_pesticide': 1000,  # Bio-pesticide (organic)
        'neem_oil': 200,        # Neem oil (organic)
        'bt_spray': 300         # Bacillus thuringiensis
    }
    
    # Soil type adjustments for pest pressure
    pest_pressure_adjustments = {
        'clay': 1.1,        # Clay soil has higher pest pressure
        'sandy': 0.9,        # Sandy soil has lower pest pressure
        'loamy': 1.0,        # Loamy soil is standard
        'silty': 1.0,        # Silty soil is standard
        'black_cotton': 1.2, # Black cotton soil has higher pest pressure
        'red_soil': 0.9,     # Red soil has lower pest pressure
        'alluvial': 1.0,     # Alluvial soil is standard
        'laterite': 0.8     # Laterite soil has lower pest pressure
    }
    
    adjustment_factor = pest_pressure_adjustments.get(soil_type, 1.0)
    
    recommendations = {}
    for pesticide, base_amount in base_pesticides.items():
        adjusted_amount = base_amount * adjustment_factor
        total_amount = round(adjusted_amount * land_size)
        cost_per_ml = get_pesticide_cost(pesticide)
        total_cost = round(total_amount * cost_per_ml)
        
        recommendations[pesticide] = {
            "amount": total_amount,
            "unit": "ml",
            "cost": total_cost,
            "cost_per_unit": cost_per_ml,
            "application": get_pesticide_application(pesticide),
            "frequency": get_pesticide_frequency(pesticide)
        }
    
    return recommendations

def calculate_irrigation_requirements(land_size, irrigation_type):
    """Calculate irrigation requirements based on land size and irrigation type"""
    # Base water requirement per acre per irrigation (liters)
    base_water_requirement = 1000
    
    # Irrigation type efficiency and frequency
    irrigation_specs = {
        'rainfed': {'frequency': 0, 'efficiency': 0, 'cost_per_liter': 0},
        'drip': {'frequency': 3, 'efficiency': 0.9, 'cost_per_liter': 0.05},
        'sprinkler': {'frequency': 2, 'efficiency': 0.8, 'cost_per_liter': 0.08},
        'flood': {'frequency': 1, 'efficiency': 0.6, 'cost_per_liter': 0.03},
        'furrow': {'frequency': 2, 'efficiency': 0.7, 'cost_per_liter': 0.04},
        'basin': {'frequency': 1, 'efficiency': 0.65, 'cost_per_liter': 0.035}
    }
    
    specs = irrigation_specs.get(irrigation_type, irrigation_specs['drip'])
    
    water_per_irrigation = round(base_water_requirement * land_size)
    weekly_water = round(water_per_irrigation * specs['frequency'])
    monthly_water = round(weekly_water * 4)
    yearly_water = round(monthly_water * 12)
    
    # Calculate costs
    cost_per_irrigation = round(water_per_irrigation * specs['cost_per_liter'])
    monthly_cost = round(monthly_water * specs['cost_per_liter'])
    
    return {
        "irrigation_type": irrigation_type,
        "water_per_irrigation": water_per_irrigation,
        "frequency_per_week": specs['frequency'],
        "weekly_water": weekly_water,
        "monthly_water": monthly_water,
        "yearly_water": yearly_water,
        "efficiency": specs['efficiency'],
        "cost_per_irrigation": cost_per_irrigation,
        "monthly_cost": monthly_cost,
        "recommendations": get_irrigation_recommendations(irrigation_type)
    }

def calculate_cost_estimates(land_size, fertilizers, pesticides, irrigation):
    """Calculate total cost estimates"""
    fertilizer_cost = sum(f['cost'] for f in fertilizers.values())
    pesticide_cost = sum(p['cost'] for p in pesticides.values())
    irrigation_cost = irrigation['monthly_cost']
    
    total_cost = fertilizer_cost + pesticide_cost + irrigation_cost
    cost_per_acre = round(total_cost / land_size) if land_size > 0 else 0
    
    return {
        "fertilizer_cost": fertilizer_cost,
        "pesticide_cost": pesticide_cost,
        "irrigation_cost": irrigation_cost,
        "total_cost": total_cost,
        "cost_per_acre": cost_per_acre,
        "breakdown": {
            "fertilizer_percentage": round((fertilizer_cost / total_cost) * 100) if total_cost > 0 else 0,
            "pesticide_percentage": round((pesticide_cost / total_cost) * 100) if total_cost > 0 else 0,
            "irrigation_percentage": round((irrigation_cost / total_cost) * 100) if total_cost > 0 else 0
        }
    }

# Helper functions for costs and applications
def get_fertilizer_cost(fertilizer):
    costs = {
        'urea': 25, 'dap': 30, 'mop': 20, 'fym': 2, 'compost': 5, 'vermicompost': 15
    }
    return costs.get(fertilizer, 10)

def get_pesticide_cost(pesticide):
    costs = {
        'insecticide': 0.5, 'fungicide': 0.8, 'herbicide': 0.3, 
        'bio_pesticide': 0.2, 'neem_oil': 0.4, 'bt_spray': 0.3
    }
    return costs.get(pesticide, 0.5)

def get_fertilizer_application(fertilizer):
    applications = {
        'urea': 'Split application: 50% basal, 25% at tillering, 25% at panicle initiation',
        'dap': 'Basal application during land preparation',
        'mop': 'Basal application or split with nitrogen',
        'fym': 'Spread evenly and incorporate into soil 15-20 days before sowing',
        'compost': 'Mix with soil during land preparation',
        'vermicompost': 'Apply around plant base and mix lightly with soil'
    }
    return applications.get(fertilizer, 'Follow manufacturer instructions')

def get_fertilizer_timing(fertilizer):
    timings = {
        'urea': 'Basal: 0-7 days, Top dressing: 25-30 days and 45-50 days',
        'dap': 'Basal application during land preparation',
        'mop': 'Basal application or split application',
        'fym': '15-20 days before sowing',
        'compost': 'During land preparation',
        'vermicompost': 'At planting and during growth stages'
    }
    return timings.get(fertilizer, 'As per crop requirements')

def get_pesticide_application(pesticide):
    applications = {
        'insecticide': 'Spray during early morning or evening, avoid flowering period',
        'fungicide': 'Preventive spray before disease onset, repeat as needed',
        'herbicide': 'Apply to moist soil, avoid contact with crop',
        'bio_pesticide': 'Apply during cooler hours, mix with water as per instructions',
        'neem_oil': 'Dilute with water and spray, effective against sucking pests',
        'bt_spray': 'Apply during evening hours, effective against caterpillars'
    }
    return applications.get(pesticide, 'Follow manufacturer instructions')

def get_pesticide_frequency(pesticide):
    frequencies = {
        'insecticide': 'As needed, typically every 10-15 days',
        'fungicide': 'Preventive: every 7-10 days, Curative: every 5 days',
        'herbicide': 'Pre-emergence or post-emergence as per weed pressure',
        'bio_pesticide': 'Every 7-10 days during pest season',
        'neem_oil': 'Every 5-7 days during pest outbreak',
        'bt_spray': 'Every 7-10 days during caterpillar season'
    }
    return frequencies.get(pesticide, 'As per pest pressure')

def get_irrigation_recommendations(irrigation_type):
    recommendations = {
        'rainfed': 'Monitor rainfall patterns and supplement with irrigation during dry spells',
        'drip': 'Most efficient for water conservation, ideal for row crops',
        'sprinkler': 'Good for uniform coverage, suitable for most crops',
        'flood': 'Traditional method, use sparingly to conserve water',
        'furrow': 'Good for row crops, more efficient than flood irrigation',
        'basin': 'Suitable for tree crops and vegetables'
    }
    return recommendations.get(irrigation_type, 'Choose based on crop and water availability')

@app.route("/api/crops/<int:crop_id>/fertilizers", methods=["GET"])
def get_crop_fertilizers(crop_id):
    """Get fertilizers for a specific crop"""
    fertilizers = Fertilizer.query.filter_by(crop_id=crop_id).all()
    return jsonify([{
        "id": f.id,
        "week": f.week,
        "name": f.name,
        "quantity": f.quantity,
        "price": f.price,
        "gap_days": f.gap_days
    } for f in fertilizers])

@app.route("/api/crops/<int:crop_id>/pesticides", methods=["GET"])
def get_crop_pesticides(crop_id):
    """Get pesticides for a specific crop"""
    pesticides = Pesticide.query.filter_by(crop_id=crop_id).all()
    return jsonify([{
        "id": p.id,
        "week": p.week,
        "name": p.name,
        "application": p.application,
        "quantity": p.quantity,
        "price": p.price
    } for p in pesticides])

@app.route("/api/crops/<int:crop_id>/weekly-tasks", methods=["GET"])
def get_crop_weekly_tasks(crop_id):
    """Get detailed weekly tasks for a specific crop"""
    week = request.args.get('week', type=int)
    
    query = WeeklyTask.query.filter_by(crop_id=crop_id)
    if week:
        query = query.filter_by(week_number=week)
    
    tasks = query.order_by(WeeklyTask.week_number, WeeklyTask.priority).all()
    
    return jsonify([{
        "id": t.id,
        "week_number": t.week_number,
        "task_title": t.task_title,
        "task_description": t.task_description,
        "task_type": t.task_type,
        "priority": t.priority,
        "estimated_duration": t.estimated_duration,
        "equipment_needed": t.equipment_needed,
        "materials_needed": t.materials_needed,
        "video_url": t.video_url,
        "image_url": t.image_url,
        "step_by_step_instructions": t.step_by_step_instructions,
        "tips_and_notes": t.tips_and_notes,
        "weather_conditions": t.weather_conditions,
        "safety_precautions": t.safety_precautions,
        "expected_outcome": t.expected_outcome
    } for t in tasks])

@app.route("/api/crops/<int:crop_id>/total-weeks", methods=["GET"])
def get_crop_total_weeks(crop_id):
    """Return dynamic total weeks for a crop using weekly_tasks then crop_stages."""
    try:
        # Prefer detailed weekly tasks
        max_weekly = db.session.query(db.func.max(WeeklyTask.week_number))\
            .filter(WeeklyTask.crop_id == crop_id).scalar()
        # Fallback to stage end weeks
        max_stage = db.session.query(db.func.max(CropStage.end_week))\
            .filter(CropStage.crop_id == crop_id).scalar()
        total = max(filter(None, [max_weekly, max_stage])) if any([max_weekly, max_stage]) else 12
        return jsonify({"crop_id": crop_id, "total_weeks": int(total)})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/crops/<int:crop_id>/active-weeks", methods=["GET"])
def get_crop_active_weeks(crop_id):
    """Return only the weeks that have activity (weekly tasks) for a crop."""
    try:
        weeks = db.session.query(WeeklyTask.week_number) \
            .filter(WeeklyTask.crop_id == crop_id, WeeklyTask.week_number.isnot(None)) \
            .distinct() \
            .order_by(WeeklyTask.week_number) \
            .all()
        return jsonify([w[0] for w in weeks])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/crops/<int:crop_id>/videos", methods=["GET"])
def get_crop_videos(crop_id):
    """Get videos for a specific crop"""
    week = request.args.get('week', type=int)
    video_type = request.args.get('type')
    featured_only = request.args.get('featured', 'false').lower() == 'true'
    
    query = CropVideo.query.filter_by(crop_id=crop_id)
    if week:
        query = query.filter_by(week_number=week)
    if video_type:
        query = query.filter_by(video_type=video_type)
    if featured_only:
        query = query.filter_by(is_featured=True)
    
    videos = query.order_by(CropVideo.week_number, CropVideo.created_at).all()
    
    return jsonify([{
        "id": v.id,
        "week_number": v.week_number,
        "video_title": v.video_title,
        "video_url": v.video_url,
        "video_type": v.video_type,
        "duration_minutes": v.duration_minutes,
        "description": v.description,
        "thumbnail_url": v.thumbnail_url or _derive_youtube_thumbnail(v.video_url),
        "is_featured": v.is_featured,
        "created_at": v.created_at.isoformat() if v.created_at else None
    } for v in videos])

@app.route('/api/crops/<int:crop_id>/video-folders', methods=['GET'])
def get_video_folders(crop_id):
    """Return folder-like grouping: Common Process Videos vs Crop-Specific Videos."""
    # Common process videos by process_category
    process_groups = {}
    for pv in ProcessVideo.query.order_by(ProcessVideo.is_featured.desc(), ProcessVideo.created_at.desc()).all():
        key = pv.process_category
        process_groups.setdefault(key, []).append({
            "video_title": pv.video_title,
            "video_url": pv.video_url,
            "duration_minutes": pv.duration_minutes,
            "description": pv.description,
            "thumbnail_url": pv.thumbnail_url or _derive_youtube_thumbnail(pv.video_url),
            "is_featured": pv.is_featured,
            "process_type": pv.process_type
        })

    # Crop-specific videos by video_type (e.g., tutorial, harvesting, troubleshooting, safety)
    crop_groups = {}
    for v in CropVideo.query.filter_by(crop_id=crop_id).order_by(CropVideo.week_number.nulls_last(), CropVideo.is_featured.desc()).all():
        key = v.video_type or 'general'
        crop_groups.setdefault(key, []).append({
            "id": v.id,
            "week_number": v.week_number,
            "video_title": v.video_title,
            "video_url": v.video_url,
            "duration_minutes": v.duration_minutes,
            "description": v.description,
            "thumbnail_url": v.thumbnail_url or _derive_youtube_thumbnail(v.video_url),
            "is_featured": v.is_featured
        })

    # Build folder structure
    folders = [
        {
            "folder_key": "common",
            "folder_title": "Common Process Videos",
            "sections": [{
                "section_key": k,
                "section_title": k.replace('_', ' ').title(),
                "videos": vids
            } for k, vids in process_groups.items()]
        },
        {
            "folder_key": "crop_specific",
            "folder_title": "Crop-Specific Videos",
            "sections": [{
                "section_key": k,
                "section_title": k.title(),
                "videos": vids
            } for k, vids in crop_groups.items()]
        }
    ]

    return jsonify({"crop_id": crop_id, "folders": folders})

@app.route('/api/crops/<int:crop_id>/playlists', methods=['GET'])
def list_crop_playlists(crop_id):
    """List playlists (folders) for a crop."""
    items = CropPlaylist.query.filter_by(crop_id=crop_id).order_by(CropPlaylist.is_featured.desc(), CropPlaylist.created_at.desc()).all()
    return jsonify([{
        "id": p.id,
        "title": p.title,
        "description": p.description,
        "cover_image_url": p.cover_image_url,
        "is_featured": p.is_featured,
        "created_at": p.created_at.isoformat() if p.created_at else None
    } for p in items])

@app.route('/api/playlists/<int:playlist_id>/videos', methods=['GET'])
def get_playlist_videos(playlist_id):
    """Get ordered videos inside a playlist."""
    q = db.session.query(CropPlaylistItem, CropVideo).join(CropVideo, CropPlaylistItem.video_id == CropVideo.id).filter(CropPlaylistItem.playlist_id == playlist_id).order_by(CropPlaylistItem.position, CropPlaylistItem.added_at)
    result = []
    for item, v in q.all():
        result.append({
            "id": v.id,
            "week_number": v.week_number,
            "video_title": v.video_title,
            "video_url": v.video_url,
            "video_type": v.video_type,
            "duration_minutes": v.duration_minutes,
            "description": v.description,
            "thumbnail_url": v.thumbnail_url or _derive_youtube_thumbnail(v.video_url),
            "is_featured": v.is_featured,
            "position": item.position
        })
    return jsonify(result)

# ===== Process Videos (common across crops) =====
@app.route('/api/process-videos', methods=['GET'])
def list_process_videos():
    category = request.args.get('category')
    proc_type = request.args.get('type')
    query = ProcessVideo.query
    if category:
        query = query.filter_by(process_category=category)
    if proc_type:
        query = query.filter_by(process_type=proc_type)
    items = query.order_by(ProcessVideo.created_at.desc()).all()
    return jsonify([{
        "id": v.id,
        "process_category": v.process_category,
        "process_type": v.process_type,
        "video_title": v.video_title,
        "video_url": v.video_url,
        "duration_minutes": v.duration_minutes,
        "description": v.description,
        "thumbnail_url": v.thumbnail_url or _derive_youtube_thumbnail(v.video_url),
        "is_featured": v.is_featured,
        "created_at": v.created_at.isoformat()
    } for v in items])

@app.route('/api/admin/process-videos', methods=['GET'])
@admin_required
def admin_list_process_videos():
    items = ProcessVideo.query.order_by(ProcessVideo.created_at.desc()).all()
    return jsonify([{
        "id": v.id,
        "process_category": v.process_category,
        "process_type": v.process_type,
        "video_title": v.video_title,
        "video_url": v.video_url,
        "duration_minutes": v.duration_minutes,
        "description": v.description,
        "thumbnail_url": v.thumbnail_url or _derive_youtube_thumbnail(v.video_url),
        "is_featured": v.is_featured,
        "created_at": v.created_at.isoformat()
    } for v in items])

@app.route('/api/admin/process-videos', methods=['POST'])
@admin_required
def admin_create_process_video():
    data = request.get_json(force=True)
    item = ProcessVideo(
        process_category=data.get('process_category'),
        process_type=data.get('process_type'),
        video_title=data.get('video_title'),
        video_url=data.get('video_url'),
        duration_minutes=data.get('duration_minutes'),
        description=data.get('description'),
        thumbnail_url=data.get('thumbnail_url'),
        is_featured=bool(data.get('is_featured'))
    )
    db.session.add(item)
    db.session.commit()
    return jsonify({"success": True, "id": item.id})

@app.route('/api/admin/process-videos/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_process_video(item_id):
    item = ProcessVideo.query.get_or_404(item_id)
    data = request.get_json(force=True)
    for field in ['process_category','process_type','video_title','video_url','duration_minutes','description','thumbnail_url','is_featured']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/process-videos/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_process_video(item_id):
    item = ProcessVideo.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

@app.route("/api/crops/<int:crop_id>/weekly-guidance/<int:week>", methods=["GET"])
def get_weekly_guidance(crop_id, week):
    """Get comprehensive weekly guidance for a specific crop and week"""
    # Get crop basic info
    crop = Crop.query.get_or_404(crop_id)
    
    # Get weekly tasks for this week
    tasks = WeeklyTask.query.filter_by(crop_id=crop_id, week_number=week).all()
    
    # Get videos for this week
    videos = CropVideo.query.filter_by(crop_id=crop_id, week_number=week).all()
    
    # Get crop stages that cover this week
    stages = CropStage.query.filter(
        CropStage.crop_id == crop_id,
        CropStage.start_week <= week,
        CropStage.end_week >= week
    ).all()
    
    # Get fertilizers and pesticides for this week
    fertilizers = Fertilizer.query.filter_by(crop_id=crop_id).all()
    pesticides = Pesticide.query.filter_by(crop_id=crop_id).all()
    
    # Filter by week
    week_fertilizers = [f for f in fertilizers if f.week and f"Week {week}" in f.week]
    week_pesticides = [p for p in pesticides if p.week and f"Week {week}" in p.week]
    
    # Compute dynamic total weeks for UI convenience
    max_weekly = db.session.query(db.func.max(WeeklyTask.week_number))\
        .filter(WeeklyTask.crop_id == crop_id).scalar()
    max_stage = db.session.query(db.func.max(CropStage.end_week))\
        .filter(CropStage.crop_id == crop_id).scalar()
    dynamic_total_weeks = max(filter(None, [max_weekly, max_stage])) if any([max_weekly, max_stage]) else 12

    return jsonify({
        "crop": {
            "id": crop.id,
            "name": crop.name,
            "season": crop.season,
            "crop_category": crop.crop_category
        },
        "week_number": week,
        "stages": [{
            "id": s.id,
            "stage_number": s.stage_number,
            "title": s.title,
            "start_week": s.start_week,
            "end_week": s.end_week,
            "tasks": s.tasks,
            "video_url": s.video_url,
            "detailed_description": s.detailed_description,
            "equipment_needed": s.equipment_needed,
            "time_required": s.time_required,
            "difficulty_level": s.difficulty_level
        } for s in stages],
        "weekly_tasks": [{
            "id": t.id,
            "task_title": t.task_title,
            "task_description": t.task_description,
            "task_type": t.task_type,
            "priority": t.priority,
            "estimated_duration": t.estimated_duration,
            "equipment_needed": t.equipment_needed,
            "materials_needed": t.materials_needed,
            "video_url": t.video_url,
            "image_url": t.image_url,
            "step_by_step_instructions": t.step_by_step_instructions,
            "tips_and_notes": t.tips_and_notes,
            "weather_conditions": t.weather_conditions,
            "safety_precautions": t.safety_precautions,
            "expected_outcome": t.expected_outcome
        } for t in tasks],
        "videos": [{
            "id": v.id,
            "video_title": v.video_title,
            "video_url": v.video_url,
            "video_type": v.video_type,
            "duration_minutes": v.duration_minutes,
            "description": v.description,
            "thumbnail_url": v.thumbnail_url or _derive_youtube_thumbnail(v.video_url),
            "is_featured": v.is_featured
        } for v in videos],
        "fertilizers": [{
            "id": f.id,
            "week": f.week,
            "name": f.name,
            "quantity": f.quantity,
            "price": f.price,
            "gap_days": f.gap_days
        } for f in week_fertilizers],
        "pesticides": [{
            "id": p.id,
            "week": p.week,
            "name": p.name,
            "application": p.application,
            "quantity": p.quantity,
            "price": p.price
        } for p in week_pesticides],
        "total_weeks": int(dynamic_total_weeks)
    })

@app.route("/api/crop-progress/<int:session_id>/week/<int:week>", methods=["GET"])
def get_week_progress(session_id, week):
    """Get progress tracking for a specific session and week"""
    if 'user_id' not in session:
        return jsonify({"error": "User not logged in"}), 401
    
    # Verify session belongs to user
    crop_session = CropMonitoringSession.query.filter_by(
        id=session_id, 
        user_id=session['user_id']
    ).first()
    
    if not crop_session:
        return jsonify({"error": "Session not found"}), 404
    
    # Get progress tracking for this week
    progress_records = CropProgressTracking.query.filter_by(
        session_id=session_id,
        week_number=week
    ).all()
    
    # Get weekly tasks for this crop and week
    tasks = WeeklyTask.query.filter_by(
        crop_id=crop_session.crop_id,
        week_number=week
    ).all()
    
    return jsonify({
        "session_id": session_id,
        "week_number": week,
        "crop_name": crop_session.crop_name,
        "tasks": [{
            "task_id": t.id,
            "task_title": t.task_title,
            "task_description": t.task_description,
            "task_type": t.task_type,
            "priority": t.priority,
            "estimated_duration": t.estimated_duration,
            "video_url": t.video_url,
            "step_by_step_instructions": t.step_by_step_instructions,
            "progress": next((p for p in progress_records if p.task_id == t.id), None)
        } for t in tasks],
        "progress_summary": {
            "total_tasks": len(tasks),
            "completed_tasks": len([p for p in progress_records if p.completion_status == 'completed']),
            "in_progress_tasks": len([p for p in progress_records if p.completion_status == 'in_progress']),
            "not_started_tasks": len([p for p in progress_records if p.completion_status == 'not_started'])
        }
    })

@app.route("/api/crop-progress/<int:session_id>/task/<int:task_id>", methods=["POST"])
def update_task_progress(session_id, task_id):
    """Update progress for a specific task"""
    if 'user_id' not in session:
        return jsonify({"error": "User not logged in"}), 401
    
    data = request.get_json() or {}
    completion_status = data.get('completion_status', 'not_started')
    notes = data.get('notes', '')
    photos_urls = data.get('photos_urls', '')
    rating = data.get('rating')
    feedback = data.get('feedback', '')
    
    # Verify session belongs to user
    crop_session = CropMonitoringSession.query.filter_by(
        id=session_id, 
        user_id=session['user_id']
    ).first()
    
    if not crop_session:
        log_audit("task_progress_update_attempt", "task_progress", details={
            "session_id": session_id,
            "task_id": task_id,
            "error": "Session not found"
        }, status="failure")
        return jsonify({"error": "Session not found"}), 404
    
    # Get the task
    task = WeeklyTask.query.get_or_404(task_id)
    
    # Check if progress record exists
    progress_record = CropProgressTracking.query.filter_by(
        session_id=session_id,
        task_id=task_id
    ).first()
    
    try:
        if not progress_record:
            # Create new progress record
            progress_record = CropProgressTracking(
                session_id=session_id,
                week_number=task.week_number,
                task_id=task_id,
                completion_status=completion_status,
                notes=notes,
                photos_urls=photos_urls,
                rating=rating,
                feedback=feedback
            )
            if completion_status == 'completed':
                progress_record.completion_date = datetime.now()
            db.session.add(progress_record)
            log_audit("task_progress_created", "task_progress", task_id, {
                "session_id": session_id,
                "task_title": task.task_title,
                "status": completion_status,
                "week_number": task.week_number
            })
        else:
            # Update existing record
            old_status = progress_record.completion_status
            progress_record.completion_status = completion_status
            progress_record.notes = notes
            progress_record.photos_urls = photos_urls
            progress_record.rating = rating
            progress_record.feedback = feedback
            if completion_status == 'completed' and not progress_record.completion_date:
                progress_record.completion_date = datetime.now()
            elif completion_status != 'completed':
                progress_record.completion_date = None
                
            log_audit("task_progress_updated", "task_progress", task_id, {
                "session_id": session_id,
                "task_title": task.task_title,
                "old_status": old_status,
                "new_status": completion_status,
                "week_number": task.week_number
            })
        
        db.session.commit()
        return jsonify({
            "success": True,
            "message": "Progress updated successfully",
            "progress": {
                "task_id": task_id,
                "completion_status": completion_status,
                "completion_date": progress_record.completion_date.isoformat() if progress_record.completion_date else None,
                "notes": notes,
                "rating": rating
            }
        })
    except Exception as e:
        db.session.rollback()
        log_audit("task_progress_update_attempt", "task_progress", task_id, {
            "session_id": session_id,
            "task_title": task.task_title,
            "error": str(e)
        }, status="error")
        return jsonify({"error": str(e)}), 500

@app.route("/api/start-crop-monitoring", methods=["POST"])
def start_crop_monitoring():
    """Start monitoring a crop for a logged-in user"""
    if 'user_id' not in session:
        return jsonify({"error": "User not logged in"}), 401
    
    data = request.get_json() or {}
    crop_id = data.get('crop_id')
    crop_name = data.get('crop_name')
    land_size = data.get('land_size')
    soil_type = data.get('soil_type')
    start_date = data.get('start_date')
    
    # land_size is optional; require the rest
    required_map = {
        'crop_id': crop_id,
        'crop_name': crop_name,
        'soil_type': soil_type,
        'start_date': start_date
    }
    missing_fields = [k for k, v in required_map.items() if v in (None, '')]
    if missing_fields:
        log_audit("crop_monitoring_start_attempt", "crop_monitoring", details={
            "crop_id": crop_id,
            "missing_fields": missing_fields
        }, status="failure")
        return jsonify({"error": "Missing required fields", "missing": missing_fields}), 400
    
    try:
        # Normalize optional land_size (treat empty string as None)
        if land_size in (None, ""):
            parsed_land_size = None
        else:
            try:
                parsed_land_size = float(land_size)
            except (ValueError, TypeError):
                log_audit("crop_monitoring_start_attempt", "crop_monitoring", details={
                    "crop_id": crop_id,
                    "error": "Invalid land size"
                }, status="failure")
                return jsonify({"error": "Invalid land size"}), 400

        # Create a new crop monitoring session in database
        monitoring_session = CropMonitoringSession(
            user_id=session['user_id'],
            crop_id=crop_id,
            crop_name=crop_name,
            land_size=parsed_land_size,
            soil_type=soil_type,
            start_date=datetime.fromisoformat(start_date.replace('Z', '+00:00'))
        )
        
        db.session.add(monitoring_session)
        db.session.commit()
        
        log_audit("crop_monitoring_start", "crop_monitoring", monitoring_session.id, {
            "crop_id": crop_id,
            "crop_name": crop_name,
            "land_size": parsed_land_size,
            "soil_type": soil_type
        })
        
        return jsonify({
            "message": "Crop monitoring started successfully",
            "session_id": monitoring_session.id
        })
        
    except Exception as e:
        db.session.rollback()
        log_audit("crop_monitoring_start_attempt", "crop_monitoring", details={
            "crop_id": crop_id,
            "error": str(e)
        }, status="error")
        return jsonify({"error": str(e)}), 500

@app.route("/api/active-crops", methods=["GET"])
def get_active_crops():
    """Get all active crop monitoring sessions for the logged-in user"""
    if 'user_id' not in session:
        return jsonify({"error": "User not logged in"}), 401
    
    try:
        sessions = CropMonitoringSession.query.filter_by(user_id=session['user_id']).all()
        active_crops = []
        
        for session_obj in sessions:
            # Get completed tasks for this session
            completed_tasks = TaskCompletion.query.filter_by(session_id=session_obj.id).all()
            # Compute dynamic total weeks (prefer weekly_tasks, then stages, else session value or 12)
            max_weekly = db.session.query(db.func.max(WeeklyTask.week_number))\
                .filter(WeeklyTask.crop_id == session_obj.crop_id).scalar()
            max_stage = db.session.query(db.func.max(CropStage.end_week))\
                .filter(CropStage.crop_id == session_obj.crop_id).scalar()
            dynamic_total_weeks = max(filter(None, [max_weekly, max_stage])) if any([max_weekly, max_stage]) else (session_obj.total_weeks or 12)
            
            active_crops.append({
                "id": session_obj.id,
                "crop_id": session_obj.crop_id,
                "crop_name": session_obj.crop_name,
                "land_size": session_obj.land_size,
                "soil_type": session_obj.soil_type,
                "start_date": session_obj.start_date.isoformat(),
                "current_week": session_obj.current_week,
                "status": session_obj.status,
                "total_weeks": int(dynamic_total_weeks),
                "completed_tasks": [{
                    "id": task.id,
                    "task_name": task.task_name,
                    "task_type": task.task_type,
                    "week_number": task.week_number,
                    "completed_at": task.completed_at.isoformat(),
                    "notes": task.notes
                } for task in completed_tasks]
            })
        
        return jsonify({"active_crops": active_crops})
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/crop-progress/<int:session_id>", methods=["POST"])
def update_crop_progress(session_id):
    """Update progress for a specific crop monitoring session"""
    if 'user_id' not in session:
        return jsonify({"error": "User not logged in"}), 401
    
    data = request.get_json() or {}
    task_id = data.get('task_id')
    task_name = data.get('task_name', '')
    task_type = data.get('task_type', 'other')
    week_number = data.get('week_number', 1)
    completed = data.get('completed', False)
    
    try:
        # Check if session belongs to user
        crop_session = CropMonitoringSession.query.filter_by(
            id=session_id, 
            user_id=session['user_id']
        ).first()
        
        if not crop_session:
            return jsonify({"error": "Crop session not found"}), 404
        
        if completed:
            # Add task completion
            task_completion = TaskCompletion(
                session_id=session_id,
                task_type=task_type,
                task_name=task_name,
                week_number=week_number
            )
            db.session.add(task_completion)
        else:
            # Remove task completion
            TaskCompletion.query.filter_by(
                session_id=session_id,
                task_name=task_name,
                week_number=week_number
            ).delete()
        
        db.session.commit()
        
        # Get updated completed tasks
        completed_tasks = TaskCompletion.query.filter_by(session_id=session_id).all()
        
        return jsonify({
            "message": "Progress updated successfully",
            "completed_tasks": [{
                "id": task.id,
                "task_name": task.task_name,
                "task_type": task.task_type,
                "week_number": task.week_number,
                "completed_at": task.completed_at.isoformat()
            } for task in completed_tasks]
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

# ================= Enhanced Crop Guidance APIs =================

@app.route("/api/crops/<int:crop_id>/tips", methods=["GET"])
def get_crop_tips(crop_id):
    """Get growing tips for a specific crop"""
    week = request.args.get('week', type=int)
    category = request.args.get('category')
    featured_only = request.args.get('featured', 'false').lower() == 'true'
    
    query = db.session.query(CropTip).filter_by(crop_id=crop_id)
    if week:
        query = query.filter_by(week_number=week)
    if category:
        query = query.filter_by(tip_category=category)
    if featured_only:
        query = query.filter_by(is_featured=True)
    
    tips = query.order_by(CropTip.week_number, CropTip.created_at).all()
    
    return jsonify([{
        "id": t.id,
        "week_number": t.week_number,
        "tip_category": t.tip_category,
        "tip_title": t.tip_title,
        "tip_description": t.tip_description,
        "tip_image_url": t.tip_image_url,
        "is_featured": t.is_featured,
        "created_at": t.created_at.isoformat() if t.created_at else None
    } for t in tips])

@app.route("/api/crops/<int:crop_id>/weather-recommendations", methods=["GET"])
def get_weather_recommendations(crop_id):
    """Get weather-based recommendations for a specific crop"""
    week = request.args.get('week', type=int)
    weather_condition = request.args.get('weather')
    
    query = db.session.query(WeatherRecommendation).filter_by(crop_id=crop_id)
    if week:
        query = query.filter_by(week_number=week)
    if weather_condition:
        query = query.filter_by(weather_condition=weather_condition)
    
    recommendations = query.order_by(WeatherRecommendation.priority.desc(), WeatherRecommendation.week_number).all()
    
    return jsonify([{
        "id": r.id,
        "week_number": r.week_number,
        "weather_condition": r.weather_condition,
        "recommendation": r.recommendation,
        "priority": r.priority,
        "created_at": r.created_at.isoformat() if r.created_at else None
    } for r in recommendations])

@app.route("/api/crops/<int:crop_id>/task-dependencies", methods=["GET"])
def get_task_dependencies(crop_id):
    """Get task dependencies for a specific crop"""
    week = request.args.get('week', type=int)
    
    # Get tasks for the crop
    tasks_query = WeeklyTask.query.filter_by(crop_id=crop_id)
    if week:
        tasks_query = tasks_query.filter_by(week_number=week)
    
    tasks = tasks_query.all()
    task_ids = [t.id for t in tasks]
    
    if not task_ids:
        return jsonify([])
    
    # Get dependencies for these tasks
    dependencies = db.session.query(TaskDependency).filter(
        TaskDependency.task_id.in_(task_ids)
    ).all()
    
    return jsonify([{
        "id": d.id,
        "task_id": d.task_id,
        "depends_on_task_id": d.depends_on_task_id,
        "dependency_type": d.dependency_type,
        "created_at": d.created_at.isoformat() if d.created_at else None
    } for d in dependencies])

@app.route("/api/crops/<int:crop_id>/comprehensive-guidance/<int:week>", methods=["GET"])
def get_comprehensive_guidance(crop_id, week):
    """Get comprehensive guidance including tips, weather recommendations, and dependencies"""
    # Get basic weekly guidance
    basic_guidance = get_weekly_guidance(crop_id, week)
    guidance_data = basic_guidance.get_json()
    
    # Get additional tips
    tips_response = get_crop_tips(crop_id)
    tips_data = tips_response.get_json()
    
    # Get weather recommendations
    weather_response = get_weather_recommendations(crop_id)
    weather_data = weather_response.get_json()
    
    # Get task dependencies
    dependencies_response = get_task_dependencies(crop_id)
    dependencies_data = dependencies_response.get_json()
    
    # Combine all data
    comprehensive_data = {
        **guidance_data,
        "tips": tips_data,
        "weather_recommendations": weather_data,
        "task_dependencies": dependencies_data
    }
    
    return jsonify(comprehensive_data)

# ================= Admin Monitoring APIs =================
@app.route("/api/admin/monitoring-sessions", methods=["GET"])
@auth_required
def get_all_monitoring_sessions():
    """Get all monitoring sessions for admin dashboard"""
    if not session.get('is_admin'):
        return jsonify({"error": "Admin access required"}), 403
    
    try:
        sessions = db.session.query(
            CropMonitoringSession,
            User.username
        ).join(User, CropMonitoringSession.user_id == User.id).all()
        
        monitoring_data = []
        for session_obj, username in sessions:
            monitoring_data.append({
                "id": session_obj.id,
                "user_id": session_obj.user_id,
                "username": username,
                "crop_id": session_obj.crop_id,
                "crop_name": session_obj.crop_name,
                "land_size": session_obj.land_size,
                "soil_type": session_obj.soil_type,
                "start_date": session_obj.start_date.isoformat(),
                "current_week": session_obj.current_week,
                "status": session_obj.status,
                "total_weeks": session_obj.total_weeks,
                "created_at": session_obj.created_at.isoformat(),
                "updated_at": session_obj.updated_at.isoformat()
            })
        
        return jsonify(monitoring_data)
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/admin/session-details/<int:session_id>", methods=["GET"])
@auth_required
def get_session_details(session_id):
    """Get detailed information about a specific monitoring session"""
    if not session.get('is_admin'):
        return jsonify({"error": "Admin access required"}), 403
    
    try:
        session_data = db.session.query(
            CropMonitoringSession,
            User.username
        ).join(User, CropMonitoringSession.user_id == User.id).filter(
            CropMonitoringSession.id == session_id
        ).first()
        
        if not session_data:
            return jsonify({"error": "Session not found"}), 404
        
        session_obj, username = session_data
        
        # Get completed tasks
        completed_tasks = TaskCompletion.query.filter_by(session_id=session_id).all()
        
        return jsonify({
            "id": session_obj.id,
            "user_id": session_obj.user_id,
            "username": username,
            "crop_id": session_obj.crop_id,
            "crop_name": session_obj.crop_name,
            "land_size": session_obj.land_size,
            "soil_type": session_obj.soil_type,
            "start_date": session_obj.start_date.isoformat(),
            "current_week": session_obj.current_week,
            "status": session_obj.status,
            "total_weeks": session_obj.total_weeks,
            "created_at": session_obj.created_at.isoformat(),
            "updated_at": session_obj.updated_at.isoformat(),
            "completed_tasks": [{
                "id": task.id,
                "task_name": task.task_name,
                "task_type": task.task_type,
                "week_number": task.week_number,
                "completed_at": task.completed_at.isoformat(),
                "notes": task.notes
            } for task in completed_tasks]
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ================= Plant Disease Detection =================
@app.route("/api/detect-disease", methods=["POST"])
def detect_disease():
    try:
        if _disease_model is None:
            return jsonify({"error": "Disease model not available on server. Place model file and restart."}), 503

        if "file" not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        file = request.files["file"]
        try:
            img = Image.open(file).convert("RGB")
        except Exception:
            return jsonify({"error": "Invalid image file"}), 400

        # Preprocess image (matching training)
        img_tensor = _disease_transform(img).unsqueeze(0).to(DISEASE_DEVICE)

        with torch.no_grad():
            outputs = _disease_model(img_tensor)
            predicted_idx = int(np.argmax(outputs.detach().cpu().numpy()))
            disease = IDX_TO_CLASSES.get(predicted_idx, "Unknown")

        # Disease advice
        disease_info = {
            "Apple___Apple_scab": "Remove infected leaves and apply fungicides. Maintain good air circulation.",
            "Apple___Black_rot": "Prune infected branches and apply copper-based fungicides.",
            "Apple___Cedar_apple_rust": "Remove nearby cedar trees and apply fungicides during bloom.",
            "Apple___healthy": "Plant is healthy. Continue proper care and maintenance.",
            "Corn___Common_rust": "Use resistant hybrids and apply triazole fungicides.",
            "Corn___healthy": "Plant is healthy. Continue proper care and maintenance.",
            "Potato___Early_blight": "Rotate crops and apply chlorothalonil fungicides.",
            "Potato___Late_blight": "Avoid excess irrigation and apply metalaxyl + mancozeb.",
            "Potato___healthy": "Plant is healthy. Continue proper care and maintenance.",
            "Tomato___Bacterial_spot": "Use disease-free seeds and apply copper-based bactericides.",
            "Tomato___Early_blight": "Remove infected leaves and apply chlorothalonil fungicides.",
            "Tomato___Late_blight": "Improve air circulation and apply copper fungicides.",
            "Tomato___Leaf_Mold": "Improve ventilation and avoid overhead irrigation.",
            "Tomato___healthy": "Plant is healthy. Continue proper care and maintenance."
        }

        return jsonify({"prediction": disease, "advice": disease_info.get(disease, "Consult with a plant disease expert for specific treatment recommendations.")})

    except Exception as e:
        logging.error("Unexpected error: %s", str(e))
        return jsonify({"error": str(e)}), 500

# ================= Legacy Login API (disabled path) =================
@app.route('/api/_legacy_login', methods=['POST'])
def legacy_login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    print("Received username:", username)
    print("Received password:", password)
    user = User.query.filter_by(username=username).first()
    print("User from DB:", user)
    if user:
        print("Stored password:", user.password)
    if user:
        # Plaintext comparison only
        password_valid = (user.password == password)
        
        print("Password check:", password_valid)
        
        if password_valid:
            session['user_id'] = user.id
            session['username'] = user.username
            session['is_admin'] = is_admin_user(user.username)
            return jsonify({'success': True, 'message': 'Login successful', 'user_id': user.id, 'is_admin': bool(session['is_admin'])})
    
    return jsonify({'success': False, 'message': 'Invalid credentials'}), 401


# ================= Legacy Register API (disabled path) =================
@app.route('/api/_legacy_register', methods=['POST'])
def legacy_register():
    data = request.get_json()
    username = data.get('username', '').strip()
    password = data.get('password', '')

    if not username or not password:
        return jsonify({"success": False, "error": "Username and password required."}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({"success": False, "error": "Username already exists."}), 409

    user = User(username=username, password=password)
    db.session.add(user)
    db.session.commit()
    return jsonify({"success": True})

# ================= Legacy Session Info & Logout (disabled path) =================
@app.route('/api/_legacy_me', methods=['GET'])
def legacy_me():
    if not session.get('user_id'):
        return jsonify({"authenticated": False})
    return jsonify({
        "authenticated": True,
        "id": session.get('user_id'),
        "username": session.get('username'),
        "is_admin": bool(session.get('is_admin'))
    })

@app.route('/api/_legacy_logout', methods=['POST'])
def legacy_logout():
    session.clear()
    return jsonify({"success": True})

# ================= Protected DB Operations (CRUD for crops) =================
@app.route('/api/admin/crops', methods=['GET'])
@admin_required
def admin_list_crops():
    crops = Crop.query.all()
    return jsonify([
        {
            "id": c.id, 
            "name": c.name, 
            "season": c.season, 
            "ec": c.ec_range,
            "land_size_min": float(c.land_size_min) if c.land_size_min else None,
            "land_size_max": float(c.land_size_max) if c.land_size_max else None,
            "soil_types": c.soil_types,
            "crop_category": c.crop_category
        }
        for c in crops
    ])

@app.route('/api/admin/crops', methods=['POST'])
@admin_required
def admin_create_crop():
    data = request.get_json() or {}
    name = data.get('name', '').strip()
    season = data.get('season')
    ec = data.get('ec')
    land_size_min = data.get('land_size_min')
    land_size_max = data.get('land_size_max')
    soil_types = data.get('soil_types')
    crop_category = data.get('crop_category')
    
    if not name:
        log_audit("admin_create_crop_attempt", "crop", details={"error": "Name is required"}, status="failure")
        return jsonify({"success": False, "error": "Name is required"}), 400
    if Crop.query.filter_by(name=name).first():
        log_audit("admin_create_crop_attempt", "crop", details={"error": "Crop already exists", "name": name}, status="failure")
        return jsonify({"success": False, "error": "Crop already exists"}), 409
    
    try:
        crop = Crop(
            name=name, 
            season=season, 
            ec_range=ec,
            land_size_min=land_size_min,
            land_size_max=land_size_max,
            soil_types=soil_types,
            crop_category=crop_category
        )
        db.session.add(crop)
        db.session.commit()
        log_audit("admin_create_crop", "crop", crop.id, {
            "name": name,
            "season": season,
            "crop_category": crop_category
        })
        return jsonify({"success": True, "id": crop.id})
    except Exception as e:
        db.session.rollback()
        log_audit("admin_create_crop_attempt", "crop", details={
            "error": str(e), 
            "name": name
        }, status="error")
        raise

@app.route('/api/admin/crops/<int:crop_id>', methods=['PUT'])
@admin_required
def admin_update_crop(crop_id):
    try:
        crop = Crop.query.get_or_404(crop_id)
        data = request.get_json() or {}
        changes = {}
        
        if 'name' in data and data['name']:
            # Prevent duplicate names
            existing = Crop.query.filter(Crop.name == data['name'], Crop.id != crop_id).first()
            if existing:
                return jsonify({"success": False, "error": "Another crop with this name exists"}), 409
            crop.name = data['name']
            changes['name'] = data['name']
            
        for field in ['season', 'ec', 'land_size_min', 'land_size_max', 'soil_types', 'crop_category']:
            if field in data:
                setattr(crop, field, data[field])
                changes[field] = data[field]
        
        db.session.commit()
        log_audit("admin_update_crop", "crop", crop_id, changes)
        return jsonify({"success": True})
    except Exception as e:
        db.session.rollback()
        log_audit("admin_update_crop_attempt", "crop", crop_id, {
            "error": str(e),
            "changes": changes
        }, status="error")
        raise

@app.route('/api/admin/crops/<int:crop_id>', methods=['DELETE'])
@admin_required
def admin_delete_crop(crop_id):
    try:
        crop = Crop.query.get_or_404(crop_id)
        crop_info = {
            "name": crop.name,
            "category": crop.crop_category,
            "season": crop.season
        }
        db.session.delete(crop)
        db.session.commit()
        log_audit("admin_delete_crop", "crop", crop_id, crop_info)
        return jsonify({"success": True})
    except Exception as e:
        db.session.rollback()
        log_audit("admin_delete_crop_attempt", "crop", crop_id, {
            "error": str(e)
        }, status="error")
        raise

# ================= Admin: Fertilizers =================
@app.route('/api/admin/fertilizers', methods=['GET'])
@admin_required
def admin_list_fertilizers():
    items = Fertilizer.query.all()
    return jsonify([{ 
        "id": f.id,
        "crop_id": f.crop_id,
        "week": f.week,
        "name": f.name,
        "quantity": f.quantity,
        "price": f.price,
        "gap_days": f.gap_days
    } for f in items])

@app.route('/api/admin/fertilizers', methods=['POST'])
@admin_required
def admin_create_fertilizer():
    data = request.get_json() or {}
    try:
        item = Fertilizer(
            crop_id=data.get('crop_id'),
            week=data.get('week'),
            name=data.get('name'),
            quantity=data.get('quantity'),
            price=data.get('price'),
            gap_days=data.get('gap_days')
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"success": True, "id": item.id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/admin/fertilizers/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_fertilizer(item_id):
    item = Fertilizer.query.get_or_404(item_id)
    data = request.get_json() or {}
    for field in ['crop_id','week','name','quantity','price','gap_days']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/fertilizers/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_fertilizer(item_id):
    item = Fertilizer.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

# ================= Admin: Pesticides =================
@app.route('/api/admin/pesticides', methods=['GET'])
@admin_required
def admin_list_pesticides():
    items = Pesticide.query.all()
    return jsonify([{ 
        "id": p.id,
        "crop_id": p.crop_id,
        "week": p.week,
        "name": p.name,
        "application": p.application,
        "quantity": p.quantity,
        "price": p.price
    } for p in items])

@app.route('/api/admin/pesticides', methods=['POST'])
@admin_required
def admin_create_pesticide():
    data = request.get_json() or {}
    try:
        item = Pesticide(
            crop_id=data.get('crop_id'),
            week=data.get('week'),
            name=data.get('name'),
            application=data.get('application'),
            quantity=data.get('quantity'),
            price=data.get('price')
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"success": True, "id": item.id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/admin/pesticides/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_pesticide(item_id):
    item = Pesticide.query.get_or_404(item_id)
    data = request.get_json() or {}
    for field in ['crop_id','week','name','application','quantity','price']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/pesticides/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_pesticide(item_id):
    item = Pesticide.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

# ================= Admin: Crop Guides =================
@app.route('/api/admin/crop_guides', methods=['GET'])
@admin_required
def admin_list_crop_guides():
    items = CropGuide.query.all()
    return jsonify([{ 
        "id": g.id,
        "crop_id": g.crop_id,
        "overview": g.overview,
        "climate": g.climate,
        "soil": g.soil,
        "land_preparation": g.land_preparation,
        "sowing": g.sowing,
        "irrigation": g.irrigation,
        "nutrient_management": g.nutrient_management,
        "weed_management": g.weed_management,
        "pests_diseases": g.pests_diseases,
        "harvesting": g.harvesting,
        "yield_info": g.yield_info
    } for g in items])

@app.route('/api/admin/crop_guides', methods=['POST'])
@admin_required
def admin_create_crop_guide():
    data = request.get_json() or {}
    try:
        item = CropGuide(
            crop_id=data.get('crop_id'),
            overview=data.get('overview'),
            climate=data.get('climate'),
            soil=data.get('soil'),
            land_preparation=data.get('land_preparation'),
            sowing=data.get('sowing'),
            irrigation=data.get('irrigation'),
            nutrient_management=data.get('nutrient_management'),
            weed_management=data.get('weed_management'),
            pests_diseases=data.get('pests_diseases'),
            harvesting=data.get('harvesting'),
            yield_info=data.get('yield_info')
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"success": True, "id": item.id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/admin/crop_guides/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_crop_guide(item_id):
    item = CropGuide.query.get_or_404(item_id)
    data = request.get_json() or {}
    for field in ['crop_id','overview','climate','soil','land_preparation','sowing','irrigation','nutrient_management','weed_management','pests_diseases','harvesting','yield_info']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/crop_guides/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_crop_guide(item_id):
    item = CropGuide.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

# ================= Admin: Crop Stages =================
@app.route('/api/admin/crop_stages', methods=['GET'])
@admin_required
def admin_list_crop_stages():
    items = CropStage.query.all()
    return jsonify([{ 
        "id": s.id,
        "crop_id": s.crop_id,
        "stage_number": s.stage_number,
        "title": s.title,
        "start_week": s.start_week,
        "end_week": s.end_week,
        "tasks": s.tasks
    } for s in items])

@app.route('/api/admin/crop_stages', methods=['POST'])
@admin_required
def admin_create_crop_stage():
    data = request.get_json() or {}
    try:
        item = CropStage(
            crop_id=data.get('crop_id'),
            stage_number=data.get('stage_number'),
            title=data.get('title'),
            start_week=data.get('start_week'),
            end_week=data.get('end_week'),
            tasks=data.get('tasks')
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"success": True, "id": item.id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/admin/crop_stages/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_crop_stage(item_id):
    item = CropStage.query.get_or_404(item_id)
    data = request.get_json() or {}
    for field in ['crop_id','stage_number','title','start_week','end_week','tasks']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/crop_stages/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_crop_stage(item_id):
    item = CropStage.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

# ================= Admin: Users =================
@app.route('/api/admin/users', methods=['GET'])
@auth_required
def admin_list_users():
    if not session.get('is_admin'):
        return jsonify({"error": "Admin access required"}), 403
    users = User.query.order_by(User.id.asc()).all()
    return jsonify([
        {
            "id": u.id,
            "username": u.username,
        } for u in users
    ])


@app.route('/api/admin/set-password', methods=['POST'])
@auth_required
def admin_set_password():
    if not session.get('is_admin'):
        log_audit("admin_set_password_attempt", "user", details={"error": "Unauthorized access attempt"}, status="failure")
        return jsonify({"error": "Admin access required"}), 403
    data = request.get_json(force=True) or {}
    username = (data.get('username') or '').strip()
    new_password = data.get('password') or ''
    if not username or not new_password:
        log_audit("admin_set_password_attempt", "user", details={"error": "Missing fields", "username": username}, status="failure")
        return jsonify({"success": False, "error": "username and password required"}), 400
    
    try:
        user = User.query.filter_by(username=username).first()
        if not user:
            log_audit("admin_set_password_attempt", "user", details={"error": "User not found", "username": username}, status="failure")
            return jsonify({"success": False, "error": "user not found"}), 404
        user.password = new_password
        db.session.commit()
        log_audit("admin_set_password", "user", user.id, {"username": username})
        return jsonify({"success": True})
    except Exception as e:
        db.session.rollback()
        log_audit("admin_set_password_attempt", "user", user.id if user else None, {"username": username, "error": str(e)}, status="error")
        raise

@app.route('/api/admin/users', methods=['POST'])
@admin_required
def admin_create_user():
    data = request.get_json() or {}
    username = (data.get('username') or '').strip()
    password = data.get('password') or ''
    if not username or not password:
        return jsonify({"success": False, "error": "username and password required"}), 400
    if User.query.filter_by(username=username).first():
        return jsonify({"success": False, "error": "Username exists"}), 409
    user = User(username=username, password=password)
    db.session.add(user)
    db.session.commit()
    return jsonify({"success": True, "id": user.id})

@app.route('/api/admin/users/<int:user_id>', methods=['PUT'])
@admin_required
def admin_update_user(user_id):
    item = User.query.get_or_404(user_id)
    data = request.get_json() or {}
    for field in ['username','password']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/users/<int:user_id>', methods=['DELETE'])
@admin_required
def admin_delete_user(user_id):
    item = User.query.get_or_404(user_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/users/<int:user_id>', methods=['GET'])
@admin_required
def admin_get_user(user_id):
    """Return a single user record for admin UIs."""
    try:
        u = User.query.get_or_404(user_id)
        return jsonify({"id": u.id, "username": u.username})
    except Exception as e:
        app.logger.exception('Error fetching admin user %s', user_id)
        return jsonify({"success": False, "error": str(e)}), 400

# ================= Admin: Soil Types =================
@app.route('/api/admin/soil_types', methods=['GET'])
@admin_required
def admin_list_soil_types():
    items = SoilType.query.all()
    return jsonify([{ 
        "id": s.id,
        "name": s.name,
        "description": s.description,
        "ph_range": s.ph_range,
        "drainage": s.drainage,
        "water_retention": s.water_retention,
        "fertility_level": s.fertility_level,
        "suitable_crops": s.suitable_crops
    } for s in items])

@app.route('/api/admin/soil_types', methods=['POST'])
@admin_required
def admin_create_soil_type():
    data = request.get_json() or {}
    try:
        item = SoilType(
            name=data.get('name'),
            description=data.get('description'),
            ph_range=data.get('ph_range'),
            drainage=data.get('drainage'),
            water_retention=data.get('water_retention'),
            fertility_level=data.get('fertility_level'),
            suitable_crops=data.get('suitable_crops')
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"success": True, "id": item.id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/admin/soil_types/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_soil_type(item_id):
    item = SoilType.query.get_or_404(item_id)
    data = request.get_json() or {}
    for field in ['name','description','ph_range','drainage','water_retention','fertility_level','suitable_crops']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/soil_types/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_soil_type(item_id):
    item = SoilType.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

# ================= Admin: Crop Videos =================
@app.route('/api/admin/crop_videos', methods=['GET'])
@admin_required
def admin_list_crop_videos():
    items = CropVideo.query.all()
    return jsonify([{ 
        "id": v.id,
        "crop_id": v.crop_id,
        "week_number": v.week_number,
        "video_title": v.video_title,
        "video_url": v.video_url,
        "video_type": v.video_type,
        "duration_minutes": v.duration_minutes,
        "description": v.description,
        "thumbnail_url": v.thumbnail_url,
        "is_featured": v.is_featured,
        "created_at": v.created_at.isoformat() if v.created_at else None
    } for v in items])

@app.route('/api/admin/crop_videos', methods=['POST'])
@admin_required
def admin_create_crop_video():
    data = request.get_json() or {}
    try:
        item = CropVideo(
            crop_id=data.get('crop_id'),
            week_number=data.get('week_number'),
            video_title=data.get('video_title'),
            video_url=data.get('video_url'),
            video_type=data.get('video_type'),
            duration_minutes=data.get('duration_minutes'),
            description=data.get('description'),
            thumbnail_url=data.get('thumbnail_url'),
            is_featured=data.get('is_featured', False)
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"success": True, "id": item.id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/admin/crop_videos/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_crop_video(item_id):
    item = CropVideo.query.get_or_404(item_id)
    data = request.get_json() or {}
    for field in ['crop_id','week_number','video_title','video_url','video_type','duration_minutes','description','thumbnail_url','is_featured']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/crop_videos/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_crop_video(item_id):
    item = CropVideo.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

# ================= Admin: Crop Tips =================
@app.route('/api/admin/crop_tips', methods=['GET'])
@admin_required
def admin_list_crop_tips():
    items = CropTip.query.all()
    return jsonify([{ 
        "id": t.id,
        "crop_id": t.crop_id,
        "week_number": t.week_number,
        "tip_category": t.tip_category,
        "tip_title": t.tip_title,
        "tip_description": t.tip_description,
        "tip_image_url": t.tip_image_url,
        "is_featured": t.is_featured,
        "created_at": t.created_at.isoformat() if t.created_at else None
    } for t in items])

@app.route('/api/admin/crop_tips', methods=['POST'])
@admin_required
def admin_create_crop_tip():
    data = request.get_json() or {}
    try:
        item = CropTip(
            crop_id=data.get('crop_id'),
            week_number=data.get('week_number'),
            tip_category=data.get('tip_category'),
            tip_title=data.get('tip_title'),
            tip_description=data.get('tip_description'),
            tip_image_url=data.get('tip_image_url'),
            is_featured=data.get('is_featured', False)
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"success": True, "id": item.id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/admin/crop_tips/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_crop_tip(item_id):
    item = CropTip.query.get_or_404(item_id)
    data = request.get_json() or {}
    for field in ['crop_id','week_number','tip_category','tip_title','tip_description','tip_image_url','is_featured']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/crop_tips/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_crop_tip(item_id):
    item = CropTip.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

# ================= Enhanced Progress Tracking =================
@app.route('/api/progress/upcoming-tasks/<int:session_id>', methods=['GET'])
def get_upcoming_tasks(session_id):
    """Get upcoming tasks for the next week"""
    try:
        session = CropMonitoringSession.query.get_or_404(session_id)
        current_week = session.current_week
        next_week = current_week + 1
        
        # Get tasks for next week
        upcoming_tasks = WeeklyTask.query.filter_by(
            crop_id=session.crop_id, 
            week_number=next_week
        ).all()
        
        return jsonify({
            "success": True,
            "current_week": current_week,
            "next_week": next_week,
            "upcoming_tasks": [{
                "id": task.id,
                "task_title": task.task_title,
                "task_description": task.task_description,
                "task_type": task.task_type,
                "priority": task.priority,
                "estimated_duration": task.estimated_duration,
                "equipment_needed": task.equipment_needed,
                "materials_needed": task.materials_needed
            } for task in upcoming_tasks]
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/progress/notifications/<int:session_id>', methods=['GET'])
def get_progress_notifications(session_id):
    """Get notifications for incomplete tasks"""
    try:
        session = CropMonitoringSession.query.get_or_404(session_id)
        current_week = session.current_week
        
        # Get incomplete tasks from current and previous weeks
        incomplete_tasks = []
        
        # Check current week tasks
        current_tasks = WeeklyTask.query.filter_by(
            crop_id=session.crop_id, 
            week_number=current_week
        ).all()
        
        for task in current_tasks:
            progress = CropProgressTracking.query.filter_by(
                session_id=session_id,
                task_id=task.id
            ).first()
            
            if not progress or progress.completion_status != 'completed':
                incomplete_tasks.append({
                    "task_id": task.id,
                    "task_title": task.task_title,
                    "week_number": current_week,
                    "priority": task.priority,
                    "is_overdue": False,
                    "days_overdue": 0
                })
        
        # Check previous weeks for overdue tasks
        for week in range(1, current_week):
            week_tasks = WeeklyTask.query.filter_by(
                crop_id=session.crop_id, 
                week_number=week
            ).all()
            
            for task in week_tasks:
                progress = CropProgressTracking.query.filter_by(
                    session_id=session_id,
                    task_id=task.id
                ).first()
                
                if not progress or progress.completion_status != 'completed':
                    days_overdue = (current_week - week) * 7  # Approximate days
                    incomplete_tasks.append({
                        "task_id": task.id,
                        "task_title": task.task_title,
                        "week_number": week,
                        "priority": task.priority,
                        "is_overdue": True,
                        "days_overdue": days_overdue
                    })
        
        # Sort by priority and overdue status
        priority_order = {'critical': 1, 'high': 2, 'medium': 3, 'low': 4}
        incomplete_tasks.sort(key=lambda x: (
            x['is_overdue'],  # Overdue tasks first
            priority_order.get(x['priority'], 5),  # Then by priority
            x['days_overdue']  # Then by days overdue
        ))
        
        return jsonify({
            "success": True,
            "notifications": incomplete_tasks,
            "total_incomplete": len(incomplete_tasks),
            "overdue_count": len([t for t in incomplete_tasks if t['is_overdue']])
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/progress/weekly-summary/<int:session_id>', methods=['GET'])
def get_weekly_progress_summary(session_id):
    """Get comprehensive weekly progress summary"""
    try:
        session = CropMonitoringSession.query.get_or_404(session_id)
        current_week = session.current_week
        
        # Get all tasks for current week
        current_tasks = WeeklyTask.query.filter_by(
            crop_id=session.crop_id, 
            week_number=current_week
        ).all()
        
        # Get progress for current week
        progress_records = CropProgressTracking.query.filter_by(
            session_id=session_id,
            week_number=current_week
        ).all()
        
        # Calculate statistics
        total_tasks = len(current_tasks)
        completed_tasks = len([p for p in progress_records if p.completion_status == 'completed'])
        in_progress_tasks = len([p for p in progress_records if p.completion_status == 'in_progress'])
        not_started_tasks = total_tasks - completed_tasks - in_progress_tasks
        
        completion_percentage = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0
        
        # Get upcoming week tasks
        next_week = current_week + 1
        upcoming_tasks = WeeklyTask.query.filter_by(
            crop_id=session.crop_id, 
            week_number=next_week
        ).count()
        
        # Get overdue tasks count
        overdue_count = 0
        for week in range(1, current_week):
            week_tasks = WeeklyTask.query.filter_by(
                crop_id=session.crop_id, 
                week_number=week
            ).all()
            
            for task in week_tasks:
                progress = CropProgressTracking.query.filter_by(
                    session_id=session_id,
                    task_id=task.id
                ).first()
                
                if not progress or progress.completion_status != 'completed':
                    overdue_count += 1
        
        return jsonify({
            "success": True,
            "current_week": current_week,
            "total_tasks": total_tasks,
            "completed_tasks": completed_tasks,
            "in_progress_tasks": in_progress_tasks,
            "not_started_tasks": not_started_tasks,
            "completion_percentage": round(completion_percentage, 1),
            "upcoming_tasks": upcoming_tasks,
            "overdue_tasks": overdue_count,
            "next_week": next_week
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/crops/<int:crop_id>/details', methods=['GET'])
def get_crop_details_detailed(crop_id):
    """Get detailed information about a specific crop (detailed view)"""
    try:
        # Get basic crop information
        crop = Crop.query.get_or_404(crop_id)
        
        # Get detailed crop guide
        crop_guide = CropGuide.query.filter_by(crop_id=crop_id).first()
        
        # Get crop stages
        crop_stages = CropStage.query.filter_by(crop_id=crop_id).order_by(CropStage.stage_number).all()
        
        # Get weekly tasks summary
        weekly_tasks = WeeklyTask.query.filter_by(crop_id=crop_id).all()
        tasks_by_week = {}
        for task in weekly_tasks:
            week = task.week_number
            if week not in tasks_by_week:
                tasks_by_week[week] = []
            tasks_by_week[week].append({
                "id": task.id,
                "title": task.task_title,
                "type": task.task_type,
                "priority": task.priority,
                "duration": task.estimated_duration
            })
        
        # Get fertilizers and pesticides
        fertilizers = Fertilizer.query.filter_by(crop_id=crop_id).all()
        pesticides = Pesticide.query.filter_by(crop_id=crop_id).all()
        
        # Get crop videos
        videos = CropVideo.query.filter_by(crop_id=crop_id).all()
        
        return jsonify({
            "success": True,
            "crop": {
                "id": crop.id,
                "name": crop.name,
                "season": crop.season,
               "crop_category": crop.crop_category
            },
            "guide": {
                "overview": crop_guide.overview if crop_guide else None,
                "climate": crop_guide.climate if crop_guide else None,
                "soil": crop_guide.soil if crop_guide else None,
                "land_preparation": crop_guide.land_preparation if crop_guide else None,
                "sowing": crop_guide.sowing if crop_guide else None,
                "irrigation": crop_guide.irrigation if crop_guide else None,
                "nutrient_management": crop_guide.nutrient_management if crop_guide else None,
                "weed_management": crop_guide.weed_management if crop_guide else None,
                "pests_diseases": crop_guide.pests_diseases if crop_guide else None,
                "harvesting": crop_guide.harvesting if crop_guide else None,
                "yield_info": crop_guide.yield_info if crop_guide else None
            },
            "stages": [{
                "id": stage.id,
                "stage_number": stage.stage_number,
                "title": stage.title,
                "start_week": stage.start_week,
                "end_week": stage.end_week,
                "tasks": stage.tasks,
                "detailed_description": stage.detailed_description,
                "equipment_needed": stage.equipment_needed,
                "time_required": stage.time_required,
                "difficulty_level": stage.difficulty_level,
                "video_url": stage.video_url
            } for stage in crop_stages],
            "weekly_tasks": tasks_by_week,
            "fertilizers": [{
                "id": f.id,
                "week": f.week,
                "name": f.name,
                "quantity": f.quantity,
                "price": f.price,
                "gap_days": f.gap_days
            } for f in fertilizers],
            "pesticides": [{
                "id": p.id,
                "week": p.week,
                "name": p.name,
                "application": p.application,
                "quantity": p.quantity,
                "price": p.price
            } for p in pesticides],
            "videos": [{
                "id": v.id,
                "week_number": v.week_number,
                "title": v.video_title,
                "url": v.video_url,
                "type": v.video_type,
                "duration_minutes": v.duration_minutes,
                "description": v.description,
                "thumbnail_url": v.thumbnail_url,
                "is_featured": v.is_featured
            } for v in videos]
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

# ================= Admin: Weekly Tasks =================
@app.route('/api/admin/weekly_tasks', methods=['GET'])
@admin_required
def admin_list_weekly_tasks():
    items = WeeklyTask.query.all()
    return jsonify([{ 
        "id": t.id,
        "crop_id": t.crop_id,
        "week_number": t.week_number,
        "task_title": t.task_title,
        "task_description": t.task_description,
        "task_type": t.task_type,
        "priority": t.priority,
        "estimated_duration": t.estimated_duration,
        "equipment_needed": t.equipment_needed,
        "materials_needed": t.materials_needed,
        "video_url": t.video_url,
        "image_url": t.image_url,
        "step_by_step_instructions": t.step_by_step_instructions,
        "tips_and_notes": t.tips_and_notes,
        "weather_conditions": t.weather_conditions,
        "safety_precautions": t.safety_precautions,
        "expected_outcome": t.expected_outcome
    } for t in items])

@app.route('/api/admin/weekly_tasks', methods=['POST'])
@admin_required
def admin_create_weekly_task():
    data = request.get_json() or {}
    try:
        item = WeeklyTask(
            crop_id=data.get('crop_id'),
            week_number=data.get('week_number'),
            task_title=data.get('task_title'),
            task_description=data.get('task_description'),
            task_type=data.get('task_type'),
            priority=data.get('priority'),
            estimated_duration=data.get('estimated_duration'),
            equipment_needed=data.get('equipment_needed'),
            materials_needed=data.get('materials_needed'),
            video_url=data.get('video_url'),
            image_url=data.get('image_url'),
            step_by_step_instructions=data.get('step_by_step_instructions'),
            tips_and_notes=data.get('tips_and_notes'),
            weather_conditions=data.get('weather_conditions'),
            safety_precautions=data.get('safety_precautions'),
            expected_outcome=data.get('expected_outcome')
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"success": True, "id": item.id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/admin/weekly_tasks/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_weekly_task(item_id):
    item = WeeklyTask.query.get_or_404(item_id)
    data = request.get_json() or {}
    for field in ['crop_id','week_number','task_title','task_description','task_type','priority','estimated_duration','equipment_needed','materials_needed','video_url','image_url','step_by_step_instructions','tips_and_notes','weather_conditions','safety_precautions','expected_outcome']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/weekly_tasks/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_weekly_task(item_id):
    item = WeeklyTask.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})

# ================= Admin: Weather Recommendations =================
@app.route('/api/admin/weather_recommendations', methods=['GET'])
@admin_required
def admin_list_weather_recommendations():
    items = WeatherRecommendation.query.all()
    return jsonify([{ 
        "id": r.id,
        "crop_id": r.crop_id,
        "week_number": r.week_number,
        "weather_condition": r.weather_condition,
        "recommendation": r.recommendation,
        "priority": r.priority,
        "created_at": r.created_at.isoformat() if r.created_at else None
    } for r in items])

@app.route('/api/admin/weather_recommendations', methods=['POST'])
@admin_required
def admin_create_weather_recommendation():
    data = request.get_json() or {}
    try:
        item = WeatherRecommendation(
            crop_id=data.get('crop_id'),
            week_number=data.get('week_number'),
            weather_condition=data.get('weather_condition'),
            recommendation=data.get('recommendation'),
            priority=data.get('priority')
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"success": True, "id": item.id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/admin/weather_recommendations/<int:item_id>', methods=['PUT'])
@admin_required
def admin_update_weather_recommendation(item_id):
    item = WeatherRecommendation.query.get_or_404(item_id)
    data = request.get_json() or {}
    for field in ['crop_id','week_number','weather_condition','recommendation','priority']:
        if field in data:
            setattr(item, field, data[field])
    db.session.commit()
    return jsonify({"success": True})

@app.route('/api/admin/weather_recommendations/<int:item_id>', methods=['DELETE'])
@admin_required
def admin_delete_weather_recommendation(item_id):
    item = WeatherRecommendation.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return jsonify({"success": True})


# ================= Debug: List All Users =================
@app.route('/api/debug/users')
def debug_list_users():
    users = User.query.all()
    return jsonify([
        {"id": u.id, "username": u.username, "password": u.password} for u in users
    ])

# ================= Serve Frontend =================
@app.route("/")
def serve_index():
    return send_from_directory(".", "index.html")

@app.route('/database.html')
def serve_database_page():
    return send_from_directory(".", "database.html")

@app.route('/admin-video-management.html')
def serve_admin_video_page():
    return send_from_directory(".", "admin-video-management.html")

@app.route('/admin-dashboard.html')
def serve_admin_dashboard():
    return send_from_directory(".", "admin-dashboard.html")

@app.route('/admin-content-management.html')
def serve_admin_content_management():
    return send_from_directory(".", "admin-content-management.html")

@app.route('/admin-user-management.html')
def serve_admin_user_management():
    return send_from_directory(".", "admin-user-management.html")

@app.route('/admin-crop-guidance.html')
def serve_admin_crop_guidance():
    return send_from_directory(".", "admin-crop-guidance.html")

@app.route('/admin-system-config.html')
def serve_admin_system_config():
    return send_from_directory(".", "admin-system-config.html")

@app.route('/admin-reports-analytics.html')
def serve_admin_reports_analytics():
    return send_from_directory(".", "admin-reports-analytics.html")

@app.route('/weekly-guidance-enhanced.html')
def serve_weekly_guidance_enhanced():
    return send_from_directory(".", "weekly-guidance-enhanced.html")

@app.route('/land-selection.html')
def serve_land_selection_page():
    return send_from_directory(".", "land-selection.html")

@app.route('/dashboard.html')
def serve_dashboard_page():
    return send_from_directory(".", "index.html")



@app.route('/favicon.ico')
def favicon():
    return '', 204

@app.errorhandler(500)
def internal_error(e):
    import traceback
    return jsonify({
        "error": "Internal server error",
        "details": str(e),
        "trace": traceback.format_exc()
    }), 500

def main():
    """Integrated runner replacing run_local.py (binds to env host/port)."""
    try:
        with app.app_context():
            db.create_all()
    except Exception as e:
        logging.error("DB init failed: %s", e)
    app.run(host=FLASK_HOST, port=FLASK_PORT, debug=FLASK_DEBUG, use_reloader=FLASK_USE_RELOADER)

if __name__ == "__main__":
    main()
