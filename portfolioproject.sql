use portfolioproject;

-- select data that we are going to be using
SELECT 
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    Coviddeath
ORDER BY Location,date;

-- Loking at Total Cases VS Total Deaths
-- Show likelhood dying if you contract covid in Africa

SELECT 
    Location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases)*100 AS Death_Percentage
    
FROM
    Coviddeath
WHERE Location = 'Africa'

ORDER BY 
   date,
   Location;

-- Show Max Total Cases and Total Deaths in Africa
SELECT  
    Location,
    MAX(total_cases) AS MAX_cases,
    MAX(total_deaths) AS MAX_deaths,
    (MAX(total_deaths) / MAX(total_cases)) * 100 AS Death_Percentage
FROM  
    Coviddeath
WHERE 
    Location = 'Africa'
GROUP BY 
    Location
ORDER BY 
    Location;
    
-- Looking at Total Case VS Population in Africa
-- Show what percentage got Covid 

SELECT 
    Location,
    date,
    total_cases,
    population,
    (total_cases / population) * 100 AS Percentage_population
FROM
    Coviddeath
WHERE 
   Location = 'Africa'
ORDER BY Location , date;

-- Looking at countries with hieghst infection rate compared to population
SELECT 
    Location,
    population,
    MAX(total_cases) AS HeighstInfection,
    MAX((total_cases / population)) * 100 AS percentage_population_infected
FROM
    Coviddeath
WHERE  
    Location = 'Africa' 
GROUP BY 
    Location, population
ORDER BY 
    percentage_population_infected;
    
-- Looking at countries with hieghst Death count per population

SELECT 
    Location,
    MAX(total_deaths ) AS Total_Death_Count
FROM
    Coviddeath
GROUP BY 
  Location
ORDER BY 
     Total_Death_Count ASC ; 

-- Let's Break Things Down BY Continent 
SELECT 
    continent, MAX(total_deaths) AS Total_Death_Count
FROM
    Coviddeath
GROUP BY continent
ORDER BY Total_Death_Count;


SELECT 
    date,
    SUM(new_cases IS NOT NULL) AS total_cases ,
    SUM(new_deaths IS NOT NULL) AS total_death,
    (SUM(new_deaths) / SUM(new_cases)IS NOT NULL) * 100 AS Death_Persentage
FROM
    Coviddeath
GROUP BY date 
ORDER BY Death_Persentage;

-- Looking at Total population VS Total Vaccination
SELECT 
    d.continent,
    d.population,
    d.date,
    d.Location,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.Location,d.date) AS Rollingpeoplevaccination,
	(SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.Location, d.date) / d.population) * 100 AS Percentage_of_Population_Vaccinated
FROM
    Coviddeath d
        JOIN
    covidvaccination v ON d.Location = v.Location AND d.date = v.date
WHERE new_vaccinations != '';
-- ORDER BY d.Location,d.continent ASC

-- Create tmper
DROP TABLE IF EXISTS percenpopulationvaccination;
CREATE TABLE Percent_PopulationVaccination (
    continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    Rollingpeoplevaccination NUMERIC
);
UPDATE coviddeath
SET Date = STR_TO_DATE(Date, '%m/%d/%Y')
WHERE Date LIKE '%/%/%' AND LENGTH(Date) = 10;



INSERT INTO Percent_PopulationVaccination (continent, Location, Date, population, new_vaccinations, Rollingpeoplevaccination)
SELECT 
    d.continent,
    d.Location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.Location, d.date) AS Rollingpeoplevaccination
FROM 
    Coviddeath d
JOIN 
    covidvaccination v 
ON 
    d.Location = v.Location AND d.date = v.date
WHERE 
    v.new_vaccinations != '';



CREATE VIEW Percent_PopulationVaccinationView AS
SELECT 
    d.continent,
    d.population,
    d.date,
    d.Location,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.Location, d.date) AS Rolling_new_Vaccinations
    -- (SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.Location, d.date) / d.population) * 100 AS Percentage_of_Population_Vaccinated
FROM 
    Coviddeath d
JOIN 
    covidvaccination v 
ON 
    d.Location = v.Location AND d.date = v.date
WHERE 
    v.new_vaccinations != '';
