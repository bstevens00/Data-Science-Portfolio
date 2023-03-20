/*
COVID - Analyzing the ongoing pandemic from January 8, 2020 to March 18, 2023
Data taken from the following URL:
https://ourworldindata.org/covid-deaths
Taken March 18, 2023

-- The queries in this file are broken into the following main groups:

-- The United States of America's COVID Statisics
-- All individual countries' COVID Statisics
-- Continental COVID Statisics
-- Worldwide COVID Statisics
-- Worldwide COVID Vaccinations
-- A few view creations
-- Where to go from here

--------------------------------------------------------------------------------
-- Each individual section will be broken separated by a header like this one --
--------------------------------------------------------------------------------
*/

-- Before we begin, let's see the data types
select * from information_schema.columns
-- Looks like the data read in from Excel correctly, no manual need to change data types


-- We'll begin by taking a quick look at the two tables
SELECT *
FROM [4_Covid_Project].dbo.[4_CovidDeaths]

SELECT *
FROM [4_Covid_Project].dbo.[4_CovidVaccinations]



-- WHERE location = 'United States'
-- Alternatively, could use...
-- WHERE location like '%states%'
-- But there are other States out there, like UAE and US Virgin Islands


----------------------------------
-- The United States of America --
----------------------------------



-- Note the following statement will be added to all queries for the time being:
-- WHERE location = 'United States'
-- As we're only considering the US here
-- Alternatively, could use:
-- WHERE location like '%states%'
-- But there are other States out there, like UAE and US Virgin Islands



-- A quick look at the main 5 columns that will be the foundation of most of these queries
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE location = 'United States'
ORDER BY location, date -- alternatively, ORDER BY 1, 2



-- Looking at the Total Cases vs Total Deaths, where both of these total columns are cumulative UP TO their date.
-- Let's see the likelihood of death in the US by COVID if a person is currently infected.
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS DeathPercentage
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE location = 'United States'
ORDER BY location, date
-- Early on, when there aren't that many cases, we can pretty well ignore it, since it's too sparse and turbulent.
-- Note that at about 3000 cases, the DeathPercentages starts to stabilize.
-- Looking around March of 2020, we can see the DeathPercentage peaked at a little over 6%, or 3/50 chance of dying if you currently had Covid.
-- Of course, this is without considering age, demographics, etc.
-- The data appears to skew right, with a slow, consisitent decrease in the DeathPercentage over time.
-- This lines up with expectations, as the combination of lock down, vaccinations, and herd immunity have begun to make a difference.



-- Now let's consider the Cumulative Infection Rate, or what percentage of the population has gotten Covid.
SELECT location, date, total_cases, population, ((total_cases/population) * 100) AS InfectionRate
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE location = 'United States'
ORDER BY location, date
-- By this calculation, we can see that the infection rate has apparently steadily climbed since the start of tracking data, which makes sense.
-- More surprisingly, the data indicates that as of March 16, 2023, Covid has infected a little over roughly 30% of the US population.
-- Let's see how the USA stacks up against the rest of the world.


-------------------------------------------
-- (End of) The United States of America --
-------------------------------------------


------------------------------
-- All Individual Countries -- 
------------------------------


-- Let's see what countries have the highest number of infected people in total since the beginning.
-- Looking at countries with highest infection rate compared to population.
-- We can drop the WHERE filter now, as we're no longer concerned with only the USA.
SELECT continent, location, MAX(total_cases) AS HigestInfectionCount, population, MAX((total_cases/population) * 100) AS MaxInfectionRate
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
-- WHERE location = 'United States'
GROUP BY continent, location, population
ORDER BY HigestInfectionCount DESC
-- We see that the United States has had the highest number of infected people, followed by China. Which seems suspicious, as the USA has 338,289,856 people, and China
-- has over four times that number with 1,425,887,360, yet they have 1/4 the infection rate? We'll have to look into this, something seems off.
-- Here we see that "World", "Asia", and "Europe" are listed as locations alongside other non-country locations. We need to fix this and remove them from the query.
-- Additionally, some of these categories are economic stratifiers, such as "High Income". These need to go too.
-- Luckily, any time a location value isn't a country, the "continent" column has a NULL entry, so we can filter by this by adding the following filtering WHERE statement.
-- WHERE continent IS NOT NULL.



