"""
Script to convert existing hashed passwords to plain text
WARNING: This is for development only - NEVER use in production!

This will reset all user passwords to a default value.
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
        cursor.execute("SELECT user_id, username, password_hash FROM users")
        users = cursor.fetchall()
        
        if not users:
            print("No users found in database.")
            cursor.close()
            connection.close()
            return
        
        print(f"\nFound {len(users)} users:")
        for user in users:
            user_id, username, current_pass = user
            print(f"  - {username} (ID: {user_id})")
        
        print(f"\nAll passwords will be set to: '{DEFAULT_PASSWORD}'")
        confirm = input("\nType 'YES' to continue: ")
        
        if confirm != 'YES':
            print("Operation cancelled.")
            cursor.close()
            connection.close()
            return
        
        # Update all passwords to plain text
        print("\nUpdating passwords...")
        cursor.execute(
            "UPDATE users SET password_hash = %s",
            (DEFAULT_PASSWORD,)
        )
        connection.commit()
        
        print(f"[SUCCESS] All {len(users)} user passwords have been set to '{DEFAULT_PASSWORD}'")
        print("\nYou can now login with:")
        for user in users:
            print(f"  Username: {user[1]}, Password: {DEFAULT_PASSWORD}")
        
        cursor.close()
        connection.close()
        
    except pymysql.Error as e:
        print(f"[ERROR] Database error: {e}")
    except Exception as e:
        print(f"[ERROR] Error: {e}")

if __name__ == "__main__":
    main()
