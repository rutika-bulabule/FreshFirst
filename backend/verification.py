from datetime import date
from backend.db import get_db


def verify_product(product_id):

    conn = get_db()

    if conn is None:
        return {"error": "Database connection failed"}

    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT *
            FROM products
            WHERE product_id = %s AND is_deleted = 0
        """, (product_id,))

        product = cursor.fetchone()

        if not product:
            return {"error": "Product not found"}

        cursor.execute("""
            SELECT *
            FROM category_rules
            WHERE category = %s
        """, (product["category"],))

        rule = cursor.fetchone()

        if not rule:
            return {
                "error": "Category rule not found",
                "product": product["name"]
            }

        today = date.today()
        expiry_date = product["expiry_date"]
        purchase_date = product["purchase_date"]
        quantity = product["quantity"]

        days_left = (expiry_date - today).days

        expiry_status = "VALID"
        storage_status = "OK"
        data_issue = None
        overall_status = "VALID"

        # R6: Check incomplete records
        if (
            not product["name"]
            or not product["category"]
            or not purchase_date
            or not expiry_date
            or not product["storage_condition"]
        ):
            data_issue = "INCOMPLETE RECORD"

        # R7: Check invalid dates
        elif expiry_date <= purchase_date:
            data_issue = "INVALID DATES"

        # R4: Check invalid quantity
        elif quantity is None or quantity <= 0:
            data_issue = "INVALID QUANTITY"

        # R1: Expired product
        elif days_left < 0:
            expiry_status = "EXPIRED"

        # R2: Near-expiry product
        elif days_left <= rule["near_expiry_days"]:
            expiry_status = "NEAR EXPIRY"

        # R3: Valid product
        else:
            expiry_status = "VALID"

        # R5: Check storage temperature
        temperature = product["recorded_temp"]

        if temperature is not None:
            if (
                temperature < rule["min_temp"]
                or temperature > rule["max_temp"]
            ):
                storage_status = "ALERT"

        if data_issue or storage_status == "ALERT":
            overall_status = "NEEDS ATTENTION"
        elif expiry_status != "VALID":
            overall_status = "NEEDS ATTENTION"

        return {
            "product_id": product_id,
            "product_name": product["name"],
            "days_left": days_left,
            "expiry_status": expiry_status,
            "storage_status": storage_status,
            "data_issue": data_issue,
            "overall_status": overall_status
        }

    finally:
        cursor.close()
        conn.close()
