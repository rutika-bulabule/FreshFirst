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

## 4. Database Integrity Validation

**Date:** 13 November 2026

The following database integrity checks were performed:

1. Checked invalid user references in products, verification, history and actions.
2. Checked invalid product and verification references.
3. Checked negative and zero product quantities.
4. Checked expiry dates before purchase dates.
5. Checked duplicate active product names.
6. Checked unmatched product categories.
7. Checked invalid user roles and account status values.
8. Checked missing product names and storage conditions.
9. Checked duplicate usernames and category rules.
10. Checked action status and history event records.

### 5. Validation Findings

- Most integrity checks returned no matching invalid records.
- One orphan product record was identified: Test Product (product_id: 5), with created_by = 999.
- No records were deleted or modified during testing.
- All validation queries were read-only SELECT queries.

### 6. Database Summary

- Total tables: 6
- Total records: 24
- Active products: 3
- Deleted products: 2
- Total active product quantity: 60

**Conclusion:** Database integrity testing was performed successfully. One orphan user reference was identified and documented for future correction.
