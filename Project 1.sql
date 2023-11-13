--select *
--FROM [Portfolio Project]..Worksheet$

--SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
--FROM [Portfolio Project]..Worksheet$
--where location like '%nigeria%'
--ORDER BY 1,2


-- Percentage of cases per population
--SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentCases
--FROM [Portfolio Project]..Worksheet$
--where location like '%states%'

--Countries with the highest infection rates compared to population

--SELECT location,population, MAX(total_cases) AS MaxInfectionCount, MAX((total_cases/population))*100 as PercentCases
--FROM [Portfolio Project]..Worksheet$
--GROUP BY location,population
--order by 4 desc

--Countries with highest death rate per population

--SELECT location,population, MAX(CAST (total_deaths AS INT)) AS MaxDeathCount, MAX(total_deaths /population)*100 as PercentDeath
--FROM [Portfolio Project]..Worksheet$
--WHERE Continent is not NULL 
--GROUP BY location,population
--order by 4 desc

--Breaking Things Down by Continent

--SELECT continent, MAX(CAST (total_deaths AS INT)) AS TTDeathCount, MAX(total_deaths /population)*100 as PercentDeath
--FROM [Portfolio Project]..Worksheet$
--WHERE continent is not null
--GROUP BY continent
--order by 2 desc

--GLOBAL NUMBERS

--SELECT SUM(CAST (new_cases AS INT)) AS Total_case, SUM(CAST (new_deaths AS INT)) AS Total_deaths, SUM(CAST (new_deaths AS INT))/SUM(new_cases)* 100 AS Deathpercentage 
--from [Portfolio Project]..Worksheet$
--WHERE continent is not null

	--JOIN BOTH TABLES
--Total population vs total vaccinations 

--SELECT *
--FROM  [Portfolio Project]..Worksheet$ AS cases
--INNER JOIN [Portfolio Project]..CovidVaccinations$ AS vac
--ON cases.location = vac.location
--AND cases. date = vac.date

--SELECT cases.location, MAX(population) AS Population, SUM(CAST(new_vaccinations AS INT)) as TTVacinations, SUM(CAST(new_vaccinations AS INT))/MAX(population)*100 as PercentOfVaccinatedPopulace
--FROM  [Portfolio Project]..Worksheet$ AS cases
--INNER JOIN [Portfolio Project]..CovidVaccinations$ AS vac
--ON cases.location = vac.location
--AND cases. date = vac.date
--WHERE cases.continent is not null
--Group by cases.location
--ORDER BY 1 

--SELECT cases.continent,cases.location, cases.date, population, new_vaccinations, 
--SUM(CAST( new_vaccinations AS int)) OVER(PARTITION BY cases.location order by cases.date) AS TTVacinations
--FROM  [Portfolio Project]..Worksheet$ AS cases
--INNER JOIN [Portfolio Project]..CovidVaccinations$ AS vac
--ON cases.location = vac.location
--AND cases. date = vac.date
--Where cases.continent is not null
--order by 2,3

--To find the %of TTvaccinatedpple to the populace we need to create a temp table/cte because of the newly created TTVACCINATIONS
WITH Pop_Vac AS
(SELECT cases.continent,cases.location, cases.date, population, new_vaccinations, 
SUM(CAST( new_vaccinations AS int)) OVER(PARTITION BY cases.location order by cases.date) AS TTVacinations
FROM  [Portfolio Project]..Worksheet$ AS cases
INNER JOIN [Portfolio Project]..CovidVaccinations$ AS vac
ON cases.location = vac.location
AND cases. date = vac.date
Where cases.continent is not null
)

SELECT location, MAX((TTVacinations/population)*100)  
FROM Pop_Vac
group by location
ORDER BY 2 DESC


 --USING TEMP TABLES
 
DROP TABLE IF EXISTS #PercentVaccinatedOfPopulace
CREATE TABLE #PercentVaccinatedOfPopulace
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population float,
    new_vaccinations numeric,
    TTvaccinations numeric
);

INSERT INTO #PercentVaccinatedOfPopulace
SELECT
    cases.continent,
    cases.location,
    cases.date,
    population,
    new_vaccinations,
    SUM(CONVERT(numeric,new_vaccinations)) OVER (PARTITION BY cases.location ORDER BY cases.date) AS TTvaccinations 
FROM
    [Portfolio Project]..Worksheet$ AS cases
INNER JOIN [Portfolio Project]..CovidVaccinations$ AS vac
    ON cases.location = vac.location
    AND cases.date = vac.date
	WHERE CASES.CONTINENT IS NOT NULL

	SELECT location, MAX((TTvaccinations/population)*100)
	FROM #PercentVaccinatedOfPopulace
	GROUP BY location
	ORDER BY 2 DESC

	

	--CREATING VIEWS--


--	CREATE VIEW GlobalDeathPercentage AS
--	SELECT SUM(CAST (new_cases AS INT)) AS Total_case, SUM(CAST (new_deaths AS INT)) AS Total_deaths, SUM(CAST (new_deaths AS INT))/SUM(new_cases)* 100 AS Deathpercentage 
--from [Portfolio Project]..Worksheet$
--WHERE continent is not null


--CREATE VIEW DeathPercentage AS
--SELECT continent, MAX(CAST (total_deaths AS INT)) AS TTDeathCount, MAX(total_deaths /population)*100 as PercentDeath
--FROM [Portfolio Project]..Worksheet$
--WHERE continent is not null
--GROUP BY continent

--CREATE VIEW PercentOfVaccinated AS
--WITH Pop_Vac AS
--(SELECT cases.continent,cases.location, cases.date, population, new_vaccinations, 
--SUM(CAST( new_vaccinations AS int)) OVER(PARTITION BY cases.location order by cases.date) AS TTVacinations
--FROM  [Portfolio Project]..Worksheet$ AS cases
--INNER JOIN [Portfolio Project]..CovidVaccinations$ AS vac
--ON cases.location = vac.location
--AND cases. date = vac.date
--Where cases.continent is not null
--)

--SELECT location, MAX((TTVacinations/population)*100)  AS PercentVACCINATED
--FROM Pop_Vac
--group by location

