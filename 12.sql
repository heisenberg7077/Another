create DATABASE agri_v;
USE agri_v;
CREATE TABLE crops (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    season VARCHAR(100),
    ec_range VARCHAR(50),
    land_size_min DECIMAL(10,2),
    land_size_max DECIMAL(10,2),
    soil_types TEXT,
    crop_category VARCHAR(50),
    image_url VARCHAR(500) NULL,
    description TEXT NULL,
    average_duration_weeks INT DEFAULT 12,
    difficulty ENUM('Easy','Medium','Hard') DEFAULT 'Medium'
);

CREATE TABLE fertilizers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,
    week VARCHAR(50),
    name VARCHAR(100),
    quantity VARCHAR(50),
    price VARCHAR(50),
    gap_days INT,
    FOREIGN KEY (crop_id) REFERENCES crops(id)
);

CREATE TABLE pesticides (
    id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,
    week VARCHAR(50),
    name VARCHAR(100),
    application VARCHAR(100),
    quantity VARCHAR(50),
    price VARCHAR(50),
    FOREIGN KEY (crop_id) REFERENCES crops(id)
);

CREATE TABLE crop_guides (
    id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT UNIQUE NOT NULL,
    overview TEXT,
    climate TEXT,
    soil TEXT,
    land_preparation TEXT,
    sowing TEXT,
    irrigation TEXT,
    nutrient_management TEXT,
    weed_management TEXT,
    pests_diseases TEXT,
    harvesting TEXT,
    yield_info TEXT,
    FOREIGN KEY (crop_id) REFERENCES crops(id)
);

CREATE TABLE crop_stages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,
    stage_number INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    start_week INT NOT NULL,
    end_week INT NOT NULL,
    tasks TEXT NOT NULL,
    video_url VARCHAR(255) DEFAULT NULL,
    detailed_description TEXT,
    equipment_needed TEXT,
    time_required VARCHAR(50),
    difficulty_level ENUM('Easy', 'Medium', 'Hard') DEFAULT 'Medium',
    FOREIGN KEY (crop_id) REFERENCES crops(id)
);

-- New table for detailed weekly tasks
CREATE TABLE weekly_tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,
    week_number INT NOT NULL,
    task_title VARCHAR(200) NOT NULL,
    task_description TEXT NOT NULL,
    task_type ENUM('fertilizer', 'pesticide', 'irrigation', 'pruning', 'harvesting', 'monitoring', 'maintenance', 'other') NOT NULL,
    priority ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium',
    estimated_duration VARCHAR(50),
    equipment_needed TEXT,
    materials_needed TEXT,
    video_url VARCHAR(255),
    image_url VARCHAR(255),
    step_by_step_instructions TEXT,
    tips_and_notes TEXT,
    weather_conditions TEXT,
    safety_precautions TEXT,
    expected_outcome TEXT,
    FOREIGN KEY (crop_id) REFERENCES crops(id),
    UNIQUE KEY unique_crop_week_task (crop_id, week_number, task_title)
);

-- Enhanced video management system

-- ================= Disease Management Tables =================

-- Disease categories for crops (base table)
DROP TABLE IF EXISTS disease_management_videos;
DROP TABLE IF EXISTS crop_diseases;
DROP TABLE IF EXISTS disease_categories;

CREATE TABLE IF NOT EXISTS disease_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    disease_name VARCHAR(100) NOT NULL,
    description TEXT,
    symptoms TEXT,
    common_causes TEXT,
    prevention_measures TEXT,
    treatment_methods TEXT,
    severity_level ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crop-specific diseases
CREATE TABLE IF NOT EXISTS crop_diseases (
    crop_disease_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,
    disease_id INT NOT NULL,
    typical_onset_week_start INT,
    typical_onset_week_end INT,
    risk_factors TEXT,
    crop_specific_treatment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE,
    FOREIGN KEY (disease_id) REFERENCES disease_categories(id) ON DELETE CASCADE,
    INDEX idx_crop_disease_week (crop_id, typical_onset_week_start, typical_onset_week_end)
);

-- Enhanced crop videos table
CREATE TABLE IF NOT EXISTS crop_videos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,
    week_number INT NULL,
    video_title VARCHAR(200) NOT NULL,
    video_url VARCHAR(500) NOT NULL,
    video_type ENUM('tutorial', 'problem_solving', 'disease_management', 'pest_control', 'maintenance', 'harvesting', 'general') NOT NULL,
    duration_minutes INT,
    description TEXT,
    thumbnail_url VARCHAR(500),
    is_featured BOOLEAN DEFAULT FALSE,
    relevance_start_week INT,
    relevance_end_week INT,
    difficulty_level ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'intermediate',
    prerequisites TEXT,
    learning_outcomes TEXT,
    expert_tips TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE,
    INDEX idx_crop_week_type (crop_id, week_number, video_type)
);

-- Enhanced process videos table
CREATE TABLE IF NOT EXISTS process_videos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    process_category ENUM('land_preparation', 'soil_testing', 'sowing', 'planting', 
                        'applying_fertilizer', 'applying_pesticide', 'irrigation', 
                        'pruning', 'harvesting', 'storage', 'equipment_usage', 'safety_procedures') NOT NULL,
    process_type VARCHAR(100) NULL,
    video_title VARCHAR(200) NOT NULL,
    video_url VARCHAR(500) NOT NULL,
    duration_minutes INT,
    description TEXT,
    thumbnail_url VARCHAR(500),
    is_featured BOOLEAN DEFAULT FALSE,
    applicable_crops TEXT,
    seasonal_relevance TEXT,
    equipment_needed TEXT,
    safety_precautions TEXT,
    best_practices TEXT,
    common_mistakes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_process_category (process_category)
);

-- Video problem solutions
CREATE TABLE IF NOT EXISTS video_problems (
    problem_id INT AUTO_INCREMENT PRIMARY KEY,
    problem_category ENUM('disease', 'pest', 'nutrient_deficiency', 'environmental_stress', 
                        'equipment_issue', 'general_maintenance') NOT NULL,
    problem_title VARCHAR(200) NOT NULL,
    description TEXT,
    symptoms TEXT,
    solution_steps TEXT,
    prevention_tips TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drop dependent tables first to maintain proper order
DROP TABLE IF EXISTS video_problem_solutions;
DROP TABLE IF EXISTS video_problems;

-- Video problems table must be created before it can be referenced
CREATE TABLE IF NOT EXISTS video_problems (
    id INT AUTO_INCREMENT PRIMARY KEY,
    problem_category ENUM('disease', 'pest', 'nutrient_deficiency', 'environmental_stress', 
                        'equipment_issue', 'general_maintenance') NOT NULL,
    problem_title VARCHAR(200) NOT NULL,
    description TEXT,
    symptoms TEXT,
    solution_steps TEXT,
    prevention_tips TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Link videos to specific problems they address
CREATE TABLE IF NOT EXISTS video_problem_solutions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    video_id INT,
    process_video_id INT,
    problem_id INT NOT NULL,
    relevance_score INT DEFAULT 5,
    solution_summary TEXT,
    expert_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (video_id) REFERENCES crop_videos(id) ON DELETE CASCADE,
    FOREIGN KEY (process_video_id) REFERENCES process_videos(id) ON DELETE CASCADE,
    FOREIGN KEY (problem_id) REFERENCES video_problems(id) ON DELETE CASCADE,
    -- Using a trigger instead of CHECK constraint for MySQL compatibility
    INDEX idx_problem_videos (problem_id, video_id, process_video_id)
);

-- Add trigger to enforce that either video_id or process_video_id must be NOT NULL
DELIMITER //
CREATE TRIGGER video_problem_solutions_validation
BEFORE INSERT ON video_problem_solutions
FOR EACH ROW
BEGIN
    IF NEW.video_id IS NULL AND NEW.process_video_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Either video_id or process_video_id must not be NULL';
    END IF;
END;//
DELIMITER ;

-- Disease management videos
CREATE TABLE IF NOT EXISTS disease_management_videos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    disease_id INT NOT NULL,
    video_id INT NULL,
    process_video_id INT NULL,
    management_phase ENUM('identification', 'prevention', 'treatment', 'recovery') NOT NULL,
    effectiveness_rating INT DEFAULT 5,
    expert_recommendations TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (disease_id) REFERENCES disease_categories(id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES crop_videos(id) ON DELETE CASCADE,
    FOREIGN KEY (process_video_id) REFERENCES process_videos(id) ON DELETE CASCADE,
    CHECK (video_id IS NOT NULL OR process_video_id IS NOT NULL),
    INDEX idx_disease_phase (disease_id, management_phase)
);

-- User Management Tables

-- Roles table
CREATE TABLE IF NOT EXISTS roles (
    role_id INT AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id)
);

-- Users table with enhanced fields
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    profile_image VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    role_id INT DEFAULT 2,
    PRIMARY KEY (user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- User sessions tracking
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP NULL DEFAULT NULL,
    expires_at TIMESTAMP NULL DEFAULT NULL,
    is_active BOOLEAN DEFAULT true,
    PRIMARY KEY (session_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- User activity logs
CREATE TABLE IF NOT EXISTS activity_logs (
    log_id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    activity_type ENUM('login', 'logout', 'profile_update', 'password_change', 'task_complete', 'crop_guidance_view'),
    description TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- User preferences
CREATE TABLE IF NOT EXISTS user_preferences (
    user_id INT NOT NULL,
    preference_key VARCHAR(50) NOT NULL,
    preference_value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, preference_key),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Password reset tokens
CREATE TABLE IF NOT EXISTS password_resets (
    reset_id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL DEFAULT NULL,
    is_used BOOLEAN DEFAULT false,
    PRIMARY KEY (reset_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Initial data: Create default roles
INSERT INTO roles (role_name, description) VALUES 
('admin', 'Full system access and management capabilities'),
('user', 'Standard user access for crop guidance and tasks')
ON DUPLICATE KEY UPDATE role_name=role_name;

-- Create default admin user (password: admin123)
INSERT INTO users (username, password_hash, email, full_name, role_id, is_verified) VALUES 
('admin', '123', 'admin@presicide.com', 'System Administrator', 1, true)
ON DUPLICATE KEY UPDATE username=username;

CREATE TABLE soil_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    ph_range VARCHAR(50),
    drainage VARCHAR(50),
    water_retention VARCHAR(50),
    fertility_level VARCHAR(50),
    suitable_crops TEXT
);

-- Crop Monitoring Sessions Table
CREATE TABLE crop_monitoring_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    crop_id INT NOT NULL,
    crop_name VARCHAR(100) NOT NULL,
    land_size DECIMAL(10,2) NULL,
    soil_type VARCHAR(100) NOT NULL,
    start_date DATETIME NOT NULL,
    current_week INT DEFAULT 1,
    status ENUM('active', 'completed', 'paused', 'cancelled') DEFAULT 'active',
    total_weeks INT DEFAULT 20,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE
);

-- New table for crop progress tracking
CREATE TABLE crop_progress_tracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    week_number INT NOT NULL,
    task_id INT,
    completion_status ENUM('not_started', 'in_progress', 'completed', 'skipped') DEFAULT 'not_started',
    completion_date DATETIME,
    notes TEXT,
    photos_urls TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES crop_monitoring_sessions(id),
    FOREIGN KEY (task_id) REFERENCES weekly_tasks(id)
);

-- Task Completions Table
CREATE TABLE task_completions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    task_type ENUM('fertilizer', 'pesticide', 'irrigation', 'harvesting', 'other') NOT NULL,
    task_name VARCHAR(200) NOT NULL,
    week_number INT NOT NULL,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (session_id) REFERENCES crop_monitoring_sessions(id) ON DELETE CASCADE
);

-- Weekly Progress Table
CREATE TABLE weekly_progress (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    week_number INT NOT NULL,
    status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
    tasks_completed INT DEFAULT 0,
    total_tasks INT DEFAULT 0,
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES crop_monitoring_sessions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_session_week (session_id, week_number)
);

-- Playlists per crop
CREATE TABLE crop_playlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    cover_image_url VARCHAR(500),
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE
);

CREATE TABLE crop_playlist_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    playlist_id INT NOT NULL,
    video_id INT NOT NULL,
    position INT DEFAULT 0,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (playlist_id) REFERENCES crop_playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES crop_videos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_playlist_video (playlist_id, video_id)
);

-- View for dynamic total weeks per crop (prefers weekly_tasks, then crop_stages)
DROP VIEW IF EXISTS crop_total_weeks;
CREATE VIEW crop_total_weeks AS
SELECT 
    c.id AS crop_id,
    c.name AS crop_name,
    COALESCE(w.max_week, s.max_end_week, 12) AS total_weeks
FROM crops c
LEFT JOIN (
    SELECT crop_id, MAX(week_number) AS max_week
    FROM weekly_tasks
    GROUP BY crop_id
) w ON w.crop_id = c.id
LEFT JOIN (
    SELECT crop_id, MAX(end_week) AS max_end_week
    FROM crop_stages
    GROUP BY crop_id
) s ON s.crop_id = c.id;

-- Helpful index for weekly task lookups
CREATE INDEX IF NOT EXISTS idx_weekly_tasks_crop_week ON weekly_tasks (crop_id, week_number);

-- ================= Crop Browser Summary View =================
DROP VIEW IF EXISTS crop_browser_summary;
CREATE VIEW crop_browser_summary AS
SELECT 
  c.id AS crop_id,
  c.name AS crop_name,
  c.crop_category,
  c.season,
  c.soil_types,
  c.image_url,
  c.description,
  c.difficulty,
  c.average_duration_weeks AS duration_weeks,
  COALESCE(ct.total_weeks, c.average_duration_weeks, 12) AS calculated_duration_weeks,
  COUNT(DISTINCT cv.id) AS total_videos,
  COUNT(DISTINCT wt.id) AS total_tasks,
  COUNT(DISTINCT cs.id) AS total_stages,
  cg.yield_info
FROM crops c
LEFT JOIN crop_total_weeks ct ON c.id = ct.crop_id
LEFT JOIN crop_videos cv ON cv.crop_id = c.id
LEFT JOIN weekly_tasks wt ON wt.crop_id = c.id
LEFT JOIN crop_stages cs ON cs.crop_id = c.id
LEFT JOIN crop_guides cg ON cg.crop_id = c.id
GROUP BY c.id, c.name, c.crop_category, c.season, c.soil_types, c.image_url, c.description, c.difficulty, c.average_duration_weeks, ct.total_weeks, cg.yield_info;

-- ================= Views for Active Weeks (only weeks with activity) =================
DROP VIEW IF EXISTS active_weeks;
CREATE VIEW active_weeks AS
SELECT DISTINCT
    wt.crop_id,
    wt.week_number
FROM weekly_tasks wt
WHERE wt.week_number IS NOT NULL
ORDER BY wt.crop_id, wt.week_number;

DROP VIEW IF EXISTS crop_active_weeks_summary;
CREATE VIEW crop_active_weeks_summary AS
SELECT
    wt.crop_id,
    COUNT(DISTINCT wt.week_number) AS active_week_count,
    MIN(wt.week_number) AS first_active_week,
    MAX(wt.week_number) AS last_active_week
FROM weekly_tasks wt
WHERE wt.week_number IS NOT NULL
GROUP BY wt.crop_id;




-- ================= Additional Feature Tables =================
CREATE TABLE IF NOT EXISTS analytics_metrics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    crop_id INT,
    metric_type ENUM('yield', 'cost', 'water_usage', 'fertilizer_efficiency'),
    value DECIMAL(10,2),
    recorded_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (crop_id) REFERENCES crops(id)
);

CREATE TABLE IF NOT EXISTS irrigation_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    crop_monitoring_session_id INT,
    water_amount DECIMAL(10,2),
    soil_moisture DECIMAL(5,2),
    irrigation_date DATETIME,
    weather_condition VARCHAR(50),
    FOREIGN KEY (crop_monitoring_session_id) REFERENCES crop_monitoring_sessions(id)
);

CREATE TABLE IF NOT EXISTS yield_predictions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    crop_id INT,
    predicted_yield DECIMAL(10,2),
    confidence_score DECIMAL(5,2),
    factors_considered JSON,
    prediction_date DATE,
    FOREIGN KEY (crop_id) REFERENCES crops(id)
);

CREATE TABLE IF NOT EXISTS community_posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    title VARCHAR(200),
    content TEXT,
    post_type ENUM('success_story', 'question', 'tip', 'problem'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    likes INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS archived_monitoring_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    original_data_id INT,
    data_type VARCHAR(50),
    archived_date DATE,
    data_json JSON
);

-- ================= Weekly Guidance Support Tables =================

-- Tips for each crop and week
CREATE TABLE IF NOT EXISTS crop_tips (
    tip_id INT AUTO_INCREMENT,
    crop_id INT NOT NULL,
    week_number INT NOT NULL,
    tip_type ENUM('general', 'preventive', 'technical', 'cost_saving', 'quality_improvement'),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    importance_level ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    source VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tip_id),
    FOREIGN KEY (crop_id) REFERENCES crops(id),
    INDEX idx_crop_week (crop_id, week_number)
);

-- Weather-based recommendations
CREATE TABLE IF NOT EXISTS weather_recommendations (
    recommendation_id INT AUTO_INCREMENT,
    crop_id INT NOT NULL,
    week_number INT NOT NULL,
    weather_condition ENUM('sunny', 'rainy', 'cloudy', 'windy', 'hot', 'cold', 'humid', 'dry'),
    recommendation_type ENUM('irrigation', 'fertilizer', 'pesticide', 'general'),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    valid_from DATE,
    valid_until DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (recommendation_id),
    FOREIGN KEY (crop_id) REFERENCES crops(id),
    INDEX idx_crop_week_weather (crop_id, week_number, weather_condition)
);

-- Task dependencies and relationships
CREATE TABLE IF NOT EXISTS task_dependencies (
    dependency_id INT AUTO_INCREMENT,
    crop_id INT NOT NULL,
    week_number INT NOT NULL,
    task_id INT NOT NULL,
    dependent_task_id INT NOT NULL,
    dependency_type ENUM('must_complete_before', 'should_complete_before', 'can_complete_parallel'),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (dependency_id),
    FOREIGN KEY (crop_id) REFERENCES crops(id),
    FOREIGN KEY (task_id) REFERENCES weekly_tasks(id),
    FOREIGN KEY (dependent_task_id) REFERENCES weekly_tasks(id),
    INDEX idx_crop_week_task (crop_id, week_number, task_id)
);

-- Enhanced crop progress tracking with detailed metrics
CREATE TABLE IF NOT EXISTS crop_progress_metrics (
    metric_id INT AUTO_INCREMENT,
    crop_id INT NOT NULL,
    monitoring_session_id INT NOT NULL,
    week_number INT NOT NULL,
    metric_type ENUM('growth_rate', 'water_usage', 'nutrient_levels', 'pest_pressure', 'disease_incidence', 'yield_estimate'),
    metric_value DECIMAL(10,2),
    unit VARCHAR(50),
    measured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    recorded_by INT,
    PRIMARY KEY (metric_id),
    FOREIGN KEY (crop_id) REFERENCES crops(id),
    FOREIGN KEY (monitoring_session_id) REFERENCES crop_monitoring_sessions(id),
    FOREIGN KEY (recorded_by) REFERENCES users(user_id),
    INDEX idx_monitoring_week (monitoring_session_id, week_number)
);

-- Sample task dependencies
INSERT INTO task_dependencies (crop_id, week_number, task_id, dependent_task_id, dependency_type, notes)
SELECT 
    t1.crop_id,
    t1.week_number,
    t1.id as task_id,
    t2.id as dependent_task_id,
    'must_complete_before',
    'Fertilizer application must be completed before irrigation'
FROM weekly_tasks t1
JOIN weekly_tasks t2 ON t1.crop_id = t2.crop_id AND t1.week_number = t2.week_number
WHERE t1.task_type = 'fertilizer' AND t2.task_type = 'irrigation'
AND t1.crop_id = 1 AND t1.week_number = 3
LIMIT 1;

-- ================= Performance Indexes =================
-- Adapt index names/columns to existing schema
ALTER TABLE crop_monitoring_sessions ADD INDEX IF NOT EXISTS idx_start_date (start_date);
ALTER TABLE task_completions ADD INDEX IF NOT EXISTS idx_completed_at (completed_at);

INSERT INTO crops (name, season, ec_range, land_size_min, land_size_max, soil_types, crop_category, image_url, description, average_duration_weeks, difficulty)
VALUES
('Tomato', 'Kharif/Rabi/Summer', '1.5 - 2.5 dS/m', 0.1, 20.0, 'Sandy Loam,Clay Loam,Loamy Soil', 'Vegetable', '🍅', 'A fast-growing vegetable crop suitable for warm climates. Rich in vitamins and widely consumed.', 12, 'Easy'),
('Rice', 'Kharif/Rabi', '1.0 - 3.0 dS/m', 0.1, 200.0, 'Clayey Soil,Alluvial Soil,Black Soil', 'Cereal', '🌾', 'Staple food crop requiring flooded conditions. High-yielding cereal for large-scale farming.', 20, 'Medium'),
('Wheat', 'Rabi', '1.2 - 2.0 dS/m', 0.1, 500.0, 'Loamy Soil,Clay Loam,Alluvial Soil', 'Cereal', '🌾', 'Major cereal crop grown in cool, dry climates. Essential for bread and flour production.', 20, 'Medium'),
('Maize', 'Kharif/Rabi', '1.0 - 1.5 dS/m', 0.1, 100.0, 'Sandy Loam,Loamy Soil,Black Soil', 'Cereal', '🌽', 'Versatile cereal crop used for food, feed, and industrial purposes. Grows well in warm weather.', 16, 'Easy'),
('Potato', 'Rabi', '1.5 - 2.5 dS/m', 0.1, 50.0, 'Sandy Loam,Loamy Soil,Well-drained Soil', 'Vegetable', '🥔', 'High-yielding tuber crop grown in cool climates. Requires well-drained soil and regular irrigation.', 16, 'Medium'),
('Onion', 'Rabi/Summer', '0.8 - 1.6 dS/m', 0.1, 20.0, 'Sandy Loam,Loamy Soil,Red Soil', 'Vegetable', '🧅', 'Essential bulb crop with high market demand. Requires careful water management and pest control.', 14, 'Medium'),
('Sugarcane', 'Annual (Plant & Ratoon)', '1.0 - 1.7 dS/m', 0.5, 200.0, 'Deep Loamy Soil,Alluvial Soil,Black Soil', 'Cash Crop', '🎋', 'Long-duration cash crop for sugar production. Requires abundant water and warm tropical climate.', 48, 'Hard'),
('Cotton', 'Kharif', '1.7 - 3.2 dS/m', 0.5, 500.0, 'Black Soil,Clay Loam,Alluvial Soil', 'Fiber Crop', '☁️', 'Major fiber crop grown in warm, dry climates. Requires careful pest management and irrigation.', 24, 'Hard'),
('Groundnut', 'Kharif/Rabi/Summer', '1.0 - 1.5 dS/m', 0.1, 100.0, 'Sandy Loam,Red Soil,Loamy Soil', 'Oilseed', '🥜', 'Important oilseed crop rich in protein. Grows well in sandy loam soils with moderate rainfall.', 18, 'Easy'),
('Soybean', 'Kharif', '1.0 - 2.0 dS/m', 0.5, 200.0, 'Clay Loam,Black Soil,Alluvial Soil', 'Oilseed', '🫘', 'Protein-rich oilseed legume. Improves soil fertility through nitrogen fixation.', 16, 'Easy'),
-- Additional crops with realistic land size ranges
('Pigeon pea', 'Kharif/Rabi', '1.0 - 2.0 dS/m', 0.1, 50.0, 'Loamy Soil', 'Pulse', '🫘', 'Drought-tolerant pulse crop. Improves soil health and provides high-protein food.', 20, 'Easy'),
('Green gram', 'Kharif/Summer', '1.0 - 1.5 dS/m', 0.1, 30.0, 'Sandy Loam', 'Pulse', '🫛', 'Short-duration pulse crop. Excellent for crop rotation and soil improvement.', 10, 'Easy'),
('Black gram', 'Kharif/Summer', '1.0 - 1.5 dS/m', 0.1, 30.0, 'Loamy Soil', 'Pulse', '⚫', 'Nutritious pulse crop grown in warm climates. Used for dal and other food products.', 12, 'Easy'),
('Chickpea', 'Rabi', '1.0 - 1.5 dS/m', 0.1, 50.0, 'Sandy Loam', 'Pulse', '🫘', 'Major pulse crop for cool season. High in protein and widely consumed.', 18, 'Medium'),
('Lentil', 'Rabi', '1.0 - 1.5 dS/m', 0.1, 30.0, 'Alluvial Soil', 'Pulse', '🟤', 'Cool-season pulse crop. Quick-growing and nutritious legume.', 14, 'Easy'),
('Banana', 'Year-round', '1.0 - 2.0 dS/m', 0.1, 100.0, 'Alluvial Soil', 'Fruit', '🍌', 'Perennial fruit crop requiring warm, humid climate. High-yielding with year-round production.', 52, 'Medium'),
('Mango', 'Summer', '1.0 - 2.0 dS/m', 0.1, 200.0, 'Loamy Soil', 'Fruit', '🥭', 'King of fruits. Long-duration perennial crop requiring tropical climate.', 260, 'Hard'),
('Papaya', 'Year-round', '1.0 - 2.0 dS/m', 0.1, 50.0, 'Sandy Loam', 'Fruit', '🍈', 'Fast-growing fruit crop. Produces year-round in tropical climates.', 40, 'Easy'),
('Guava', 'Year-round', '1.0 - 2.0 dS/m', 0.1, 50.0, 'Red Loamy Soil', 'Fruit', '🍐', 'Hardy fruit crop adaptable to various soils. Rich in vitamin C.', 104, 'Medium'),
('Pomegranate', 'Year-round', '1.0 - 2.0 dS/m', 0.1, 50.0, 'Black Soil', 'Fruit', '🍎', 'Drought-tolerant fruit crop. High market value and medicinal properties.', 104, 'Medium'),
('Turmeric', 'Kharif', '1.0 - 2.0 dS/m', 0.1, 20.0, 'Loamy Soil', 'Spice', '🟡', 'Valuable spice crop with medicinal properties. Requires warm, humid climate.', 32, 'Medium'),
('Ginger', 'Kharif', '1.0 - 2.0 dS/m', 0.1, 20.0, 'Loamy Soil', 'Spice', '🫚', 'High-value spice crop. Requires well-drained soil and regular irrigation.', 32, 'Medium'),
('Chili', 'Kharif/Rabi', '1.0 - 2.0 dS/m', 0.1, 20.0, 'Loamy Soil', 'Spice', '🌶️', 'Important spice crop with high market demand. Requires warm climate.', 20, 'Medium'),
('Coriander', 'Rabi', '1.0 - 2.0 dS/m', 0.1, 10.0, 'Sandy Loam', 'Spice', '🌿', 'Quick-growing herb and spice crop. Both leaves and seeds are valuable.', 12, 'Easy'),
('Cumin', 'Rabi', '1.0 - 2.0 dS/m', 0.1, 10.0, 'Sandy Soil', 'Spice', '🟤', 'Aromatic spice crop for cool season. High market value.', 16, 'Medium'),
('Tea', 'Year-round', '1.0 - 2.0 dS/m', 0.5, 200.0, 'Acidic Loamy Soil', 'Cash Crop', '🍵', 'Perennial cash crop for hilly regions. Requires acidic soil and cool climate.', 260, 'Hard'),
('Coffee', 'Year-round', '1.0 - 2.0 dS/m', 0.5, 200.0, 'Loamy Soil', 'Cash Crop', '☕', 'High-value perennial crop. Grows in shade with moderate rainfall.', 260, 'Hard'),
('Rubber', 'Year-round', '1.0 - 2.0 dS/m', 1.0, 500.0, 'Laterite Soil', 'Cash Crop', '⚫', 'Long-duration plantation crop. Requires tropical climate with high rainfall.', 312, 'Hard'),
('Coconut', 'Year-round', '1.0 - 2.0 dS/m', 0.5, 200.0, 'Sandy Loam', 'Cash Crop', '🥥', 'Versatile palm crop for coastal areas. Provides multiple products.', 260, 'Medium'),
('Jute', 'Kharif', '1.0 - 2.0 dS/m', 0.1, 50.0, 'Alluvial Soil', 'Fiber Crop', '🟫', 'Natural fiber crop for warm, humid climate. Used for sacks and textiles.', 16, 'Medium');

-- ================= Sample Crop Tips Data (INSERT AFTER CROPS) =================
INSERT INTO crop_tips (crop_id, week_number, tip_type, title, description, importance_level) VALUES
-- Tomato (crop_id = 1)
(1, 1, 'technical', 'Seed Selection', 'Choose disease-resistant tomato varieties suitable for your region. Hybrid varieties often give better yields.', 'high'),
(1, 1, 'preventive', 'Nursery Preparation', 'Prepare nursery beds with well-decomposed FYM and ensure proper drainage to prevent damping-off disease.', 'critical'),
(1, 2, 'technical', 'Transplanting Time', 'Transplant seedlings when they are 4-6 weeks old with 4-5 true leaves. Transplant in evening to reduce stress.', 'high'),
(1, 3, 'technical', 'Optimal Watering Time', 'Water tomato plants early in the morning to reduce evaporation loss and prevent leaf diseases.', 'high'),
(1, 3, 'preventive', 'Disease Prevention', 'Monitor leaves for early signs of blight - small brown spots with yellow halos.', 'critical'),
(1, 3, 'cost_saving', 'Natural Pest Control', 'Consider companion planting with basil to naturally repel pests and improve tomato flavor.', 'medium'),
(1, 4, 'technical', 'Staking Support', 'Provide stakes or cages to support growing plants. This improves air circulation and reduces disease risk.', 'high'),
(1, 5, 'preventive', 'Fruit Borer Management', 'Install pheromone traps to monitor and control fruit borer population before they damage fruits.', 'critical'),
(1, 6, 'quality_improvement', 'Pruning Technique', 'Remove lower leaves and suckers to improve air circulation and direct energy to fruit production.', 'medium'),

-- Rice (crop_id = 2)
(2, 1, 'technical', 'Land Leveling', 'Ensure proper land leveling for uniform water distribution. Use laser leveling for best results.', 'high'),
(2, 2, 'preventive', 'Seed Treatment', 'Treat seeds with Carbendazim to prevent seed-borne diseases before sowing.', 'critical'),
(2, 3, 'technical', 'Transplanting Depth', 'Maintain 2-3 seedlings per hill at 2-3 cm depth for optimal tillering.', 'high'),
(2, 4, 'cost_saving', 'Water Management', 'Maintain 2-5 cm water level. Drain water 10 days before harvest to reduce harvesting cost.', 'medium'),

-- Wheat (crop_id = 3)
(3, 1, 'technical', 'Seed Rate', 'Use 100-125 kg seed per hectare. Higher seed rate for late sowing.', 'high'),
(3, 2, 'preventive', 'Weed Control', 'Apply pre-emergence herbicide within 3 days of sowing to control weeds effectively.', 'high'),
(3, 3, 'technical', 'Crown Root Irrigation', 'First irrigation at crown root stage (20-25 DAS) is critical for good tillering.', 'critical'),

-- Maize (crop_id = 4)
(4, 1, 'technical', 'Spacing', 'Maintain 60 cm row spacing and 20 cm plant spacing for optimal growth.', 'high'),
(4, 2, 'preventive', 'Stem Borer Control', 'Apply Carbofuran granules in leaf whorls at 15-20 DAS to prevent stem borer damage.', 'critical'),
(4, 3, 'quality_improvement', 'Detasseling', 'Remove tassels from alternate rows in hybrid seed production for better pollination.', 'medium'),

-- Potato (crop_id = 5)
(5, 1, 'technical', 'Seed Tuber Selection', 'Use certified seed tubers of 30-40g size. Cut larger tubers ensuring each piece has 2-3 eyes.', 'critical'),
(5, 2, 'preventive', 'Earthing Up', 'Perform earthing up at 30 DAS to prevent tuber greening and improve yield.', 'high'),
(5, 3, 'technical', 'Irrigation Schedule', 'Irrigate at 7-10 day intervals. Avoid water stress during tuber formation stage.', 'high'),

-- Onion (crop_id = 6)
(6, 1, 'technical', 'Nursery Management', 'Sow seeds in raised nursery beds with proper drainage. Seedlings ready in 6-8 weeks.', 'high'),
(6, 2, 'preventive', 'Thrips Control', 'Monitor for thrips damage. Apply neem oil spray at early infestation stage.', 'high'),
(6, 3, 'cost_saving', 'Mulching', 'Apply organic mulch to conserve moisture and reduce irrigation frequency.', 'medium'),

-- Sugarcane (crop_id = 7)
(7, 1, 'technical', 'Sett Treatment', 'Treat setts with fungicide and insecticide before planting to ensure healthy germination.', 'critical'),
(7, 2, 'preventive', 'Gap Filling', 'Fill gaps within 30 days of planting to maintain uniform crop stand.', 'high'),
(7, 4, 'technical', 'Detrashing', 'Remove dry leaves at 120 days to improve air circulation and reduce pest incidence.', 'medium'),

-- Cotton (crop_id = 8)
(8, 1, 'technical', 'Seed Treatment', 'Treat seeds with Imidacloprid and fungicide for protection against early pests and diseases.', 'critical'),
(8, 3, 'preventive', 'Pink Bollworm Management', 'Install pheromone traps @ 15/hectare to monitor and control pink bollworm.', 'critical'),
(8, 4, 'quality_improvement', 'Plant Growth Regulator', 'Apply NAA or Mepiquat chloride to control excessive vegetative growth.', 'medium'),

-- Groundnut (crop_id = 9)
(9, 1, 'technical', 'Seed Inoculation', 'Treat seeds with Rhizobium culture for better nitrogen fixation and yield.', 'high'),
(9, 2, 'preventive', 'Gypsum Application', 'Apply gypsum @ 400 kg/ha at flowering stage for better pod filling.', 'critical'),
(9, 3, 'technical', 'Pegging Stage Care', 'Ensure adequate soil moisture during pegging stage for good pod development.', 'high'),

-- Soybean (crop_id = 10)
(10, 1, 'technical', 'Seed Treatment', 'Treat seeds with Rhizobium + PSB culture for better nodulation and phosphorus uptake.', 'high'),
(10, 2, 'preventive', 'Yellow Mosaic Control', 'Control whitefly population to prevent yellow mosaic virus spread.', 'critical'),
(10, 3, 'cost_saving', 'Foliar Nutrition', 'Apply 2% DAP spray at flowering for better pod setting and yield.', 'medium');

-- ================= Sample Weather Recommendations (INSERT AFTER CROPS) =================
INSERT INTO weather_recommendations (crop_id, week_number, weather_condition, recommendation_type, title, description, priority) VALUES
-- Tomato weather recommendations
(1, 1, 'rainy', 'general', 'Nursery Protection', 'Protect nursery beds from heavy rain with plastic sheets or temporary shelter.', 'high'),
(1, 2, 'hot', 'irrigation', 'Seedling Care', 'Water transplanted seedlings twice daily during hot weather to prevent wilting.', 'critical'),
(1, 3, 'rainy', 'pesticide', 'Fungicide Application', 'Apply fungicide before rain to prevent disease spread.', 'high'),
(1, 3, 'hot', 'irrigation', 'Heat Stress Management', 'Increase watering frequency and consider shade cloth during extreme heat.', 'critical'),
(1, 3, 'windy', 'general', 'Support Structure Check', 'Ensure all support stakes are secure to prevent wind damage.', 'medium'),
(1, 4, 'humid', 'pesticide', 'Disease Prevention', 'High humidity increases disease risk. Apply preventive fungicide spray.', 'high'),
(1, 5, 'dry', 'irrigation', 'Drought Management', 'Increase irrigation frequency. Apply mulch to conserve soil moisture.', 'high'),

-- Rice weather recommendations
(2, 1, 'rainy', 'general', 'Field Preparation', 'Heavy rain is ideal for puddling. Prepare fields when soil is saturated.', 'medium'),
(2, 2, 'hot', 'irrigation', 'Water Level Maintenance', 'Maintain 5-7 cm water level in hot weather to prevent stress.', 'critical'),
(2, 3, 'cloudy', 'fertilizer', 'Fertilizer Application', 'Apply fertilizer on cloudy days to reduce nutrient loss.', 'medium'),
(2, 4, 'windy', 'pesticide', 'Spray Timing', 'Avoid pesticide application during windy conditions.', 'high'),

-- Wheat weather recommendations
(3, 1, 'cold', 'general', 'Optimal Sowing', 'Cold weather is ideal for wheat sowing. Proceed with planting.', 'medium'),
(3, 2, 'rainy', 'general', 'Weed Control Delay', 'Postpone herbicide application until rain stops and fields dry.', 'medium'),
(3, 3, 'hot', 'irrigation', 'Crown Root Stage', 'Critical irrigation needed at crown root stage during warm weather.', 'critical'),

-- Maize weather recommendations
(4, 1, 'rainy', 'general', 'Sowing Delay', 'Avoid sowing in waterlogged conditions. Wait for proper drainage.', 'high'),
(4, 2, 'hot', 'irrigation', 'Vegetative Stage Care', 'Increase irrigation frequency during hot weather in vegetative stage.', 'high'),
(4, 3, 'windy', 'general', 'Lodging Prevention', 'Strong winds can cause lodging. Ensure proper earthing up.', 'medium'),

-- Potato weather recommendations
(5, 1, 'cold', 'general', 'Ideal Planting', 'Cool weather is perfect for potato planting. Proceed with sowing.', 'medium'),
(5, 2, 'humid', 'pesticide', 'Blight Prevention', 'High humidity increases late blight risk. Apply preventive fungicide.', 'critical'),
(5, 3, 'hot', 'irrigation', 'Tuber Formation', 'Critical irrigation needed during tuber formation in hot weather.', 'critical');


INSERT INTO fertilizers (crop_id, week, name, quantity, price, gap_days)
VALUES
-- Tomato
(1, 'Week 2', 'Urea', '20 kg/acre', '₹500', 15),
(1, 'Week 4', 'DAP', '25 kg/acre', '₹1200', 20),
-- Rice
(2, 'Week 3', 'Urea', '30 kg/acre', '₹750', 12),
(2, 'Week 6', 'MOP', '15 kg/acre', '₹650', 18),
-- Wheat
(3, 'Week 2', 'Urea', '25 kg/acre', '₹600', 14),
-- Maize
(4, 'Week 1', 'DAP', '20 kg/acre', '₹1100', 10),
-- Potato
(5, 'Week 3', 'Potash', '30 kg/acre', '₹950', 21),
-- Onion
(6, 'Week 2', 'Superphosphate', '20 kg/acre', '₹800', 15),
-- Sugarcane
(7, 'Week 4', 'Urea', '40 kg/acre', '₹1000', 20),
-- Cotton
(8, 'Week 3', 'DAP', '25 kg/acre', '₹1200', 18),
-- Groundnut
(9, 'Week 2', 'Gypsum', '20 kg/acre', '₹700', 22),
-- Soybean
(10, 'Week 2', 'Potash', '15 kg/acre', '₹850', 14);


INSERT INTO pesticides (crop_id, week, name, application, quantity, price)
VALUES
-- Tomato
(1, 'Week 5', 'Neem Oil', 'Foliar Spray', '2 ml/litre', '₹400'),
(1, 'Week 7', 'Imidacloprid', 'Soil Drench', '1 ml/litre', '₹550'),
-- Rice
(2, 'Week 4', 'Carbendazim', 'Seed Treatment', '2 g/kg seed', '₹300'),
-- Wheat
(3, 'Week 6', 'Chlorpyrifos', 'Foliar Spray', '2 ml/litre', '₹480'),
-- Maize
(4, 'Week 3', 'Metalaxyl', 'Soil Drench', '3 g/litre', '₹600'),
-- Potato
(5, 'Week 5', 'Mancozeb', 'Foliar Spray', '2 g/litre', '₹450'),
-- Onion
(6, 'Week 6', 'Dimethoate', 'Foliar Spray', '2 ml/litre', '₹500'),
-- Sugarcane
(7, 'Week 8', 'Chlorantraniliprole', 'Soil Drench', '3 ml/litre', '₹650'),
-- Cotton
(8, 'Week 7', 'Spinosad', 'Foliar Spray', '1 ml/litre', '₹700'),
-- Groundnut
(9, 'Week 5', 'Hexaconazole', 'Foliar Spray', '2 ml/litre', '₹550'),
-- Soybean
(10, 'Week 4', 'Triazole', 'Foliar Spray', '2 g/litre', '₹600');


INSERT INTO crop_guides (crop_id, overview, climate, soil, land_preparation, sowing, irrigation, nutrient_management, weed_management, pests_diseases, harvesting, yield_info)
VALUES
(1, 'Tomato is a popular vegetable crop.', 'Warm, frost-free climate', 'Well-drained loamy soil', 'Plough 2-3 times, add FYM', 'Transplanting', 'Irrigate every 7-10 days', 'NPK + organic manure', 'Manual weeding at 20-25 days', 'Fruit borer, blight', 'Harvest 60-70 days', '25-30 t/acre'),
(2, 'Rice is a staple food crop.', 'Hot, humid with rainfall', 'Clayey, alluvial', 'Puddling', 'Transplanting', 'Flood irrigation', 'Urea, DAP, MOP', 'Weedicide at 20 DAS', 'Blast, BPH', 'Harvest 120-150 days', '20-25 q/acre'),
(3, 'Wheat is a major cereal crop.', 'Cool, dry climate', 'Loamy soil', 'Deep ploughing', 'Drilling', 'Irrigate at crown root', '120 kg N/ha', 'Hand weeding', 'Rust, termites', 'Harvest 140 days', '18-22 q/acre'),
(4, 'Maize is a versatile cereal crop.', 'Warm, moderate rainfall', 'Well-drained sandy loam', '2-3 ploughings', 'Direct sowing', 'Irrigate every 10 days', 'NPK basal + top dressing', 'Weeding at 30 DAS', 'Stem borer, blight', 'Harvest 100-120 days', '25-30 q/acre'),
(5, 'Potato is a root crop.', 'Cool, frost-free', 'Well-drained sandy loam', 'Fine tilth, ridges', 'Tuber planting', 'Light irrigation weekly', 'NPK and potash', 'Manual weeding', 'Late blight, scab', 'Harvest 90-120 days', '200-250 q/acre'),
(6, 'Onion is a bulb crop.', 'Cool, dry season', 'Sandy loam soil', 'Well-prepared beds', 'Transplanting', 'Light irrigation every 5 days', 'NPK and FYM', 'Pre-emergence herbicides', 'Thrips, purple blotch', 'Harvest 100-120 days', '100-150 q/acre'),
(7, 'Sugarcane is a cash crop.', 'Tropical, warm humid', 'Deep loamy soil', 'Deep ploughing + manuring', 'Setts planting', 'Frequent irrigation', 'High NPK requirement', 'Inter-row cultivation', 'Borers, red rot', 'Harvest 10-12 months', '40-50 t/acre'),
(8, 'Cotton is a fiber crop.', 'Warm, dry climate', 'Black soil', '2-3 ploughings', 'Direct sowing', 'Irrigate at flowering stage', 'NPK application', 'Weeding at 20-25 DAS', 'Bollworm, jassids', 'Harvest 150-180 days', '8-12 q/acre'),
(9, 'Groundnut is an oilseed crop.', 'Warm climate', 'Sandy loam soil', '2 ploughings, FYM', 'Direct sowing', 'Irrigate at pegging stage', 'Gypsum + NPK', 'Weeding at 20 DAS', 'Leaf spot, rust', 'Harvest 110-120 days', '8-10 q/acre'),
(10, 'Soybean is an oilseed legume.', 'Warm, humid', 'Well-drained clay loam', 'Fine tilth', 'Direct sowing', 'Irrigate at pod filling', 'NPK + Rhizobium inoculation', 'Weeding at 30 DAS', 'Rust, root rot', 'Harvest 100-110 days', '12-15 q/acre');


INSERT INTO crop_stages (crop_id, stage_number, title, start_week, end_week, tasks, video_url, detailed_description, equipment_needed, time_required, difficulty_level)
VALUES
(1, 1, 'Nursery Preparation', 0, 2, 'Seed treatment, nursery bed', 'https://www.youtube.com/watch?v=tomato-nursery-prep', 'Prepare healthy tomato seedlings in controlled nursery environment', 'Seed trays, potting mix, watering can, labels', '2-3 hours', 'Easy'),
(1, 2, 'Vegetative Growth', 3, 6, 'Fertilization, irrigation, weeding', 'https://www.youtube.com/watch?v=tomato-vegetative-growth', 'Focus on strong root and stem development', 'Fertilizer, hoe, irrigation system', '1-2 hours daily', 'Medium'),
(1, 3, 'Flowering', 7, 9, 'Pesticide spray, staking', 'https://www.youtube.com/watch?v=tomato-flowering', 'Support flowering and prevent diseases', 'Stakes, twine, sprayer, fungicide', '2-3 hours', 'Medium'),
(1, 4, 'Harvesting', 10, 12, 'Harvest fruits', 'https://www.youtube.com/watch?v=tomato-harvesting', 'Harvest ripe tomatoes at optimal stage', 'Harvesting basket, pruning shears', '1-2 hours daily', 'Easy'),

(2, 1, 'Land Prep', 0, 2, 'Puddling, bunding', NULL, NULL, NULL, NULL, NULL),
(2, 2, 'Transplanting', 3, 4, 'Plant seedlings', NULL, NULL, NULL, NULL, NULL),
(2, 3, 'Tillering', 5, 8, 'Fertilizer top dressing', NULL, NULL, NULL, NULL, NULL),
(2, 4, 'Harvesting', 16, 20, 'Drain, harvest crop', NULL, NULL, NULL, NULL, NULL),

(3, 1, 'Sowing', 0, 1, 'Drill sowing', NULL, NULL, NULL, NULL, NULL),
(3, 2, 'Vegetative Growth', 2, 6, 'Top dressing', NULL, NULL, NULL, NULL, NULL),
(3, 3, 'Flowering', 7, 10, 'Irrigation', NULL, NULL, NULL, NULL, NULL),
(3, 4, 'Harvesting', 18, 20, 'Cutting and threshing', NULL, NULL, NULL, NULL, NULL),

(4, 1, 'Land Prep', 0, 1, 'Plough and prepare beds', NULL, NULL, NULL, NULL, NULL),
(4, 2, 'Vegetative Growth', 2, 6, 'Weeding, irrigation', NULL, NULL, NULL, NULL, NULL),
(4, 3, 'Silking', 7, 9, 'Pest management', NULL, NULL, NULL, NULL, NULL),
(4, 4, 'Harvesting', 14, 16, 'Harvest cobs', NULL, NULL, NULL, NULL, NULL),

(5, 1, 'Land Prep', 0, 1, 'Ridges and furrows', NULL, NULL, NULL, NULL, NULL),
(5, 2, 'Tuber Growth', 2, 8, 'Irrigation, earthing up', NULL, NULL, NULL, NULL, NULL),
(5, 3, 'Flowering', 9, 11, 'Blight control', NULL, NULL, NULL, NULL, NULL),
(5, 4, 'Harvesting', 12, 16, 'Digging tubers', NULL, NULL, NULL, NULL, NULL),

(6, 1, 'Nursery', 0, 2, 'Seed treatment', NULL, NULL, NULL, NULL, NULL),
(6, 2, 'Vegetative Growth', 3, 6, 'Fertilizer, irrigation', NULL, NULL, NULL, NULL, NULL),
(6, 3, 'Bulb Formation', 7, 10, 'Weeding, irrigation', NULL, NULL, NULL, NULL, NULL),
(6, 4, 'Harvesting', 11, 14, 'Pulling bulbs', NULL, NULL, NULL, NULL, NULL),

(7, 1, 'Planting', 0, 1, 'Setts sowing', NULL, NULL, NULL, NULL, NULL),
(7, 2, 'Vegetative Growth', 2, 12, 'Irrigation, weeding', NULL, NULL, NULL, NULL, NULL),
(7, 3, 'Grand Growth', 13, 20, 'Top dressing, earthing up', NULL, NULL, NULL, NULL, NULL),
(7, 4, 'Harvesting', 45, 50, 'Cutting cane', NULL, NULL, NULL, NULL, NULL),

(8, 1, 'Sowing', 0, 1, 'Direct sowing', NULL, NULL, NULL, NULL, NULL),
(8, 2, 'Vegetative', 2, 6, 'Weeding, irrigation', NULL, NULL, NULL, NULL, NULL),
(8, 3, 'Flowering', 7, 12, 'Spray against bollworm', NULL, NULL, NULL, NULL, NULL),
(8, 4, 'Harvesting', 20, 24, 'Picking cotton', NULL, NULL, NULL, NULL, NULL),

(9, 1, 'Sowing', 0, 1, 'Direct sowing', NULL, NULL, NULL, NULL, NULL),
(9, 2, 'Pegging', 3, 6, 'Irrigation, gypsum', NULL, NULL, NULL, NULL, NULL),
(9, 3, 'Pod Development', 7, 10, 'Weed and pest control', NULL, NULL, NULL, NULL, NULL),
(9, 4, 'Harvesting', 15, 18, 'Uproot and collect pods', NULL, NULL, NULL, NULL, NULL),

(10, 1, 'Sowing', 0, 1, 'Direct sowing', NULL, NULL, NULL, NULL, NULL),
(10, 2, 'Vegetative', 2, 5, 'Irrigation, weeding', NULL, NULL, NULL, NULL, NULL),
(10, 3, 'Flowering', 6, 8, 'Pest control', NULL, NULL, NULL, NULL, NULL),
(10, 4, 'Harvesting', 14, 16, 'Cut and thresh pods', NULL, NULL, NULL, NULL, NULL);

INSERT INTO soil_types (name, description, ph_range, drainage, water_retention, fertility_level, suitable_crops)
VALUES
('Sandy Loam', 'Well-drained soil with good aeration, moderate water retention', '6.0-7.5', 'Excellent', 'Moderate', 'Medium', 'Tomato,Maize,Potato,Onion,Groundnut'),
('Clay Loam', 'Heavy soil with good water retention, moderate drainage', '6.5-7.5', 'Moderate', 'High', 'High', 'Rice,Wheat,Maize,Cotton,Soybean'),
('Loamy Soil', 'Balanced soil with good structure and fertility', '6.0-7.0', 'Good', 'Good', 'High', 'Tomato,Wheat,Maize,Potato,Onion'),
('Clayey Soil', 'Heavy soil with high water retention, poor drainage', '6.0-8.0', 'Poor', 'Very High', 'High', 'Rice,Sugarcane,Cotton'),
('Alluvial Soil', 'Fertile soil deposited by rivers, rich in nutrients', '6.5-8.0', 'Good', 'Good', 'Very High', 'Rice,Wheat,Sugarcane,Cotton,Soybean'),
('Black Soil', 'Volcanic soil with high clay content, excellent for cotton', '7.0-8.5', 'Moderate', 'High', 'High', 'Cotton,Sugarcane,Maize,Soybean'),
('Red Soil', 'Well-drained soil with iron oxide, suitable for many crops', '5.5-7.0', 'Good', 'Moderate', 'Medium', 'Groundnut,Onion,Maize'),
('Well-drained Soil', 'Any soil type with excellent drainage properties', '6.0-7.5', 'Excellent', 'Moderate', 'Medium', 'Potato,Tomato,Maize');

INSERT INTO fertilizers (crop_id, week, name, quantity, price, gap_days)
VALUES
-- Pulses
(11, 'Week 2', 'DAP', '20 kg/acre', '₹1100', 15),
(12, 'Week 1', 'Urea', '15 kg/acre', '₹500', 12),
(13, 'Week 2', 'SSP', '20 kg/acre', '₹750', 18),
(14, 'Week 3', 'DAP', '25 kg/acre', '₹1200', 20),
(15, 'Week 2', 'Urea', '15 kg/acre', '₹600', 14),

-- Fruits
(16, 'Week 4', 'FYM', '5 tons/acre', '₹2000', 30),
(17, 'Week 6', 'Urea', '40 kg/acre', '₹1500', 40),
(18, 'Week 2', 'DAP', '20 kg/acre', '₹1100', 20),
(19, 'Week 3', 'Superphosphate', '15 kg/acre', '₹900', 18),
(20, 'Week 5', 'Potash', '25 kg/acre', '₹1300', 22),

