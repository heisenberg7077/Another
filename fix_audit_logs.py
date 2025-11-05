"""
Script to create the missing audit_logs table
Run this to fix the 500 error on /api/login
"""
import pymysql

# Database connection details
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'agri_v',
    'charset': 'utf8mb4'
}

# SQL to create audit_logs table
CREATE_TABLE_SQL = """
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
"""

def main():
    try:
        # Connect to database
        print("Connecting to database...")
        connection = pymysql.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        # Create the table
        print("Creating audit_logs table...")
        cursor.execute(CREATE_TABLE_SQL)
        connection.commit()
        
        # Verify the table was created
        cursor.execute("SHOW TABLES LIKE 'audit_logs'")
        result = cursor.fetchone()
        
        if result:
            print("[SUCCESS] audit_logs table created successfully.")
            
            # Show table structure
            cursor.execute("DESCRIBE audit_logs")
            columns = cursor.fetchall()
            print("\nTable structure:")
            for col in columns:
                print(f"  - {col[0]}: {col[1]}")
        else:
            print("[ERROR] Table was not created.")
        
        cursor.close()
        connection.close()
        print("\nYou can now restart your Flask application and the login should work!")
        
    except pymysql.Error as e:
        print(f"[ERROR] Database error: {e}")
    except Exception as e:
        print(f"[ERROR] Error: {e}")

if __name__ == "__main__":
    main()
