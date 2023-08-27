select *
from Project..CovidDeaths
where continent is not null
order by 3,4

--select *
--from Project..CovidVaccinations
--order by 3,4



select location, date, total_cases, new_cases, total_deaths, population
from Project..CovidDeaths
where continent is not null
order by 1,2

--Looking at the total cases vs total deaths
--shows the likelihood of dying if you are affected with covid in Canada.

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Project..CovidDeaths
where location like 'Canada' and continent is not null
order by 1,2


-- Looking at the total cases vs population.
-- shows what percentage of the population got covid in Canada.

select location, date, total_cases, population, (total_cases/population)*100 as PercentageofPeopleInfected
from Project..CovidDeaths
where location like 'Canada' and continent is not null
order by 1,2

-- Looking at the countries with highest infection rate compared to population.

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageofPeopleInfected
from Project..CovidDeaths
--where location like 'Canada'
where continent is not null
group by location,population
order by 4 desc


-- Looking at the countries with highest death count per population.

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Project..CovidDeaths
--where location like 'Canada'
where continent is not null
group by location
order by 2 desc


-- Looking at the continents with highest death count per population.

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Project..CovidDeaths
--where location like 'Canada'
where continent is null
group by location
order by 2 desc


-- Global numbers.

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Project..CovidDeaths
--where location like 'Canada' 
where continent is not null
--group by date
order by 1,2

-- Looking at total populations vs vaccinations.

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from project..CovidDeaths dea
join project..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date	
 where dea.continent is not null
 order by 2,3


 -- Using CTE

	 with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	 as
	 (
	 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
	from project..CovidDeaths dea
	join project..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date	
	 where dea.continent is not null
	 --order by 2,3
	 )
	 select *, (RollingPeopleVaccinated/Population)*100
	 from PopvsVac


-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated	
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
	from project..CovidDeaths dea
	join project..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date	
	 --where dea.continent is not null
	 --order by 2,3
	 
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations.
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
	from project..CovidDeaths dea
	join project..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date	
	 where dea.continent is not null
	 --order by 2,3
