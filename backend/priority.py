import heapq
from backend.db import get_db


def calculate_priority(product_id, verification_result):

    conn = get_db()

    if conn is None:
        return {"error": "Database connection failed"}

    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT p.quantity, p.category, r.large_qty
            FROM products p
            JOIN category_rules r ON p.category = r.category
            WHERE p.product_id = %s
        """, (product_id,))

        product = cursor.fetchone()

        if not product:
            return {"error": "Product not found"}

        expiry = verification_result["expiry_status"]
        storage = verification_result["storage_status"]
        issue = verification_result["data_issue"]
        days_left = verification_result["days_left"]

        quantity = product["quantity"]
        large_qty = product["large_qty"]

        # Priority calculation
        if expiry == "EXPIRED":
            priority = "CRITICAL"
        elif issue:
            priority = "INSPECTION NEEDED"
        elif expiry == "NEAR EXPIRY" and storage == "ALERT":
            priority = "HIGH"
        elif expiry == "NEAR EXPIRY" and days_left <= 2:
            priority = "HIGH"
        elif expiry == "NEAR EXPIRY":
            priority = "MEDIUM"
        elif storage == "ALERT":
            priority = "MEDIUM"
        else:
            priority = "LOW"

        # Suggested action
        if expiry == "EXPIRED":
            action = "REMOVE/DISPOSE"
        elif issue or storage == "ALERT":
            action = "FURTHER INSPECTION"
        elif expiry == "NEAR EXPIRY" and quantity >= large_qty:
            action = "REDISTRIBUTION"
        elif expiry == "NEAR EXPIRY":
            action = "PRIORITY SALE/QUICK USAGE"
        else:
            action = "NO ACTION/CONTINUE"

        return {
            "product_id": product_id,
            "priority": priority,
            "suggested_action": action
        }

    finally:
        cursor.close()
        conn.close()


def priority_queue(products):

    queue = []

    priority_order = {
        "CRITICAL": 1,
        "HIGH": 2,
        "MEDIUM": 3,
        "INSPECTION NEEDED": 4,
        "LOW": 5
    }

    for product in products:
        level = priority_order.get(product["priority"], 5)

        heapq.heappush(
            queue,
            (level, product["product_id"], product)
        )

    return [
        heapq.heappop(queue)[2]
        for _ in range(len(queue))
    ]