-- Let's try again.
-- Let's also reorder this from highest to lowest MaxInfectionRate to see which country was hit hardest per capita.
SELECT continent, location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population) * 100) AS MaxInfectionRate
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY MaxInfectionRate DESC -- Order changes
-- Wow! Cypris has had 72 percent of it's population infected.
-- And it's not even an outlier, there are a lot of countries in the 60% infected category.
-- Similarly, many countries report numbers under 10%.
-- Seems like the USA and China have numbers well within the distribution of the MaxInfectionRate Column.
-- That column would make for an interesting Histogram.
-- In fact, many countries have had twice the number of their people infected as the United States.
-- Shows that raw numbers aren't the whole story.
-- Also, Europe got annihilated, with 8 of 10 of the highest infection rates in the world coming from there.
-- And infection rates appear to be independent of population size.
-- Maybe we should look into Population Density?
-- But for now, let's consider a bit of a darker topic.



-- Let's see how many people died in each country, to understand the lethality of the virus.
-- Countries with the highest death count (total raw deaths).
SELECT location, MAX(total_deaths) AS TotalDeathCount, population
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC
-- Looks like the United States is number one in a category not worth bragging about.
-- This also shows the US to be an order of magnitude higher than most other developed countries.
-- The US has apparently had almost twice as many people die as the nearest country?
-- That just seems strange, considering how few people live in the US compared to China and India, but...
-- One quick way to check is percentages.



-- Now let's see how many people died out of the entire population
-- Countries with the highest death count per population (mortality rate)
SELECT location, MAX(total_deaths) AS TotalDeathCount, population, MAX((total_deaths/population) * 100) AS MortalityRate
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MortalityRate DESC
-- Interesting. The highest Mortality Rate was in Peru at just a little over 0.6%, meaning more than 1 out of 200 people in their country died from Covid.
-- In the USA, it was 0.33%, or 1/300 people in the USA died from it.
-- The USA is higher on this list of 243 countries, sitting at the 19th highest Mortality Rate and 1st highest Total Death Count.
-- This shows that while the US has had many infected people overall, as a percentage of the overall population, it's within expectations when compared to other countries.
-- So we answered the last question, it appears the USA doesn't have an abnormal death count when given percentage context


---------------------------------------
-- (End of) All Individual Countries -- 
---------------------------------------


---------------------------
-- Continental Groupings --
---------------------------


-- Let's see how many deaths three have been in each continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
-- There appear to be some oversights in the data, as North America only contains the United States of America's total. The 1,113,229 was the number for the USA's Total Death Count
-- This would mean that there were no deaths in Canada, Mexico... etc. This isn't right.
-- We're going to have to see if there's another way to see the data we're seeking.



-- Let's try breaking it down by location, filtering out continent NULL row values, maybe this will get what we're looking for.
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE continent IS NULL -- Removed the "NOT", so we don't include any place that exists on a continent, leaving alternative grouping methods
GROUP BY location
ORDER BY TotalDeathCount DESC
-- Here we have what a higher number for North America.
-- This must be the proper breakdown.
-- However, we need to filter out the non-country location rows.



-- The correct numbers for TotalDeathCount by Continent are:
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE continent IS NULL AND location IN('North America', 'South America', 'Asia', 'Europe', 'Africa', 'Asia', 'Oceania')
GROUP BY location
ORDER BY TotalDeathCount DESC
-- Yeah, this seems correct. The North American number is now higher than the singular USA.
-- Also Europe, which had 8/10 of the highest Max Infection Rates, is now the leading continent in Total Death Count.



--------------------------------------------------------------
-- A note for later, we should consider break down by income group too:
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE continent IS NULL AND location NOT IN('North America', 'South America', 'Asia', 'Europe', 'Africa', 'Asia', 'Oceania') AND location NOT IN ('World', 'European Union')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- And perhaps by population density and demographics, if the data is available.
--------------------------------------------------------------



------------------------------------
-- (End of) Continental Groupings --
------------------------------------


--------------------------------
-- Worldwide COVID Statistics --
--------------------------------



-- Let's consider the total number of cases, total new cases, total deaths, and overall population of the worlde every day since the start of the pandemic
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE location = 'World'
ORDER BY location, date -- alternatively, ORDER BY 1, 2
-- These raw deaths numbers are disheartening, but we need to look deeper by considering the rates.



-- Let's see what percentage of the World has had COVID.
SELECT location, date, total_cases, population, ((total_cases/population) * 100) AS InfectionRate
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE location = 'World'
ORDER BY location, date
-- As of March 16, 2023, 9.5% of the world has been infected with Covid, or 1 in 10 people.



-- Let's look at the overall percentage of people who died from COVID out of those who had caught it every day so far.
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS DeathPercentage
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE location = 'World'
ORDER BY location, date
-- The peak of the Death Percentage was a little above 7 percent in May of 2020. At that point, a person with COVID had a 7-8% chance of dying.
-- Again, this might be worth diving more into, as the data from this site didn't provide demographics of those infected.



