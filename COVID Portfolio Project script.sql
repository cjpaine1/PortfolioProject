Select *
	From PortfolioProject..coviddeaths
	Order by 3, 4


--Select *
--	From PortfolioProject..covidvaccinations
--	Order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..coviddeaths
	Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..coviddeaths
	Where location like '%states%'
	Order by 1, 2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
	From PortfolioProject..coviddeaths
	Where location = 'United States'
	Order by 1, 2

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
	From PortfolioProject..coviddeaths
	Group by location, population
	Order by PercentPopulationInfected desc

-- Showing countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..coviddeaths
	Where continent is not null
	Group by location
	Order by TotalDeathCount desc

-- Breaking things down by continent

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..coviddeaths
	Where continent is null
	Group by location
	Order by TotalDeathCount desc

-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	From PortfolioProject..coviddeaths
	where continent is not null
	Group by date
	Order by 1, 2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
From popvsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
