-- Preview the data
SELECT * FROM nashvilledata;

-- Format the saledate column using STR_TO_DATE
SELECT ï»¿UniqueID, saledate, STR_TO_DATE(saledate, '%M %e, %Y') AS parsed_date
FROM nashvilledata;

-- Update the saledate column with standardized date format
UPDATE nashvilledata
SET saledate = STR_TO_DATE(saledate, '%M %e, %Y');

-- Replace empty strings with NULLs for various columns
UPDATE nashvilledata
SET 
	propertyaddress = NULLIF(propertyaddress, ''),
	OwnerName = NULLIF(OwnerName, ''),
	OwnerAddress = NULLIF(OwnerAddress, ''),
	Acreage = NULLIF(Acreage, ''),
	TaxDistrict = NULLIF(TaxDistrict, ''),
	LandValue = NULLIF(LandValue, ''),
	BuildingValue = NULLIF(BuildingValue, ''),
	TotalValue = NULLIF(TotalValue, ''),
	YearBuilt = NULLIF(YearBuilt, ''),
	Bedrooms = NULLIF(Bedrooms, ''),
	FullBath = NULLIF(FullBath, ''),
	HalfBath = NULLIF(HalfBath, '');

-- Identify NULL property addresses by comparing rows with same ParcelID
SELECT 
	a.ParcelID, 
	a.propertyaddress AS address_a,  
	b.propertyaddress AS address_b,
	COALESCE(a.propertyaddress, b.propertyaddress) AS filled_address
FROM nashvilledata a 
JOIN nashvilledata b
	ON a.ParcelID = b.ParcelID 
	AND a.ï»¿UniqueID != b.ï»¿UniqueID
WHERE a.PropertyAddress IS NULL;

-- Fill missing propertyaddress values using matching ParcelID data
UPDATE nashvilledata a
JOIN nashvilledata b 
	ON a.ParcelID = b.ParcelID 
	AND a.ï»¿UniqueID != b.ï»¿UniqueID
SET a.propertyaddress = b.propertyaddress
WHERE a.propertyaddress IS NULL OR a.propertyaddress = '';

-- Split propertyaddress into Address and City columns
SELECT 
	SUBSTRING(propertyaddress, 1, LOCATE(',', propertyaddress) - 1) AS Address, 
	SUBSTRING(propertyaddress, LOCATE(',', propertyaddress) + 1) AS City
FROM nashvilledata;

-- Add Address and City columns
ALTER TABLE nashvilledata
ADD COLUMN Address VARCHAR(255) AFTER propertyaddress,
ADD COLUMN City VARCHAR(255) AFTER Address;

-- Populate the Address and City columns
UPDATE nashvilledata
SET 
	Address = SUBSTRING(propertyaddress, 1, LOCATE(',', propertyaddress) - 1),
	City = SUBSTRING(propertyaddress, LOCATE(',', propertyaddress) + 1);

-- (Optional) Drop propertyaddress if no longer needed
-- ALTER TABLE nashvilledata DROP COLUMN propertyaddress;

-- Split OwnerAddress into Address, City, and State
SELECT 
	owneraddress, 
	SUBSTRING_INDEX(owneraddress, ',', 1) AS owner_address,
	SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) AS owner_city,
	SUBSTRING_INDEX(owneraddress, ',', -1) AS owner_state 
FROM nashvilledata;

-- Add columns to store split parts of owneraddress
ALTER TABLE nashvilledata
ADD COLUMN owner_address VARCHAR(255) AFTER owneraddress,
ADD COLUMN owner_city VARCHAR(255) AFTER owner_address,
ADD COLUMN owner_state VARCHAR(255) AFTER owner_city;

-- Populate the new owner address columns
UPDATE nashvilledata
SET 
	owner_address = SUBSTRING_INDEX(owneraddress, ',', 1),
	owner_city = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1),
	owner_state = SUBSTRING_INDEX(owneraddress, ',', -1);

-- Standardize 'SoldAsVacant' column values from 'Y/N' to 'Yes/No'
SELECT DISTINCT SoldAsVacant 
FROM nashvilledata;

-- Check distribution of values in SoldAsVacant
SELECT 
	SoldAsVacant,
	COUNT(*) 
FROM nashvilledata
GROUP BY SoldAsVacant;

-- Prepare transformation logic
SELECT 
	SoldAsVacant, 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant 
	END AS standardized
FROM nashvilledata;

-- Update SoldAsVacant with standardized values
UPDATE nashvilledata
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant 
END;

-- Remove duplicate rows based on ParcelID, SaleDate, and LegalReference
WITH cte AS (
	SELECT 
		*, 
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID, SaleDate, LegalReference 
			ORDER BY ï»¿UniqueID
		) AS rn
	FROM nashvilledata
)
DELETE FROM nashvilledata
WHERE ï»¿UniqueID IN (
	SELECT ï»¿UniqueID 
	FROM cte
	WHERE rn > 1
);

-- Drop unnecessary columns
ALTER TABLE nashvilledata 
DROP COLUMN propertyaddress, 
DROP COLUMN owneraddress, 
DROP COLUMN TaxDistrict;

-- Final data check
-- SELECT * FROM nashvilledata;
