select location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathRatio
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

--Looking at the Total Caes vs Population
--Shows what Percentage of population got covid
select location,date, population,total_cases, (total_cases/population)*100 AS CasesRate
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


--Looking at countries have the highest infection rate compared to population
select location,population,MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS MaxCasesRate
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location, population
Order by MaxCasesRate desc


--Looking at countries with higheest death count per population

select location,population,MAX(Cast(total_deaths as int)) AS HighestDeathCount, MAX(total_deaths/population)*100 AS MaxDeathRate
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location, population
Order by HighestDeathCount desc



--LETS BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the highest death count

select continent,MAX(Cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
Order by HighestDeathCount desc


--GLOBAL NUMBERS

--
select SUM(new_cases) as Total_Cases,SUM(CAST(new_deaths AS INT)) as Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathRatio
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date 
where dea.continent is not null
order by 2,3


--WITH CTE

With PopvsVac (continent, location,date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP INTO

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Create view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated