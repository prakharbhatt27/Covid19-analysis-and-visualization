SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

--Select the data that we are going to be using


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2


--Looking at the total cases vs the total deaths  (Death percentage)
 
SELECT location,date,total_cases,total_deaths, Round(total_deaths/total_cases,4)*100 as "Death percentage"
FROM PortfolioProject..CovidDeaths
Where location='India' AND continent is not null
Order by 1,2


--Looking at the total cases vs population  (Infection percentage)
 
SELECT location,date,total_cases,population, Round(total_cases/population,4)*100 as "Infection percentage"
FROM PortfolioProject..CovidDeaths
Where location='India' AND continent is not null
Order by 1,2



--Looking at countries with highest Infection percentage per country
 
SELECT location,population,MAX(total_cases) as "Highest Infection count",MAX(Round(total_cases/population,4))*100 as "Infection percentage"
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
Order by [Infection percentage] DESC



--Looking at countries with Highest deaths per country

SELECT location,MAX(cast(total_deaths as int)) as "Total Deaths"
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by [Total Deaths] DESC

----Looking at continents with Highest deaths

SELECT continent,MAX(cast(total_deaths as int)) as "Total Deaths"
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by [Total Deaths] DESC





--Global Numbers (Across the world)

SELECT date,SUM(new_cases) as 'Total cases', SUM(cast(new_deaths as int)) as 'Total Deaths', (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as 'Death Percentage'
FROM PortfolioProject..CovidDeaths
Where continent is not null 
Group by date
Order by 1,2


--Looking at total population vs vaccination

Select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int)) OVER 
(Partition by Dea.location Order by Dea.location,Dea.date) AS 'Rolling people vaccinated'
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	On Dea.location=Vac.location
	and Dea.date=Vac.date
Where Dea.continent is not null 
order by 2,3

--Using CTE

With PopVsVac (continent,location,date,population,new_vacciations,Rolling_Vaccinations)
AS
(Select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int)) OVER 
(Partition by Dea.location Order by Dea.location,Dea.date) AS 'Rolling people vaccinated'
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	On Dea.location=Vac.location
	and Dea.date=Vac.date
Where Dea.continent is not null 
--order by 2,3
)

Select *, (Rolling_Vaccinations/population)*100
FROM PopVsVac
Order by 2,3



--TEMP TABLE

Drop table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Vaccinations numeric
)

Insert into #PercentPeopleVaccinated
Select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int)) OVER 
(Partition by Dea.location Order by Dea.location,Dea.date) AS 'Rolling people vaccinated'
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	On Dea.location=Vac.location
	and Dea.date=Vac.date
Where Dea.continent is not null 
--order by 2,3


Select *, (Rolling_Vaccinations/population)*100
FROM #PercentPeopleVaccinated
Order by 2,3




--Creating view to store data for later visualizations

Create view PercentPeopleVaccinated AS
Select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int)) OVER 
(Partition by Dea.location Order by Dea.location,Dea.date) AS 'Rolling people vaccinated'
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
	On Dea.location=Vac.location
	and Dea.date=Vac.date
Where Dea.continent is not null 
