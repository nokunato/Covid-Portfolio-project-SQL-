
select * 
from [Covid Portfolio project]..[Covid Deaths]
where continent is not null
order by 3,4

--select * 
--from [Covid Portfolio project]..[Covid Vaccinations]
--order by 3,4

--select data that we would be using

select location, date, total_cases, new_cases, total_deaths, population
from [Covid Portfolio project]..[Covid Deaths]
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths and percentage

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent
from [Covid Portfolio project]..[Covid Deaths]
--where location like '%nigeria%'
where continent is not null
order by 1,2

--looking at total cases vs population
--percent of covic cases to population
select location, date, total_cases, population, (total_cases/population)*100 as casepercent
from [Covid Portfolio project]..[Covid Deaths]
--where location like '%nigeria%'
where continent is not null
order by 1,2

--countries with the highest infection rate compared to population
select location, max(total_cases) as InfectionCount, population, max((total_cases/population))*100 as 
percentpopulationinfected
from [Covid Portfolio project]..[Covid Deaths]
--where location like '%nigeria%'
where continent is not null
group by location, population
order by 4 desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as DeathCount, population, max((total_deaths/population))*100 as 
percentpopulationdeath
from [Covid Portfolio project]..[Covid Deaths]
--where location like '%nigeria%'
where continent is not null
group by location, population
order by 4 desc


--Break things down by continent
select location, max(cast(total_deaths as int)) as DeathCount
from [Covid Portfolio project]..[Covid Deaths]
--where location like '%nigeria%'
where continent is null
group by location
order by DeathCount desc


-- continent with the highest death count per population
select continent, max(cast(total_deaths as int)) as DeathCount
from [Covid Portfolio project]..[Covid Deaths]
--where location like '%nigeria%'
where continent is not null
group by continent
order by DeathCount desc



--global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercent
from [Covid Portfolio project]..[Covid Deaths]
where continent is not null
group by date
order by 1,2

--without dates

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercent
from [Covid Portfolio project]..[Covid Deaths]
where continent is not null
--group by date
order by 1,2

--joining two tables

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccination
from [Covid Portfolio project]..[Covid Deaths] dea
join [Covid Portfolio project]..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, CummulativeVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum (cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccination
from [Covid Portfolio project]..[Covid Deaths] dea
join [Covid Portfolio project]..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (CummulativeVaccination/population)*100
from PopvsVac


-- TEMP table 

--Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
CummulativeVaccination numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum (cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccination
from [Covid Portfolio project]..[Covid Deaths] dea
join [Covid Portfolio project]..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (CummulativeVaccination/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum (cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccination
from [Covid Portfolio project]..[Covid Deaths] dea
join [Covid Portfolio project]..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated