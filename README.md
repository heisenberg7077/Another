# Agricultural Management System

A comprehensive web-based agricultural management system with AI-powered chatbot for crop cultivation guidance.

## Modernized App (Flask Blueprints + ORM)

This codebase has been refactored into a modular Flask package with Blueprints, SQLAlchemy models, services, and production-ready configuration.

### Quick Start (New)

1. Install dependencies
   ```bash
   pip install -r requirements.txt
   ```
2. Seed the database (SQLite by default)
   ```bash
   python init_database.py
   ```
3. Run the app
   ```bash
   set FLASK_APP=presicide_agri  # on Windows PowerShell: $env:FLASK_APP="presicide_agri"
   flask run
   ```
4. Open `http://127.0.0.1:5000` and API docs at `/docs/`.

Environment variables can be placed in `instance/.env` (see keys in `presicide_agri/config.py`). Defaults use SQLite for easy local use.

## 🌾 Features

- **Crop Management**: View and manage crop information, cultivation guides, and schedules
- **AI Chatbot**: Get instant agricultural advice powered by Tamil Nadu crop dataset
- **Database Integration**: Connected to MySQL database for data persistence
- **User Authentication**: Secure login system with multiple user roles
- **Responsive Web Interface**: Modern, mobile-friendly design

## 🚀 Quick Start

### Prerequisites
- Python 3.7+
- MySQL (XAMPP recommended)
- Required Python packages (see requirements below)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd project-5.1
   ```

2. **Install dependencies**
   ```bash
   pip install flask flask-sqlalchemy flask-cors pymysql requests werkzeug
   ```

3. **Setup Database**
   - Start XAMPP MySQL
   - Create database named `agri_v`
   - Import `mysql.sql` file

4. **Run the Application**
   
   **Terminal 1 - AI Server:**
   ```bash
   python enhanced_agricultural_ai.py
   ```
   
   **Terminal 2 - Main App:**
   ```bash
   python app.py
   ```

5. **Access the Application**
   - Open browser: `http://127.0.0.1:5050`
   - Login credentials:
     - Username: `farmer1` | Password: `123`
     - Username: `farmer2` | Password: `123`
     - Username: `admink` | Password: `123`

## 📁 Project Structure

```
presicide_agri/
├── __init__.py              # create_app(), extensions, logging, Swagger
├── config.py                # env-driven configuration
├── models/                  # SQLAlchemy models (User, Crop, SoilType, WeeklyTask)
├── routes/                  # Blueprints (user, admin, api)
├── services/                # AI and agricheck services with Pydantic schemas
├── templates/               # Jinja2 templates
└── static/                  # CSS/JS assets
```

## 🔧 Configuration

### Database Configuration
The application connects to MySQL database. Update the connection string in `app.py`:
```python
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost:3306/agri_v'
```

### AI Server Configuration
The AI server runs on port 5001 and provides agricultural guidance based on the comprehensive Tamil Nadu crop dataset.

## 📊 Available Crops

The system includes detailed information for major Tamil Nadu crops:
- Rice, Tomato, Sugarcane, Cotton, Maize
- Groundnut, Black Gram, Banana, Turmeric, Coconut
- And many more with complete cultivation guides

## 🤖 AI Features

- **Crop-specific advice**: Get tailored recommendations for specific crops
- **Seasonal guidance**: Information based on Tamil Nadu's agricultural seasons
- **Cultivation tips**: Detailed growing, harvesting, and management advice
- **Pest and disease management**: Integrated pest management strategies

<!-- Plant disease detection feature has been removed per project requirements. -->
## 🛠️ API Endpoints

- `GET /api/crops` - List all crops
- `GET /api/crops/<id>` - Get crop details
- `GET /api/crops/<id>/week/<week>` - Get weekly tasks
- `POST /api/login` - User authentication
- `POST /api/chatbot` - AI chatbot queries

## 📝 License

This project is for educational and agricultural development purposes.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For support and questions, please open an issue in the repository.

---

**🌾 Built for Tamil Nadu Agriculture | Powered by AI**
