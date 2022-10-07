USE CovidPortfolioProject
-- Select Data that we are going to be using

SELECT location,
       date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
FROM CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER By 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location,date,population,total_cases,
       (total_cases/population)*100 AS PopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%India%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) AS TotalCases,
       MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%India%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
 

 -- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS


SELECT --date,
	   SUM(new_cases) AS total_cases,
	   SUM(CAST(new_deaths AS INT)) AS total_deaths,
       SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER By 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cv.location=cd.location AND cv.date=cd.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
 WITH PopvsVac (Continent,location,date,population,new_Vaccinations, RollingPeopleVaccinated)
 AS(
 SELECT cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cv.location=cd.location AND cv.date=cd.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
) 
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_Vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cv.location=cd.location AND cv.date=cd.date
--WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cv.location=cd.location AND cv.date=cd.date
WHERE cd.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated

