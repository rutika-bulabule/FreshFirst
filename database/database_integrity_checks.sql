USE fresh_first;

-- 1. Invalid product user references
SELECT p.product_id, p.name, p.created_by
FROM products p
LEFT JOIN users u ON p.created_by = u.user_id
WHERE u.user_id IS NULL;

-- 2. Invalid verification user references
SELECT v.verification_id, v.verified_by
FROM verification v
LEFT JOIN users u ON v.verified_by = u.user_id
WHERE u.user_id IS NULL;

-- 3. Invalid verification product references
SELECT v.verification_id, v.product_id
FROM verification v
LEFT JOIN products p ON v.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 4. Invalid history product references
SELECT h.history_id, h.product_id
FROM history h
LEFT JOIN products p ON h.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 5. Invalid history user references
SELECT h.history_id, h.user_id
FROM history h
LEFT JOIN users u ON h.user_id = u.user_id
WHERE u.user_id IS NULL;

-- 6. Invalid action product references
SELECT a.action_id, a.product_id
FROM actions a
LEFT JOIN products p ON a.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 7. Invalid action verification references
SELECT a.action_id, a.verification_id
FROM actions a
LEFT JOIN verification v ON a.verification_id = v.verification_id
WHERE v.verification_id IS NULL;

-- 8. Invalid action user references
SELECT a.action_id, a.decided_by
FROM actions a
LEFT JOIN users u ON a.decided_by = u.user_id
WHERE a.decided_by IS NOT NULL
AND u.user_id IS NULL;

-- 9. Zero or negative product quantities
SELECT product_id, name, quantity
FROM products
WHERE quantity <= 0;

-- 10. Invalid expiry dates
SELECT product_id, name, purchase_date, expiry_date
FROM products
WHERE expiry_date <= purchase_date;

-- 11. Duplicate active product names
SELECT name, COUNT(*) AS total
FROM products
WHERE is_deleted = 0
GROUP BY name
HAVING COUNT(*) > 1;

-- 12. Unmatched product categories
SELECT p.product_id, p.name, p.category
FROM products p
LEFT JOIN category_rules cr
ON CASE
    WHEN p.category = 'Vegetable' THEN 'Vegetables'
    ELSE p.category
END = cr.category
WHERE p.is_deleted = 0
AND cr.category IS NULL;

-- 13. Invalid user roles
SELECT user_id, username, role
FROM users
WHERE role IS NULL
OR role NOT IN ('ADMIN', 'MANAGER', 'STAFF');

-- 14. Invalid product deletion status
SELECT product_id, name, is_deleted
FROM products
WHERE is_deleted IS NULL
OR is_deleted NOT IN (0, 1);

-- 15. Duplicate usernames
SELECT username, COUNT(*) AS total
FROM users
GROUP BY username
HAVING COUNT(*) > 1;

-- 16. Duplicate category rules
SELECT category, COUNT(*) AS total
FROM category_rules
GROUP BY category
HAVING COUNT(*) > 1;

-- 17. Missing product names
SELECT product_id, name
FROM products
WHERE name IS NULL OR TRIM(name) = '';

-- 18. Missing product categories
SELECT product_id, name, category
FROM products
WHERE category IS NULL OR TRIM(category) = '';

-- 19. Missing purchase dates
SELECT product_id, name, purchase_date
FROM products
WHERE purchase_date IS NULL;

-- 20. Missing expiry dates
SELECT product_id, name, expiry_date
FROM products
WHERE expiry_date IS NULL;

-- 21. Missing storage conditions
SELECT product_id, name, storage_condition
FROM products
WHERE storage_condition IS NULL
OR TRIM(storage_condition) = '';

-- 22. Invalid category temperature ranges
SELECT category, min_temp, max_temp
FROM category_rules
WHERE min_temp IS NULL
OR max_temp IS NULL
OR min_temp > max_temp;

-- 23. Invalid near-expiry thresholds
SELECT category, near_expiry_days
FROM category_rules
WHERE near_expiry_days IS NULL
OR near_expiry_days < 0;

-- 24. Verification priority distribution
SELECT priority, COUNT(*) AS total
FROM verification
GROUP BY priority;

-- 25. Action status distribution
SELECT status, COUNT(*) AS total
FROM actions
GROUP BY status;

-- 26. History event distribution
SELECT event_type, COUNT(*) AS total
FROM history
GROUP BY event_type;

-- 27. Category-wise stock summary
SELECT category,
       COUNT(*) AS total_products,
       SUM(quantity) AS total_quantity
FROM products
WHERE is_deleted = 0
GROUP BY category;

-- 28. Active and deleted product count
SELECT is_deleted, COUNT(*) AS total_products
FROM products
GROUP BY is_deleted;

-- 29. Final record count
SELECT
    (SELECT COUNT(*) FROM users) AS users,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM category_rules) AS category_rules,
    (SELECT COUNT(*) FROM verification) AS verification,
    (SELECT COUNT(*) FROM history) AS history,
    (SELECT COUNT(*) FROM actions) AS actions;