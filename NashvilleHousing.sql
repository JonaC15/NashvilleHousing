--Cleaning Data in SQL Queries

select *
from NashvilleHousing.dbo.NashvilleHousing

--Standardize Date Format
select SaleDate, convert(date, SaleDate)
from NashvilleHousing.dbo.NashvilleHousing

update NashvilleHousing.dbo.NashvilleHousing
set SaleDate = Convert(Date, SaleDate)

--Populate Property Address Data
select *
from NashvilleHousing.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing.dbo.NashvilleHousing a
JOIN NashvilleHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[uniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing.dbo.NashvilleHousing a
JOIN NashvilleHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[uniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--Breaking out Address into Individual Columns(Address, City, State)
select PropertyAddress
from NashvilleHousing.dbo.NashvilleHousing

--SUBSTRING will look for a comma starting at character 1. Once comma is found it will go back on character(hence '-1')
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From NashvilleHousing.dbo.NashvilleHousing

Alter Table NashvilleHousing.dbo.NashvilleHousing
add PropertySplitaddress Nvarchar(255)

Update NashvilleHousing.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(PropertyAddress))

--Break Owner address into seperate columns with an different/easier method than what was done for property address
Select
Parsename(Replace(OwnerAddress,',', '.'), 3)
, Parsename(Replace(OwnerAddress,',', '.'), 2)
, Parsename(Replace(OwnerAddress,',', '.'), 1)
from NashvilleHousing.dbo.nashvillehousing

Alter table NashvilleHousing.dbo.nashvillehousing
Add ownerSplitAddress Nvarchar(255);

update NashvilleHousing.dbo.nashvillehousing
set OwnersplitAddress = Parsename(Replace(OwnerAddress,',', '.'), 3)

Alter table NashvilleHousing.dbo.nashvillehousing
Add ownerSplitCity Nvarchar(255);

update NashvilleHousing.dbo.nashvillehousing
set OwnersplitCity = Parsename(Replace(OwnerAddress,',', '.'), 2)

Alter table NashvilleHousing.dbo.nashvillehousing
Add ownerSplitState Nvarchar(255);

update NashvilleHousing.dbo.nashvillehousing
set OwnersplitState = Parsename(Replace(OwnerAddress,',', '.'), 1)

-- Remove Duplicates
With RowNumCTE as(
Select *,
	row_number()Over (
	Partition by parcelID,
				 propertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				 UniqueID
				 ) row_num

from NashvilleHousing.dbo.NashvilleHousing
--order by ParcelID
Delete
from RowNumCTE
where row_num > 1

--Delete Unused columns
alter table NashvilleHousing.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress
