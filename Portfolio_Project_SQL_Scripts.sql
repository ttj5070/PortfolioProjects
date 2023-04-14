SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


--Selecting data of interest

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2 


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY 1, 2 


-- Looking at Total Cases vs Population
-- Showing percentage of the population that got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States' 
ORDER BY 1, 2 


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


-- Breaking things down by Continent


-- Showing Continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- Global Numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2 


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated,
--(Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- Use CTE 

With Pop_Vs_Vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (Rolling_People_Vaccinated/population)*100 AS Percent_Population_Vaccinated
FROM Pop_Vs_Vac


-- Temp Table
DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated

(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
Rolling_People_Vaccinated NUMERIC
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (Rolling_People_Vaccinated/population)*100 AS Percent_Population_Vaccinated
FROM #Percent_Population_Vaccinated


-- Creating View to store data for later visualizations

CREATE VIEW Percentage_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


 SELECT *
  FROM Percentage_Population_Vaccinated