/* ===============================================
   SMART CROP ADVISOR - UTILITY FUNCTIONS
   Shared JavaScript utilities for all pages
   Includes: API calls, localStorage, helpers
   =============================================== */

// ========== API BASE URL ==========
const API_BASE = '/api';

// ========== API HELPER FUNCTIONS ==========

/**
 * Generic fetch wrapper with error handling
 * @param {string} url - API endpoint
 * @param {object} options - Fetch options
 * @returns {Promise} - Response data or error
 */
async function apiFetch(url, options = {}) {
  try {
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      },
      ...options
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return { success: true, data };
  } catch (error) {
    console.error('API Error:', error);
    return { success: false, error: error.message };
  }
}

/**
 * Fetch weather data based on coordinates
 * @param {number} lat - Latitude
 * @param {number} lon - Longitude
 * @returns {Promise} - Weather data
 */
async function fetchWeather(lat, lon) {
  return await apiFetch(`${API_BASE}/weather?lat=${lat}&lon=${lon}`);
}

/**
 * Fetch all soil types
 * @returns {Promise} - Soil types array
 */
async function fetchSoilTypes() {
  return await apiFetch(`${API_BASE}/soil-types`);
}

/**
 * Fetch crop suggestions based on criteria
 * @param {object} params - { soilType, ph, landSize, irrigation }
 * @returns {Promise} - Crop suggestions array
 */
async function fetchCropSuggestions(params) {
  const queryString = new URLSearchParams(params).toString();
  return await apiFetch(`${API_BASE}/crop-suggestions?${queryString}`);
}

/**
 * Fetch specific crop details by ID
 * @param {string} cropId - Crop ID
 * @returns {Promise} - Crop details
 */
async function fetchCropDetails(cropId) {
  return await apiFetch(`${API_BASE}/crops/${cropId}`);
}

/**
 * Fetch weekly tasks for a crop
 * @param {string} cropId - Crop ID
 * @param {number} weekNumber - Week number
 * @returns {Promise} - Weekly tasks
 */
async function fetchWeeklyTasks(cropId, weekNumber) {
  return await apiFetch(`${API_BASE}/crops/${cropId}/week/${weekNumber}`);
}

/**
 * Start crop monitoring
 * @param {object} data - { cropId, landSize, startDate }
 * @returns {Promise} - Monitoring session
 */
async function startCropMonitoring(data) {
  return await apiFetch(`${API_BASE}/start-crop-monitoring`, {
    method: 'POST',
    body: JSON.stringify(data)
  });
}

/**
 * Fetch land calculations
 * @param {object} params - { landSize, soilType, irrigation }
 * @returns {Promise} - Land calculations
 */
async function fetchLandCalculations(params) {
  const queryString = new URLSearchParams(params).toString();
  return await apiFetch(`${API_BASE}/land-calculations?${queryString}`);
}

// ========== LOCAL STORAGE HELPERS ==========

/**
 * Save data to localStorage
 * @param {string} key - Storage key
 * @param {any} value - Value to store
 */
function saveToStorage(key, value) {
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch (error) {
    console.error('Storage Error:', error);
  }
}

/**
 * Get data from localStorage
 * @param {string} key - Storage key
 * @param {any} defaultValue - Default value if not found
 * @returns {any} - Stored value or default
 */
function getFromStorage(key, defaultValue = null) {
  try {
    const item = localStorage.getItem(key);
    return item ? JSON.parse(item) : defaultValue;
  } catch (error) {
    console.error('Storage Error:', error);
    return defaultValue;
  }
}

/**
 * Remove item from localStorage
 * @param {string} key - Storage key
 */
function removeFromStorage(key) {
  try {
    localStorage.removeItem(key);
  } catch (error) {
    console.error('Storage Error:', error);
  }
}

/**
 * Clear all localStorage
 */
function clearStorage() {
  try {
    localStorage.clear();
  } catch (error) {
    console.error('Storage Error:', error);
  }
}

// ========== THEME MANAGEMENT ==========

