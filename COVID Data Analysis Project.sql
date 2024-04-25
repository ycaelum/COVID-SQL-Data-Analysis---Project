

Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

-- select data to be used

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths$ 
Where continent is not null
order by 1,2


-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathPercentage
From PortfolioProject..CovidDeaths$ 
Where location like 'Philippines'
and continent is not null 
order by 1,2


--looking at the total cases vs population

Select location, date, total_cases,population, (population-total_cases) as covidFree
From PortfolioProject..CovidDeaths$ 
where location like 'Philippines'
and continent is not null
order by 1,2

--percentage of population with covid

Select location, date, total_cases,population, (total_cases/population)*100 as covidPercentage
From PortfolioProject..CovidDeaths$ 
--where location like 'Philippines'
order by 1,2


--looking at countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
as PercentPopulationInfected
From PortfolioProject..CovidDeaths$ 
--where location like 'Philippines'
Group by location, population
order by PercentPopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$ 
--where location like 'Philippines'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths$ 
----where location like 'Philippines'
--Where continent is null
--Group by location
--order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$ 
--where location like 'Philippines'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing continents with highest death counts per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$ 
--where location like 'Philippines'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

--Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
--From PortfolioProject..CovidDeaths$ 
----Where location like 'Philippines'
--where continent is not null
--Group by date
--order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
From PortfolioProject..CovidDeaths$ 
--Where location like 'Philippines'
where continent is not null
--Group by date
order by 1,2


-- Looking at total population vs vaccinations

Select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

-- looking at total cases vs vaccinations 

Select dea.continent, dea.location, dea.date, dea.total_cases, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 percentage 
From PopvsVac


--TEMP table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 percentage 
FROM #PercentPopulationVaccinated


-- Creating view to store data later for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

