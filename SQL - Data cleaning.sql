--Cleaning data in SQL

Select * 
from PortfolioProject..NashvilleHousing	

-------------------------------------------------------------------------------------\
--Changing the sale date 

Select SaleDate
from PortfolioProject..NashvilleHousing	


ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE


-------------------------------------------------------------------------------------\
--Populate property address data

Select *
from PortfolioProject..NashvilleHousing	
WHERE PropertyAddress is NULL


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing	a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing	a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL


-------------------------------------------------------------------------------------
--Breaking out address into individual columns (address, city, state)

Select PropertyAddress
from PortfolioProject..NashvilleHousing	

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing	


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
from PortfolioProject..NashvilleHousing	







SELECT OwnerAddress
from PortfolioProject..NashvilleHousing	

Select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing	


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

SELECT *
from PortfolioProject..NashvilleHousing	


-------------------------------------------------------------------------------------
--Change Y and N to Yes and No in the "Sold as vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing	
Group by SoldAsVacant


SELECT SoldAsVacant
,CASE When SoldAsVacant='Y' THEN 'Yes'
	  When SoldAsVacant='N' THEN 'No'
	  Else SoldAsVacant
	  END
from PortfolioProject..NashvilleHousing	

Update NashvilleHousing
Set SoldAsVacant= CASE When SoldAsVacant='Y' THEN 'Yes'
	  When SoldAsVacant='N' THEN 'No'
	  Else SoldAsVacant
	  END





-------------------------------------------------------------------------------------
--Remove duplicates

With RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					ParcelID
					) row_number
from PortfolioProject..NashvilleHousing	
)

Select *
FROM RowNumCTE
Where row_number>1




SELECT *
from PortfolioProject..NashvilleHousing	


-------------------------------------------------------------------------------------
--Remove unused columns


SELECT *
from PortfolioProject..NashvilleHousing	

ALTER Table PortfolioProject..NashvilleHousing	
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
