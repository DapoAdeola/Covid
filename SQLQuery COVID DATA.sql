-- Dataset
SELECT * fROM COVIDDATA


-- Number of countries
SELECT COUNT(DISTINCT location) AS NumberCountries
FROM COVIDDATA
WHERE DATALENGTH(continent)!=0

-- Number of continents
SELECT COUNT(DISTINCT continent) AS NumberContinents
FROM COVIDDATA


-- List of countries 
SELECT DISTINCT location, continent
FROM COVIDDATA
WHERE DATALENGTH(continent)!=0
ORDER BY location

-- List of continents
SELECT DISTINCT continent
FROM COVIDDATA
WHERE continent IS NOT NULL


--checking max values OF COUNTRIES
SELECT 
	continent, location, population, median_age,
	MAX(CAST(total_cases AS BIGINT)) AS ToatalCases, 
	MAX(CAST(total_deaths AS BIGINT)) AS TotalDeaths, 
	MAX(CAST(total_tests AS BIGINT)) AS TotalTests
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population, median_age


----checking max values OF Continents
SELECT 
	continent, location, population, median_age,
	MAX(CAST(total_cases AS BIGINT)) AS ToatalCases, 
	MAX(CAST(total_deaths AS BIGINT)) AS TotalDeaths, 
	MAX(CAST(total_tests AS BIGINT)) AS TotalTests 
FROM COVIDDATA
WHERE continent IS NULL
GROUP BY continent, location, population, median_age



--checking max values of world, unitedkingdom and nigeria
SELECT 
	location, population, median_age,
	MAX(CAST(total_cases AS BIGINT)) AS TotalCases, 
	MAX(CAST(total_deaths AS BIGINT)) AS TotalDeaths,
	MAX(CAST(total_tests AS BIGINT)) AS TotalTests
FROM COVIDDATA
WHERE location = 'world' OR location ='united kingdom' OR location ='nigeria'
GROUP BY location, population, median_age

-- calculating Rate of infection, Death rate, Test Rate
SELECT Max.continent, Max.location, 
	(TotalCases/population)*100 AS InfectionRate,
	(TotalDeaths/TotalCases)*100 AS DeathRate,
	(TotalTests/population)*100 AS TestRate
	FROM 
	(SELECT 
	continent, location, population, median_age,
	MAX(CAST(total_cases AS BIGINT)) AS TotalCases, 
	MAX(CAST(total_deaths AS NUMERIC)) AS TotalDeaths, 
	MAX(CAST(total_tests AS BIGINT)) AS TotalTests, 
	MAX(CAST(total_vaccinations AS BIGINT)) AS TotalVaccinations
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population, median_age) AS Max
ORDER BY TestRate DESC



-- calculating Rate of infection top 5 countries
SELECT  Max.continent, Max.location, 
	(TotalCases/population) AS InfectionRate
FROM (SELECT 
	continent, location, population, median_age,
	MAX(CAST(total_cases AS BIGINT)) AS TotalCases, 
	MAX(CAST(total_deaths AS NUMERIC)) AS TotalDeaths, 
	MAX(CAST(total_tests AS BIGINT)) AS TotalTests
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population, median_age) AS Max
ORDER BY InfectionRate DESC


-- calculating DeathRate top 5 countries
SELECT TOP 5 Max.continent, Max.location, 
		(TotalDeaths/TotalCases) AS DeathRate
	FROM (SELECT 
	continent, location, population, median_age,
	MAX(CAST(total_cases AS BIGINT)) AS TotalCases, 
	MAX(CAST(total_deaths AS NUMERIC)) AS TotalDeaths, 
	MAX(CAST(total_tests AS BIGINT)) AS TotalTests
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population, median_age) AS Max
ORDER BY DeathRate DESC


-- calculating TestRate top 5 countries
SELECT TOP 5 Max.continent, Max.location, 
	(TotalTests/population) AS TestRate
	FROM (SELECT 
	continent, location, population, median_age,
	MAX(CAST(total_cases AS BIGINT)) AS TotalCases, 
	MAX(CAST(total_deaths AS NUMERIC)) AS TotalDeaths, 
	MAX(CAST(total_tests AS BIGINT)) AS TotalTests
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population, median_age) AS Max
ORDER BY TestRate DESC


--date vs Rate of infection, Death rate, Test Rate
SELECT 
	continent, location, date, population, median_age,
	CAST(total_cases AS BIGINT) AS TotalCases, 
	CAST(total_deaths AS BIGINT) AS TotalDeaths, 
	CAST(total_tests AS BIGINT) AS TotalTests,
	CAST(total_cases AS BIGINT) / population AS InfectionRate, 
	CAST(total_deaths AS NUMERIC) / total_cases AS DeathRate, 
	CAST(total_tests AS BIGINT) / population AS TestRate
FROM COVIDDATA
WHERE continent IS NOT NULL
ORDER BY 1,2,3



--hospital patients  vs patients in icu
SELECT TOP 5 continent, location, population, 
	MAX(cast(icu_patients as int)) AS TotalICUpatients, 
	MAX(cast(hosp_patients as int)) AS TotalHospitalPatients,
	MAX(cast(icu_patients as int)) / MAX(cast(hosp_patients as numeric)) as ICURate
