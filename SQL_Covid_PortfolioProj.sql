
Select *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4;

--- Preparing the data set ---

/* I will only work with European countries thus I will
create a temporary table which includes information on Europe only
 */
DROP TABLE IF EXISTS #Covid_deaths_Europe
SELECT 
	iso_code, location, CAST(date as DATE) as date, population, total_cases, new_cases, total_deaths, new_deaths, 
	total_cases_per_million, total_deaths_per_million, new_deaths_per_million
INTO #Covid_deaths_Europe
FROM CovidDeaths
	WHERE continent = 'Europe';

-- I decided to exclude Jersey and Guernsey from the list of EU countries (the countries belong to UK and have no data entered)
DELETE FROM #Covid_deaths_Europe
	WHERE location IN ('Jersey', 'Guernsey');



--- Some basic analysis ---

-- Country with the highest infection rate 
SELECT location, population, MAX(total_cases) AS MaxInfectionCount, MAX(total_cases/population)*100 AS MaxInfectioRate
FROM #Covid_deaths_Europe
	GROUP BY population, location
	ORDER BY 4 DESC;

-- Country with the highest death rate 
SELECT location, population, MAX(cast(total_deaths as int)) AS TotalDeaths -- As the data on Total detahs would be desplayed as varchar we need to change it into integer
FROM #Covid_deaths_Europe
	GROUP BY population, location
	ORDER BY 3 DESC;

-- First reported Covid case and death case in each country in Europe
SELECT t1.location, t1.first_occurance, t2.first_death
FROM
(SELECT  location, MIN(date) as first_occurance
FROM #Covid_deaths_Europe
	GROUP BY location) as t1
LEFT JOIN 
(SELECT location, min(date) as first_death
FROM #Covid_deaths_Europe
	WHERE new_deaths > 0
	GROUP BY location) as t2
	ON t1.location = t2.location;

-- Create CTE to calculate in which country did it take the shortest from the first occurance until the first death
WITH first_cases as 
(SELECT t1.location, t1.first_occurance, t2.first_death
FROM
(SELECT  location, MIN(date) as first_occurance
	FROM #Covid_deaths_Europe
	GROUP BY location) as t1
LEFT JOIN 
(SELECT location, min(date) as first_death
	FROM #Covid_deaths_Europe
	WHERE new_deaths > 0
	GROUP BY location) as t2
	ON t1.location = t2.location
)
SELECT location, DATEDIFF (day, first_occurance, first_death) as date_diff
FROM first_cases
	ORDER BY 2;
/*
From this we can see, for exmaple, 
that in San Marino, they reported Covid for the first time when someone died
or that in Faeroe Islands it took almost a year from the first person getting infected until the first person died
*/



--- Comparing Scandinavia and Visegrad group (As I am from Slovakia which is part of the Visegrad group)---

DROP TABLE IF EXISTS #Scandi_Viseg
SELECT *, 
	CASE WHEN location IN ('Poland', 'Slovakia', 'Czechia', 'Hungary') THEN 'Visegrad_group'
		 WHEN location IN ('Sweden',  'Norway', 'Denmark') THEN 'Scandinavia' END 
		 AS geo_group
INTO #Scandi_Viseg
FROM #Covid_deaths_Europe;

DELETE FROM #Scandi_Viseg
	WHERE geo_group IS NULL;

-- One of the factors of infection rate could be density of population. Let's add information on density per km2
ALTER TABLE #Scandi_Viseg
	ADD density int;

UPDATE #Scandi_Viseg
	SET density =
	( CASE 
	WHEN location = 'Slovakia' THEN 114
	WHEN location = 'Poland' THEN 123
	WHEN location = 'Hungary' THEN 107
	WHEN location = 'Czechia' THEN 139
	WHEN location = 'Sweden' THEN 25
	WHEN location = 'Finland' THEN 18
	WHEN location = 'Norway' THEN 15
	WHEN location = 'Denmark' THEN 137
	END);

SELECT *
FROM #Scandi_Viseg;

-- How does the infection rate looks compared to population density?
SELECT location, population, MAX(total_cases) AS MaxInfectionCount, MAX(total_cases/population)*100 AS MaxInfectioRate, density
FROM #Scandi_Viseg
	GROUP BY population, location, density
	ORDER BY 4 DESC;
/*
On the first glance it seems there is no relationship between infection rate and density however we would need more proper correlation analysis
However the density of population is not homogenous across the country so we can't really draw conclusions from this analysis.
For example in Sweden most people may live in large cities, therefore even though the population density across the country is low, most of the people may live in high density cities while in other country it can be the opposite.
*/

-- Where is more cases, in Scandinavia or Visegrad group? Where is higher death rate? (using new cases/deaths)
SELECT geo_group, SUM(new_cases) As cases_group, SUM(CAST(new_deaths as int)) AS deaths_group, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM #Scandi_Viseg
GROUP BY geo_group
ORDER BY 4;

-- What is the difference in an infection rate between the two groups (using total cases/deaths)?
SELECT geo_group, MAX(total_cases) AS cases_group, MAX(total_cases/population)*100 AS group_infectioRate
FROM #Scandi_Viseg
GROUP BY geo_group
ORDER BY 3;


--- Let's look on cases over monthly periods! ---
SELECT location, 
	date,
	geo_group,
	MONTH(date) as month_date,
	YEAR(date) as year_date,
	ROUND(AVG(new_cases) OVER (PARTITION BY MONTH(date), YEAR(date), location), 2) as monthly_average, 
	SUM(new_cases) OVER (PARTITION BY MONTH(date), YEAR(date), location) as monthly_new_cases,
	SUM(CAST(new_deaths as int)) OVER (PARTITION BY MONTH(date), YEAR(date), location) as monthly_deaths
FROM #Scandi_Viseg
	GROUP BY location, geo_group, date, MONTH(date), YEAR(date), new_cases, new_deaths
	ORDER BY YEAR(date), MONTH(date);

-- What was the maximum average number of new cases in each country?
WITH monthly_waves AS 
(SELECT location, 
	date,
	geo_group,
	MONTH(date) as month_date,
	YEAR(date) as year_date,
	ROUND(AVG(new_cases) OVER (PARTITION BY MONTH(date), YEAR(date), location), 2) as monthly_average, 
	SUM(new_cases) OVER (PARTITION BY MONTH(date), YEAR(date), location) as monthly_new_cases,
	SUM(CAST(new_deaths as int)) OVER (PARTITION BY MONTH(date), YEAR(date), location) as monthly_deaths
FROM #Scandi_Viseg
	GROUP BY location, geo_group, date, MONTH(date), YEAR(date), new_cases, new_deaths) 
SELECT MAX(monthly_average) AS monthly_max, 
	location
FROM monthly_waves
	GROUP BY location;

