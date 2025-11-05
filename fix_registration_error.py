"""
Script to fix registration error by ensuring roles table exists and has data
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

def main():
    try:
        print("Connecting to database...")
        connection = pymysql.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        # Check if roles table exists
        cursor.execute("SHOW TABLES LIKE 'roles'")
        roles_exists = cursor.fetchone()
        
        if not roles_exists:
            print("Creating roles table...")
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS roles (
                    role_id INT AUTO_INCREMENT,
                    role_name VARCHAR(50) NOT NULL,
                    description TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    PRIMARY KEY (role_id)
                )
            """)
            connection.commit()
            print("[SUCCESS] Roles table created")
        else:
            print("[OK] Roles table exists")
        
        # Check if roles have data
        cursor.execute("SELECT COUNT(*) FROM roles")
        role_count = cursor.fetchone()[0]
        
        if role_count == 0:
            print("Inserting default roles...")
            cursor.execute("""
                INSERT INTO roles (role_id, role_name, description) VALUES
                (1, 'admin', 'Administrator with full access'),
                (2, 'user', 'Regular user with limited access')
            """)
            connection.commit()
            print("[SUCCESS] Default roles inserted")
        else:
            print(f"[OK] Roles table has {role_count} roles")
        
        # Check users table structure
        cursor.execute("DESCRIBE users")
        columns = cursor.fetchall()
        column_names = [col[0] for col in columns]
        
        print("\nUsers table columns:")
        for col in columns:
            print(f"  - {col[0]}: {col[1]}")
        
        # Check if email column allows NULL
        cursor.execute("SHOW COLUMNS FROM users LIKE 'email'")
        email_col = cursor.fetchone()
        if email_col:
            is_nullable = email_col[2]  # NULL field
            print(f"\nEmail column nullable: {is_nullable}")
            
            if is_nullable == 'NO':
                print("\nWARNING: Email column is NOT NULL")
                print("Modifying email column to allow NULL...")
                cursor.execute("ALTER TABLE users MODIFY COLUMN email VARCHAR(100) NULL")
                connection.commit()
                print("[SUCCESS] Email column now allows NULL")
        
        # Test registration
        print("\n" + "="*60)
        print("Testing registration with minimal data...")
        test_username = "testuser_temp"
        test_password = "123"
        test_email = f"{test_username}@presicide.local"
        
        # Delete test user if exists
        cursor.execute("DELETE FROM users WHERE username = %s", (test_username,))
        connection.commit()
        
        # Try to insert
        try:
            cursor.execute("""
                INSERT INTO users (username, password_hash, email, role_id)
                VALUES (%s, %s, %s, %s)
            """, (test_username, test_password, test_email, 2))
            connection.commit()
            print(f"[SUCCESS] Test user created: {test_username}")
            
            # Clean up
            cursor.execute("DELETE FROM users WHERE username = %s", (test_username,))
            connection.commit()
            print("[SUCCESS] Test user deleted")
        except Exception as e:
            print(f"[ERROR] Test registration failed: {e}")
            connection.rollback()
        
        cursor.close()
        connection.close()
        
        print("\n" + "="*60)
        print("Database setup complete!")
        print("You can now try registering a new user.")
        
    except pymysql.Error as e:
        print(f"[ERROR] Database error: {e}")
    except Exception as e:
        print(f"[ERROR] Error: {e}")

if __name__ == "__main__":
    main()
