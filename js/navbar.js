/* ===============================================
   SMART CROP ADVISOR - NAVIGATION COMPONENT
   Shared navigation bar for all pages
   =============================================== */

/**
 * Create and inject navigation bar
 * @param {string} activePage - Current active page name
 */
function createNavbar(activePage = 'home') {
  const navbar = document.createElement('nav');
  navbar.className = 'navbar-custom';
  navbar.innerHTML = `
    <div class="container-custom">
      <div class="navbar-content">
        <a href="index.html" class="navbar-brand">
          <span class="brand-icon">🌾</span>
          <span class="brand-text">Smart Crop Advisor</span>
        </a>
        
        <button class="mobile-menu-toggle" id="mobileMenuToggle" aria-label="Toggle menu">
          <span class="hamburger"></span>
        </button>
        
        <div class="navbar-menu" id="navbarMenu">
          <a href="index.html" class="nav-link ${activePage === 'home' ? 'active' : ''}">
            <span class="nav-icon">🏠</span>
            <span>Dashboard</span>
          </a>
          <a href="crops.html" class="nav-link ${activePage === 'crops' ? 'active' : ''}">
            <span class="nav-icon">🌱</span>
            <span>Crop Suggestions</span>
          </a>
          <a href="land.html" class="nav-link ${activePage === 'land' ? 'active' : ''}">
            <span class="nav-icon">🗺️</span>
            <span>Land Planning</span>
          </a>
          <div class="nav-dropdown" id="myJourneysDropdown">
            <button class="nav-link dropdown-toggle" id="myJourneysToggle">
              <span class="nav-icon">📋</span>
              <span>My Journey</span>
              <span class="dropdown-arrow">▼</span>
            </button>
            <div class="dropdown-menu" id="journeysMenu">
              <a href="/my-tasks.html" class="dropdown-item">
                <span class="nav-icon">📋</span>
                <span>My Tasks</span>
              </a>
              <a href="/weekly-guidance.html" class="dropdown-item">
                <span class="nav-icon">🌱</span>
                <span>Weekly Guidance</span>
              </a>
            </div>
          </div>
          
          <button class="theme-toggle" id="themeToggle" aria-label="Toggle theme">
            <span class="theme-icon-light">🌞</span>
            <span class="theme-icon-dark">🌙</span>
          </button>
        </div>
      </div>
    </div>
  `;
  
  // Insert navbar at the beginning of body
  document.body.insertBefore(navbar, document.body.firstChild);
  
  // Add navbar styles
  addNavbarStyles();
  
  // Initialize navbar functionality
  initNavbarFunctionality();
}

/**
 * Add navbar styles dynamically
 */
