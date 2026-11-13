# FreshFirst - Database Testing Report

**Date:** 13 November 2026

## 1. Database Details

**Database Name:** fresh_first

## 2. Tables Verified

1. users
2. products
3. category_rules
4. verification
5. history
6. actions

## 3. Record Count

| Table | Records |
|---|---:|
| users | 3 |
| products | 5 |
| category_rules | 4 |
| verification | 3 |
| history | 6 |
| actions | 3 |
| **Total** | **24** |

## 4. Testing Completed

- Checked all six table structures.
- Verified product and user relationships.
- Checked verification and action relationships.
- Checked history records.
- Checked category rule values.
- Checked for orphan records.

## 5. Findings

- One orphan product record was found (product_id: 5).
- Its created_by value does not match an existing user.
- No foreign-key constraints are currently defined.
- No database records were modified or deleted during the initial testing.

## 6. Conclusion

All six tables were checked. A total of 24 records were found. The identified integrity issues are documented for further review.

## 7. Smart Product Expiry Verification

**Development Date:** 13 November 2026

A new SQL query was developed to verify product expiry and storage conditions.

### Features Implemented

- Automatic calculation of remaining expiry days.
- Identification of expired products.
- Identification of products nearing expiry.
- Category-based storage temperature checking.
- Automatic priority generation.
- Suggested action generation.
- Exclusion of deleted products.

## 8. Testing Results

The SQL query was successfully executed in phpMyAdmin.

| Product | Days Left | Expiry Status | Storage | Priority | Action |
|---|---:|---|---|---|---|
| Tomato | -1 | EXPIRED | OK | HIGH | REMOVE |
| Carrot | 1 | NEAR EXPIRY | OK | MEDIUM | USE SOON |
| Apple | 2 | NEAR EXPIRY | OK | MEDIUM | USE SOON |

## 9. Testing Conclusion

- SQL query executed successfully.
- Three active products were verified.
- Expired and near-expiry products were correctly identified.
- Storage conditions were checked using category rules.
- Deleted products were excluded from verification.
- No existing database records were modified by the SELECT query.
- The results matched the expected expiry and storage conditions.

**Overall Status: SQL Testing Successful**
