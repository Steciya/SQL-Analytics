---------------------------------------------------------------------------------------------------------------------------------------------------
/* Data cleaning using SQL*/
---------------------------------------------------------------------------------------------------------------------------------------------------

Select * from DataPortfolioProject..NashvileHousing

---------------------------------------------------------------------------------------------------------------------------------------------------

/*Standardize date format*/

Select SaleDateConverted,Convert(Date,SaleDate) from NashvileHousing

update NashvileHousing
set SaleDate=Convert(Date,SaleDate)

Alter Table NashvileHousing
Add SaleDateConverted Date;

update NashvileHousing
set SaleDateConverted=Convert(Date,SaleDate)
