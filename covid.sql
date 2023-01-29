select * FROM PortfolioProject_Covid..['covid deaths']
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject_Covid..['covid deaths'] order by 1,2

--Looking at total cases vs total deaths
-- shows likelihood of dying if you get covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject_Covid..['covid deaths']
where location like'%states%'
order by 1,2

-- the total cases vs the population
--shows what % of pop got covid
Select location, date, total_cases, population, (total_cases/population)*100 as casepercentage
From PortfolioProject_Covid..['covid deaths']
where location= 'united states'
order by 1,2

-- finding countries with highest infection rate
select location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/max(population))*100 as PercentPopInfected
from PortfolioProject_Covid..['covid deaths']
where population > 100000000
group by location, population
order by 4 desc

-- Highest death count per population
select location, max(cast(total_deaths as int)) as HighestdeathCount, (max(total_deaths)/max(population))*100 as PercentPopDead
from PortfolioProject_Covid..['covid deaths']
where continent is not null
group by location, population
order by 2 desc

-- Lets look at continent level
select continent, max(cast(total_deaths as int)) as HighestDeathCount, (max(total_deaths)/max(population))*100 as PercentPopDead
from PortfolioProject_Covid..['covid deaths']
where continent is not null
group by continent
order by 2 desc

-- Global numbers by date
Select date, sum(new_cases) as Totalcases, sum(cast(new_deaths as int)) as TotalDeaths , (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercent    --, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject_Covid..['covid deaths']
where new_cases is not null and new_cases > 0
group by date
order by 1


--Global SUM
Select sum(new_cases) as Totalcases, sum(cast(new_deaths as int)) as TotalDeaths , (sum(convert(int,new_deaths))/sum(new_cases))*100 as Deathpercent    --, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject_Covid..['covid deaths']


select * 
from PortfolioProject_Covid..['covid deaths'] death
join PortfolioProject_Covid..covidvaccine vaccine
on death.location = vaccine.location
and death.date = vaccine.date

--Looking at Total Pop Vs Vaccinations

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, sum(cast(vaccine.new_vaccinations as int)) OVER (partition by death.location order by death.location, death.date) as VaccinatedPeople
from PortfolioProject_Covid..['covid deaths'] death
join PortfolioProject_Covid..covidvaccine vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
order by 2,3


--USE CTE
WITH PopVsVac (Continent, location, date, population, newvaccines, rolling)
as
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, sum(cast(vaccine.new_vaccinations as bigint)) OVER (partition by death.location order by death.location, death.date) as VaccinatedPeople
from PortfolioProject_Covid..['covid deaths'] death
join PortfolioProject_Covid..covidvaccine vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by 2,3
)
select *, (rolling/population)*100 from PopVsVac
order by 2,3

--TEMP TABLE
drop table if exists #peoplevaccinated
create table #peoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinatedPeople numeric
)
insert into #peoplevaccinated
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, sum(cast(vaccine.new_vaccinations as int)) OVER (partition by death.location order by death.location, death.date) as VaccinatedPeople
from PortfolioProject_Covid..['covid deaths'] death
join PortfolioProject_Covid..covidvaccine vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
--where death.continent is not null
--order by 2,3

select *, (VaccinatedPeople/population)*100 from #peoplevaccinated

--Creating view for later visualizations

create view percentpeoplevaccinated1 as
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, sum(cast(vaccine.new_vaccinations as bigint)) OVER (partition by death.location order by death.location, death.date) as VaccinatedPeople
from PortfolioProject_Covid..['covid deaths'] death
join PortfolioProject_Covid..covidvaccine vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by 2,3

create view globalcases1 as
Select date, sum(new_cases) as Totalcases, sum(cast(new_deaths as int)) as TotalDeaths , (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercent    --, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject_Covid..['covid deaths']
where new_cases is not null and new_cases > 0
group by date
--order by 1

select * from percentpeoplevaccinated1
order by 2,3
