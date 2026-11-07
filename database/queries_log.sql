SELECT * FROM products;

SHOW TABLES;

-- FreshFirst Database Reports

SELECT * FROM users;

SELECT * FROM category_rules;

SELECT * FROM products;

SELECT * FROM verification;

SELECT * FROM actions;

SELECT * FROM history;

-- Expiry Checking
SELECT name, expiry_date
FROM products
WHERE expiry_date <= DATE_ADD(CURDATE(), INTERVAL 3 DAY);

-- Category-wise Stock
SELECT category, SUM(quantity)
FROM products
WHERE is_deleted = 0
GROUP BY category;

-- Database Tables
SHOW TABLES;

-- Trigger Checking
SHOW TRIGGERS;