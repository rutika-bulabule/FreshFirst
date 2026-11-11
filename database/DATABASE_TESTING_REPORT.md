# FreshFirst - Database Testing Report

**Date:** 11 November 2026

## 1. Database Details
Database Name: fresh_first

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
| Total | 24 |

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
- No database records were modified or deleted during testing.

## 6. Conclusion
All six tables were checked. A total of 24 records were found. The identified integrity issues are documented for further review.
