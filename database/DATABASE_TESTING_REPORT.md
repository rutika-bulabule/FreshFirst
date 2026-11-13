# FreshFirst – Database Testing Report

**Project Title:** Perishable Stock Verification Register  
**Application Name:** FreshFirst  
**Date:** 13 November 2026  
**Database Name:** fresh_first  
**Database:** MySQL  

## 1. Database Overview

The FreshFirst application uses MySQL to store and manage perishable stock information.

The database stores user details, product details, category rules, verification results, action records and history.

## 2. Tables Verified

The database contains six tables:

1. users
2. products
3. category_rules
4. verification
5. history
6. actions

All six tables were checked.

## 3. Record Count

| Table Name | Records |
|---|---:|
| users | 3 |
| products | 5 |
| category_rules | 4 |
| verification | 3 |
| history | 6 |
| actions | 3 |
| **Total** | **24** |

## 4. Storage Engine Verification

All six tables in the actual database use the InnoDB storage engine.

No MyISAM tables were found.

InnoDB supports transactions and foreign key relationships.

The corrected backup file was also checked to confirm that all six table definitions explicitly specify InnoDB.

## 5. Foreign Key Verification

The following nine foreign key relationships were checked:

| Foreign Key | Relationship |
|---|---|
| fk_products_created_by | products.created_by → users.user_id |
| fk_products_category | products.category → category_rules.category |
| fk_verification_product | verification.product_id → products.product_id |
| fk_verification_user | verification.verified_by → users.user_id |
| fk_history_product | history.product_id → products.product_id |
| fk_history_user | history.user_id → users.user_id |
| fk_actions_product | actions.product_id → products.product_id |
| fk_actions_verification | actions.verification_id → verification.verification_id |
| fk_actions_decided_by | actions.decided_by → users.user_id |

All nine foreign keys were verified.

## 6. Data Corrections

The following corrections were made during database testing:

1. Corrected the product category from `Vegetable` to `Vegetables`.
2. Corrected the Test Product user reference to user ID 1.
3. Restored Banana by setting `is_deleted = 0`.
4. Restored Test Product by setting `is_deleted = 0`.
5. Checked product records to confirm that all five products are active.

No existing records were permanently deleted.

## 7. History Table Protection

Two database triggers were created:

- `trg_history_no_update`
- `trg_history_no_delete`

These triggers prevent modification and deletion of existing history records.

### UPDATE Test

```sql
UPDATE history
SET details = details
WHERE history_id = 1;
```

**Expected Result:** Modification should be blocked.

**Actual Result:** MySQL returned the error:

`History records cannot be modified`

**Status:** PASS

### DELETE Test

```sql
DELETE FROM history
WHERE history_id = 1;
```

**Expected Result:** Deletion should be blocked.

**Actual Result:** MySQL returned the error:

`History records cannot be deleted`

**Status:** PASS

The original history record remained unchanged.

## 8. Database Integrity Testing

A total of 29 SQL checks were executed.

### Checks 1–23: Data Validation

The following conditions were checked:

- Invalid user references
- Invalid product references
- Invalid verification references
- Invalid history references
- Invalid action references
- Invalid quantities
- Invalid purchase and expiry dates
- Duplicate active product names
- Unmatched product categories
- Invalid user roles
- Invalid `is_deleted` values
- Duplicate usernames
- Duplicate category rules
- Missing product names
- Missing categories
- Missing purchase dates
- Missing expiry dates
- Missing storage conditions
- Invalid temperature ranges
- Negative near-expiry thresholds

**Result:** All 23 issue-detection checks returned zero invalid records.

### Checks 24–29: Summary Reports

The following summary queries were executed successfully:

| Check | Result |
|---|---|
| Verification priority | LOW: 3 |
| Action status | DONE: 3 |
| History events | PRODUCT_ADDED: 3, VERIFIED: 3 |
| Fruits stock | 3 products, quantity 45 |
| Vegetables stock | 2 products, quantity 35 |
| Active products | 5 |
| Deleted products | 0 |

The final table record counts matched the expected database records.

## 9. Expiry Verification

An expiry checking query was executed on 13 November 2026.

| Product | Days Left | Expiry Status | Storage Status | Priority | Suggested Action |
|---|---:|---|---|---|---|
| Banana | -3 | EXPIRED | ALERT | HIGH | REMOVE |
| Tomato | -1 | EXPIRED | OK | HIGH | REMOVE |
| Carrot | 1 | NEAR EXPIRY | OK | MEDIUM | USE SOON |
| Apple | 2 | NEAR EXPIRY | OK | MEDIUM | USE SOON |
| Test Product | 2 | NEAR EXPIRY | OK | MEDIUM | USE SOON |

No data issues were returned by this expiry checking query.

## 10. Verification Record Observation

During database testing, an important observation was found.

1. Apple, Tomato and Carrot have existing verification records.
2. These records were created on 7 November 2026.
3. Their saved expiry information does not match the current product expiry dates.
4. Banana and Test Product do not yet have verification records.
5. Existing verification, action and history records have been preserved.

**Conclusion:** These existing verification records are historical records. Fresh verification records should be created through the Flask backend whenever products are verified. Existing history records must remain unchanged.

## 11. Active Stock Summary

| Category | Product Count | Total Quantity |
|---|---:|---:|
| Fruits | 3 | 45 |
| Vegetables | 2 | 35 |
| **Total** | **5** | **80** |

Active products: 5  
Deleted products: 0  
Total active stock quantity: 80

## 12. Database Backup

Database backups were maintained during development.

A corrected backup file was created:

**Backup File:** `fresh_first_backup_corrected.sql`  
**Date:** 13 November 2026

The corrected backup was checked for:

- Six table definitions
- Six InnoDB table declarations
- Nine foreign key constraints
- Two history triggers
- Restored Banana record
- Corrected Test Product record
- Correct AUTO_INCREMENT definitions

The corrected backup contains all 24 database records.

The backup file passed the structural checks. A separate database restore test has not yet been performed.

## 13. Database Files Maintained

The following files are maintained in the `database` folder:

1. `fresh_first_backup.sql`
2. `fresh_first_backup_latest.sql.sql`
3. `fresh_first_backup_final.sql`
4. `fresh_first_backup_final (1).sql`
5. `fresh_first_backup_corrected.sql`
6. `queries_log.sql`
7. `database_integrity_checks.sql`
8. `expiry_verification.sql`
9. `DATABASE_TESTING_REPORT.md`

## 14. Conclusion

The FreshFirst MySQL database contains six tables with 24 records.

All six tables use InnoDB, and nine foreign key relationships were verified. Two triggers protect the history table from modification and deletion.

The 23 data validation checks returned no invalid records. The remaining six queries successfully generated database summary reports.

The corrected database backup was checked and contains six InnoDB table definitions, nine foreign keys and two history triggers.

The database work completed so far provides the foundation for connecting the FreshFirst application with its Flask backend, frontend and testing modules.