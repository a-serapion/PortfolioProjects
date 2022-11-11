SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio project database] ..[COVID DEATHS]
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio project database] ..[COVID DEATHS]
WHERE location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, new_cases, population, (total_cases/population)*100 as DeathPercentage
FROM [Portfolio project database] ..[COVID DEATHS]
WHERE location like '%Canada%'
order by 1,2

-- Looking at Countries with the highest infection rate compared to Population

SELECT Location, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as InfectedPercentage
FROM [Portfolio project database] ..[COVID DEATHS]
--WHERE location like '%Canada%'
GROUP by Location, Population
order by InfectedPercentage desc

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio project database] ..[COVID DEATHS]
WHERE location like '%Philippines%'
order by 1,2

-- Showing the countries with the highest death count per population
-- Got rid of the null by adding a WHERE function

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount	
FROM [Portfolio project database] ..[COVID DEATHS]
--WHERE location like '%Canada%'
WHERE continent is not null
GROUP by Location, Population
order by TotalDeathCount desc

-- WHAT DOES IT LOOK LIKE BY CONTINENT?

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount	
FROM [Portfolio project database] ..[COVID DEATHS]
--WHERE location like '%Canada%'
WHERE continent is null
GROUP by location
order by TotalDeathCount desc

--- side quest lmao what do the covid numbers look like when comparing higher, middle, and lower classes?
-- We will start by comparing the rate of infection in comparison to the population in Canada
SELECT Location, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as InfectedPercentage
FROM [Portfolio project database] ..[COVID DEATHS]
WHERE location like '%High income%'
GROUP by location, Population
order by InfectedPercentage desc

-- The total infected percentage that died when getting Covid in the High income class is 0.2%

-- BACK TO THE PROJECT
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount	
FROM [Portfolio project database] ..[COVID DEATHS]
--WHERE location like '%Canada%'
WHERE continent is not null
GROUP by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) --(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio project database] ..[COVID DEATHS]
-- WHERE location is like '%Canada%'
where continent is not null
group by date
order by 1,2

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)) --(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio project database] ..[COVID DEATHS]
-- WHERE location is like '%Canada%'
where continent is not null
group by date
order by 1,2

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio project database] ..[COVID DEATHS]
-- WHERE location is like '%Canada%'
where continent is not null
group by date
order by 1,2

-- NTS when you get an error code for SUM ensure that it is an integer, otherwise just use CAST to turn the column into one

-- Looking at Total Population vs Vaccinations
-- Free to use either CONVERT OR CAST - its nice to show that you can do both I guess
-- ALSO, if you get one of those Arithmetic Overflow errors try bigint .. it worked?
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM [Portfolio project database] ..[COVID DEATHS] dea
Join [Portfolio project database] .. [COVID VACCINATIONS] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
With PopvsVac(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.LOCATION Order by dea.location, dea.date)
FROM [Portfolio project database].. [COVID DEATHS] dea
Join [Portfolio project database].. [COVID VACCINATIONS] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
SELECT*
FROM PopvsVac
-- Now lets see how many people are vaccinated in comparison to the entire population
-- USE CTE
With PopvsVac(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.LOCATION Order by dea.location, dea.date)
FROM [Portfolio project database].. [COVID DEATHS] dea
Join [Portfolio project database].. [COVID VACCINATIONS] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinatedx
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
insert into #PercentPopulationVaccinatedx
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.LOCATION Order by dea.location, dea.date)
FROM [Portfolio project database].. [COVID DEATHS] dea
Join [Portfolio project database].. [COVID VACCINATIONS] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.LOCATION Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio project database].. [COVID DEATHS] dea
Join [Portfolio project database].. [COVID VACCINATIONS] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3