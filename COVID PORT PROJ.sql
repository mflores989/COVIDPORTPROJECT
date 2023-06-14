SELECT *
From COVIDPROJECT..CovidDeaths
order by 3,4

SELECT *
From COVIDPROJECT..CovidVaccinations
order by 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
From COVIDPROJECT..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
--Shows likelihood of death after contracting Covid in specific country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From COVIDPROJECT..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Total Cases vs Population
--Shows percentage of population contracted Covid

SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From COVIDPROJECT..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From COVIDPROJECT..CovidDeaths
--WHERE location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From COVIDPROJECT..CovidDeaths
--WHERE location like '%states
WHERE continent is null
Group by Location
order by TotalDeathCount desc


--Continents with Highest Death Count per Population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From COVIDPROJECT..CovidDeaths
--WHERE location like '%states
WHERE continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From COVIDPROJECT..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group by date
order by 1,2

--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From COVIDPROJECT..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--Group by date
order by 1,2


--Joining tables

SELECT *
FROM COVIDPROJECT..CovidDeaths dea
JOIN COVIDPROJECT..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.Location, dea.date) as RollingVaccinated
, (RollingVaccinated/population)*100
FROM COVIDPROJECT..CovidDeaths dea
JOIN COVIDPROJECT..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2, 3

--CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.Location, dea.date) as RollingVaccinated
--, (RollingVaccinated/population)*100
FROM COVIDPROJECT..CovidDeaths dea
JOIN COVIDPROJECT..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3
)
SELECT *, (RollingVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric, 
New_Vaccinations numeric, 
RollingVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.Location, dea.date) as RollingVaccinated
--, (RollingVaccinated/population)*100
FROM COVIDPROJECT..CovidDeaths dea
JOIN COVIDPROJECT..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2, 3

SELECT *, (RollingVaccinated/Population)*100
From #PercentPopulationVaccinated


--View for DATA VISUALIZATION

Create view PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.Location, dea.date) as RollingVaccinated
--, (RollingVaccinated/population)*100
FROM COVIDPROJECT..CovidDeaths dea
JOIN COVIDPROJECT..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3