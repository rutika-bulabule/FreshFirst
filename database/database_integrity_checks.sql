```sql
-- ==========================================
-- FreshFirst Database Integrity Checks
-- Date: 13 November 2026
-- Database: fresh_first
-- Purpose: Validate database records
-- All queries are READ ONLY (SELECT)
-- ==========================================

USE fresh_first;

-- 1. Check products with invalid user references
SELECT p.product_id, p.name, p.created_by
FROM products p
LEFT JOIN users u ON p.created_by = u.user_id
WHERE u.user_id IS NULL;

-- 2. Check invalid verification user references
SELECT v.verification_id, v.verified_by
FROM verification v
LEFT JOIN users u ON v.verified_by = u.user_id
WHERE u.user_id IS NULL;

-- 3. Check negative product quantities
SELECT product_id, name, quantity
FROM products
WHERE quantity < 0;

-- 4. Check expiry date before purchase date
SELECT product_id, name, purchase_date, expiry_date
FROM products
WHERE expiry_date < purchase_date;

-- 5. Check duplicate active product names
SELECT name, COUNT(*) AS total
FROM products
WHERE is_deleted = 0
GROUP BY name
HAVING COUNT(*) > 1;

-- 6. Check unmatched product categories
SELECT p.product_id, p.name, p.category
FROM products p
LEFT JOIN category_rules cr
ON CASE
    WHEN p.category = 'Vegetable' THEN 'Vegetables'
    ELSE p.category
END = cr.category
WHERE p.is_deleted = 0
AND cr.category IS NULL;

-- 7. Check invalid user roles
SELECT user_id, username, role
FROM users
WHERE role NOT IN ('ADMIN', 'MANAGER', 'STAFF');

-- 8. Check invalid product deletion status
SELECT product_id, name, is_deleted
FROM products
WHERE is_deleted NOT IN (0, 1);

-- 9. Check duplicate usernames
SELECT username, COUNT(*) AS total
FROM users
GROUP BY username
HAVING COUNT(*) > 1;

-- 10. Check duplicate category rules
SELECT category, COUNT(*) AS total
FROM category_rules
GROUP BY category
HAVING COUNT(*) > 1;

-- 11. Check missing product names
SELECT product_id, name
FROM products
WHERE name IS NULL OR TRIM(name) = '';

-- 12. Check missing storage conditions
SELECT product_id, name, storage_condition
FROM products
WHERE storage_condition IS NULL
OR TRIM(storage_condition) = '';

-- 13. Check verification priority distribution
SELECT priority, COUNT(*) AS total
FROM verification
GROUP BY priority;

-- 14. Check action status distribution
SELECT status, COUNT(*) AS total
FROM actions
GROUP BY status;

-- 15. Check history event distribution
SELECT event_type, COUNT(*) AS total
FROM history
GROUP BY event_type;

-- 16. Category-wise stock summary
SELECT category,
       COUNT(*) AS total_products,
       SUM(quantity) AS total_quantity
FROM products
WHERE is_deleted = 0
GROUP BY category;

-- 17. Active and deleted product count
SELECT is_deleted, COUNT(*) AS total_products
FROM products
GROUP BY is_deleted;

-- 18. Final record count
SELECT
(SELECT COUNT(*) FROM users) AS users,
(SELECT COUNT(*) FROM products) AS products,
(SELECT COUNT(*) FROM category_rules) AS category_rules,
(SELECT COUNT(*) FROM verification) AS verification,
(SELECT COUNT(*) FROM history) AS history,
(SELECT COUNT(*) FROM actions) AS actions;

-- End of Database Integrity Checks
```