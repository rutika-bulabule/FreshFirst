from flask import Flask, jsonify, request, session, render_template, redirect
from backend.db import get_db
from backend.auth import authenticate_user
from backend.verification import verify_product
from backend.priority import calculate_priority, priority_queue

app = Flask(__name__, template_folder="../templates", static_folder="../static")

app.secret_key = "FreshFirst-Development-Secret-2026"


@app.route("/")
def home():
    return jsonify({
        "project": "FreshFirst",
        "message": "FreshFirst Backend is running!",
        "status": "SUCCESS"
    })


@app.route("/login")
def login():
    return render_template("login.html")


@app.route("/api/login", methods=["POST"])
def api_login():

    data = request.get_json(silent=True) or request.form

    username = data.get("username", "").strip()
    password = data.get("password", "")

    if not username or not password:
        return jsonify({"error": "Username and password are required"}), 400

    user = authenticate_user(username, password)

    if "error" in user:
        return jsonify(user), 401

    session.clear()
    session["user_id"] = user["user_id"]
    session["username"] = user["username"]
    session["full_name"] = user["full_name"]
    session["role"] = user["role"]

    return jsonify({
        "message": "Login successful",
        "user": user
    })


@app.route("/api/logout", methods=["POST"])
def api_logout():
    session.clear()
    return jsonify({"message": "Logged out successfully"})


@app.route("/api/me")
def current_user():

    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    return jsonify({
        "user_id": session["user_id"],
        "username": session["username"],
        "full_name": session["full_name"],
        "role": session["role"]
    })


@app.route("/dashboard")
def dashboard():

    if "user_id" not in session:
        return redirect("/login")

    return render_template("dashboard.html")


@app.route("/stock")
def stock():

    if "user_id" not in session:
        return redirect("/login")

    return render_template("stock.html")


@app.route("/add-product")
def add_product_page():

    if "user_id" not in session:
        return redirect("/login")

    return render_template("add_product.html")


@app.route("/api/products", methods=["GET"])
def get_products():

    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    conn = get_db()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT product_id, name, category, quantity,
                   purchase_date, expiry_date,
                   storage_condition, recorded_temp
            FROM products
            WHERE is_deleted = 0
            ORDER BY product_id DESC
        """)

        products = cursor.fetchall()

        return jsonify(products)

    except Exception as error:
        return jsonify({"error": str(error)}), 500

    finally:
        cursor.close()
        conn.close()


@app.route("/api/products/add", methods=["POST"])
def add_product():

    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    data = request.get_json(silent=True) or {}

    required_fields = [
        "name", "category", "quantity",
        "purchase_date", "expiry_date", "storage_condition"
    ]

    for field in required_fields:
        if not str(data.get(field, "")).strip():
            return jsonify({"error": field + " is required"}), 400

    try:
        quantity = int(data["quantity"])

        if quantity <= 0:
            return jsonify({"error": "Quantity must be greater than zero"}), 400

        temperature = data.get("recorded_temp")

        if temperature in ("", None):
            temperature = None
        else:
            temperature = float(temperature)

        conn = get_db()

        if conn is None:
            return jsonify({"error": "Database connection failed"}), 500

        cursor = conn.cursor()

        try:
            cursor.execute("""
                INSERT INTO products
                (name, category, quantity, purchase_date,
                 expiry_date, storage_condition, recorded_temp,
                 created_by)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                data["name"].strip(),
                data["category"],
                quantity,
                data["purchase_date"],
                data["expiry_date"],
                data["storage_condition"],
                temperature,
                session["user_id"]
            ))

            product_id = cursor.lastrowid

            cursor.execute("""
                INSERT INTO history
                (product_id, user_id, event_type, details)
                VALUES (%s, %s, %s, %s)
            """, (
                product_id,
                session["user_id"],
                "PRODUCT ADDED",
                "Product " + data["name"].strip() + " was added"
            ))

            conn.commit()

            return jsonify({
                "message": "Product added successfully",
                "product_id": product_id
            }), 201

        except Exception:
            conn.rollback()
            raise

        finally:
            cursor.close()
            conn.close()

    except ValueError:
        return jsonify({"error": "Enter valid quantity and temperature"}), 400

    except Exception as error:
        return jsonify({"error": str(error)}), 500


@app.route("/api/verify/<int:product_id>", methods=["GET"])
def verify(product_id):

    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    result = verify_product(product_id)

    if "error" in result:
        return jsonify(result), 400

    priority = calculate_priority(product_id, result)

    if "error" in priority:
        return jsonify(priority), 400

    return jsonify({
        "verification": result,
        "priority": priority
    })




@app.route("/priority")
def priority_page():
    if "user_id" not in session:
        return redirect("/login")

    return render_template("priority.html")