-- Spices
(21, 'Week 3', 'Urea', '20 kg/acre', '₹700', 20),
(22, 'Week 2', 'FYM', '3 tons/acre', '₹1200', 25),
(23, 'Week 3', 'DAP', '20 kg/acre', '₹1100', 18),
(24, 'Week 1', 'Urea', '10 kg/acre', '₹400', 15),
(25, 'Week 2', 'Superphosphate', '15 kg/acre', '₹950', 20),

-- Cash Crops
(26, 'Week 5', 'Ammonium Sulphate', '30 kg/acre', '₹1500', 25),
(27, 'Week 6', 'NPK Mix', '35 kg/acre', '₹2000', 28),
(28, 'Week 4', 'Urea', '40 kg/acre', '₹1700', 30),
(29, 'Week 3', 'DAP', '25 kg/acre', '₹1300', 22),
(30, 'Week 2', 'Urea', '20 kg/acre', '₹700', 18);


INSERT INTO pesticides (crop_id, week, name, application, quantity, price)
VALUES
-- Pulses
(11, 'Week 4', 'Chlorpyrifos', 'Foliar Spray', '2 ml/litre', '₹550'),
(12, 'Week 3', 'Carbendazim', 'Seed Treatment', '2 g/kg seed', '₹450'),
(13, 'Week 5', 'Triazole', 'Foliar Spray', '2 ml/litre', '₹600'),
(14, 'Week 4', 'Imidacloprid', 'Soil Drench', '1 ml/litre', '₹700'),
(15, 'Week 3', 'Mancozeb', 'Foliar Spray', '2 g/litre', '₹500'),

-- Fruits
(16, 'Week 8', 'Copper Oxychloride', 'Spray', '2 g/litre', '₹750'),
(17, 'Week 10', 'Sulphur Dust', 'Dusting', '5 kg/acre', '₹900'),
(18, 'Week 4', 'Neem Oil', 'Foliar Spray', '3 ml/litre', '₹600'),
(19, 'Week 6', 'Imidacloprid', 'Spray', '1 ml/litre', '₹800'),
(20, 'Week 7', 'Carbendazim', 'Soil Drench', '2 g/litre', '₹850'),

-- Spices
(21, 'Week 5', 'Hexaconazole', 'Foliar Spray', '2 ml/litre', '₹550'),
(22, 'Week 4', 'Mancozeb', 'Foliar Spray', '2 g/litre', '₹500'),
(23, 'Week 6', 'Dimethoate', 'Foliar Spray', '2 ml/litre', '₹650'),
(24, 'Week 2', 'Neem Oil', 'Foliar Spray', '2 ml/litre', '₹450'),
(25, 'Week 3', 'Carbendazim', 'Seed Treatment', '2 g/kg seed', '₹400'),

-- Cash Crops
(26, 'Week 12', 'Endosulfan', 'Spray', '2 ml/litre', '₹1200'),
(27, 'Week 14', 'Copper Oxychloride', 'Spray', '2 g/litre', '₹1000'),
(28, 'Week 20', 'Fungicide Mix', 'Soil Drench', '3 g/litre', '₹1500'),
(29, 'Week 8', 'Chlorpyrifos', 'Spray', '2 ml/litre', '₹700'),
(30, 'Week 5', 'Triazole', 'Spray', '2 ml/litre', '₹650');


INSERT INTO crop_guides (crop_id, overview, climate, soil, land_preparation, sowing, irrigation, nutrient_management, weed_management, pests_diseases, harvesting, yield_info)
VALUES
(11, 'Pigeon pea is a major pulse crop.', 'Warm, semi-arid', 'Loamy soils', 'Deep ploughing', 'Direct sowing', 'Irrigate at flowering', 'NPK + FYM', 'Weeding at 25 DAS', 'Wilt, pod borer', 'Harvest 150 days', '8-10 q/acre'),
(12, 'Green gram is a short duration pulse.', 'Warm, dry', 'Sandy loam', 'Light ploughing', 'Direct sowing', 'Irrigate at pod filling', 'NPK basal', 'Weeding at 20 DAS', 'Yellow mosaic virus', 'Harvest 65-70 days', '4-5 q/acre'),
(13, 'Black gram is widely grown.', 'Warm, dry', 'Loamy soil', 'Fine tilth', 'Direct sowing', 'Irrigate at flowering', 'FYM + phosphates', 'Manual weeding', 'Wilt, YMV', 'Harvest 80-90 days', '5-6 q/acre'),
(14, 'Chickpea is an important Rabi pulse.', 'Cool, dry', 'Sandy loam', 'Deep ploughing', 'Drill sowing', 'Light irrigation', 'Phosphorus rich fertilizer', 'Weeding at 30 DAS', 'Wilt, blight', 'Harvest 120 days', '8-10 q/acre'),
(15, 'Lentil is a winter pulse.', 'Cool, dry', 'Alluvial soil', '2-3 ploughings', 'Drill sowing', 'Irrigate at pod filling', 'NPK application', 'Weeding at 25 DAS', 'Rust, wilt', 'Harvest 100 days', '6-8 q/acre'),

(16, 'Banana is a tropical fruit.', 'Hot, humid', 'Alluvial soil', 'Pits with FYM', 'Sucker planting', 'Frequent irrigation', 'NPK + FYM', 'Mulching', 'Bunchy top, sigatoka', 'Harvest 11-12 months', '30-40 t/acre'),
(17, 'Mango is a perennial fruit.', 'Tropical, dry', 'Loamy soil', 'Pit preparation', 'Grafting', 'Seasonal irrigation', 'Organic manure + NPK', 'Mulching', 'Powdery mildew, fruit fly', 'Harvest summer', '8-10 t/acre'),
(18, 'Papaya is a short-duration fruit.', 'Warm, frost-free', 'Sandy loam', 'Fine tilth', 'Direct sowing', 'Light irrigation', 'Organic manure + urea', 'Mulching', 'Papaya mosaic virus', 'Harvest 9-11 months', '20-25 t/acre'),
(19, 'Guava is hardy fruit crop.', 'Tropical, dry', 'Red loamy soil', 'Deep ploughing', 'Seedling planting', 'Irrigate during fruiting', 'NPK + FYM', 'Mulching', 'Wilt, fruit fly', 'Harvest 2 years', '10-15 t/acre'),
(20, 'Pomegranate is a drought tolerant fruit.', 'Semi-arid', 'Black soil', 'Deep ploughing', 'Cutting planting', 'Irrigate at flowering', 'Potash + NPK', 'Weeding', 'Wilt, fruit borer', 'Harvest 10-12 months', '8-12 t/acre'),

(21, 'Turmeric is a spice crop.', 'Humid climate', 'Loamy soils', 'Ridges & furrows', 'Rhizome planting', 'Irrigate at sprouting', 'FYM + NPK', 'Weeding 30 DAS', 'Rhizome rot', 'Harvest 8-9 months', '20-25 q/acre'),
(22, 'Ginger is a rhizome crop.', 'Humid, moderate', 'Loamy soil', 'Beds with FYM', 'Rhizome planting', 'Light irrigation', 'Organic manure', 'Mulching', 'Rhizome rot, wilt', 'Harvest 8 months', '15-20 q/acre'),
(23, 'Chili is a spice crop.', 'Warm climate', 'Loamy soil', 'Ridges & furrows', 'Transplanting', 'Irrigate 10 days', 'NPK basal + top dressing', 'Weeding 20 DAS', 'Thrips, wilt', 'Harvest 120-150 days', '6-8 q/acre'),
(24, 'Coriander is an annual spice.', 'Cool, dry', 'Sandy loam', 'Fine tilth', 'Direct sowing', 'Light irrigation', 'FYM + NPK', 'Weeding', 'Stem rot, mildew', 'Harvest 90 days', '4-6 q/acre'),
(25, 'Cumin is a winter spice.', 'Cool, dry', 'Sandy soils', 'Deep ploughing', 'Direct sowing', 'Light irrigation', 'Phosphate fertilizer', 'Weeding', 'Blight, wilt', 'Harvest 120 days', '5-6 q/acre'),

(26, 'Tea is a plantation crop.', 'Humid, high rainfall', 'Acidic loamy soil', 'Deep tillage', 'Cutting planting', 'Frequent irrigation', 'NPK + lime', 'Manual weeding', 'Blister blight', 'Harvest 3-4 years onwards', '1500-2000 kg/ha'),
(27, 'Coffee is a perennial cash crop.', 'Humid, shaded', 'Loamy soil', 'Pit preparation', 'Seedlings', 'Irrigate during dry season', 'Organic manure', 'Weeding', 'Leaf rust', 'Harvest 3 years onwards', '600-800 kg/ha'),
(28, 'Rubber is a plantation crop.', 'Humid, high rainfall', 'Laterite soils', 'Deep ploughing', 'Budded stumps', 'Rainfed', 'Organic manure', 'Weeding', 'Leaf fall disease', 'Harvest 6 years', '1500 kg/ha latex'),
(29, 'Coconut is a perennial palm.', 'Tropical humid', 'Sandy loam', 'Pit with FYM', 'Seedling planting', 'Rainfed/Irrigation', 'NPK fertilizer', 'Mulching', 'Bud rot, mite', 'Harvest year-round', '80-100 nuts/tree'),
(30, 'Jute is a fiber crop.', 'Warm, humid', 'Alluvial soil', 'Fine tilth', 'Broadcast sowing', 'Frequent irrigation', 'FYM + NPK', 'Weeding at 30 DAS', 'Stem rot, mites', 'Harvest 120 days', '25-30 q/acre');


INSERT INTO crop_stages (crop_id, stage_number, title, start_week, end_week, tasks, video_url, detailed_description, equipment_needed, time_required, difficulty_level)
VALUES
-- Pulses (example: Pigeon pea, Moong, etc.)
(11, 1, 'Sowing', 0, 1, 'Direct sowing', NULL, NULL, NULL, NULL, NULL),
(11, 2, 'Vegetative Growth', 2, 8, 'Weeding, irrigation', NULL, NULL, NULL, NULL, NULL),
(11, 3, 'Flowering', 9, 14, 'Pest control, fertilization', NULL, NULL, NULL, NULL, NULL),
(11, 4, 'Harvesting', 20, 22, 'Pod collection', NULL, NULL, NULL, NULL, NULL),
(12, 1, 'Sowing', 0, 1, 'Direct sowing', NULL, NULL, NULL, NULL, NULL),
(12, 2, 'Vegetative Growth', 2, 5, 'Weeding', NULL, NULL, NULL, NULL, NULL),
(12, 3, 'Flowering', 6, 8, 'Irrigation', NULL, NULL, NULL, NULL, NULL),
(12, 4, 'Harvesting', 9, 10, 'Pod collection', NULL, NULL, NULL, NULL, NULL);
-- (Repeat similar pattern for IDs 13–30 with adjusted weeks/tasks)

-- Detailed Weekly Tasks for Tomato (Crop ID 1)
INSERT INTO weekly_tasks (crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, video_url, step_by_step_instructions, tips_and_notes, weather_conditions, safety_precautions, expected_outcome)
VALUES
-- Week 1: Seed Preparation and Nursery Setup
(1, 1, 'Seed Selection and Treatment', 'Select high-quality tomato seeds and treat them for better germination', 'maintenance', 'High', '1 hour', 'Seed packets, fungicide, warm water', 'Quality seeds, fungicide solution', 'https://www.youtube.com/watch?v=tomato-seed-treatment', '1. Choose disease-resistant varieties\n2. Soak seeds in warm water for 2 hours\n3. Treat with fungicide solution\n4. Air dry on paper towel', 'Use certified seeds for better results', 'Warm, dry conditions', 'Wear gloves when handling chemicals', 'Healthy, treated seeds ready for planting'),

(1, 1, 'Nursery Bed Preparation', 'Prepare nursery beds with proper soil mixture and drainage', 'maintenance', 'High', '2-3 hours', 'Spade, rake, measuring tape', 'Potting mix, compost, sand', 'https://www.youtube.com/watch?v=tomato-nursery-bed', '1. Select well-drained location\n2. Prepare 1m x 0.5m beds\n3. Mix soil with compost (3:1 ratio)\n4. Level and water the bed', 'Ensure good drainage to prevent root rot', 'Clear, sunny day', 'Use proper lifting techniques', 'Well-prepared nursery bed ready for seeding'),

-- Week 2: Seeding and Initial Care
(1, 2, 'Seed Sowing', 'Sow treated seeds in nursery beds with proper spacing', 'maintenance', 'Critical', '1-2 hours', 'Measuring stick, watering can', 'Treated seeds, fine soil', 'https://www.youtube.com/watch?v=tomato-seed-sowing', '1. Make shallow furrows 1cm deep\n2. Space seeds 2-3cm apart\n3. Cover with fine soil\n4. Water gently with fine spray', 'Keep soil moist but not waterlogged', 'Cool morning hours', 'Handle seeds carefully', 'Seeds sown with proper spacing'),

(1, 2, 'Nursery Protection Setup', 'Set up shade net or protection for young seedlings', 'maintenance', 'Medium', '1 hour', 'Shade net, bamboo poles, rope', 'Shade net (50% shade), support materials', 'https://www.youtube.com/watch?v=tomato-nursery-protection', '1. Install bamboo frame\n2. Fix shade net at 1m height\n3. Ensure proper ventilation\n4. Secure all edges', 'Protect from direct sun and heavy rain', 'Any weather condition', 'Secure structure properly', 'Protected nursery environment'),

