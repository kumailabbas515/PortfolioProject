-- DATA CLEANING

Select*
FROM PortfolioProject..NashvileHousing

-- STANDARDIZE DATE FORMATE

Select SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvileHousing

Update NashvileHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- If it doesn't Update properly

Alter Table NashvileHousing
Add SaleDateConverted Date;

Update NashvileHousing
SET SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted
From NashvileHousing

--Populate Property Address Data

SELECT*
From PortfolioProject.dbo.NashvileHousing
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvileHousing a
JOIN PortfolioProject..NashvileHousing b 
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvileHousing a
JOIN PortfolioProject..NashvileHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


--BREAKINGOUT ADDRESS INTO INDIVIDUAL COLUMNS

Select PropertyAddress
From PortfolioProject..NashvileHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvileHousing

Alter Table NashvileHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, charindex(',', PropertyAddress)-1)

Alter Table NashvileHousing
Add PropertySplitCity Nvarchar(255);

Update NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress))

Select*
From PortfolioProject..NashvileHousing


Select OwnerAddress
From PortfolioProject..NashvileHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvileHousing 


Alter Table NashvileHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvileHousing
ADD OwnerSplitCity NVARCHAR(255);


Update NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


Alter Table NashvileHousing
Add OwnerSplitState nvarchar(255);

Update NashvileHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


Select*
From PortfolioProject..NashvileHousing


--Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(SoldasVacant)
From PortfolioProject..NashvileHousing

Select SoldasVacant
, Case When SoldasVacant = 'Y' THEN 'YES'
       when SoldAsVacant= 'N' THEN 'NO'
	   Else SoldasVacant
	   End
From PortfolioProject..NashvileHousing

Update NashvileHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'YES'
                        when SoldAsVacant = 'N' THEN 'NO'
						Else SoldAsVacant
						End
From PortfolioProject..NashvileHousing 

-- REMOVING DUPLICATES

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

From PortfolioProject.dbo.NashvileHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

DELETE
From RowNumCTE
Where row_num > 1


-- DELETING UNUSED COLUMNS

 Select*
 From PortfolioProject..NashvileHousing

 Alter Table NashvileHousing
 Drop Column PropertyAddress, OwnerAddress, TaxDistrict

  Alter Table NashvileHousing
 Drop Column SaleDate

