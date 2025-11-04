# auth.py - Authentication and authorization utilities
from flask import session, jsonify, request
from functools import wraps
from models.user import User
import os

def auth_required(f):
    """
    Decorator to require authentication for a route
    """
    @wraps(f)
    def wrapper(*args, **kwargs):
        if not session.get('user_id'):
            return jsonify({"success": False, "error": "Unauthorized"}), 401
        return f(*args, **kwargs)
    return wrapper

def is_admin_user(username: str) -> bool:
    """
    Check if a username is an admin user
    """
    admins_csv = os.environ.get('ADMIN_USERS', '')
    admin_usernames = {u.strip().lower() for u in admins_csv.split(',') if u.strip()}
    if not admin_usernames:
        admin_usernames = {"admin"}
    return (username or '').lower() in admin_usernames

def admin_required(f):
    """
    Decorator to require admin authentication for a route
    """
    @wraps(f)
    def wrapper(*args, **kwargs):
        if not session.get('user_id'):
            return jsonify({"success": False, "error": "Unauthorized"}), 401
        if not session.get('is_admin'):
            return jsonify({"success": False, "error": "Forbidden"}), 403
        return f(*args, **kwargs)
    return wrapper

def hash_password(password: str) -> str:
    """
    Plaintext pass-through. Hashing disabled per project requirement.
    """
    return password

def verify_password(password_hash: str, password: str) -> bool:
    """
    Plaintext comparison only.
    """
    return (password_hash == password)
