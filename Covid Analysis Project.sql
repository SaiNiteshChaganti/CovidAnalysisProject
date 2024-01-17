Select *
From CovidAnalysis.dbo.CovidDeaths
where continent is NOT NULL
order by 3,4

--Select *
--From CovidAnalysis.dbo.CovidVaccinations
--order by 3,4

-- Select the columns required for queries
Select location, date, total_cases, new_cases, total_deaths, population
From CovidAnalysis.dbo.CovidDeaths
where continent is NOT NULL
order by 1,2

-- Percentage of deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidAnalysis.dbo.CovidDeaths
where continent is NOT NULL
order by 1,2

-- Likelihood of dying in Australia if you contracted the disease
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidAnalysis.dbo.CovidDeaths
Where location like '%Australia%'
order by 1,2

-- Percentage of population that got covid
Select location, date, population, total_cases, (total_cases/population)*100 as TotalPercentage
From CovidAnalysis.dbo.CovidDeaths
Where location like '%Australia%'
order by 1,2

-- Looking at countries with highest infection rate
Select location, population, MAX(total_cases) as MaximumInfected, MAX((total_cases/population))*100 as TotalPercentage
From CovidAnalysis.dbo.CovidDeaths
where continent is NOT NULL
group by location, population
order by 4 DESC


-- Looking at countries with highest deaths
Select location, MAX(cast(total_deaths as int)) as MaximumDeaths
From CovidAnalysis.dbo.CovidDeaths
where continent is NOT NULL
group by location
order by MaximumDeaths DESC

-- Looking at continents with highest deaths
Select location, MAX(cast(total_deaths as int)) as MaximumDeaths
From CovidAnalysis.dbo.CovidDeaths
where continent is NULL
group by location
order by MaximumDeaths DESC


-- Global death percentage by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidAnalysis.dbo.CovidDeaths
where continent is NOT NULL
group by date
order by 1,2 

-- Joining two tables 

Select *
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
order by 3,4

-- Total population vs vaccinations
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
where dea.continent is NOT NULL
order by 2,3

-- Using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
where dea.continent is NOT NULL
)
Select *, (RollingPeopleVaccinated/population)*100 as vaccpercentage
From PopvsVac

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
where dea.continent is NOT NULL
Select *, (RollingPeopleVaccinated/population)*100 as vaccpercentage
From #PercentPopulationVaccinated


-- Creating views for data visualisation

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
where dea.continent is NOT NULL

Select *
From PercentPopulationVaccinated