function addNavbarStyles() {
  const style = document.createElement('style');
  style.textContent = `
    .navbar-custom {
      background: var(--bg-secondary);
      border-bottom: 1px solid var(--border-color);
      box-shadow: var(--shadow-sm);
      position: sticky;
      top: 0;
      z-index: 1000;
      transition: var(--transition);
    }
    
    .navbar-content {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 1rem 0;
    }
    
    .navbar-brand {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      text-decoration: none;
      font-weight: 700;
      font-size: 1.25rem;
      color: var(--primary-green);
      transition: var(--transition);
    }
    
    .navbar-brand:hover {
      color: var(--primary-green-dark);
    }
    
    .brand-icon {
      font-size: 1.75rem;
    }
    
    .brand-text {
      display: none;
    }
    
    .navbar-menu {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }
    
    .nav-link {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.75rem 1rem;
      border-radius: var(--border-radius-sm);
      text-decoration: none;
      color: var(--text-secondary);
      font-weight: 600;
      font-size: 0.95rem;
      transition: var(--transition);
      white-space: nowrap;
    }
    
    .nav-link:hover {
      background: rgba(74, 124, 89, 0.1);
      color: var(--primary-green);
    }
    
    .nav-link.active {
      background: var(--primary-gradient);
      color: var(--white);
    }
    
    .nav-icon {
      font-size: 1.25rem;
    }
    
    .nav-dropdown {
      position: relative;
    }
    
    .dropdown-toggle {
      background: transparent;
      border: none;
      cursor: pointer;
    }
    
    .dropdown-arrow {
      font-size: 0.7rem;
      margin-left: 0.25rem;
      transition: transform 0.3s ease;
    }
    
    .nav-dropdown.active .dropdown-arrow {
      transform: rotate(180deg);
    }
    
    .dropdown-menu {
      position: absolute;
      top: 100%;
      left: 0;
      min-width: 200px;
      background: var(--bg-secondary);
      border: 1px solid var(--border-color);
      border-radius: var(--border-radius-sm);
      box-shadow: var(--shadow-lg);
      margin-top: 0.5rem;
      opacity: 0;
      visibility: hidden;
      transform: translateY(-10px);
      transition: all 0.3s ease;
      z-index: 1000;
    }
    
    .nav-dropdown.active .dropdown-menu {
      opacity: 1;
      visibility: visible;
      transform: translateY(0);
    }
    
    .dropdown-item {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.75rem 1rem;
      text-decoration: none;
      color: var(--text-secondary);
      font-weight: 600;
      font-size: 0.95rem;
      transition: var(--transition);
      border-bottom: 1px solid var(--border-color);
    }
    
    .dropdown-item:last-child {
      border-bottom: none;
    }
    
    .dropdown-item:hover {
      background: rgba(74, 124, 89, 0.1);
      color: var(--primary-green);
    }
    
    .theme-toggle {
      background: var(--bg-primary);
      border: 2px solid var(--border-color);
      border-radius: 50%;
      width: 40px;
      height: 40px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: var(--transition);
      margin-left: 0.5rem;
    }
    
    .theme-toggle:hover {
      border-color: var(--primary-green);
      transform: rotate(180deg);
    }
    
    .theme-icon-dark {
      display: none;
    }
    
    [data-theme='dark'] .theme-icon-light {
      display: none;
    }
    
    [data-theme='dark'] .theme-icon-dark {
      display: block;
    }
    
    .mobile-menu-toggle {
      display: none;
      background: transparent;
      border: none;
      cursor: pointer;
      padding: 0.5rem;
    }
    
    .hamburger {
      display: block;
      width: 25px;
      height: 2px;
      background: var(--text-primary);
      position: relative;
      transition: var(--transition);
    }
    
    .hamburger::before,
    .hamburger::after {
      content: '';
      position: absolute;
      width: 25px;
      height: 2px;
      background: var(--text-primary);
      transition: var(--transition);
    }
    
    .hamburger::before {
      top: -8px;
    }
    
    .hamburger::after {
      bottom: -8px;
    }
    
    .mobile-menu-toggle.active .hamburger {
      background: transparent;
    }
    
    .mobile-menu-toggle.active .hamburger::before {
      top: 0;
      transform: rotate(45deg);
    }
    
    .mobile-menu-toggle.active .hamburger::after {
      bottom: 0;
      transform: rotate(-45deg);
    }
    
    @media (min-width: 769px) {
      .brand-text {
        display: inline;
      }
    }
    
    @media (max-width: 768px) {
      .mobile-menu-toggle {
        display: block;
      }
      
      .navbar-menu {
        position: fixed;
        top: 65px;
        right: -100%;
        width: 280px;
        height: calc(100vh - 65px);
        background: var(--bg-secondary);
        border-left: 1px solid var(--border-color);
        flex-direction: column;
        align-items: stretch;
        padding: 1rem;
        gap: 0.5rem;
        transition: right 0.3s ease;
        box-shadow: var(--shadow-lg);
      }
      
      .navbar-menu.active {
        right: 0;
      }
      
      .nav-link {
        width: 100%;
        justify-content: flex-start;
      }
      
      .nav-dropdown {
        width: 100%;
      }
      
      .dropdown-toggle {
        width: 100%;
        justify-content: flex-start;
      }
      
      .dropdown-menu {
        position: static;
        opacity: 1;
        visibility: visible;
        transform: none;
        margin-top: 0.5rem;
        margin-left: 1rem;
        box-shadow: none;
        border: none;
        background: transparent;
        display: none;
      }
      
      .nav-dropdown.active .dropdown-menu {
        display: block;
      }
      
      .dropdown-item {
        border-radius: var(--border-radius-sm);
        border-bottom: none;
        margin-bottom: 0.25rem;
      }
      
      .theme-toggle {
        margin-left: 0;
        width: 100%;
        border-radius: var(--border-radius-sm);
      }
    }
  `;
  
  document.head.appendChild(style);
}

/**
 * Initialize navbar functionality
 */
function initNavbarFunctionality() {
  // Mobile menu toggle
  const mobileMenuToggle = document.getElementById('mobileMenuToggle');
  const navbarMenu = document.getElementById('navbarMenu');
  
  if (mobileMenuToggle && navbarMenu) {
    mobileMenuToggle.addEventListener('click', () => {
      mobileMenuToggle.classList.toggle('active');
      navbarMenu.classList.toggle('active');
    });
    
    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
      if (!e.target.closest('.navbar-custom')) {
        mobileMenuToggle.classList.remove('active');
        navbarMenu.classList.remove('active');
      }
    });
    
    // Close menu when clicking nav link
    const navLinks = navbarMenu.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
      link.addEventListener('click', () => {
        mobileMenuToggle.classList.remove('active');
        navbarMenu.classList.remove('active');
      });
    });
  }
  
  // Theme toggle
  const themeToggle = document.getElementById('themeToggle');
  if (themeToggle) {
    themeToggle.addEventListener('click', () => {
      const newTheme = toggleTheme();
      showToast(
        `Switched to ${newTheme} mode`,
        'success',
        2000
      );
    });
  }
  
  // My Journey dropdown toggle
  const myJourneysToggle = document.getElementById('myJourneysToggle');
  const myJourneysDropdown = document.getElementById('myJourneysDropdown');
  
  if (myJourneysToggle && myJourneysDropdown) {
    myJourneysToggle.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      myJourneysDropdown.classList.toggle('active');
    });
    
    // Close dropdown when clicking outside
    document.addEventListener('click', (e) => {
      if (!e.target.closest('#myJourneysDropdown')) {
        myJourneysDropdown.classList.remove('active');
      }
    });
    
    // Close dropdown when clicking a menu item
    const dropdownItems = myJourneysDropdown.querySelectorAll('.dropdown-item');
    dropdownItems.forEach(item => {
      item.addEventListener('click', () => {
        myJourneysDropdown.classList.remove('active');
      });
    });
  }
}

// Auto-initialize navbar if this script is loaded
document.addEventListener('DOMContentLoaded', () => {
  // Get active page from body data attribute or URL
  const activePage = document.body.dataset.page || 
                     window.location.pathname.split('/').pop().replace('.html', '') || 
                     'home';
  createNavbar(activePage);
});
