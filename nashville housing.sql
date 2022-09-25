/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProjects].[dbo].[NashvilleHousing]


select * from PortfolioProjects..NashvilleHousing

-- standardize date format

select SaleDate, convert(date,SaleDate)
from PortfolioProjects..NashvilleHousing

Update PortfolioProjects..NashvilleHousing
set SaleDate = convert(date,SaleDate)

Alter table PortfolioProjects..NashvilleHousing
Add SaleDateUpdated date

Update PortfolioProjects..NashvilleHousing
set SaleDateUpdated = convert(date,SaleDate)

select SaleDate, convert(date,SaleDate)
from PortfolioProjects..NashvilleHousing

----------------------------------------------------------------
-- populate property address data
select *
from PortfolioProjects..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, a.[UniqueID ],b.[UniqueID ], isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------
--breaking out Address into individual columns

select PropertyAddress
from PortfolioProjects..NashvilleHousing
--where PropertyAddress is null
 
 select substring (PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address,
 substring (PropertyAddress, charindex(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProjects..NashvilleHousing

Alter table PortfolioProjects..NashvilleHousing
Add Address nvarchar(255)

Update PortfolioProjects..NashvilleHousing
set Address = substring (PropertyAddress, 1, charindex(',',PropertyAddress)-1)

Alter table PortfolioProjects..NashvilleHousing
Add City nvarchar(255)

Update PortfolioProjects..NashvilleHousing
set City = substring (PropertyAddress, charindex(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT * from PortfolioProjects..NashvilleHousing

--Owner Address Split

SELECT OwnerAddress from PortfolioProjects..NashvilleHousing

SELect PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProjects..NashvilleHousing

Alter table PortfolioProjects..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update PortfolioProjects..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--Change Y to Yes and N to No

SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
from PortfolioProjects..NashvilleHousing
GROUP by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
from PortfolioProjects..NashvilleHousing

Update PortfolioProjects..NashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END


----------------------------------------------------------------------------------
--Removing duplicates
WITH ROMnumCTE AS
(
select *,  ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by UniqueID
		) row_num

from PortfolioProjects..NashvilleHousing
)
DELETE From ROMnumCTE
where row_num > 1


-------------------------------------
--delete unused coloumns

SELECT *
from PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMn PropertyAddress

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMn SaleDate