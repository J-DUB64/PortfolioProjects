
-- Datasets are from the https://ourworlddata.org/covid-deaths
-- Data to ensure it loaded correctly
select *
from CovidDeaths
where continent is not null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract COVID
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of the population got COVID
Select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as PercentagePopulationInfected 
From CovidDeaths
-- Where location like '%states%'
where continent is not null
order by 1,2

-- What countries have the highest infection rates compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as PercentagePopulationInfected 
From CovidDeaths
where continent is not null
-- Where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc


-- Showing the Countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeath
From CovidDeaths
where continent is not null
-- Where location like '%states%'
group by location
order by TotalDeath desc

-- Breaking things down by continent
-- Showing the Countinents with highest death count per population
Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
-- Where location like '%states%'
group by continent
order by TotalDeathCount desc

-- Global Numbers
Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
-- Where location like '%states%'
group by date
order by 1,2 desc

-- total death percentage
Select SUM(New_Cases), SUM(cast(New_Deaths as int)), SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
-- Where location like '%states%'
-- group by date
order by 1,2 desc

-- Looking at Total Population vs Vaccination
-- Right Join Covid Vaccinations to Covide Deaths
Select *
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) Over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
With PopvsVac (Continent, Location,Date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinatedtotal
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population) *100
from PopvsVac

-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population) *100
from #PercentPopulationVaccinated

-- Creating View to store for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *
from PercentPopulationVaccinated