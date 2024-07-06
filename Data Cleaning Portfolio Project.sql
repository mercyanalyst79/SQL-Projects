/*
Cleaning Data in SQL Queries
*/


Select *
FROM [Portfolio project].[dbo].[NashvilleHousing]


-----------------------------------------------------------------------------------------------------------------------------------------------
--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate) 
FROM [Portfolio project].[dbo].[NashvilleHousing]

Update [Portfolio project].[dbo].[NashvilleHousing]
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [Portfolio project].[dbo].[NashvilleHousing]
Add SaleDateConverted Date;

Update [Portfolio project].[dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Adress data

Select *
FROM [Portfolio project].[dbo].[NashvilleHousing]
--WHERE PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio project].[dbo].[NashvilleHousing] a
JOIN [Portfolio project].[dbo].[NashvilleHousing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio project].[dbo].[NashvilleHousing] a
JOIN [Portfolio project].[dbo].[NashvilleHousing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------

--Break out the Address into individual columns (Address, City, State)

Select PropertyAddress
FROM [Portfolio project].[dbo].[NashvilleHousing]
--WHERE PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM [Portfolio project].[dbo].[NashvilleHousing]


ALTER TABLE [Portfolio project].[dbo].[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update [Portfolio project].[dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [Portfolio project].[dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select *
FROM [Portfolio project].[dbo].[NashvilleHousing]

Select OwnerAddress
FROM [Portfolio project].[dbo].[NashvilleHousing]

select 
PARSENAME(REPLACE(OwnerAddress,',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)
FROM [Portfolio project].[dbo].[NashvilleHousing]

ALTER TABLE [Portfolio project].[dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio project].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') , 3)

ALTER TABLE [Portfolio project].[dbo].[NashvilleHousing]
Add  OwnerSplitCity Nvarchar(255);

Update [Portfolio project].[dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') , 2)

ALTER TABLE [Portfolio project].[dbo].[NashvilleHousing]
Add OwnerSplitStates Nvarchar(255);

Update [Portfolio project].[dbo].[NashvilleHousing]
SET OwnerSplitStates = PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)

Select *
FROM [Portfolio project].[dbo].[NashvilleHousing]

------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold As Vacant' field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio project].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Portfolio project].[dbo].[NashvilleHousing]

Update [Portfolio project].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

----------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID
			 ) row_num
FROM [Portfolio project].[dbo].[NashvilleHousing]
--order by ParcelID 
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

Select *
FROM [Portfolio project].[dbo].[NashvilleHousing]

ALTER TABLE [Portfolio project].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate