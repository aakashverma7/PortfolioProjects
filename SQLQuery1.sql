Select *
from PortfolioProject..CovidDeaths$
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Total Cases vs Total Deaths
-- Shows the probablity of you dying if you contract Covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Total Cases vs Population
-- Percentage of population that got covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Countries with highest infection rate compared to Population

Select location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
Group by location,population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
WHERE continent is not null
Group by location
order by TotalDeathCount desc



-- Categorise by continent
-- Continents with highest death count


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

-- This one is better :-
--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths$
--WHERE continent is null
--Group by location
--order by TotalDeathCount desc


-- Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where continent is not null
group by date
order by 1,2

--Total Population vs vaccinations

Select DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations, SUM(convert(int,VAC.new_vaccinations)) OVER(Partition by DEA.location order by 
dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.continent is not null
order by 2,3



--USE CTE

With POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations, SUM(convert(int,VAC.new_vaccinations)) OVER(Partition by DEA.location order by 
dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from Popvsvac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert INTO #PercentPopulationVaccinated

Select DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations, SUM(convert(int,VAC.new_vaccinations)) OVER(Partition by DEA.location order by 
dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations, SUM(convert(int,VAC.new_vaccinations)) OVER(Partition by DEA.location order by 
dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.continent is not null

Select * 
From PercentPopulationVaccinated