-- Let's manually calculate the Total New Cases and Total New Deaths by day using the SUM aggregation function.
-- Then we'll calculate a new column, called the "New Death Rate".
-- This will be the total new cases of COVID reported each day divided by the total new deaths each day.
-- This is useful, because when we're fighting a virus, it's not relevant that it's not currently infecting as many people as it once did,
-- we're more concerned with whether the day to day New Death Rate is dropping, showing signs that the virus is losing efficacy in the population.
SELECT
	date,
	SUM(new_cases) AS TotalNewCases,
	SUM(new_deaths) AS TotalNewDeaths,
	(SELECT CASE
				WHEN SUM(new_cases) = 0 -- Early on, there isn't any data in the "new cases" column, as no one had it yet. As we can't divide by zero, we'll need a CASE, WHEN statement here to handle division by zero.
				THEN NULL
				ELSE SUM(new_deaths)/SUM(new_cases)*100
				END) AS NewDeathRate
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, SUM(new_cases)
-- Early on, when few people were infected, the percentages fluctuated too rapidly to grasp the NewDeathRate
-- However, from March 2020 to June 2020, around 5% of all COVID infections lead to death.
-- This number began to drop, with a few occasional jumps, as COVID likely entered previously unreached populations and spread again.
-- But eventually, this number began to drop again, as has been slowly going down.
-- Today, things look incredibly promising, as the NewDeathRate is on a decreasing downtrend, hovering around 0.5% and dropping.



-- Let's look at Total New Cases vs Total New Deaths for Covid since the beginning, averaging all days into one percentage
SELECT
	--date,
	SUM(new_cases) AS TotalNewCases,
	SUM(new_deaths) AS TotalNewDeaths,
	(SELECT CASE
				WHEN SUM(new_cases) = 0 -- We can't divide by zero!
				THEN NULL
				ELSE SUM(new_deaths)/SUM(new_cases)*100
				END) AS NewDeathRate
FROM [4_Covid_Project].dbo.[4_CovidDeaths]
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date, SUM(new_cases)
-- This shows that the Total New Death Rate is just under 1% of the population since the beginning on average.
-- So the average is much lower than it was during the peak, and it appears to have mostly subsided.
-- Still, that's new death rate per day. That's About 1% of the world population dying from the sickness per day since January 2020. That's crazy.



-----------------------------------------
-- (End of) Worldwide COVID Statistics --
-----------------------------------------


--------------------------------------
-- Worldwide Vaccination Statistics --
--------------------------------------



-- Let's look at the total population vs vaccinations
-- This will require a JOIN on two tables, as the vaccination data is in the other table we haven't touched yet.
SELECT DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations
FROM [4_Covid_Project].dbo.[4_CovidDeaths] DEA
JOIN [4_Covid_Project].dbo.[4_CovidVaccinations] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY DEA.continent, DEA.location
-- Wow, it's interesting that there were almost no new vaccinations in Algeria for the first year, then all of a sudden on ONE dayu, 2021-11-30, 147,230 people got vaccinated?
-- Was that aid from another country?
-- In fact, this happened in more than a few countries in Africa.



-- Let's create a rolling, cumulative count column for new vaccinations by Continent and Country. This will track the total number of vaccinations every country has ever had in the final column.
SELECT DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.location) AS RunningTotalVaccinations
FROM [4_Covid_Project].dbo.[4_CovidDeaths] DEA
JOIN [4_Covid_Project].dbo.[4_CovidVaccinations] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY DEA.continent, DEA.location
-- This is cool, but let's see if we can further break this down by date, showing the Running Total Growing each day.
-- It'll also be interesting to see what percentage of the population is vaccinated in each country every day of the pandemic.



-- To add the date, we'll partition the data on date in addition to the location
-- However, to do the second part - that is, the percentage of the population is vaccinated in each country every day of the pandemic,
-- that will require a new column to be calculated using existing ones, and then a second new column to be created that's dependent on the first newly created one.
-- SQL can't create a column in the SELECT statement and in the very same SELECT statement, use the newly created column to create another new one.
-- This code attempts to do it, but it fails
SELECT
	DEA.continent,
	DEA.location,
	DEA.date,
	population,
	VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS BIGINT))
		OVER (PARTITION BY DEA.location
		ORDER BY DEA.location,
				 DEA.date) AS RunningTotalVaccinations,
	(RunningTotalVaccinations/population)*100 AS PercentNewlyVaccinated -- Get an error here, because we're referring to a column that's being created in the query, and we can't do that, it needs to exist before the query
FROM [4_Covid_Project].dbo.[4_CovidDeaths] DEA
JOIN [4_Covid_Project].dbo.[4_CovidVaccinations] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY DEA.continent, DEA.location
-- This FAILS, because we're trying to create a new column with a column that is currently being created, we can only create new columns from previously existing ones



