--------------------------------------------------------------------------------------------------------------------------------------------------------------
/*Data cleaning using SQL*/
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Standardize date format

Select SalesDateConverted,convert(Date,SaleDate) from DataPortfolioProject..NashvileHousing

Update NashvileHousing 
set SaleDate=convert(Date,SaleDate)

Alter table NashvileHousing Add SalesDateConverted date;

Update NashvileHousing 
set SalesDateConverted=convert(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property address data

Select * from DataPortfolioProject..NashvileHousing
where PropertyAddress is null

select Nasha.ParcelID,Nasha.PropertyAddress,Nashb.ParcelID,Nashb.PropertyAddress ,ISNULL(Nasha.PropertyAddress,Nashb.PropertyAddress)
from DataPortfolioProject..NashvileHousing Nasha
Join DataPortfolioProject..NashvileHousing Nashb
on Nasha.ParcelID=Nashb.ParcelID 
and Nasha.[UniqueID ]<>Nashb.[UniqueID ]
where Nasha.PropertyAddress is null

Update Nasha
set PropertyAddress=ISNULL(Nasha.PropertyAddress,Nashb.PropertyAddress)
from DataPortfolioProject..NashvileHousing Nasha
Join DataPortfolioProject..NashvileHousing Nashb
on Nasha.ParcelID=Nashb.ParcelID 
and Nasha.[UniqueID ]<>Nashb.[UniqueID ]
where Nasha.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns(Address,City,State)

Select PropertyAddress from DataPortfolioProject..NashvileHousing

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
from DataPortfolioProject..NashvileHousing

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from DataPortfolioProject..NashvileHousing


Alter table NashvileHousing Add PropertSplitAddress nvarchar(255);

Update NashvileHousing 
set PropertSplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table NashvileHousing Add PropertySplitCity nvarchar(255);

Update NashvileHousing 
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select PropertSplitAddress as Address,PropertySplitCity as City
from DataPortfolioProject..NashvileHousing

select PARSENAME(Replace(OwnerAddress,',','.'),3) AS Address,
PARSENAME(Replace(OwnerAddress,',','.'),2) AS City,
PARSENAME(Replace(OwnerAddress,',','.'),1) AS State
from DataPortfolioProject..NashvileHousing


Alter table NashvileHousing Add OwnerSplitAddress nvarchar(255);

Update NashvileHousing 
set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)


Alter table NashvileHousing Add OwnerSplitCity nvarchar(255);

Update NashvileHousing 
set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table NashvileHousing Add OwnerSplitState nvarchar(255);

Update NashvileHousing 
set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

select OwnerSplitAddress AS Address,
OwnerSplitCity AS City,
OwnerSplitState AS State
from DataPortfolioProject..NashvileHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Yand N to Yes and No in Sold as Vacant 

select distinct(SoldAsVacant) ,count(SoldAsVacant)
from DataPortfolioProject..NashvileHousing
group by SoldAsVacant
order by 1


Select SoldAsVacant,
Case when SoldAsVacant='Y' Then 'Yes'
	When SoldAsVacant='N' Then 'No'
	Else SoldAsVacant
	End
from DataPortfolioProject..NashvileHousing

Update DataPortfolioProject..NashvileHousing
Set SoldAsVacant=Case when SoldAsVacant='Y' Then 'Yes'
	When SoldAsVacant='N' Then 'No'
	Else SoldAsVacant
	End

-------------------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates
with RownumCTE 
AS
(
Select *, 
Row_Number()Over (partition by
ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID)row_num
from DataPortfolioProject..NashvileHousing
--order by ParcelId
)
select * from RownumCTE
where row_num>1
--order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete unused columns

Select * from DataPortfolioProject..NashvileHousing

Alter Table DataPortfolioProject..NashvileHousing
Drop Column PropertyAddress,OwnerAddress,TaxDistrict

Alter Table DataPortfolioProject..NashvileHousing
Drop Column SaleDate