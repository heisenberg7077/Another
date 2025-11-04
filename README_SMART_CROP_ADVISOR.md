# 🌾 Smart Crop Advisor - Multi-Page System

## 📋 Project Overview

The **Smart Crop Advisor** is a modular, multi-page precision agriculture assistant that helps farmers make informed decisions about crop selection, land planning, and crop management through an intuitive web interface.

## 🏗️ System Architecture

### File Structure
```
presicide_agri-main/
├── css/
│   ├── common.css          # Shared styles and theme variables
│   └── style.css           # Existing page-specific styles
├── js/
│   ├── utils.js            # API calls, storage, helpers
│   ├── navbar.js           # Shared navigation component
│   ├── weather.js          # Weather widget component
│   └── chatbot.js          # AI chatbot component
├── index.html              # Dashboard Overview
├── crops.html              # Crop Suggestion Page
├── journey.html            # Crop Journey Page
├── land.html               # Land Planning Page
└── README_SMART_CROP_ADVISOR.md
```

## 🎨 Design System

### Color Palette
- **Primary Green**: `#4a7c59`
- **Primary Green Dark**: `#3a6b4a`
- **Primary Green Light**: `#5a8c69`
- **Secondary Blue**: `#e7f3ff`
- **Secondary Gray**: `#f8f9fa`
- **White**: `#ffffff`
- **Text Primary**: `#2d1e2f`

### Theme Support
- Light mode (default)
- Dark mode (toggle via navbar)
- Theme preference saved to localStorage

## 📄 Page Specifications

### 1. index.html - Dashboard Overview

**Purpose**: At-a-glance farming assistant dashboard

**Features**:
- Weather widget with current conditions
- Top 3 crop suggestions (auto-fetched based on location)
- Quick soil input form (soil type + pH)
- Recent activity cards
- Quick action buttons

**Key Components**:
```html
<!-- Hero Section -->
<section class="hero-section">
  <h1>Welcome to Smart Crop Advisor</h1>
  <p>Your intelligent farming companion</p>
</section>

<!-- Weather Widget -->
<div id="weatherWidget"></div>

<!-- Top Crops -->
<div id="topCrops" class="grid-3"></div>

<!-- Quick Input -->
<form id="quickSoilForm">
  <select id="soilType"></select>
  <input type="number" id="soilPh" placeholder="pH (optional)">
  <button type="submit">Get Suggestions</button>
</form>
```

**JavaScript Functions**:
```javascript
// Auto-fetch weather on load
async function loadWeather() {
  const location = await getCurrentLocation();
  const weather = await fetchWeather(location.lat, location.lon);
  displayWeather(weather.data);
}

// Auto-fetch top 3 crops
async function loadTopCrops() {
  const suggestions = await fetchCropSuggestions({
    limit: 3,
    season: getCurrentSeason()
  });
  displayTopCrops(suggestions.data);
}

// Quick form submission
document.getElementById('quickSoilForm').addEventListener('submit', (e) => {
  e.preventDefault();
  const soilType = document.getElementById('soilType').value;
  const ph = document.getElementById('soilPh').value;
  redirectWithParams('crops.html', { soilType, ph });
});
```

### 2. crops.html - Crop Suggestion Page

**Purpose**: Full crop recommendation experience

**Features**:
- Comprehensive input form (soil, pH, land size, irrigation)
- Grid display of crop suggestions
- Crop cards with suitability percentage
- Filter and sort options
- Modal for crop details
- "Start Journey" button

**Key Components**:
```html
<!-- Input Form -->
<form id="cropSuggestionForm" class="card-custom">
  <div class="grid-2">
    <div class="form-group-custom">
      <label>Soil Type</label>
      <select id="soilType" required></select>
    </div>
    <div class="form-group-custom">
      <label>Soil pH</label>
      <input type="number" id="soilPh" step="0.1">
    </div>
    <div class="form-group-custom">
      <label>Land Size (acres)</label>
      <input type="number" id="landSize" step="0.1">
    </div>
    <div class="form-group-custom">
      <label>Irrigation Type</label>
      <select id="irrigationType"></select>
    </div>
  </div>
  <button type="submit" class="btn-custom btn-primary">
    Get Crop Suggestions
  </button>
</form>

<!-- Results Grid -->
<div id="cropResults" class="grid-auto"></div>
```

**Crop Card Template**:
```javascript
function createCropCard(crop) {
  return `
    <div class="card-custom crop-card">
      <div class="crop-header">
        <h3>${crop.name}</h3>
        <span class="badge-custom badge-primary">${crop.category}</span>
      </div>
      <div class="crop-body">
        <div class="suitability-meter">
          <div class="meter-fill" style="width: ${crop.suitability}%"></div>
          <span>${crop.suitability}% Suitable</span>
        </div>
        <div class="crop-details">
          <p><strong>Season:</strong> ${crop.season}</p>
          <p><strong>Duration:</strong> ${crop.duration} weeks</p>
          <p><strong>Expected Yield:</strong> ${crop.yield}</p>
        </div>
      </div>
      <div class="crop-actions">
        <button class="btn-custom btn-outline" onclick="viewCropPlan('${crop.id}')">
          🌱 View Plan
        </button>
        <button class="btn-custom btn-primary" onclick="startJourney('${crop.id}')">
          🚀 Start Journey
        </button>
      </div>
    </div>
  `;
}
```

### 3. journey.html - Crop Journey Page

**Purpose**: Step-by-step crop guidance and progress tracking

**Features**:
- Crop header with progress bar
- Week selector/slider
- Weekly task cards
- Fertilizer & pesticide schedules
- Photo upload for progress
- Mark tasks as complete
- AI chatbot integration

**Key Components**:
```html
<!-- Crop Header -->
<div class="journey-header card-custom">
  <h1 id="cropName"></h1>
  <div class="progress-bar">
    <div class="progress-fill" id="progressFill"></div>
  </div>
  <p id="progressText">Week 1 of 12 (8% Complete)</p>
</div>

<!-- Week Selector -->
<div class="week-selector">
  <button class="btn-custom btn-sm" onclick="previousWeek()">← Previous</button>
  <div class="week-timeline" id="weekTimeline"></div>
  <button class="btn-custom btn-sm" onclick="nextWeek()">Next →</button>
</div>

<!-- Content Tabs -->
<div class="tabs">
  <button class="tab active" data-tab="tasks">📋 Tasks</button>
  <button class="tab" data-tab="fertilizers">💊 Fertilizers</button>
  <button class="tab" data-tab="pesticides">🛡️ Pesticides</button>
  <button class="tab" data-tab="overview">📊 Overview</button>
</div>

<!-- Tab Content -->
<div id="tabContent"></div>
```

**JavaScript Functions**:
```javascript
// Load crop journey
async function loadCropJourney(cropId) {
  const crop = await fetchCropDetails(cropId);
  const progress = getCropProgress(cropId) || {
    currentWeek: 1,
    completedWeeks: [],
    startDate: new Date().toISOString()
  };
  
  displayCropHeader(crop.data);
  displayProgress(progress);
  loadWeekTasks(cropId, progress.currentWeek);
}

// Load week tasks
async function loadWeekTasks(cropId, weekNumber) {
  showLoading(document.getElementById('tabContent'));
  const tasks = await fetchWeeklyTasks(cropId, weekNumber);
  displayTasks(tasks.data);
}

// Mark task complete
function markTaskComplete(cropId, weekNumber, taskId) {
  const progress = getCropProgress(cropId);
  if (!progress.completedTasks) progress.completedTasks = {};
  if (!progress.completedTasks[weekNumber]) progress.completedTasks[weekNumber] = [];
  
  progress.completedTasks[weekNumber].push(taskId);
  saveCropProgress(cropId, progress);
  
  showToast('Task marked as complete!', 'success');
  updateProgressBar();
}
```

### 4. land.html - Land Planning Page

**Purpose**: Land cost analysis and planning

**Features**:
- Land size and soil type inputs
- Water requirement calculator
- Nutrient requirement display
- Monthly cost breakdown table
- Simple charts (using Chart.js)
- Irrigation recommendations

**Key Components**:
```html
<!-- Input Form -->
<form id="landPlanningForm" class="card-custom">
  <div class="grid-2">
    <div class="form-group-custom">
      <label>Land Size (acres)</label>
      <input type="number" id="landSize" required>
    </div>
    <div class="form-group-custom">
      <label>Soil Type</label>
      <select id="soilType" required></select>
    </div>
    <div class="form-group-custom">
      <label>Irrigation Type</label>
      <select id="irrigationType" required></select>
    </div>
  </div>
  <button type="submit" class="btn-custom btn-primary">
    Calculate Requirements
  </button>
</form>

<!-- Results -->
<div id="landResults" class="grid-2">
  <div class="card-custom">
    <h3>💧 Water Requirements</h3>
    <div id="waterRequirements"></div>
  </div>
  <div class="card-custom">
    <h3>🌱 Nutrient Requirements</h3>
    <div id="nutrientRequirements"></div>
  </div>
</div>

<!-- Cost Breakdown -->
<div class="card-custom">
  <h3>💰 Monthly Cost Breakdown</h3>
  <table id="costTable" class="table-custom"></table>
  <canvas id="costChart"></canvas>
</div>
```

## 🔌 API Integration

### Available Endpoints

```javascript
// Weather
GET /api/weather?lat={lat}&lon={lon}

// Soil Types
GET /api/soil-types

// Crop Suggestions
GET /api/crop-suggestions?soilType={type}&ph={ph}&landSize={size}&irrigation={type}

// Crop Details
GET /api/crops/{id}

// Weekly Tasks
GET /api/crops/{id}/week/{weekNumber}

// Start Monitoring
POST /api/start-crop-monitoring
Body: { cropId, landSize, startDate }

// Land Calculations
GET /api/land-calculations?landSize={size}&soilType={type}&irrigation={type}
```

