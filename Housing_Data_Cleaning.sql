/*

Cleaning Data In SQL Queries

*/
select *
from roshandb.dbo.[Nashville Housing Data for Data Cleaning]

-------------------------------------------------------------------------------------------

--Populate Property Address Data
select *
from roshandb.dbo.[Nashville Housing Data for Data Cleaning]
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.Propertyaddress, b.PropertyAddress)
from roshandb.dbo.[Nashville Housing Data for Data Cleaning] a
join roshandb.dbo.[Nashville Housing Data for Data Cleaning] b
     on a.ParcelID = b.ParcelID
	 and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null 

update a
set PropertyAddress = ISNULL(a.Propertyaddress, b.PropertyAddress)
from roshandb.dbo.[Nashville Housing Data for Data Cleaning] a
join roshandb.dbo.[Nashville Housing Data for Data Cleaning] b
     on a.ParcelID = b.ParcelID
	 and a.UniqueID <> b.UniqueID
 where a.PropertyAddress is null 


 --------------------------------------------------------------------------------------------------------------------------------

 -- Breaking out Address into Individual Columns ( Address, City, State)

 select PropertyAddress
 from roshandb.dbo.[Nashville Housing Data for Data Cleaning]

 -- Splitting PropertyAddress using Substring
 select 
 substring(PropertyAddress, 1, Charindex(',',PropertyAddress)-1) as Address
,substring(PropertyAddress, Charindex(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
 from roshandb.dbo.[Nashville Housing Data for Data Cleaning]

 alter table roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 add PropertySplitAddress Nvarchar(255);

 update roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 set PropertySplitAddress = substring(PropertyAddress, 1, Charindex(',',PropertyAddress)-1)

 alter table roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 add PropertySplitCity Nvarchar(255);

 update roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 set PropertySplitCity = substring(PropertyAddress, Charindex(',',PropertyAddress)+1, LEN(PropertyAddress))



  ---Splitting Owner Address using Parsename
  select
  Parsename(replace(OwnerAddress,',','.'),3)
 ,Parsename(replace(OwnerAddress,',','.'),2)
 ,Parsename(replace(OwnerAddress,',','.'),1)
  from roshandb.dbo.[Nashville Housing Data for Data Cleaning]

  alter table roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 add OwnerSplitAddress Nvarchar(255);

 update roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 set OwnerSplitAddress=Parsename(replace(OwnerAddress,',','.'),3)

 alter table roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 add OwnerSplitCity Nvarchar(255);

 update roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 set OwnerSplitCity = Parsename(replace(OwnerAddress,',','.'),2)

  alter table roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 add OwnerSplitState Nvarchar(255);

 update roshandb.dbo.[Nashville Housing Data for Data Cleaning]
 set OwnerSplitState = Parsename(replace(OwnerAddress,',','.'),1)


--------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field


ALTER TABLE roshandb.dbo.[Nashville Housing Data for Data Cleaning]
ALTER COLUMN SoldAsVacant VARCHAR(3); -- Change the length accordingly based on your data

UPDATE roshandb.dbo.[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE 
                    WHEN SoldAsVacant = 1 THEN 'Yes'
                    WHEN SoldAsVacant = 0 THEN 'No'
                    ELSE SoldAsVacant -- Leave the original value if it's not 1 or 0
                  END
WHERE SoldAsVacant IN ('1', '0'); -- Filter out any rows with invalid values

select distinct(SoldAsVacant), count(SoldAsVacant)
from roshandb.dbo.[Nashville Housing Data for Data Cleaning]
group by SoldAsVacant
order by 2


-------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates using Row_num, CTE and partion by
WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER (
     Partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order by 
				      UniqueID
					  ) row_num

from roshandb.dbo.[Nashville Housing Data for Data Cleaning]
)
DELETE
from RowNumCTE
where row_num>1
--der by PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns



alter table roshandb.dbo.[Nashville Housing Data for Data Cleaning]
drop column OwnerAddress, PropertyAddress, TaxDistrict


Select *
from roshandb.dbo.[Nashville Housing Data for Data Cleaning]
