-- =====================================================
-- FRESHFIRST
-- PERISHABLE STOCK VERIFICATION REGISTER
-- DATABASE SQL QUERIES LOG
-- Database: fresh_first
-- Date: 13 November 2026
-- =====================================================

USE fresh_first;


-- =====================================================
-- 1. CREATE TABLES
-- =====================================================

CREATE TABLE users (
    user_id INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('ADMIN','MANAGER','STAFF') NOT NULL,
    is_active TINYINT(1) DEFAULT '1',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE TABLE category_rules (
    category VARCHAR(50) NOT NULL,
    near_expiry_days INT NOT NULL DEFAULT '3',
    min_temp DECIMAL(5,2) NOT NULL,
    max_temp DECIMAL(5,2) NOT NULL,
    large_qty INT NOT NULL DEFAULT '20'
) ENGINE=InnoDB;


CREATE TABLE products (
    product_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    purchase_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    storage_condition VARCHAR(50) NOT NULL,
    recorded_temp DECIMAL(5,2) DEFAULT NULL,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0'
) ENGINE=InnoDB;


CREATE TABLE verification (
    verification_id INT NOT NULL,
    product_id INT NOT NULL,
    verified_by INT NOT NULL,
    verified_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    days_left INT DEFAULT NULL,
    expiry_status VARCHAR(20) NOT NULL,
    storage_status VARCHAR(20) NOT NULL,
    data_issue VARCHAR(30) DEFAULT NULL,
    overall_status VARCHAR(30) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    suggested_action VARCHAR(30) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE history (
    history_id INT NOT NULL,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    event_type VARCHAR(30) NOT NULL,
    details VARCHAR(255) DEFAULT NULL,
    event_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE TABLE actions (
    action_id INT NOT NULL,
    product_id INT NOT NULL,
    verification_id INT NOT NULL,
    suggested_action VARCHAR(30) NOT NULL,
    final_action VARCHAR(30) NOT NULL,
    status ENUM('PENDING','DONE') DEFAULT 'PENDING',
    action_date DATETIME DEFAULT NULL,
    decided_by INT DEFAULT NULL
) ENGINE=InnoDB;


-- =====================================================
-- 2. INSERT CATEGORY RULES
-- =====================================================

INSERT INTO category_rules
(category, near_expiry_days, min_temp, max_temp, large_qty)
VALUES
('Bakery', 2, 15.00, 25.00, 30),
('Dairy', 3, 2.00, 8.00, 20),
('Fruits', 3, 4.00, 12.00, 25),
('Vegetables', 3, 4.00, 12.00, 25);


-- =====================================================
-- 3. INSERT USERS
-- =====================================================

INSERT INTO users
(user_id, username, password_hash, full_name, role, is_active)
VALUES
(1, 'admin', 'demo_hash_1', 'Fresh First Admin', 'ADMIN', 1),
(2, 'manager1', 'demo_hash_2', 'Store Manager', 'MANAGER', 1),
(3, 'staff1', 'demo_hash_3', 'Store Staff', 'STAFF', 1);


-- =====================================================
-- 4. INSERT PRODUCTS
-- =====================================================

INSERT INTO products
(product_id, name, category, quantity, purchase_date,
 expiry_date, storage_condition, recorded_temp,
 created_by, is_deleted)
VALUES
(1, 'Apple', 'Fruits', 25, '2026-11-06',
 '2026-11-15', 'Refrigerated', 5.00, 1, 0),

(2, 'Banana', 'Fruits', 15, '2026-11-06',
 '2026-11-10', 'Room Temperature', 22.00, 1, 0),

(3, 'Tomato', 'Vegetables', 10, '2026-11-06',
 '2026-11-12', 'Refrigerated', 6.00, 1, 0),

(4, 'Carrot', 'Vegetables', 25, '2026-11-06',
 '2026-11-14', 'Refrigerated', 5.00, 1, 0),

(5, 'Test Product', 'Fruits', 5, '2026-11-06',
 '2026-11-15', 'Refrigerated', 5.00, 1, 0);


-- =====================================================
-- 5. INSERT VERIFICATION RECORDS
-- =====================================================

INSERT INTO verification
(verification_id, product_id, verified_by, days_left,
 expiry_status, storage_status, data_issue,
 overall_status, priority, suggested_action)
VALUES
(1, 1, 1, 8, 'SAFE', 'OK', NULL,
 'ACCEPTABLE', 'LOW', 'CONTINUE'),

(2, 3, 1, 5, 'SAFE', 'OK', NULL,
 'ACCEPTABLE', 'LOW', 'CONTINUE'),

(3, 4, 1, 7, 'SAFE', 'OK', NULL,
 'ACCEPTABLE', 'LOW', 'CONTINUE');


-- =====================================================
-- 6. INSERT ACTION RECORDS
-- =====================================================

INSERT INTO actions
(action_id, product_id, verification_id,
 suggested_action, final_action, status, action_date, decided_by)
VALUES
(1, 1, 1, 'CONTINUE', 'CONTINUE', 'DONE',
 '2026-11-07 22:16:58', 1),

(2, 3, 2, 'CONTINUE', 'CONTINUE', 'DONE',
 '2026-11-07 22:16:58', 1),

(3, 4, 3, 'CONTINUE', 'CONTINUE', 'DONE',
 '2026-11-07 22:16:58', 1);


-- =====================================================
-- 7. INSERT HISTORY RECORDS
-- =====================================================

INSERT INTO history
(history_id, product_id, user_id, event_type, details)
VALUES
(1, 1, 1, 'PRODUCT_ADDED', 'Apple added to stock'),
(2, 3, 1, 'PRODUCT_ADDED', 'Tomato added to stock'),
(3, 4, 1, 'PRODUCT_ADDED', 'Carrot added to stock'),
(4, 1, 1, 'VERIFIED', 'Apple verification completed'),
(5, 3, 1, 'VERIFIED', 'Tomato verification completed'),
(6, 4, 1, 'VERIFIED', 'Carrot verification completed');


-- =====================================================
-- 8. PRIMARY KEYS AND INDEXES
-- =====================================================

ALTER TABLE actions
ADD PRIMARY KEY (action_id),
ADD KEY fk_actions_product (product_id),
ADD KEY fk_actions_verification (verification_id),
ADD KEY fk_actions_decided_by (decided_by);


ALTER TABLE category_rules
ADD PRIMARY KEY (category);


ALTER TABLE history
ADD PRIMARY KEY (history_id),
ADD KEY idx_history_product (product_id),
ADD KEY fk_history_user (user_id);


ALTER TABLE products
ADD PRIMARY KEY (product_id),
ADD KEY idx_products_expiry (expiry_date),
ADD KEY fk_products_created_by (created_by),
ADD KEY fk_products_category (category);


ALTER TABLE users
ADD PRIMARY KEY (user_id),
ADD UNIQUE KEY username (username);


ALTER TABLE verification
ADD PRIMARY KEY (verification_id),
ADD KEY idx_verification_product (product_id),
ADD KEY fk_verification_user (verified_by);


-- =====================================================
-- 9. AUTO INCREMENT
-- =====================================================

ALTER TABLE actions
MODIFY action_id INT NOT NULL AUTO_INCREMENT,
AUTO_INCREMENT = 4;


ALTER TABLE history
MODIFY history_id INT NOT NULL AUTO_INCREMENT,
AUTO_INCREMENT = 7;


ALTER TABLE products
MODIFY product_id INT NOT NULL AUTO_INCREMENT;


ALTER TABLE users
MODIFY user_id INT NOT NULL AUTO_INCREMENT,
AUTO_INCREMENT = 4;


ALTER TABLE verification
MODIFY verification_id INT NOT NULL AUTO_INCREMENT,
AUTO_INCREMENT = 4;


-- =====================================================
-- 10. FOREIGN KEY CONSTRAINTS
-- =====================================================

ALTER TABLE actions
ADD CONSTRAINT fk_actions_decided_by
FOREIGN KEY (decided_by) REFERENCES users(user_id),

ADD CONSTRAINT fk_actions_product
FOREIGN KEY (product_id) REFERENCES products(product_id),

ADD CONSTRAINT fk_actions_verification
FOREIGN KEY (verification_id)
REFERENCES verification(verification_id);


ALTER TABLE history
ADD CONSTRAINT fk_history_product
FOREIGN KEY (product_id) REFERENCES products(product_id),

ADD CONSTRAINT fk_history_user
FOREIGN KEY (user_id) REFERENCES users(user_id);


ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (category) REFERENCES category_rules(category),

ADD CONSTRAINT fk_products_created_by
FOREIGN KEY (created_by) REFERENCES users(user_id);


ALTER TABLE verification
ADD CONSTRAINT fk_verification_product
FOREIGN KEY (product_id) REFERENCES products(product_id),

ADD CONSTRAINT fk_verification_user
FOREIGN KEY (verified_by) REFERENCES users(user_id);


-- =====================================================
-- 11. HISTORY PROTECTION TRIGGERS
-- =====================================================

DELIMITER $$

CREATE TRIGGER trg_history_no_delete
BEFORE DELETE ON history
FOR EACH ROW
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'History records cannot be deleted'$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_history_no_update
BEFORE UPDATE ON history
FOR EACH ROW
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'History records cannot be modified'$$

DELIMITER ;


-- =====================================================
-- 12. PRODUCT RESTORATION
-- Already performed on 13 November 2026.
-- Kept as a historical record.
-- =====================================================

-- UPDATE products
-- SET is_deleted = 0
-- WHERE product_id IN (2, 5);


-- =====================================================
-- 13. DISPLAY DATABASE TABLES
-- =====================================================

SHOW TABLES;


-- =====================================================
-- 14. DISPLAY ALL RECORDS
-- =====================================================

SELECT * FROM users;

SELECT * FROM products;

SELECT * FROM category_rules;

SELECT * FROM verification;

SELECT * FROM actions;

SELECT * FROM history;


-- =====================================================
-- 15. ACTIVE STOCK SUMMARY
-- =====================================================

SELECT
    COUNT(*) AS total_active_products,
    SUM(quantity) AS total_active_quantity
FROM products
WHERE is_deleted = 0;


-- =====================================================
-- 16. CATEGORY-WISE STOCK
-- =====================================================

SELECT
    category,
    COUNT(*) AS total_products,
    SUM(quantity) AS total_quantity
FROM products
WHERE is_deleted = 0
GROUP BY category;


-- =====================================================
-- 17. EXPIRY CHECKING
-- =====================================================

SELECT
    name,
    expiry_date,
    DATEDIFF(expiry_date, CURDATE()) AS days_left
FROM products
WHERE is_deleted = 0
AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL 3 DAY)
ORDER BY expiry_date;


-- =====================================================
-- 18. FOREIGN KEY VERIFICATION
-- =====================================================

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'fresh_first'
AND REFERENCED_TABLE_NAME IS NOT NULL;


-- =====================================================
-- 19. STORAGE ENGINE CHECKING
-- =====================================================

SELECT
    TABLE_NAME,
    ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'fresh_first'
AND TABLE_TYPE = 'BASE TABLE';


-- =====================================================
-- 20. TRIGGER CHECKING
-- =====================================================

SHOW TRIGGERS;


-- =====================================================
-- 21. HISTORY TRIGGER TESTING
-- Manual tests. Expected to return errors.
-- Do not uncomment and execute with the full file.
-- =====================================================

-- UPDATE history
-- SET details = details
-- WHERE history_id = 1;

-- DELETE FROM history
-- WHERE history_id = 1;

SELECT *
FROM history
WHERE history_id = 1;


-- =====================================================
-- END OF FRESHFIRST DATABASE QUERIES LOG
-- =====================================================