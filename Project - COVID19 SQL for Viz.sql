-- 1. Global Numbers as of Aug 2021
SELECT 
	SUM(new_cases) as total_cases, 
	SUM(new_deaths) as total_deaths, 
	SUM(new_deaths)/SUM(New_Cases)*100 as death_percent
FROM covid_data
WHERE continent IS NOT NULL -- To filter out 'continent', such as Asia, Europe, Africa etc.
ORDER BY 1,2

-- 2. Highest Infection Count and %Population Infected for Infected Cases Map as of Aug 2021
SELECT
	location, population, date,
	MAX(total_cases) as highest_infection_count, 
	Max((total_cases/population))*100 as population_infected_percent
FROM covid_data
WHERE continent IS NOT null 
GROUP BY location, population, date
ORDER BY population_infected_percent DESC NULLS LAST

-- 3. New Cases (and Deaths) by Continent in 2021
SELECT 
	location, date, new_cases, new_deaths
FROM covid_data
WHERE continent IS NULL AND date >= '2021-1-1'

-- 4. Total Cases and Vaccinations by Continent in 2021
SELECT 
	covid_data.location, covid_data.date, 
	covid_data.new_cases, vacc_data.new_vaccinations
FROM covid_data
JOIN vacc_data ON covid_data.location = vacc_data.location AND covid_data.date = vacc_data.date
WHERE covid_data.continent IS NULL AND covid_data.date >= '2021-1-1'

-- 5. Month vs. Vaccinations and Hospitalizations in 2021
SELECT 
	vacc_data.location, vacc_data.date, 
	vacc_data.total_vaccinations/1000000 AS total_vacc_per_million,
	country_data.weekly_hosp_admission/1000000 AS wk_hosp_admission_per_million
FROM vacc_data
JOIN country_data ON vacc_data.location = country_data.location AND vacc_data.date = country_data.date

-- 6. Total Population vs. Vaccinations; Looking for rolling count of vaccinations and vaccination per population
WITH pop_vs_vac AS
(SELECT 
 	covid_data.continent, covid_data.location, covid_data.date, covid_data.population, 
 	vacc_data.new_vaccinations,
	SUM(vacc_data.new_vaccinations) OVER (PARTITION BY covid_data.location ORDER BY covid_data.location, covid_data.date) AS rolling_count
FROM covid_data
JOIN vacc_data ON covid_data.location = vacc_data.location AND covid_data.date = vacc_data.date
WHERE covid_data.continent IS NOT NULL
)
SELECT *, (rolling_count/population)*100 AS rolling_percent FROM pop_vs_vac
ORDER BY location, rolling_count NULLS LAST