/**
 * Get current theme
 * @returns {string} - 'light' or 'dark'
 */
function getTheme() {
  return getFromStorage('theme', 'light');
}

/**
 * Set theme
 * @param {string} theme - 'light' or 'dark'
 */
function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  saveToStorage('theme', theme);
}

/**
 * Toggle theme between light and dark
 */
function toggleTheme() {
  const currentTheme = getTheme();
  const newTheme = currentTheme === 'light' ? 'dark' : 'light';
  setTheme(newTheme);
  return newTheme;
}

/**
 * Initialize theme on page load
 */
function initTheme() {
  const theme = getTheme();
  setTheme(theme);
}

// ========== CROP PROGRESS TRACKING ==========

/**
 * Save crop progress
 * @param {string} cropId - Crop ID
 * @param {object} progress - Progress data
 */
function saveCropProgress(cropId, progress) {
  const allProgress = getFromStorage('cropProgress', {});
  allProgress[cropId] = {
    ...progress,
    lastUpdated: new Date().toISOString()
  };
  saveToStorage('cropProgress', allProgress);
}

/**
 * Get crop progress
 * @param {string} cropId - Crop ID
 * @returns {object} - Progress data
 */
function getCropProgress(cropId) {
  const allProgress = getFromStorage('cropProgress', {});
  return allProgress[cropId] || null;
}

/**
 * Mark week as completed
 * @param {string} cropId - Crop ID
 * @param {number} weekNumber - Week number
 */
function markWeekCompleted(cropId, weekNumber) {
  const progress = getCropProgress(cropId) || { completedWeeks: [] };
  if (!progress.completedWeeks.includes(weekNumber)) {
    progress.completedWeeks.push(weekNumber);
  }
  saveCropProgress(cropId, progress);
}

/**
 * Check if week is completed
 * @param {string} cropId - Crop ID
 * @param {number} weekNumber - Week number
 * @returns {boolean}
 */
function isWeekCompleted(cropId, weekNumber) {
  const progress = getCropProgress(cropId);
  return progress && progress.completedWeeks && progress.completedWeeks.includes(weekNumber);
}

// ========== UI HELPERS ==========

/**
 * Show loading state
 * @param {HTMLElement} element - Target element
 * @param {string} message - Loading message
 */
function showLoading(element, message = 'Loading...') {
  element.innerHTML = `
    <div class="text-center p-4">
      <div class="loading-spinner mx-auto mb-3"></div>
      <p class="text-secondary">${message}</p>
    </div>
  `;
}

/**
 * Show error message
 * @param {HTMLElement} element - Target element
 * @param {string} message - Error message
 */
function showError(element, message = 'An error occurred') {
  element.innerHTML = `
    <div class="alert-custom alert-danger">
      <span class="icon">⚠️</span>
      <span>${message}</span>
    </div>
  `;
}

/**
 * Show success message
 * @param {HTMLElement} element - Target element
 * @param {string} message - Success message
 */
function showSuccess(element, message) {
  element.innerHTML = `
    <div class="alert-custom alert-success">
      <span class="icon">✓</span>
      <span>${message}</span>
    </div>
  `;
}

/**
 * Show empty state
 * @param {HTMLElement} element - Target element
 * @param {string} message - Empty state message
 * @param {string} icon - Icon emoji
 */
function showEmptyState(element, message, icon = '📭') {
  element.innerHTML = `
    <div class="text-center p-4">
      <div style="font-size: 4rem; opacity: 0.5; margin-bottom: 1rem;">${icon}</div>
      <h4 class="text-secondary">${message}</h4>
    </div>
  `;
}

/**
 * Show toast notification
 * @param {string} message - Notification message
 * @param {string} type - 'success', 'error', 'warning', 'info'
 * @param {number} duration - Duration in ms
 */
