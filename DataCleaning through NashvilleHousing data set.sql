
-- STANDARDIZE DATE FORMAT --
Select saleDateConverted, CONVERT(Date, SaleDate)
From [Portfolio project database]..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- POPULATE PROPERTY ADDRESS DATA --
Select Propertyaddress
From [Portfolio project database].. NashvilleHousing
Where PropertyAddress is null
-- We can see that there are a lot of NULL properties so we need to find a way around that through investigation.

Select *
From [Portfolio project database].. NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID
-- When looking at the PARCILID with respect to the property address you can see that the PARCELID pertains to an address and only changes for a different address.
-- Therefore, we will need to do a self join. We are doing this self join because then it will get rid of the duplicates that would appear as NULL.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio project database].. NashvilleHousing a
JOIN [Portfolio project database].. NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
-- The UniqueID does not repeat itself so we can use an AND statement to populate the PropertyAddress column cleanly.
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio project database].. NashvilleHousing a
JOIN [Portfolio project database].. NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Now if you run this code, there will be no NULL statements in PropertyAddresses

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) --
Select PropertyAddress
From [Portfolio project database].. NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address

From [Portfolio project database].. NashvilleHousing
-- The -1 is added because CHARINDEX  brings back a number when executed to display where the comma would initially be. The -1 allows you to execute the function 1 before the comma.
-- Below we want to start where the comma is instead.
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City

From [Portfolio project database].. NashvilleHousing
-- Since every Address has a different length we can use LEN to separate the Address from the City

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NvarChar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

Select*
From [Portfolio project database].. NashvilleHousing

Select Owneraddress
From [Portfolio project database].. NashvilleHousing
--Instead of using a SUBSTRING we will use PARSENAME

Select
PARSENAME(REPLACE(Owneraddress,',','.'), 3) as Address
, PARSENAME(REPLACE(Owneraddress,',','.'), 2) as City
, PARSENAME(REPLACE(Owneraddress,',','.'), 1) as State
From [Portfolio project database].. NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(Owneraddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NvarChar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(Owneraddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NvarChar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(Owneraddress,',','.'), 1)

-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" field --

Select Distinct(SoldasVacant), Count(SoldasVacant)
From [Portfolio project database].. NashvilleHousing
Group by SoldAsVacant
order by 2
 -- Used a distinct function in conjunction with count in order to identify the amount of Y's and N's in the table.

Select SoldasVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From [Portfolio project database]..NashvilleHousing

-- The line of code above creates a separate column which will then change any of the Y's and N's to YES or NO through a CASE statement.

Update NashvilleHousing
SET SoldasVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From [Portfolio project database]..NashvilleHousing

-- REMOVE DUPLICATES --

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From [Portfolio project database].. NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

-- Need to partition to what is unique to the row. With the a CTE we can create something like a temp table to highlight all the duplicates in the data piece.

-- DELETE UNUSED COLUMNS

Select*
From [Portfolio project database].. NashvilleHousing

ALTER TABLE [Portfolio project database].. NashvilleHousing
DROP COLUMN SaleDate


