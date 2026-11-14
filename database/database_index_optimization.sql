-- =====================================================
-- FRESHFIRST DATABASE INDEX OPTIMIZATION
-- Date: 14 November 2026
-- =====================================================

USE fresh_first;

-- 1. Optimize active stock filtering and expiry sorting

CREATE INDEX idx_products_active_expiry
ON products (is_deleted, expiry_date);

-- 2. Optimize recent history retrieval

CREATE INDEX idx_history_event_time
ON history (event_time);

-- 3. Verify optimized indexes

SHOW INDEX FROM products;
SHOW INDEX FROM history;

-- =====================================================
-- END OF INDEX OPTIMIZATION
-- =====================================================
