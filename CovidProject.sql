
--Select * from PortfolioProject..['Covid-Vaccinations']
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['Covid-Deaths']
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..['Covid-Deaths']
order by 1,2

-- I.e Afghanistan Key ID 432 day 30/04/2021 we had total cases of 59745 and total deaths of 2625 as of that day there is a 4.39% chance of
-- of dying from Covid on that date

-- Shows the Likelihood of dying from Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..['Covid-Deaths']
Where location like '%Kingdom%'
order by 1,2

-- I.e In the United Kingdom on the 01/03/2022 there has been 19036570 total cases of covid and 161773 deaths this means there
-- is a 0.85% of dying from Covid currently in the UK 

--Looking at total cases vs the population in the UK
-- shows what percentage of the population has gotten Covid 
Select location, date, total_cases, population, (total_cases/population)*100 AS Casepercentage
from PortfolioProject..['Covid-Deaths']
Where location like '%Kingdom%'
order by 1,2

-- On the 01/03/2022 27.9% of the population has gotten Covid in the UK

-- Looking at countries with the higest infection rate compared to the population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
from PortfolioProject..['Covid-Deaths']
--Where location like '%Kingdom%'
Group by location,population 
order by PercentagePopulationInfected desc

-- We can see that the Highest Population infected ins the Faeroe Islands followed by Andorra and Denmark
--the UK is ranked as the 31st highest country infection rate

--Showing Countries with the Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) AS HighestDeathCount
from PortfolioProject..['Covid-Deaths']
Where continent is not null
--Where location like '%Kingdom%'
Group by location
order by HighestDeathCount desc
--the cast converts Nvarchar 255 to an int so we can see the ranking properly for the above query
-- We can see that the highest death count is within the United states at 952423
-- The UK has the 7th highest at 161773

--Lets Break things down by continent
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..['Covid-Deaths']
Where continent is not null
--Where location like '%Kingdom%'
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..['Covid-Deaths']
Where continent is not null
--Where location like '%Kingdom%'
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..['Covid-Deaths']
Where continent is not null
--Where location like '%Kingdom%'
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid-Deaths'] dea
Join PortfolioProject..['Covid-Vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and dea.location like '%Kingdom%'
order by 2,3

-- We need to add a CTE to have a custom Column like this

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['Covid-Deaths'] dea
Join ['Covid-Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['Covid-Deaths'] dea
Join ['Covid-Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['Covid-Deaths'] dea
Join ['Covid-Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3