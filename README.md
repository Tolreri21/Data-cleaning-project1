# Nashville Housing Data Cleaning Project

This SQL project focuses on cleaning a raw housing dataset from Nashville to make it more usable for analysis. The cleaning process involves handling date formatting, missing values, splitting columns, standardizing values, and removing duplicates. All operations are performed using MySQL.

## Dataset

The dataset includes housing-related information such as:
- Sale dates
- Property and owner addresses
- Property characteristics (value, year built, number of bedrooms/bathrooms, etc.)
- Ownership information

---

## Cleaning Tasks and Solutions

### 1. **Previewing the Data**
- Function used: `SELECT *`
- Purpose: Understand the structure and contents of the dataset.

### 2. **Date Formatting**
- Function used: `STR_TO_DATE()`
- Problem solved: Converted inconsistent text-based date formats (e.g., "April 15, 2021") into standardized SQL `DATE` format.

### 3. **Handling Empty Strings**
- Function used: `NULLIF()`
- Problem solved: Replaced empty strings (`''`) in several columns with `NULL` to make missing values easier to handle.

### 4. **Filling Missing Property Addresses**
- Functions used: `JOIN`, `COALESCE()`, `UPDATE`
- Problem solved: Filled missing `propertyaddress` values by finding other rows with the same `ParcelID` and copying the address from those.

### 5. **Splitting Property Address**
- Functions used: `SUBSTRING()`, `LOCATE()`, `ALTER TABLE`, `UPDATE`
- Problem solved: Split the `propertyaddress` into two separate columns: `Address` and `City`.

### 6. **Splitting Owner Address**
- Functions used: `SUBSTRING_INDEX()`, `ALTER TABLE`, `UPDATE`
- Problem solved: Broke the `owneraddress` into three new columns: `owner_address`, `owner_city`, and `owner_state`.

### 7. **Standardizing Categorical Values**
- Function used: `CASE`
- Problem solved: Standardized values in the `SoldAsVacant` column (e.g., changed `'Y'` and `'N'` to `'Yes'` and `'No'`).

### 8. **Removing Duplicates**
- Functions used: `ROW_NUMBER()`, `CTE (Common Table Expression)`, `DELETE`
- Problem solved: Removed duplicate rows by keeping only the first occurrence based on `ParcelID`, `SaleDate`, and `LegalReference`.

### 9. **Dropping Unnecessary Columns**
- Function used: `ALTER TABLE ... DROP COLUMN`
- Problem solved: Removed columns like `propertyaddress`, `owneraddress`, and `TaxDistrict` that were no longer needed after splitting and standardizing data.

---

## Final Output

The final dataset is:
- Cleaned and standardized
- Structured into more meaningful columns
- Free of duplicates and empty values
- Ready for analysis or export to a BI tool like Power BI or Tableau

---

## Tools Used
- **MySQL** for writing and executing SQL queries
- SQL functions: `SELECT`, `UPDATE`, `ALTER TABLE`, `JOIN`, `ROW_NUMBER()`, `CASE`, `COALESCE`, `NULLIF`, `SUBSTRING`, `SUBSTRING_INDEX`, `STR_TO_DATE`, `DELETE`, `CTE`

---

## Author
This project was created by Anatolii Perederii, as part of my portfolio development and SQL practice.