-- In order to add the percent of newly vaccinated out of entire population, and to keep the code from looking cluttered, we're going to use a "Common Table Expression" (CTE) to create a temporary table in memory.
-- A CTE is a temporary table created and stored in memory that can only be used in the immediate after it, after which it will be flushed from memory, making it even more temporary than a temp table, and faster to use.
-- Very useful when doing a query that calculates something based off of something else that needs calculating.
WITH PopVSVac (continent, location, date, population, new_vaccinations, RunningTotalVaccinations) -- CTEs being with the WITH naming the CTE and stating the columns being created
AS
( 
SELECT
	DEA.continent,
	DEA.location,
	DEA.date,
	population,
	VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS BIGINT))
		OVER (PARTITION BY DEA.location
		ORDER BY DEA.location,
				 DEA.date) AS RunningTotalVaccinations -- Here we're creating the temporary calculation
FROM [4_Covid_Project].dbo.[4_CovidDeaths] DEA
JOIN [4_Covid_Project].dbo.[4_CovidVaccinations] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
-- ORDER BY DEA.continent, DEA.location -- ORDER BY can't be inside of a subquery, CTE, etc.
) -- END OF CTE. This CTE can now be used in the VERY NEXT query, but NEVER AGAIN, after which it is removed from memory
SELECT *, (RunningTotalVaccinations/population)*100 AS PercentNewlyVaccinated
FROM PopVSVac -- The CTE is called, displayed, and disappears forever from memory
-- Here we can see, in last two columns, the total number of people in each country that have been vaccinated in each country by the day, as well as what percentage of the country has been vaccinated by the day.



-- Now, the same calculation could have been done using a tempoary table, and that's shown here. Mainly to compare and contrast the two, but also as notes for myself, practice, and evidence of competence with the method.
-- Anyway, this could also be done with a temporary table, which doesn't appear in the database, but after being run in the current instance of the server, can be queried or used for other queries until the server is closed, after which it disappears until being ran again.
-- The upside to this method is the table doesn't disappear as it would with a CTE's ONE use restriction. The downside the temporary table is slower in almost every instance.
DROP TABLE IF EXISTS #PercentPopulationVaccinated -- Always good practice to wipe a temporary table before running it.
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RunningTotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	DEA.continent,
	DEA.location,
	DEA.date,
	population,
	VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS numeric))
		OVER (PARTITION BY DEA.location
		ORDER BY DEA.location,
				 DEA.date) AS RunningTotalVaccinations
FROM [4_Covid_Project].dbo.[4_CovidDeaths] DEA
JOIN [4_Covid_Project].dbo.[4_CovidVaccinations] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
-- Note that after running this, there is a significantly longer delay before it completes. Half a second for the CTE, roughly, and 5 seconds for the temp table.
-- Might not seem like a lot, but it means a lot if the tables are huge.

SELECT * --, (RunningTotalVaccinations/population)*100 AS PercentNewlyVaccinated
FROM #PercentPopulationVaccinated
-- These are the same results we saw before.



--------------------------------------
-- Worldwide Vaccination Statistics --
--------------------------------------


---------------------------------------------
-- Creating Views for later visualizations --
---------------------------------------------

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	DEA.continent,
	DEA.location,
	DEA.date,
	population,
	VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS BIGINT))
		OVER (PARTITION BY DEA.location
		ORDER BY DEA.location,
				 DEA.date) AS RunningTotalVaccinations
	-- (RunningTotalVaccinations/population)*100 AS PercentNewlyVaccinated -- Get an error here, because we're referring to a column that's being created in the query, and we can't do that, it needs to exist before the query
FROM [4_Covid_Project].dbo.[4_CovidDeaths] DEA
JOIN [4_Covid_Project].dbo.[4_CovidVaccinations] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
-- ORDER BY DEA.continent, DEA.location

-- This added a new entry to the "Views" folder in the left pane
-- Right click it and view top 1000 rows to see what's in the view


-- Let's now try and query off of it
SELECT *
FROM PercentPopulationVaccinated



-----------------------------
-- (End of) Creating Views --
-----------------------------



---------------------------
-- Where to go from here --
---------------------------

-- There is a lot of data in these tables. Future queries could consider demographic analysis, including income, education status, gender, race, pre-exisiting conditions, smoking status, religiosity, etc.
-- Additionally, geographic questions could be asked, using the aid of data-to-map software, perhaps in Tableau or PowerBI, or maybe in Python or R.
-- Finally, population density should be considered, as one would expect that relatively denser populations spread a virus quicker, but are then also quicker to reach herd immunity, the 80/20 split.