-- Week 3: Seedling Care and First Fertilization
(1, 3, 'Thinning and Weeding', 'Remove weak seedlings and weeds from nursery', 'maintenance', 'Medium', '1 hour', 'Small trowel, hand tools', 'None', 'https://www.youtube.com/watch?v=tomato-thinning', '1. Identify healthy seedlings\n2. Remove weak and crowded plants\n3. Maintain 5cm spacing\n4. Remove all weeds carefully', 'Keep only the strongest seedlings', 'Cool morning hours', 'Be gentle with young plants', 'Well-spaced, healthy seedlings'),

(1, 3, 'First Fertilization', 'Apply first dose of liquid fertilizer to seedlings', 'fertilizer', 'High', '30 minutes', 'Sprayer, measuring cup', 'Liquid fertilizer (NPK 19:19:19)', 'https://www.youtube.com/watch?v=tomato-first-fertilizer', '1. Mix 1g fertilizer per liter water\n2. Apply as foliar spray\n3. Avoid direct sun application\n4. Water after 2 hours', 'Apply in early morning or evening', 'Cool, cloudy day preferred', 'Wear protective gear', 'Healthy, well-nourished seedlings'),

-- Week 4: Transplanting Preparation
(1, 4, 'Hardening Off', 'Gradually expose seedlings to outdoor conditions', 'maintenance', 'High', '1 week process', 'None', 'None', 'https://www.youtube.com/watch?v=tomato-hardening', '1. Reduce shade gradually\n2. Increase sun exposure daily\n3. Reduce watering frequency\n4. Monitor plant response', 'Gradual process prevents shock', 'Stable weather conditions', 'Monitor for stress signs', 'Hardened seedlings ready for transplanting'),

(1, 4, 'Main Field Preparation', 'Prepare main field for transplanting', 'maintenance', 'High', '4-6 hours', 'Tractor/plow, rake, measuring tape', 'Compost, lime (if needed)', 'https://www.youtube.com/watch?v=tomato-field-prep', '1. Deep plowing to 30cm\n2. Add 10 tons compost per acre\n3. Level the field\n4. Make ridges 60cm apart', 'Ensure good soil structure', 'Dry soil conditions', 'Use proper safety equipment', 'Well-prepared field ready for transplanting'),

-- Week 5: Transplanting
(1, 5, 'Seedling Transplanting', 'Transplant hardened seedlings to main field', 'maintenance', 'Critical', '3-4 hours', 'Trowel, watering can, measuring tape', 'Healthy seedlings', 'https://www.youtube.com/watch?v=tomato-transplanting', '1. Water seedlings before transplanting\n2. Dig holes 30cm apart\n3. Plant at same depth as nursery\n4. Water immediately after planting', 'Transplant in evening for better survival', 'Cool, cloudy day', 'Handle roots carefully', 'Successfully transplanted tomato plants'),

-- Week 6: Post-Transplant Care
(1, 6, 'First Irrigation', 'Provide adequate water after transplanting', 'irrigation', 'High', '1 hour', 'Irrigation system, timer', 'Water', 'https://www.youtube.com/watch?v=tomato-first-irrigation', '1. Water immediately after transplanting\n2. Provide 2-3 liters per plant\n3. Check soil moisture daily\n4. Adjust frequency based on weather', 'Consistent moisture is crucial', 'Any time of day', 'Avoid overwatering', 'Well-established root system'),

(1, 6, 'Staking Setup', 'Install support system for tomato plants', 'maintenance', 'Medium', '2-3 hours', 'Bamboo stakes, twine, hammer', 'Bamboo stakes, jute twine', 'https://www.youtube.com/watch?v=tomato-staking', '1. Install 6ft stakes every 2 plants\n2. Tie plants loosely to stakes\n3. Allow room for growth\n4. Check ties regularly', 'Early staking prevents damage', 'Any weather condition', 'Secure stakes properly', 'Supported plants ready for growth'),

-- Week 7: Vegetative Growth Management
(1, 7, 'Side Shoot Removal', 'Remove side shoots to promote main stem growth', 'pruning', 'Medium', '1-2 hours', 'Pruning shears, gloves', 'None', 'https://www.youtube.com/watch?v=tomato-pruning', '1. Identify side shoots in leaf axils\n2. Remove when 2-3cm long\n3. Use clean, sharp shears\n4. Disinfect tools between plants', 'Regular pruning improves yield', 'Dry conditions', 'Use clean, sharp tools', 'Well-pruned plants with strong main stems'),

(1, 7, 'Second Fertilization', 'Apply second dose of fertilizer for vegetative growth', 'fertilizer', 'High', '1 hour', 'Spreader, watering can', 'NPK fertilizer (20:10:10)', 'https://www.youtube.com/watch?v=tomato-second-fertilizer', '1. Apply 50kg NPK per acre\n2. Spread around plant base\n3. Mix lightly with soil\n4. Water thoroughly', 'Balanced nutrition for growth', 'Cool morning hours', 'Wear protective gear', 'Healthy vegetative growth'),

-- Week 8: Flowering Stage Preparation
(1, 8, 'Flower Bud Monitoring', 'Monitor and protect developing flower buds', 'monitoring', 'Medium', '30 minutes', 'Magnifying glass, notebook', 'None', 'https://www.youtube.com/watch?v=tomato-flower-monitoring', '1. Check for flower bud formation\n2. Monitor for pest damage\n3. Record development stage\n4. Note any abnormalities', 'Early detection prevents problems', 'Any time of day', 'Handle buds gently', 'Healthy flower bud development'),

(1, 8, 'Pest and Disease Check', 'Regular inspection for pests and diseases', 'monitoring', 'High', '1 hour', 'Magnifying glass, sprayer', 'Organic pesticides (if needed)', 'https://www.youtube.com/watch?v=tomato-pest-check', '1. Check leaves for spots or holes\n2. Look for insect damage\n3. Check stem for lesions\n4. Apply treatment if needed', 'Prevention is better than cure', 'Early morning', 'Wear protective clothing', 'Healthy plants free from major pests'),

-- Week 9: Flowering and Fruit Set
(1, 9, 'Pollination Support', 'Ensure proper pollination for fruit set', 'maintenance', 'Medium', '30 minutes', 'Soft brush, water spray', 'None', 'https://www.youtube.com/watch?v=tomato-pollination', '1. Gently shake plants in morning\n2. Use soft brush if needed\n3. Ensure good air circulation\n4. Avoid excessive handling', 'Natural pollination is best', 'Early morning', 'Be gentle with flowers', 'Good fruit set and development'),

(1, 9, 'Fruit Thinning', 'Remove excess fruits for better quality', 'pruning', 'Medium', '1 hour', 'Pruning shears, gloves', 'None', 'https://www.youtube.com/watch?v=tomato-fruit-thinning', '1. Keep 4-5 fruits per cluster\n2. Remove small, deformed fruits\n3. Keep largest, healthiest ones\n4. Maintain plant balance', 'Quality over quantity', 'Dry conditions', 'Use clean tools', 'Well-spaced, quality fruits'),

-- Week 10: Fruit Development
(1, 10, 'Calcium Application', 'Apply calcium to prevent blossom end rot', 'fertilizer', 'High', '1 hour', 'Sprayer, measuring cup', 'Calcium nitrate solution', 'https://www.youtube.com/watch?v=tomato-calcium', '1. Mix 2g calcium nitrate per liter\n2. Apply as foliar spray\n3. Repeat every 2 weeks\n4. Avoid over-application', 'Prevents common fruit disorders', 'Cool morning hours', 'Follow label instructions', 'Healthy fruit development'),

(1, 10, 'Support Adjustment', 'Adjust plant supports as fruits develop', 'maintenance', 'Medium', '1 hour', 'Twine, scissors', 'Additional twine', 'https://www.youtube.com/watch?v=tomato-support-adjust', '1. Check all plant ties\n2. Loosen if too tight\n3. Add extra support for heavy clusters\n4. Ensure good air circulation', 'Prevent stem damage', 'Any time of day', 'Be careful with sharp tools', 'Well-supported plants'),

-- Week 11: Pre-Harvest Preparation
(1, 11, 'Harvest Planning', 'Plan harvesting schedule and storage', 'harvesting', 'Medium', '30 minutes', 'Calendar, notebook', 'Harvesting containers', 'https://www.youtube.com/watch?v=tomato-harvest-planning', '1. Identify ripening fruits\n2. Plan daily harvest schedule\n3. Prepare storage containers\n4. Check weather forecast', 'Plan ahead for best results', 'Any time of day', 'None', 'Organized harvest plan'),

(1, 11, 'Final Pest Check', 'Final inspection before harvest', 'monitoring', 'High', '1 hour', 'Magnifying glass, sprayer', 'Organic pesticides', 'https://www.youtube.com/watch?v=tomato-final-pest-check', '1. Check all plant parts\n2. Look for late-season pests\n3. Apply treatment if needed\n4. Note any issues', 'Last chance for pest control', 'Early morning', 'Follow safety guidelines', 'Clean, pest-free fruits'),

-- Week 12: Harvesting
(1, 12, 'First Harvest', 'Harvest first ripe tomatoes', 'harvesting', 'Critical', '2-3 hours', 'Harvesting basket, pruning shears', 'None', 'https://www.youtube.com/watch?v=tomato-first-harvest', '1. Pick fully ripe fruits\n2. Use clean, sharp shears\n3. Handle fruits gently\n4. Sort by quality', 'Harvest in cool morning hours', 'Early morning', 'Use clean tools', 'High-quality first harvest'),

(1, 12, 'Post-Harvest Handling', 'Proper handling and storage of harvested fruits', 'harvesting', 'High', '1 hour', 'Storage containers, labels', 'Clean containers, labels', 'https://www.youtube.com/watch?v=tomato-post-harvest', '1. Sort fruits by size and quality\n2. Remove damaged fruits\n3. Store in cool, dry place\n4. Label with harvest date', 'Proper handling maintains quality', 'Cool, dry conditions', 'Handle fruits carefully', 'Well-preserved harvest');

-- Sample crop videos for Tomato
-- Sample disease categories
INSERT INTO disease_categories (disease_name, description, symptoms, common_causes, prevention_measures, treatment_methods, severity_level) VALUES
('Early Blight', 'Common fungal disease affecting tomatoes', 'Dark brown spots with concentric rings on leaves', 'Fungal spores, wet conditions', 'Proper spacing, mulching', 'Fungicide application, remove affected leaves', 'high'),
('Powdery Mildew', 'Fungal disease affecting various crops', 'White powdery coating on leaves', 'High humidity, poor air circulation', 'Good air circulation, resistant varieties', 'Fungicide application', 'medium'),
('Root Rot', 'Soil-borne disease affecting roots', 'Wilting, yellowing leaves, stunted growth', 'Overwatering, poor drainage', 'Well-draining soil, proper irrigation', 'Improve drainage, fungicide treatment', 'critical');

-- Sample crop diseases
INSERT INTO crop_diseases (crop_id, disease_id, typical_onset_week_start, typical_onset_week_end, risk_factors, crop_specific_treatment) VALUES
(1, 1, 4, 8, 'High humidity, leaf wetness', 'Copper-based fungicide specific for tomatoes'),
(1, 2, 6, 12, 'Dense foliage, high humidity', 'Sulfur-based treatments, improve ventilation'),
(2, 3, 3, 6, 'Waterlogged soil, high soil moisture', 'Adjust irrigation, apply biological controls');

-- Enhanced crop videos with new fields
INSERT INTO crop_videos (crop_id, week_number, video_title, video_url, video_type, duration_minutes, description, thumbnail_url, is_featured, relevance_start_week, relevance_end_week, difficulty_level, prerequisites, learning_outcomes, expert_tips) VALUES
(1, 1, 'Complete Tomato Growing Guide - Week 1', 'https://www.youtube.com/watch?v=tomato-week1-complete', 'tutorial', 15, 'Complete guide to starting tomato seeds and nursery preparation', 'https://img.youtube.com/vi/tomato-week1-complete/maxresdefault.jpg', TRUE, 1, 3, 'beginner', 'Basic gardening knowledge', 'Understanding seed starting process', 'Pre-soak seeds for better germination'),

(1, 3, 'Early Blight Management in Tomatoes', 'https://www.youtube.com/watch?v=tomato-blight-management', 'disease_management', 12, 'Identifying and treating early blight in tomatoes', 'https://img.youtube.com/vi/tomato-blight-management/maxresdefault.jpg', FALSE, 3, 8, 'intermediate', 'Basic disease knowledge', 'Disease identification and treatment', 'Monitor lower leaves carefully'),

(1, 5, 'Advanced Pest Control Techniques', 'https://www.youtube.com/watch?v=tomato-pest-control', 'pest_control', 15, 'Advanced methods for controlling common tomato pests', 'https://img.youtube.com/vi/tomato-pest-control/maxresdefault.jpg', TRUE, 4, 12, 'advanced', 'Basic pest management', 'Integrated pest management', 'Use companion planting');

-- Sample process videos
INSERT INTO process_videos (process_category, process_type, video_title, video_url, duration_minutes, description, applicable_crops, seasonal_relevance, equipment_needed, safety_precautions, best_practices) VALUES
('land_preparation', 'soil_preparation', 'Proper Soil Preparation Techniques', 'https://www.youtube.com/watch?v=soil-prep', 20, 'Complete guide to soil preparation', 'All crops', 'Pre-planting season', 'Tiller, spade, rake', 'Wear protective gear', 'Test soil pH before starting'),

