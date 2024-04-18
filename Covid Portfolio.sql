Select *
From PortfolioProject..CovidDeaths
Order By 3,4


--Seleect Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2


-- Total Cases Vs Total Deaths
--Likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From CovidDeaths
Where location like '%Nigeria%'
Order By 1,2


-- Total Cases Vs Population
-- Show what percentage of population got Covid

Select location, date, population, total_cases,  (total_cases/population)* 100 as PercentOfPopulationInfected 
From CovidDeaths
Where location like '%Nigeria%'
Order By 1,2


--Countries with highest rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))* 100 as 
PercentOfPopulationInfected
From CovidDeaths
--Where location like '%Nigeria%'
Group By location, population
Order By 4 desc

--Countries with highest death count per population

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group By location
Order By TotalDeathCount desc

--Breaking Things Down By Continent

--continent with the highest death count per population

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
--Where location like '%Nigeria%'
Where continent is null
Group By location
Order By TotalDeathCount desc

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
--Where location like '%Nigeria%'
Where continent is  not null
Group By continent
Order By TotalDeathCount desc



--Global Numbers

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From CovidDeaths
--Where location like '%Nigeria%'
where continent is not null
Group By date
Order By 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From CovidDeaths
--Where location like '%Nigeria%'
where continent is not null
--Group By date
Order By 1,2


 Select *
 From CovidDeaths dea
 Join CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date


--Total Population Vs Vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date)
 as RollingPeopleVaccinated
 From CovidDeaths dea
 Join CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order By 2,3



--Use CTE

with popvsVac(continent, location, date , population, new_vaccination, RollingPeopleVaccinated)
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date)
 as RollingPeopleVaccinated
 From CovidDeaths dea
 Join CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From popvsVac



--Temp Table


DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date)
 as RollingPeopleVaccinated
 From CovidDeaths dea
 Join CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date)
 as RollingPeopleVaccinated
 From CovidDeaths dea
 Join CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated