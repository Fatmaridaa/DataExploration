select *
from nashvillaHousing


-- Standardize Date Format


select SaleDate --, CONVERT(date,SaleDate)
from nashvillaHousing


ALTER TABLE nashvillaHousing
ALTER COLUMN SaleDate date;



-- Populate Property Address data



select a.ParcelID , a.PropertyAddress  , b.ParcelID , b.PropertyAddress , ISNULL ( a.PropertyAddress , b.PropertyAddress)
from nashvillaHousing a
join nashvillaHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL ( a.PropertyAddress , b.PropertyAddress)
from nashvillaHousing a
join nashvillaHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress , OwnerAddress
from nashvillaHousing



select SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress  , CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) as City

from nashvillaHousing


Alter table nashvillaHousing
add propertySplitAddress nvarchar(225);

update nashvillaHousing
set propertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) -1) 



Alter table nashvillaHousing
add propertySplitCity nvarchar(225);

update nashvillaHousing
set propertySplitCity =  SUBSTRING(PropertyAddress  , CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress))


select propertySplitAddress , propertySplitCity
from nashvillaHousing




-- another way to split

select OwnerAddress
from nashvillaHousing



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From nashvillaHousing




Alter table nashvillaHousing
add ownerSplitAddress nvarchar(225);

update nashvillaHousing
set ownerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


Alter table nashvillaHousing
add ownerSplitCity nvarchar(225);


update nashvillaHousing
set ownerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter table nashvillaHousing
add ownerSplitState nvarchar(225);


update nashvillaHousing
set ownerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


select ownerSplitAddress, ownerSplitAddress, ownerSplitState
from nashvillaHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant)
from nashvillaHousing



select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END
from nashvillaHousing



Update nashvillaHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END

select distinct(SoldAsVacant)
from nashvillaHousing


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From nashvillaHousing
--order by ParcelID
)


select * 
From RowNumCTE
Where row_num > 1






select *
from nashvillaHousing



-- Delete Unused Columns



select *
from nashvillaHousing



ALTER TABLE nashvillaHousing
DROP COLUMN OwnerAddress, PropertyAddress

