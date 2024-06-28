select * from CovidDeaths where continent is not null order by 3,4
select * from CovidVaccinations order by 3,4

---Selecting the data that we are goiong to use

Select Location,date,total_cases,new_cases,total_deaths,population 
from DataPortfolioProject..CovidDeaths order by 1,2

--Looking at Total cases VS Total Deaths
--Show likelihood of dying if you cantracted covid in your country

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from DataPortfolioProject..CovidDeaths where Location like '%india%' and continent is not null order by 1,2

--Looking at Total cases Vs Population
--Show what percentage of population got covid

Select Location,date,population,total_cases,(total_cases/population)*100 as PopulationPercentage
from DataPortfolioProject..CovidDeaths where continent is not null
--where Location like '%india% 
order by 1,2

--Looking at countries with highest infection rate compared with population

Select Location,population,Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
from DataPortfolioProject..CovidDeaths where continent is not null
--where Location like '%india%' 
group by Location,population
order by PercentPopulationInfected desc

--Looking at countries with highest death rate 
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from DataPortfolioProject..CovidDeaths 
--where Location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc

--BREAKING THINGS BY CONTINENT
--Showing Continents with highest death counts per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from DataPortfolioProject..CovidDeaths 
--where Location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date,sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as TotalNewDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage--,(total_deaths/total_cases)*100 as DeathPercentage
from DataPortfolioProject..CovidDeaths 
--where Location like '%india%'
where continent is not null 
group by date
order by 1,2

--Join Two Tables
--Looking at total population vs vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from DataPortfolioProject..CovidDeaths as dea join 
DataPortfolioProject..CovidVaccinations as vac on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--Using CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from DataPortfolioProject..CovidDeaths as dea join 
DataPortfolioProject..CovidVaccinations as vac on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100 as Popvsvac
from PopvsVac

--Temp table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from DataPortfolioProject..CovidDeaths as dea join 
DataPortfolioProject..CovidVaccinations as vac on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3 

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from DataPortfolioProject..CovidDeaths as dea join 
DataPortfolioProject..CovidVaccinations as vac on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

select * from PercentPopulationVaccinated