### Error Handling Pattern

```javascript
async function handleApiCall(apiFunction, errorMessage) {
  try {
    const result = await apiFunction();
    if (!result.success) {
      throw new Error(result.error);
    }
    return result.data;
  } catch (error) {
    showToast(errorMessage || 'An error occurred', 'error');
    console.error(error);
    return null;
  }
}
```

## 💾 Data Storage

### LocalStorage Schema

```javascript
// Theme preference
localStorage.theme = 'light' | 'dark'

// Crop progress
localStorage.cropProgress = {
  [cropId]: {
    currentWeek: number,
    completedWeeks: number[],
    completedTasks: {
      [weekNumber]: taskId[]
    },
    startDate: ISO string,
    lastUpdated: ISO string,
    photos: {
      [weekNumber]: photoUrl[]
    }
  }
}

// User preferences
localStorage.userPreferences = {
  location: { lat, lon },
  defaultSoilType: string,
  defaultIrrigation: string
}
```

## 🎯 Key Features Implementation

### 1. Smart Weather-Crop Matching

```javascript
function filterCropsByWeather(crops, weather) {
  return crops.filter(crop => {
    const tempMatch = weather.temp >= crop.minTemp && weather.temp <= crop.maxTemp;
    const rainMatch = weather.rainfall >= crop.minRainfall && weather.rainfall <= crop.maxRainfall;
    return tempMatch && rainMatch;
  });
}
```

### 2. Progress Tracking

```javascript
function calculateProgress(cropId) {
  const progress = getCropProgress(cropId);
  const crop = getCropDetails(cropId);
  
  const totalWeeks = crop.duration;
  const completedWeeks = progress.completedWeeks.length;
  const percentage = calculatePercentage(completedWeeks, totalWeeks);
  
  return {
    percentage,
    completedWeeks,
    totalWeeks,
    currentWeek: progress.currentWeek
  };
}
```

### 3. Dark Mode Toggle

```javascript
// Already implemented in utils.js
// Usage:
document.getElementById('themeToggle').addEventListener('click', () => {
  const newTheme = toggleTheme();
  showToast(`Switched to ${newTheme} mode`, 'success');
});
```

## 📱 Responsive Design

### Breakpoints
- **Desktop**: > 1024px
- **Tablet**: 768px - 1024px
- **Mobile**: < 768px
- **Small Mobile**: < 480px

### Mobile Optimizations
- Hamburger menu for navigation
- Single-column layouts
- Touch-friendly buttons (min 44px)
- Swipeable week timeline
- Bottom-fixed action buttons

## 🚀 Getting Started

### 1. Include Required Files

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Smart Crop Advisor</title>
  
  <!-- Bootstrap 5 (optional) -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  
  <!-- Common Styles -->
  <link rel="stylesheet" href="/css/common.css">
  <link rel="stylesheet" href="/css/style.css">
</head>
<body data-page="home">
  
  <!-- Content goes here -->
  
  <!-- Scripts -->
  <script src="/js/utils.js"></script>
  <script src="/js/navbar.js"></script>
  <script src="/js/page-specific.js"></script>
</body>
</html>
```

### 2. Initialize Page

```javascript
document.addEventListener('DOMContentLoaded', async () => {
  // Initialize theme
  initTheme();
  
  // Load initial data
  await loadInitialData();
  
  // Setup event listeners
  setupEventListeners();
});
```

## 🧪 Testing Checklist

- [ ] Weather widget loads correctly
- [ ] Crop suggestions display properly
- [ ] Journey page tracks progress
- [ ] Dark mode toggles correctly
- [ ] Mobile menu works on small screens
- [ ] Forms validate input
- [ ] API errors handled gracefully
- [ ] LocalStorage persists data
- [ ] Responsive on all devices
- [ ] Cross-browser compatible

## 🔧 Maintenance & AI Collaboration

### Code Comments Standard
```javascript
/**
 * Function description
 * @param {type} paramName - Parameter description
 * @returns {type} - Return value description
 */
```

### Modular Structure
- Each page has its own JS file
- Shared utilities in utils.js
- Shared components in separate files
- CSS follows BEM naming convention

### Future Enhancements
- [ ] Add crop comparison feature
- [ ] Implement notification system
- [ ] Add export to PDF functionality
- [ ] Integrate payment gateway for premium features
- [ ] Add multi-language support
- [ ] Implement offline mode with Service Workers

## 📞 Support & Documentation

For detailed API documentation, refer to the backend API docs.
For UI component library, see `common.css` comments.

---

**Built with ❤️ for farmers by Smart Crop Advisor Team**
