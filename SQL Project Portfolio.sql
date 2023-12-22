Select*
From PortfolioProject..CovidDeath
Order by 3,4

Select*
From PortfolioProject..CovidVaccinations
Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
Order by 1,2

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths,
    COALESCE(TRY_CAST(total_deaths AS float) * 100.0 / NULLIF(TRY_CAST(total_cases AS float), 0), 0) AS DeathPercentage
FROM PortfolioProject..CovidDeath
ORDER BY 1, 2;

SELECT Location, date, total_cases, total_deaths,
    COALESCE(TRY_CAST(total_deaths as FLOAT)*100 /  Nullif(Try_cast(total_cases as FLOAT),0),0) as DeathPercentage
From PortfolioProject..CovidDeath
Where location Like '%Pakistan%'
Order by 1,2 

--Total cases vs Population
SELECT Location, date,population, total_cases,
    COALESCE(Try_cast(total_cases as FLOAT)/ (population),0)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location Like '%Pakistan%'
Order by 1,2 

--Countries with highest infection rate compare to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases )/(Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
Where continent is not null
Group by Location, Population
Order by PercentPopulationInfected desc

--Countries with highest death count

Select Location, Max(cast(total_deaths as int)) as TotaltDeathCount
From PortfolioProject..CovidDeath
Where continent is not null
Group by location 
Order by TotaltDeathCount desc


--Continents with Highest Deat Count

Select Continent,Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numnbers

SELECT date, SUM(CAST(new_cases AS INT)) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeath, SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(CAST(new_cases AS INT)), 0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(CAST(new_cases AS INT)) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeath, SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(CAST(new_cases AS INT)), 0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Joining tables
SELECT*
FROM PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is not null 
Order by 2,3


--Partition  by
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
Sum(Convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,dea.date) as Total_vaccinations
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Using CTE 
With PopvsVac(continent, location, date, population,new_vaccinations, Total_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(float,vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location, dea.date) as Total_Vaccinations
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select* ,(Total_Vaccinations/population)*100 as PercentagePerCountry
From PopvsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date DATETIME,
Population numeric,
new_vaccinaions numeric,
Total_vaccinations numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS float)) Over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinations
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select* ,(Total_Vaccinations/population)*100 as PercentagePerCountry
From #PercentPopulationVaccinated

-- Creating view to store data

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS float)) Over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinations
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select*
From PercentPopulationVaccinated
