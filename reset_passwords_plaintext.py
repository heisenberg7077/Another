"""
Script to reset all passwords to plain text '123'
WARNING: This is for development only - NEVER use in production!
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

# Default password for all users
DEFAULT_PASSWORD = '123'

def main():
    try:
        print("=" * 60)
        print("WARNING: Converting passwords to plain text")
        print("This is a SECURITY RISK - use only for development!")
        print("=" * 60)
        
        # Connect to database
        print("\nConnecting to database...")
        connection = pymysql.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        # Get all users
        cursor.execute("SELECT user_id, username FROM users")
        users = cursor.fetchall()
        
        if not users:
            print("No users found in database.")
            cursor.close()
            connection.close()
            return
        
        print(f"\nFound {len(users)} users")
        
        # Update all passwords to plain text
        print(f"Setting all passwords to: '{DEFAULT_PASSWORD}'")
        cursor.execute(
            "UPDATE users SET password_hash = %s",
            (DEFAULT_PASSWORD,)
        )
        connection.commit()
        
        print(f"\n[SUCCESS] All {len(users)} user passwords updated!")
        print("\nLogin credentials:")
        print("-" * 40)
        for user in users:
            print(f"  Username: {user[1]}")
            print(f"  Password: {DEFAULT_PASSWORD}")
            print("-" * 40)
        
        cursor.close()
        connection.close()
        
    except pymysql.Error as e:
        print(f"[ERROR] Database error: {e}")
    except Exception as e:
        print(f"[ERROR] Error: {e}")

if __name__ == "__main__":
    main()
