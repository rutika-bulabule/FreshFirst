-- FreshFirst
-- Smart Product Expiry Verification
-- Development Date: 13 November 2026

SELECT
    p.product_id,
    p.name,
    p.category,
    p.quantity,
    p.expiry_date,

    DATEDIFF(p.expiry_date, CURDATE()) AS days_left,

    CASE
        WHEN p.expiry_date < CURDATE()
            THEN 'EXPIRED'
        WHEN DATEDIFF(p.expiry_date, CURDATE())
             <= cr.near_expiry_days
            THEN 'NEAR EXPIRY'
        ELSE 'SAFE'
    END AS expiry_status,

    CASE
        WHEN p.recorded_temp IS NULL
            THEN 'UNKNOWN'
        WHEN p.recorded_temp BETWEEN cr.min_temp AND cr.max_temp
            THEN 'OK'
        ELSE 'ALERT'
    END AS storage_status,

    CASE
        WHEN cr.category IS NULL THEN 'MISSING RULE'
        WHEN p.recorded_temp IS NULL THEN 'MISSING TEMP'
        WHEN p.quantity <= 0 THEN 'INVALID QUANTITY'
        ELSE NULL
    END AS data_issue,

    CASE
        WHEN p.expiry_date < CURDATE()
            OR (p.recorded_temp IS NOT NULL
                AND (p.recorded_temp < cr.min_temp
                OR p.recorded_temp > cr.max_temp))
            THEN 'REQUIRES ACTION'
        WHEN cr.category IS NULL
            OR p.recorded_temp IS NULL
            OR p.quantity <= 0
            THEN 'NEEDS REVIEW'
        WHEN DATEDIFF(p.expiry_date, CURDATE())
             <= cr.near_expiry_days
            THEN 'WARNING'
        ELSE 'ACCEPTABLE'
    END AS overall_status,

    CASE
        WHEN p.expiry_date < CURDATE()
            OR (p.recorded_temp IS NOT NULL
                AND (p.recorded_temp < cr.min_temp
                OR p.recorded_temp > cr.max_temp))
            THEN 'HIGH'
        WHEN cr.category IS NULL
            OR p.recorded_temp IS NULL
            OR p.quantity <= 0
            OR DATEDIFF(p.expiry_date, CURDATE())
               <= cr.near_expiry_days
            THEN 'MEDIUM'
        ELSE 'LOW'
    END AS priority,

    CASE
        WHEN p.expiry_date < CURDATE() THEN 'REMOVE'
        WHEN cr.category IS NULL THEN 'CHECK CATEGORY'
        WHEN p.recorded_temp IS NULL THEN 'CHECK TEMPERATURE'
        WHEN p.quantity <= 0 THEN 'CHECK QUANTITY'
        WHEN p.recorded_temp < cr.min_temp
            OR p.recorded_temp > cr.max_temp
            THEN 'CHECK STORAGE'
        WHEN DATEDIFF(p.expiry_date, CURDATE())
             <= cr.near_expiry_days
            THEN 'USE SOON'
        ELSE 'CONTINUE'
    END AS suggested_action

FROM products p

LEFT JOIN category_rules cr
    ON cr.category =
       CASE
           WHEN p.category = 'Vegetable' THEN 'Vegetables'
           ELSE p.category
       END

WHERE p.is_deleted = 0

ORDER BY priority, p.expiry_date;