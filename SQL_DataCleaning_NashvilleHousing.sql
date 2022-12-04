/*

Cleaning Data in SQL Queries

*/

select *
from portfolioproject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select saledateconverted, CONVERT(date,saledate)
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(date, saledate)

alter table nashvillehousing --creating new column
add saledateconverted date;

Update NashvilleHousing --populating the new column with newly standardized date
set saledateconverted = CONVERT(date, saledate)


-------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is Null
order by ParcelID

select l.ParcelID, l.PropertyAddress, r.ParcelID, r.PropertyAddress, isnull(l.propertyaddress, r.PropertyAddress)
-- if left is null populate it with what is on the right
from PortfolioProject..NashvilleHousing l  -- creating a self join so I could check for matching parcel id's and property Addresses
join PortfolioProject..NashvilleHousing r  -- l for left and r for right :)
	on l.ParcelID = r.ParcelID
	and l.[UniqueID ] <> r.[UniqueID ]
where l.PropertyAddress is null



Update r
set PropertyAddress = isnull(l.propertyaddress, r.PropertyAddress)
from PortfolioProject..NashvilleHousing l  
join PortfolioProject..NashvilleHousing r  
	on l.ParcelID = r.ParcelID
	and l.[UniqueID ] <> r.[UniqueID ]

	------------------------------------------------------------------------------------------------------------------------------

	-- Breaking out Address into individual columns (address, city, state)
select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is Null

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table portfolioproject..NashvilleHousing --creating new column
add PropertySplitAddress Nvarchar(255);

Update portfolioproject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table portfolioproject..NashvilleHousing --creating new column
add PropertySplitCity Nvarchar(255);

Update portfolioproject..NashvilleHousing --populating the new column with newly standardized date
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



select *--Uniqueid, ParcelID, OwnerAddress
from PortfolioProject..NashvilleHousing
--where OwnerAddress is not null
--order by ParcelID desc


select OwnerAddress
from PortfolioProject..NashvilleHousing


-- parse name only looks out for '.'
select
parsename(replace(OwnerAddress,',','.'),3)
,parsename(replace(OwnerAddress,',','.'),2)
,parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing



alter table portfolioproject..NashvilleHousing --creating new column
add OwnerSplitAddress Nvarchar(255);

Update portfolioproject..NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table portfolioproject..NashvilleHousing --creating new column
add OwnerSplitCity Nvarchar(255);

Update portfolioproject..NashvilleHousing --populating the new column with newly standardized date
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table portfolioproject..NashvilleHousing --creating new column
add OwnerSplitState Nvarchar(255);

Update portfolioproject..NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)

select *--Uniqueid, ParcelID, OwnerAddress
from PortfolioProject..NashvilleHousing


------ Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

alter table portfolioproject..NashvilleHousing --creating new column
add soldasvacant1 Nvarchar(255);

drop table if exists nashvillehousing.soldasvacant1;

Update portfolioproject..NashvilleHousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else SoldAsVacant
	 end


-----------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

with rownumcte as(
select *,
	ROW_NUMBER() over (
	partition by parcelid, 
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by
					uniqueid
					) row_num

from portfolioproject..nashvillehousing
--order by ParcelID
)
/*delete
from rownumcte
where row_num > 1
*/

select*
from rownumcte
where row_num > 1
order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

alter table portfolioproject..nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress

alter table portfolioproject..nashvillehousing
drop column saledate
