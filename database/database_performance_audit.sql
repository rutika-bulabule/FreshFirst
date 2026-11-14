-- =====================================================
-- FRESHFIRST DATABASE PERFORMANCE AUDIT
-- Date: 14 November 2026
-- Purpose: Inspect indexes and query performance
-- =====================================================

USE fresh_first;

-- 1. Check indexes on all six tables

SHOW INDEX FROM users;
SHOW INDEX FROM products;
SHOW INDEX FROM category_rules;
SHOW INDEX FROM verification;
SHOW INDEX FROM history;
SHOW INDEX FROM actions;

-- 2. Analyse active stock retrieval

EXPLAIN
SELECT *
FROM products
WHERE is_deleted = 0
ORDER BY expiry_date;

-- 3. Analyse category-based stock retrieval

EXPLAIN
SELECT *
FROM products
WHERE category = 'Fruits'
AND is_deleted = 0;

-- 4. Analyse verification priority retrieval

EXPLAIN
SELECT *
FROM verification
WHERE priority = 'HIGH';

-- 5. Analyse pending actions retrieval

EXPLAIN
SELECT *
FROM actions
WHERE status = 'PENDING';

-- 6. Analyse recent history retrieval

EXPLAIN
SELECT *
FROM history
ORDER BY event_time DESC;

-- =====================================================
-- END OF PERFORMANCE AUDIT
-- =====================================================