('applying_fertilizer', 'organic', 'Organic Fertilizer Application Guide', 'https://www.youtube.com/watch?v=organic-fertilizer', 15, 'How to apply organic fertilizers', 'Vegetables, fruits', 'Growing season', 'Spreader, gloves', 'Avoid skin contact', 'Apply in early morning'),

('irrigation', 'drip_system', 'Setting Up Drip Irrigation', 'https://www.youtube.com/watch?v=drip-irrigation', 25, 'Installing and maintaining drip irrigation', 'All crops', 'Any season', 'Drip pipes, connectors', 'Check water quality', 'Regular maintenance tips');

-- Sample video problems
INSERT INTO video_problems (problem_category, problem_title, description, symptoms, solution_steps, prevention_tips) VALUES
('disease', 'Early Blight Management', 'Managing early blight in tomatoes', 'Brown spots on leaves', '1. Remove affected leaves\n2. Apply fungicide', 'Proper spacing, mulching'),
('pest', 'Aphid Control', 'Controlling aphid infestations', 'Curled leaves, sticky residue', '1. Spray with neem oil\n2. Introduce beneficial insects', 'Regular monitoring, healthy plants'),
('nutrient_deficiency', 'Nitrogen Deficiency', 'Addressing nitrogen deficiency', 'Yellowing leaves', '1. Apply nitrogen-rich fertilizer\n2. Monitor growth', 'Regular soil testing');

-- Link videos to problems
INSERT INTO video_problem_solutions (video_id, problem_id, relevance_score, solution_summary, expert_notes) VALUES
(3, 1, 5, 'Complete guide to managing early blight', 'Focus on prevention methods'),
(2, 2, 4, 'Natural aphid control methods', 'Best for organic growing'),
(1, 3, 5, 'Correcting nitrogen deficiency', 'Regular monitoring required');

-- Disease management videos
INSERT INTO disease_management_videos (disease_id, video_id, management_phase, effectiveness_rating, expert_recommendations) VALUES
(1, 3, 'identification', 5, 'Focus on early detection'),
(1, 2, 'prevention', 4, 'Emphasize cultural practices'),
(2, 1, 'treatment', 5, 'Follow up treatment important');

-- Additional Tomato Weekly Monitoring Tasks (User-provided plan)
INSERT INTO weekly_tasks (
    crop_id, week_number, task_title, task_description,
    task_type, priority, estimated_duration, equipment_needed,
    materials_needed, video_url, step_by_step_instructions,
    tips_and_notes, weather_conditions, safety_precautions, expected_outcome
) VALUES
(1, 1, 'Sow tomato seed in nursery trays / seedbeds', 'Start tomato seeds in sterilized media and maintain ideal conditions', 'maintenance', 'High', NULL, NULL, NULL, NULL, NULL, 'Sterilize media; keep soil moist; temp 20–25°C ideal', NULL, NULL, 'Uniform germination'),
(1, 2, 'Monitor germination; keep trays moist', 'Monitor germination progress and maintain moisture', 'monitoring', 'Medium', NULL, NULL, NULL, NULL, NULL, 'Remove weak seedlings', NULL, NULL, 'Healthy, vigorous seedlings'),
(1, 3, 'Thin seedlings; start light fertiliser once true leaves appear', 'Thin crowded seedlings and begin light fertilization at true leaf stage', 'maintenance', 'Medium', NULL, NULL, 'Dilute balanced fertilizer', NULL, NULL, NULL, NULL, 'Use gloves when handling fertilizer', 'Stronger seedlings with proper spacing'),
(1, 4, 'Harden off seedlings (gradually expose to outdoor conditions)', 'Gradually acclimate seedlings to outdoor conditions before transplanting', 'maintenance', 'High', NULL, NULL, NULL, NULL, 'Reduce watering before transplanting', NULL, NULL, NULL, 'Hardened seedlings ready for transplant'),
(1, 5, 'Transplant to main bed/containers; install stakes/trellis', 'Transplant seedlings at proper spacing and set up support structures', 'maintenance', 'Critical', NULL, 'Stakes/trellis, trowel, watering can', NULL, NULL, 'Plant at correct spacing; water after transplant', NULL, NULL, 'Handle roots carefully', 'Properly established plants with supports'),
(1, 6, 'Apply basal fertilizer; mulch around plants', 'Apply basal nutrients and mulch to conserve moisture and suppress weeds', 'fertilizer', 'High', NULL, NULL, 'Basal fertilizer, mulch', NULL, 'Mulch conserves moisture, reduces weeds', NULL, NULL, 'Follow label rates', 'Improved early growth and moisture conservation'),
(1, 7, 'First tying of plants to stakes; remove lowest suckers', 'Tie plants to stakes and remove lowest suckers to encourage structure', 'pruning', 'Medium', NULL, 'Stakes, twine, pruning shears', NULL, NULL, 'Start training indeterminate varieties', NULL, NULL, 'Use clean tools', 'Well-supported, trained plants'),
(1, 8, 'Scout for pests/diseases; apply preventive measures if needed', 'Regular scouting and preventive protection as needed', 'monitoring', 'High', NULL, 'Hand lens, sprayer', 'Organic protectants (if needed)', NULL, 'Check for aphids, whiteflies, early blight', 'Dry weather preferred', NULL, 'Wear PPE during sprays', 'Early detection and reduced incidence'),
(1, 9, 'Flowering — support pollination; calcium spray to prevent BER', 'Support pollination and apply calcium to prevent blossom-end rot', 'fertilizer', 'High', NULL, 'Sprayer, soft brush', 'Calcium solution', NULL, 'Keep consistent soil moisture', NULL, 'Follow spray safety', NULL, 'Good fruit set and reduced BER'),
(1, 10, 'Fruit set and early fruit development; side-dress with balanced NPK', 'Side-dress balanced nutrients during early fruiting', 'fertilizer', 'High', NULL, 'Spreader', 'Balanced NPK', NULL, 'Avoid excessive nitrogen at fruiting stage', NULL, 'Use proper dosing', NULL, 'Healthy early fruit development'),
(1, 11, 'Fruit enlargement; prune overcrowded foliage; continue pest control', 'Manage canopy and continue pest/disease management', 'pruning', 'Medium', NULL, 'Pruners', NULL, NULL, 'Remove diseased leaves promptly', NULL, NULL, 'Sanitize tools', 'Better light/airflow and healthy foliage'),
(1, 12, 'Begin harvesting (first ripe fruits may be ready)', 'Start harvesting first ripe tomatoes regularly', 'harvesting', 'High', NULL, 'Harvest shears, crates', NULL, NULL, 'Harvest ripe fruit regularly to encourage more fruiting', 'Cool mornings', 'Handle fruits gently', NULL, 'Quality early harvest'),
(1, 13, 'Harvesting continues; grade and sort harvest', 'Continue harvesting while grading and sorting produce', 'harvesting', 'Medium', NULL, 'Crates, sorting table', NULL, NULL, 'Continue nutrient feed and water management', NULL, NULL, 'Maintain hygiene', 'Consistent quality and postharvest handling'),
(1, 14, 'Harvesting continues', 'Ongoing harvesting of remaining fruit', 'harvesting', 'Medium', NULL, 'Crates', NULL, NULL, 'Monitor for pests on remaining fruits', NULL, NULL, 'Handle carefully', 'Completion of main harvest window'),
-- Week 15 intentionally skipped (empty)
(1, 16, 'Final harvest flushes; field clean-up after harvest', 'Finish harvesting and clean up field to reduce disease carryover', 'maintenance', 'Medium', NULL, 'Pruners, bags', NULL, NULL, 'Remove and destroy crop debris if disease present', NULL, NULL, 'Use PPE as needed', 'Clean field ready for next crop');

-- Sample user for testing
-- Legacy user insert removed - using new user schema with roles and better security

-- Sample crop monitoring session
INSERT INTO crop_monitoring_sessions (user_id, crop_id, crop_name, land_size, soil_type, start_date, current_week, status, total_weeks)
VALUES (1, 1, 'Tomato', 2.5, 'Sandy Loam', '2024-01-01 08:00:00', 3, 'active', 12);

-- Sample progress tracking data
INSERT INTO crop_progress_tracking (session_id, week_number, task_id, completion_status, completion_date, notes, rating, feedback)
VALUES
(1, 1, 1, 'completed', '2024-01-15 10:30:00', 'Seeds treated successfully, good quality seeds used', 5, 'Excellent results, seeds germinated well'),
(1, 1, 2, 'completed', '2024-01-15 14:00:00', 'Nursery bed prepared with proper drainage', 4, 'Good preparation, soil mix was perfect'),
(1, 2, 3, 'completed', '2024-01-22 09:00:00', 'Seeds sown with proper spacing', 5, 'Perfect spacing, good germination rate'),
(1, 2, 4, 'completed', '2024-01-22 16:00:00', 'Shade net installed properly', 4, 'Good protection from sun'),
(1, 3, 5, 'in_progress', NULL, 'Thinning in progress, will complete tomorrow', NULL, NULL),
(1, 3, 6, 'not_started', NULL, 'Waiting for thinning to complete', NULL, NULL);

-- Ensure each crop has at least two weekly tasks (crops 2..30)
INSERT INTO weekly_tasks (crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, video_url, step_by_step_instructions, tips_and_notes, weather_conditions, safety_precautions, expected_outcome)
VALUES
-- Rice (2)
(2, 2, 'Nursery Management', 'Manage rice nursery and seedbeds', 'maintenance', 'High', '2 hours', 'Watering cans, shade net', 'Seeds, water', NULL, '1. Monitor seedling health\n2. Ensure proper watering', 'Maintain moisture', 'Humid', 'Wear gloves', 'Healthy nursery'),
(2, 8, 'Transplanting', 'Transplant seedlings to main field', 'maintenance', 'High', '4 hours', 'Shovels, ropes', 'Seedlings', NULL, '1. Transplant in rows\n2. Maintain spacing', 'Transplant during cool hours', 'Morning', 'Handle seedlings gently', 'Successful transplant'),

-- Wheat (3)
(3, 1, 'Seed Sowing', 'Prepare and sow wheat seeds', 'maintenance', 'High', '3 hours', 'Seeder, rake', 'Seeds', NULL, '1. Prepare seedbed\n2. Sow at correct depth', 'Use quality seeds', 'Dry', 'Use protective mask', 'Uniform sowing'),
(3, 6, 'Top Dressing', 'Apply fertilizer top dressing', 'fertilizer', 'Medium', '1 hour', 'Spreader', 'NPK', NULL, '1. Spread evenly\n2. Water after application', 'Apply in morning', 'Cool', 'Wear gloves', 'Improved growth'),

-- Maize (4)
(4, 2, 'Weeding', 'Perform manual weeding', 'maintenance', 'Medium', '2 hours', 'Hoe', 'None', NULL, '1. Remove weeds\n2. Dispose properly', 'Keep soil clean', 'Dry', 'Protective gloves', 'Reduced competition'),
(4, 10, 'Pest Monitoring', 'Inspect for pests', 'monitoring', 'High', '1 hour', 'Magnifying glass', 'None', NULL, '1. Check leaves and stem\n2. Note pest presence', 'Early detection', 'Any', 'Avoid touching pests', 'Early control'),

-- Potato (5)
(5, 3, 'Earthing Up', 'Perform earthing up operations', 'maintenance', 'High', '3 hours', 'Hoe', 'Soil', NULL, '1. Pull soil around stems\n2. Secure tubers', 'Prevents tuber exposure', 'Dry', 'Use back support', 'Healthy tuber development'),
(5, 12, 'Disease Check', 'Inspect for blight and diseases', 'monitoring', 'High', '1 hour', 'Hand lens', 'None', NULL, '1. Inspect leaves\n2. Treat if needed', 'Treat early', 'Wet', 'Wear gloves', 'Reduced disease incidence'),

-- Onion (6)
(6, 2, 'Bed Preparation', 'Prepare beds for onion transplanting', 'maintenance', 'Medium', '2 hours', 'Rake, spade', 'Compost', NULL, '1. Level beds\n2. Add FYM', 'Good drainage', 'Dry', 'Use boots', 'Ready beds'),
(6, 11, 'Bulb Formation Care', 'Care during bulb formation', 'monitoring', 'Medium', '1 hour', 'Watering can', 'Fertilizer', NULL, '1. Ensure moisture\n2. Monitor bulb size', 'Steady watering', 'Any', 'Avoid overwatering', 'Healthy bulbs'),

-- Sugarcane (7)
(7, 4, 'Setts Planting', 'Plant sugarcane setts', 'maintenance', 'High', '5 hours', 'Plough', 'Setts', NULL, '1. Place setts in furrows\n2. Cover with soil', 'Proper spacing', 'Dry', 'Wear gloves', 'Good germination'),
(7, 20, 'Top Dressing', 'Apply top dressing fertilizers', 'fertilizer', 'Medium', '2 hours', 'Spreader', 'NPK', NULL, '1. Apply evenly\n2. Water after', 'Boost growth', 'Any', 'Use mask', 'Improved yield'),

-- Cotton (8)
(8, 3, 'Fertilizer Application', 'Apply basal fertilizer', 'fertilizer', 'Medium', '1 hour', 'Spreader', 'DAP', NULL, '1. Apply around base\n2. Mix lightly', 'Apply early', 'Dry', 'Wear gloves', 'Better growth'),
(8, 15, 'Pest Control', 'Spray for bollworm if needed', 'pesticide', 'High', '1 hour', 'Sprayer', 'Insecticide', NULL, '1. Mix as per label\n2. Spray in evening', 'Control pest', 'Evening', 'Use mask', 'Reduced pest damage'),