function showToast(message, type = 'info', duration = 3000) {
  const toast = document.createElement('div');
  toast.className = `alert-custom alert-${type}`;
  toast.style.cssText = `
    position: fixed;
    top: 80px;
    right: 20px;
    z-index: 10000;
    min-width: 300px;
    animation: slide-in-right 0.4s ease;
  `;
  
  const icons = {
    success: '✓',
    error: '✗',
    warning: '⚠',
    info: 'ℹ'
  };
  
  toast.innerHTML = `
    <span class="icon">${icons[type]}</span>
    <span>${message}</span>
  `;
  
  document.body.appendChild(toast);
  
  setTimeout(() => {
    toast.style.animation = 'fade-out 0.4s ease';
    setTimeout(() => toast.remove(), 400);
  }, duration);
}

/**
 * Format date to readable string
 * @param {Date|string} date - Date object or string
 * @returns {string} - Formatted date
 */
function formatDate(date) {
  const d = new Date(date);
  return d.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
}

/**
 * Format currency
 * @param {number} amount - Amount
 * @param {string} currency - Currency code
 * @returns {string} - Formatted currency
 */
function formatCurrency(amount, currency = 'INR') {
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: currency
  }).format(amount);
}

/**
 * Calculate percentage
 * @param {number} value - Current value
 * @param {number} total - Total value
 * @returns {number} - Percentage
 */
function calculatePercentage(value, total) {
  return total > 0 ? Math.round((value / total) * 100) : 0;
}

/**
 * Debounce function
 * @param {Function} func - Function to debounce
 * @param {number} wait - Wait time in ms
 * @returns {Function} - Debounced function
 */
function debounce(func, wait = 300) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

/**
 * Get URL parameter
 * @param {string} name - Parameter name
 * @returns {string|null} - Parameter value
 */
function getUrlParameter(name) {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get(name);
}

/**
 * Redirect to page with parameters
 * @param {string} url - Target URL
 * @param {object} params - URL parameters
 */
function redirectWithParams(url, params = {}) {
  const queryString = new URLSearchParams(params).toString();
  window.location.href = queryString ? `${url}?${queryString}` : url;
}

// ========== GEOLOCATION ==========

/**
 * Get user's current location
 * @returns {Promise} - { lat, lon } or error
 */
function getCurrentLocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocation is not supported by your browser'));
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve({
          lat: position.coords.latitude,
          lon: position.coords.longitude
        });
      },
      (error) => {
        reject(error);
      }
    );
  });
}

// ========== VALIDATION ==========

/**
 * Validate email
 * @param {string} email - Email address
 * @returns {boolean}
 */
function isValidEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

/**
 * Validate phone number (Indian format)
 * @param {string} phone - Phone number
 * @returns {boolean}
 */
function isValidPhone(phone) {
  const re = /^[6-9]\d{9}$/;
  return re.test(phone);
}

/**
 * Validate required fields
 * @param {object} data - Data object
 * @param {array} requiredFields - Array of required field names
 * @returns {object} - { valid: boolean, missing: array }
 */
function validateRequired(data, requiredFields) {
  const missing = requiredFields.filter(field => !data[field]);
  return {
    valid: missing.length === 0,
    missing
  };
}

// ========== EXPORT FOR MODULE USAGE ==========
// If using ES6 modules, uncomment below:
/*
export {
  apiFetch,
  fetchWeather,
  fetchSoilTypes,
  fetchCropSuggestions,
  fetchCropDetails,
  fetchWeeklyTasks,
  startCropMonitoring,
  fetchLandCalculations,
  saveToStorage,
  getFromStorage,
  removeFromStorage,
  clearStorage,
  getTheme,
  setTheme,
  toggleTheme,
  initTheme,
  saveCropProgress,
  getCropProgress,
  markWeekCompleted,
  isWeekCompleted,
  showLoading,
  showError,
  showSuccess,
  showEmptyState,
  showToast,
  formatDate,
  formatCurrency,
  calculatePercentage,
  debounce,
  getUrlParameter,
  redirectWithParams,
  getCurrentLocation,
  isValidEmail,
  isValidPhone,
  validateRequired
};
*/

// Initialize theme on page load
document.addEventListener('DOMContentLoaded', () => {
  initTheme();
});