FROM COVIDDATA
where icu_patients IS NOT NULL AND hosp_patients IS NOT NULL
GROUP BY continent, location, population
ORDER BY ICURate DESC

--Taken a look at vaccinations
SELECT continent, location, population, 
	MAX(CAST(total_vaccinations AS BIGINT)) AS TotalVac, 
	MAX(CAST(people_vaccinated AS BIGINT)) AS People_1_Vac, 
	MAX(CAST(people_fully_vaccinated AS BIGINT)) AS People_2_Vac, 
	MAX(CAST(total_boosters AS BIGINT)) AS PeopleBoosterVac
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population
order by 1,2

--rate of single vaccination
SELECT Vac.location, (People_1_Vac/Vac.population)*100 AS Rate_SingleVac
FROM (SELECT continent, location, population, 
	MAX(CAST(total_vaccinations AS BIGINT)) AS TotalVac, 
	MAX(CAST(people_vaccinated AS BIGINT)) AS People_1_Vac, 
	MAX(CAST(people_fully_vaccinated AS BIGINT)) AS People_2_Vac, 
	MAX(CAST(total_boosters AS BIGINT)) AS PeopleBoosterVac
FROM COVIDDATA
WHERE continent IS NOT NULL 
GROUP BY continent, location, population) AS Vac
ORDER BY Rate_SingleVac DESC

--rate of double vaccinnation fully vaccinated
SELECT Vac.location, (People_2_Vac/Vac.population)*100 AS Rate_FullyVac
FROM (SELECT continent, location, population, 
	MAX(CAST(total_vaccinations AS BIGINT)) AS TotalVac, 
	MAX(CAST(people_vaccinated AS BIGINT)) AS People_1_Vac, 
	MAX(CAST(people_fully_vaccinated AS BIGINT)) AS People_2_Vac, 
	MAX(CAST(total_boosters AS BIGINT)) AS PeopleBoosterVac
FROM COVIDDATA
WHERE continent IS NOT NULL 
GROUP BY continent, location, population) AS Vac
ORDER BY Rate_FullyVac DESC


--rate of boosted vaccinations 3rd or more vaccinations
SELECT Vac.location, (PeopleBoosterVac/Vac.population)*100 AS RateBoosterVac
FROM (SELECT continent, location, population, 
	MAX(CAST(total_vaccinations AS BIGINT)) AS TotalVac, 
	MAX(CAST(people_vaccinated AS BIGINT)) AS People_1_Vac, 
	MAX(CAST(people_fully_vaccinated AS BIGINT)) AS People_2_Vac, 
	MAX(CAST(total_boosters AS BIGINT)) AS PeopleBoosterVac
FROM COVIDDATA
WHERE continent IS NOT NULL 
GROUP BY continent, location, population) AS Vac
ORDER BY RateBoosterVac DESC

--COMPARING CERTAIN PARAMETERS

-- infection rate vs population
SELECT continent, location, population, population_density, MAX(CAST(total_cases AS BIGINT))/population AS InfectionRate
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population, population_density

-- infection rate vs extreme poverty
SELECT continent, location, population, extreme_poverty, MAX(CAST(total_cases AS BIGINT))/population AS InfectionRate
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population, extreme_poverty


-- infection rate vs median age
SELECT continent, location, population, median_age, MAX(CAST(total_cases AS BIGINT))/population AS InfectionRate
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population, median_age

-- infection rate vs GDP
SELECT continent, location, population, gdp_per_capita, MAX(CAST(total_cases AS BIGINT))/population AS InfectionRate
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, population, gdp_per_capita

-- Death rate vs cardiovascular death rate
SELECT continent, location, total_cases, cardiovasc_death_rate, MAX(CAST(total_deaths AS NUMERIC))/total_cases AS DeathRate
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, total_cases, cardiovasc_death_rate

--Death rate vs diabetes prevalence
SELECT continent, location, total_cases, diabetes_prevalence, MAX(CAST(total_deaths AS NUMERIC))/total_cases AS DeathRate
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, total_cases, diabetes_prevalence

--Death rate vs smokers
SELECT continent, location, total_cases, female_smokers, male_smokers, MAX(CAST(total_deaths AS NUMERIC))/total_cases AS DeathRate
FROM COVIDDATA
WHERE continent IS NOT NULL AND female_smokers IS NOT NULL
GROUP BY continent, location, total_cases, female_smokers, male_smokers


--Death rate vs life expectancy
SELECT continent, location, total_cases, life_expectancy, MAX(CAST(total_deaths AS NUMERIC))/total_cases AS DeathRate
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, total_cases, life_expectancy

--Death rate vs human development index
SELECT continent, location, total_cases, human_development_index, MAX(CAST(total_deaths AS NUMERIC))/total_cases AS DeathRate
FROM COVIDDATA
WHERE continent IS NOT NULL
GROUP BY continent, location, total_cases, human_development_index, total_cases