-- Groundnut (9)
(9, 5, 'Soil Loosening', 'Loosen soil around plants', 'maintenance', 'Low', '1 hour', 'Hand fork', 'None', NULL, '1. Loosen soil gently\n2. Avoid root damage', 'Aerate soil', 'Dry', 'Use gloves', 'Improved aeration'),
(9, 14, 'Harvest Prep', 'Prepare for harvesting', 'harvesting', 'Medium', '2 hours', 'Tools', 'Storage', NULL, '1. Check pod maturity\n2. Plan harvest', 'Proper timing', 'Any', 'Use protective gear', 'Efficient harvest'),

-- Soybean (10)
(10, 2, 'Seed Bed Check', 'Check seed bed and moisture', 'monitoring', 'Low', '30 minutes', 'Moisture meter', 'None', NULL, '1. Measure moisture\n2. Adjust irrigation', 'Maintain moisture', 'Any', 'Handle with care', 'Optimal moisture'),
(10, 12, 'Pod Filling Monitoring', 'Monitor pod filling', 'monitoring', 'Medium', '1 hour', 'Hand lens', 'None', NULL, '1. Inspect pods\n2. Note development', 'Good pod set', 'Any', 'Be gentle', 'Good yields'),

-- Pulses & remaining crops (11..30) - add two basic tasks each
(11, 2, 'Sowing Check', 'Ensure sowing depth and spacing', 'maintenance', 'High', '1 hour', 'Rake', 'Seeds', NULL, '1. Check spacing\n2. Adjust as needed', 'Uniform sowing', 'Dry', 'Use gloves', 'Good stand'),
(11, 18, 'Weed Management', 'Remove weeds and apply mulch', 'maintenance', 'Medium', '2 hours', 'Hoe', 'Mulch', NULL, '1. Remove weeds\n2. Apply mulch', 'Reduce weed pressure', 'Any', 'Protect hands', 'Cleaner field'),
(12, 3, 'Moisture Management', 'Ensure moisture for green gram', 'irrigation', 'Medium', '30 minutes', 'Irrigation system', 'Water', NULL, '1. Water as needed\n2. Avoid waterlogging', 'Balanced moisture', 'Any', 'Avoid overwatering', 'Healthy growth'),
(12, 9, 'Pest Monitoring', 'Inspect for YMV symptoms', 'monitoring', 'High', '1 hour', 'Hand lens', 'None', NULL, '1. Inspect leaves\n2. Identify symptoms', 'Early action', 'Any', 'Seek expert help if needed', 'Disease control'),
(13, 4, 'Phosphate Application', 'Apply SSP for early growth', 'fertilizer', 'Medium', '1 hour', 'Spreader', 'SSP', NULL, '1. Apply near root zone\n2. Water after', 'Boost phosphorus', 'Dry', 'Wear gloves', 'Better root growth'),
(13, 12, 'Pest Watch', 'Monitor for pests', 'monitoring', 'Medium', '1 hour', 'Magnifying glass', 'None', NULL, '1. Check regularly\n2. Record findings', 'Timely detection', 'Any', 'Be gentle', 'Control measures ready'),
(14, 2, 'Sowing Care', 'Ensure drill sowing uniformity', 'maintenance', 'High', '1 hour', 'Seeder', 'Seeds', NULL, '1. Check drill settings\n2. Correct depth', 'Uniform stand', 'Dry', 'Use gloves', 'Good emergence'),
(14, 10, 'Harvest Planning', 'Plan harvest logistics', 'harvesting', 'Medium', '1 hour', 'Notebook', 'Tools', NULL, '1. Schedule labor\n2. Prepare storage', 'Efficient harvest', 'Any', 'Use care', 'On-time harvest'),
(15, 3, 'Lentil Care', 'Monitor lentil growth and moisture', 'monitoring', 'Low', '30 minutes', 'Moisture meter', 'None', NULL, '1. Check moisture\n2. Adjust watering', 'Maintain moisture', 'Any', 'Be careful', 'Good crop'),
(15, 12, 'Disease Scout', 'Scout for rust and wilt', 'monitoring', 'Medium', '1 hour', 'Hand lens', 'None', NULL, '1. Inspect plants\n2. Note issues', 'Early detection', 'Any', 'Use gloves', 'Apply control if needed'),
(16, 6, 'Banana Suckers Care', 'Manage suckers and nutrient supply', 'maintenance', 'Medium', '2 hours', 'Knife', 'Fertilizer', NULL, '1. Remove excess suckers\n2. Apply FYM', 'Promote growth', 'Any', 'Use cut-resistant gloves', 'Healthy plants'),
(16, 40, 'Fertilizer Regimen', 'Apply planned fertilizers', 'fertilizer', 'High', '3 hours', 'Spreader', 'FYM', NULL, '1. Follow schedule\n2. Water after', 'Sustain nutrition', 'Any', 'Mask for dust', 'Steady growth'),
(17, 8, 'Fruit Tree Care', 'Prune and manage mango trees', 'maintenance', 'Medium', '3 hours', 'Pruners', 'None', NULL, '1. Prune dead wood\n2. Mulch base', 'Promote fruiting', 'Dry', 'Use pruners', 'Better yield'),
(17, 24, 'Pest Control', 'Manage fruit fly if seen', 'pesticide', 'High', '1 hour', 'Sprayer', 'Insecticide', NULL, '1. Trap flies\n2. Apply bait', 'Reduce damage', 'Any', 'Use PPE', 'Lower infestation'),
(18, 2, 'Seedling Care', 'Ensure papaya seedlings establish', 'maintenance', 'Medium', '1 hour', 'Watering can', 'Fertilizer', NULL, '1. Provide shade\n2. Water regularly', 'Good establishment', 'Any', 'Handle gently', 'Healthy seedlings'),
(18, 24, 'Fruit Management', 'Thin fruits and manage pests', 'maintenance', 'Medium', '2 hours', 'Pruners', 'None', NULL, '1. Thin crowded fruits\n2. Monitor pests', 'Better fruit size', 'Any', 'Careful pruning', 'Quality fruits'),
(19, 6, 'Soil Conditioning', 'Improve soil with FYM', 'maintenance', 'Medium', '2 hours', 'Spade', 'FYM', NULL, '1. Incorporate FYM\n2. Level soil', 'Better soil', 'Dry', 'Use gloves', 'Improved fertility'),
(19, 30, 'Fruit Harvest', 'Harvest and store guava', 'harvesting', 'Medium', '3 hours', 'Baskets', 'Storage', NULL, '1. Harvest ripe fruits\n2. Pack carefully', 'Reduce damage', 'Any', 'Handle gently', 'Good marketable fruits'),
(20, 5, 'Pomegranate Care', 'Monitor flowering and water', 'maintenance', 'Medium', '1 hour', 'Watering can', 'None', NULL, '1. Ensure water\n2. Monitor flowers', 'Support fruit set', 'Any', 'Be careful', 'Good set'),
(20, 40, 'Potash Application', 'Apply potash as per schedule', 'fertilizer', 'Medium', '1 hour', 'Spreader', 'Potash', NULL, '1. Apply evenly\n2. Water after', 'Improve fruit quality', 'Any', 'Use gloves', 'Better quality'),
(21, 6, 'Turmeric Planting', 'Plant turmeric rhizomes properly', 'maintenance', 'High', '3 hours', 'Spade', 'Rhizomes', NULL, '1. Prepare beds\n2. Plant rhizomes', 'Good planting', 'Any', 'Use gloves', 'Healthy plants'),
(21, 30, 'Weed Control', 'Manage weeds in turmeric beds', 'maintenance', 'Medium', '2 hours', 'Hoe', 'Mulch', NULL, '1. Remove weeds\n2. Apply mulch', 'Lower competition', 'Any', 'Protect hands', 'Cleaner beds'),
(22, 8, 'Ginger Care', 'Monitor ginger beds and moisture', 'maintenance', 'Medium', '1 hour', 'Watering can', 'Mulch', NULL, '1. Maintain moisture\n2. Mulch', 'Prevent drying', 'Any', 'Use gloves', 'Good rhizomes'),
(22, 28, 'Harvest Prep', 'Prepare for ginger harvest', 'harvesting', 'Medium', '2 hours', 'Tools', 'Storage', NULL, '1. Plan harvest\n2. Store properly', 'Efficient harvest', 'Any', 'Use care', 'Good yields'),
(23, 6, 'Chili Nursery', 'Manage chili nursery and transplanting', 'maintenance', 'High', '2 hours', 'Shade net', 'Seedlings', NULL, '1. Harden seedlings\n2. Transplant', 'Healthy transplants', 'Any', 'Handle gently', 'Strong plants'),
(23, 14, 'Disease Monitoring', 'Watch for wilt and blight', 'monitoring', 'High', '1 hour', 'Hand lens', 'None', NULL, '1. Inspect regularly\n2. Treat promptly', 'Early care', 'Any', 'Use gloves', 'Reduced disease'),
(24, 3, 'Coriander Sowing', 'Sow coriander under cool conditions', 'maintenance', 'Medium', '1 hour', 'Seeder', 'Seeds', NULL, '1. Sow at correct depth\n2. Keep moist', 'Good germination', 'Cool morning', 'Be gentle', 'Good stand'),
(24, 10, 'Harvest Planning', 'Plan coriander harvest and drying', 'harvesting', 'Medium', '2 hours', 'Drying racks', 'Storage', NULL, '1. Harvest on dry day\n2. Dry properly', 'Quality seed', 'Dry', 'Use mask', 'Marketable produce'),
(25, 4, 'Cumin Bed Prep', 'Prepare beds for cumin', 'maintenance', 'Low', '1 hour', 'Rake', 'Seeds', NULL, '1. Level bed\n2. Sow evenly', 'Uniform stand', 'Dry', 'Use gloves', 'Good emergence'),
(25, 12, 'Pest Watch', 'Monitor cumin for pests', 'monitoring', 'Low', '1 hour', 'Hand lens', 'None', NULL, '1. Inspect plants\n2. Note pests', 'Timely action', 'Any', 'Be careful', 'Manage pests'),
(26, 20, 'Tea Pruning', 'Prune tea bushes for renewal', 'maintenance', 'High', '3 hours', 'Pruners', 'None', NULL, '1. Prune selectively\n2. Remove old wood', 'Encourage new growth', 'Dry', 'Use gloves', 'Better yield'),
(26, 60, 'Fertilizer Schedule', 'Apply fertilizer as per plan', 'fertilizer', 'Medium', '4 hours', 'Spreader', 'NPK', NULL, '1. Follow timetable\n2. Water after', 'Sustained nutrition', 'Any', 'Mask', 'Healthy bushes'),
(27, 24, 'Shade Management', 'Manage shade for coffee', 'maintenance', 'Medium', '2 hours', 'Pruners', 'None', NULL, '1. Ensure proper shade\n2. Prune as needed', 'Right microclimate', 'Any', 'Use care', 'Optimal growth'),
(27, 72, 'Harvest Prep', 'Prepare for coffee cherry harvest', 'harvesting', 'Medium', '3 hours', 'Baskets', 'Storage', NULL, '1. Plan harvest\n2. Train pickers', 'Efficient harvest', 'Any', 'Use care', 'Good cherries'),
(28, 30, 'Rubber Tapping Prep', 'Prepare trees for tapping', 'maintenance', 'High', '3 hours', 'Chisel', 'None', NULL, '1. Select trees\n2. Clean bark', 'Correct tapping', 'Any', 'Use PPE', 'Quality latex'),
(28, 180, 'Long Term Care', 'Plan long term maintenance', 'maintenance', 'Low', '5 hours', 'Tools', 'Fertilizer', NULL, '1. Schedule maintenance\n2. Monitor', 'Sustained productivity', 'Any', 'Use care', 'Healthy plantation'),
(29, 12, 'Coconut Care', 'Fertilize and manage palms', 'fertilizer', 'Medium', '3 hours', 'Spreader', 'Fertilizer', NULL, '1. Apply fertilizer\n2. Mulch base', 'Better nut production', 'Any', 'Use gloves', 'Improved yield'),
(29, 48, 'Harvest Management', 'Manage nut collection and storage', 'harvesting', 'Medium', '4 hours', 'Climbers', 'Baskets', NULL, '1. Harvest safely\n2. Store nuts', 'Reduce damage', 'Any', 'Use PPE', 'Good collection'),
(30, 6, 'Jute Sowing', 'Prepare and sow jute', 'maintenance', 'Medium', '2 hours', 'Seeder', 'Seeds', NULL, '1. Sow evenly\n2. Maintain moisture', 'Good emergence', 'Wet', 'Be careful', 'Uniform stand'),
(30, 18, 'Harvest Prep', 'Prepare for jute retting and harvest', 'harvesting', 'Medium', '2 hours', 'Tools', 'Storage', NULL, '1. Plan retting\n2. Harvest timely', 'Quality fiber', 'Any', 'Use care', 'Good fiber');

-- Audit logs table for tracking user actions
CREATE TABLE IF NOT EXISTS audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id INT,
    details JSON,
    ip_address VARCHAR(45),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;