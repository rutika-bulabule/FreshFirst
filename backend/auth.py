from werkzeug.security import check_password_hash
from backend.db import get_db


def authenticate_user(username, password):

    conn = get_db()

    if conn is None:
        return {"error": "Database connection failed"}

    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT user_id, username, password_hash,
                   full_name, role, is_active
            FROM users
            WHERE username = %s
        """, (username,))

        user = cursor.fetchone()

        if not user:
            return {"error": "Invalid username or password"}

        if user["is_active"] != 1:
            return {"error": "Account is inactive"}

        if not check_password_hash(user["password_hash"], password):
            return {"error": "Invalid username or password"}

        return {
            "user_id": user["user_id"],
            "username": user["username"],
            "full_name": user["full_name"],
            "role": user["role"]
        }

    except Exception as error:
        return {"error": str(error)}

    finally:
        cursor.close()
        conn.close()