@app.route("/api/products/<int:product_id>/update", methods=["PUT"])
def update_product(product_id):

    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    data = request.get_json(silent=True) or {}

    required_fields = [
        "name", "category", "quantity",
        "purchase_date", "expiry_date", "storage_condition"
    ]

    for field in required_fields:
        if not str(data.get(field, "")).strip():
            return jsonify({"error": field + " is required"}), 400

    try:
        quantity = int(data["quantity"])

        if quantity <= 0:
            return jsonify({"error": "Quantity must be greater than zero"}), 400

        temperature = data.get("recorded_temp")

        if temperature in ("", None):
            temperature = None
        else:
            temperature = float(temperature)

        conn = get_db()

        if conn is None:
            return jsonify({"error": "Database connection failed"}), 500

        cursor = conn.cursor()

        try:
            cursor.execute("""
                UPDATE products
                SET name = %s,
                    category = %s,
                    quantity = %s,
                    purchase_date = %s,
                    expiry_date = %s,
                    storage_condition = %s,
                    recorded_temp = %s
                WHERE product_id = %s AND is_deleted = 0
            """, (
                data["name"].strip(),
                data["category"],
                quantity,
                data["purchase_date"],
                data["expiry_date"],
                data["storage_condition"],
                temperature,
                product_id
            ))

            if cursor.rowcount == 0:
                conn.rollback()
                return jsonify({"error": "Product not found"}), 404

            conn.commit()

            return jsonify({
                "message": "Product updated successfully",
                "product_id": product_id
            }), 200

        except Exception as error:
            conn.rollback()
            return jsonify({"error": str(error)}), 400

        finally:
            cursor.close()
            conn.close()

    except (ValueError, TypeError):
        return jsonify({"error": "Invalid quantity or temperature"}), 400



@app.route("/api/products/<int:product_id>/delete", methods=["POST"])
def delete_product(product_id):

    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    if session.get("role") not in ["ADMIN", "MANAGER"]:
        return jsonify({"error": "Permission denied"}), 403

    conn = get_db()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor()

    try:
        cursor.execute(
            "SELECT name FROM products WHERE product_id = %s AND is_deleted = 0",
            (product_id,)
        )
        product = cursor.fetchone()

        if not product:
            return jsonify({"error": "Product not found"}), 404

        cursor.execute(
            "UPDATE products SET is_deleted = 1 WHERE product_id = %s",
            (product_id,)
        )

        cursor.execute("""
            INSERT INTO history
            (product_id, user_id, event_type, details)
            VALUES (%s, %s, %s, %s)
        """, (
            product_id,
            session["user_id"],
            "PRODUCT DELETED",
            "Product " + product[0] + " was removed from active stock"
        ))

        conn.commit()

        return jsonify({
            "message": "Product deleted successfully"
        }), 200

    except Exception as error:
        conn.rollback()
        return jsonify({"error": str(error)}), 400

    finally:
        cursor.close()
        conn.close()

@app.route("/api/priority", methods=["GET"])
def get_priority():

    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    conn = get_db()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT product_id
            FROM products
            WHERE is_deleted = 0
        """)

        product_ids = cursor.fetchall()
        products = []

        for item in product_ids:
            result = verify_product(item["product_id"])

            if "error" in result:
                continue

            priority = calculate_priority(item["product_id"], result)

            if "error" not in priority:
                products.append({
                    **result,
                    **priority
                })

        return jsonify(priority_queue(products))

    finally:
        cursor.close()
        conn.close()



@app.route("/api/verify-save/<int:product_id>", methods=["POST"])
def save_verification(product_id):

    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    result = verify_product(product_id)

    if "error" in result:
        return jsonify(result), 400

    priority = calculate_priority(product_id, result)

    if "error" in priority:
        return jsonify(priority), 400

    conn = get_db()

    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO verification
            (product_id, verified_by, days_left, expiry_status,
             storage_status, data_issue, overall_status,
             priority, suggested_action)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            product_id,
            session["user_id"],
            result["days_left"],
            result["expiry_status"],
            result["storage_status"],
            result["data_issue"],
            result["overall_status"],
            priority["priority"],
            priority["suggested_action"]
        ))

        verification_id = cursor.lastrowid

        cursor.execute("""
            INSERT INTO actions
            (product_id, verification_id, suggested_action,
             final_action, status, action_date, decided_by)
            VALUES (%s, %s, %s, %s, 'PENDING', NOW(), %s)
        """, (
            product_id,
            verification_id,
            priority["suggested_action"],
            priority["suggested_action"],
            session["user_id"]
        ))

        cursor.execute("""
            INSERT INTO history
            (product_id, user_id, event_type, details)
            VALUES (%s, %s, %s, %s)
        """, (
            product_id,
            session["user_id"],
            "PRODUCT VERIFIED",
            "Verification saved. Priority: " + priority["priority"]
        ))

        conn.commit()

        return jsonify({
            "message": "Verification saved successfully",
            "verification_id": verification_id,
            "verification": result,
            "priority": priority
        }), 201

    except Exception as error:
        conn.rollback()
        return jsonify({"error": str(error)}), 500

    finally:
        cursor.close()
        conn.close()



@app.route("/api/history", methods=["GET"])
def get_history():
    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    conn = get_db()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT h.history_id, h.product_id, p.name AS product_name,
                   u.full_name, h.event_type, h.details, h.event_time
            FROM history h
            JOIN products p ON h.product_id = p.product_id
            JOIN users u ON h.user_id = u.user_id
            ORDER BY h.event_time DESC, h.history_id DESC
        """)
        records = cursor.fetchall()

        for record in records:
            if record["event_time"]:
                record["event_time"] = record["event_time"].strftime("%Y-%m-%d %H:%M:%S")

        return jsonify(records)

    except Exception as error:
        return jsonify({"error": str(error)}), 500
    finally:
        cursor.close()
        conn.close()



@app.route("/api/actions", methods=["GET"])
def get_actions():
    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    conn = get_db()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT a.action_id, a.product_id, p.name AS product_name,
                   a.verification_id, a.suggested_action,
                   a.final_action, a.status, a.action_date,
                   u.full_name AS decided_by_name,
                   v.priority, v.expiry_status, v.overall_status
            FROM actions a
            JOIN products p ON a.product_id = p.product_id
            JOIN verification v ON a.verification_id = v.verification_id
            LEFT JOIN users u ON a.decided_by = u.user_id
            ORDER BY a.action_id DESC
        """)
        records = cursor.fetchall()

        for record in records:
            if record["action_date"]:
                record["action_date"] = record["action_date"].strftime("%Y-%m-%d %H:%M:%S")

        return jsonify(records)

    except Exception as error:
        return jsonify({"error": str(error)}), 500
    finally:
        cursor.close()
        conn.close()



@app.route("/api/actions/<int:action_id>/complete", methods=["POST"])
def complete_action(action_id):
    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    if session.get("role") not in ("ADMIN", "MANAGER"):
        return jsonify({"error": "Permission denied"}), 403

    conn = get_db()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)

    try:
        data = request.get_json(silent=True) or {}
        final_action = data.get("final_action", "").strip()

        if not final_action:
            return jsonify({"error": "Final action is required"}), 400

        cursor.execute("""
            SELECT product_id, status
            FROM actions
            WHERE action_id = %s
        """, (action_id,))

        action = cursor.fetchone()

        if not action:
            return jsonify({"error": "Action not found"}), 404

        if action["status"] == "DONE":
            return jsonify({"error": "Action is already completed"}), 400

        cursor.execute("""
            UPDATE actions
            SET final_action = %s, status = 'DONE',
                action_date = NOW(), decided_by = %s
            WHERE action_id = %s
        """, (final_action, session["user_id"], action_id))

        cursor.execute("""
            INSERT INTO history
            (product_id, user_id, event_type, details)
            VALUES (%s, %s, %s, %s)
        """, (
            action["product_id"],
            session["user_id"],
            "ACTION COMPLETED",
            "Action " + str(action_id) + " completed: " + final_action
        ))

        conn.commit()

        return jsonify({
            "message": "Action completed successfully",
            "action_id": action_id,
            "final_action": final_action,
            "status": "DONE"
        })

    except Exception as error:
        conn.rollback()
        return jsonify({"error": str(error)}), 500

    finally:
        cursor.close()
        conn.close()



@app.route("/api/reports", methods=["GET"])
def get_reports():
    if "user_id" not in session:
        return jsonify({"error": "Please login first"}), 401

    conn = get_db()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT COUNT(*) AS total_products
            FROM products
            WHERE is_deleted = 0
        """)
        total = cursor.fetchone()

        cursor.execute("""
            SELECT expiry_status, COUNT(*) AS total
            FROM verification v
            JOIN (
                SELECT product_id, MAX(verification_id) AS latest_id
                FROM verification
                GROUP BY product_id
            ) latest ON v.verification_id = latest.latest_id
            GROUP BY expiry_status
        """)
        expiry = cursor.fetchall()

        cursor.execute("""
            SELECT priority, COUNT(*) AS total
            FROM verification v
            JOIN (
                SELECT product_id, MAX(verification_id) AS latest_id
                FROM verification
                GROUP BY product_id
            ) latest ON v.verification_id = latest.latest_id
            GROUP BY priority
        """)
        priorities = cursor.fetchall()

        cursor.execute("""
            SELECT status, COUNT(*) AS total
            FROM actions
            GROUP BY status
        """)
        actions = cursor.fetchall()

        cursor.execute("""
            SELECT category, COUNT(*) AS total_products,
                   SUM(quantity) AS total_quantity
            FROM products
            WHERE is_deleted = 0
            GROUP BY category
        """)
        categories = cursor.fetchall()

        return jsonify({
            "total_products": total["total_products"],
            "expiry_summary": expiry,
            "priority_summary": priorities,
            "action_summary": actions,
            "category_summary": categories
        })

    except Exception as error:
        return jsonify({"error": str(error)}), 500

    finally:
        cursor.close()
        conn.close()



@app.route("/reports")
def reports_page():
    if "user_id" not in session:
        return redirect("/login")
    return render_template("reports.html")



@app.route("/history")
def history_page():
    if "user_id" not in session:
        return redirect("/login")
    return render_template("history.html")



@app.route("/actions")
def actions_page():
    if "user_id" not in session:
        return redirect("/login")
    return render_template("actions.html")


if __name__ == "__main__":
    app.run(
        host="127.0.0.1",
        port=5000,
        debug=False,
        use_reloader=False
    )
