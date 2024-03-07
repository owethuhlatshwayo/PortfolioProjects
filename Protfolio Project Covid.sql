select *
from projectportfolio..CovidDeaths
order by 3,4

select *
from projectportfolio..CovidVaccinations

--select the Data we're going to use 

select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeaths
where continent is not null 
order by 1,2

--looking at total cases vs total deaths
-- shows the probability of dying if you get covid in your country 
select location, date, total_cases, total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
order by 1,2

-- total cases vs Population (shows what % of population got covid)
select continent, location, date, total_cases, population,(total_cases/population) *100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where location like '%south%'
order by 1,2

--countries with highest infection rate compared to population 
select continent, location, population, Max(total_cases) as highestinfectionCount, Max((total_cases/population)) *100 as PercentPopulationInfected
from ProjectPortfolio..CovidDeaths
--where location like '%south%'
group by population, continent
order by PercentPopulationInfected desc

--showing countries with highest death count per population
select continent, location,Max(cast(total_deaths as Int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

--LETS BREAK IT DOWN BY CONTINENT

select continent, Max(cast(total_deaths as Int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

--showing continents with highest death count
select location,Max(cast(total_deaths as Int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount desc




--Global Numbers 
select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
--group by date
order by 1,2


--lokking at total population vs vaccinations
 --USE CTE
 with PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVccinated)
 as
 (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum( cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
 )
 select *, (RollingPeopleVccinated/population)*100
 from PopvsVac

 --TEMP TABLE

 DROP TABLE IF EXISTS  #PERCENTPOPULATIONVACCINATED
 CREATE TABLE #PERCENTPOPULATIONVACCINATED
 ( 
 CONTINENT NVARCHAR(255),
 LOCATION NVARCHAR(255),
 DATE DATETIME,
 POPULATION NUMERIC,
 NEW_VACCINATIONS NUMERIC,
 RollingPeopleVccinated NUMERIC
 )

  INSERT INTO #PERCENTPOPULATIONVACCINATED
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum( cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

 select *, (RollingPeopleVccinated/population)*100
 from #PERCENTPOPULATIONVACCINATED




 --CREAT VIEW TO STORE DATA FOR LATER VIZULIZATION

 CREATE VIEW PERCENTPOPULATIONVACCINATED AS
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum( cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PERCENTPOPULATIONVACCINATED