select location, date, total_cases, new_cases,  total_deaths,population
from covidDeaths$
order by 1,2


--looking at the total cases vs the total deaths

select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from covidDeaths$

where location like '%egy%'
order by 1,2


-- looking at the total cases vs the population 


select location, date, total_cases,  population,(total_cases/population)*100 as casesPercentage
from covidDeaths$

where location like '%egy%'
order by 1,2


-- countries with hieghest infection rate compared to population


select location, population, MAX(total_cases) as highestInfectionCount,  max((total_cases/population))*100 as percentPopulationInfected
from covidDeaths$

--where location like '%egy%'
group by location , population
order by percentPopulationInfected desc


-- looking at counties with hieghest death rate per population


select location, population, MAX(total_deaths) as highestDeathCount,  max((total_deaths/population))*100 as percentPopulationDeaths
from covidDeaths$

--where location like '%egy%'
group by location , population
order by percentPopulationDeaths desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


select *
from covidDeaths$
where continent is not null
order by 3,4
	

select continent, max(cast(total_deaths as int)) as highestDeathCount
from covidDeaths$

--where location like '%egy%'
where continent is not null
group by continent
order by highestDeathCount desc





-- GLOBAL NUMBERS

select date, sum(new_cases)as sumNewCases, sum(new_deaths)as sumNewDeaths, sum(new_deaths)/ sum(new_cases)*100 as deathPercentage
from covidDeaths$
where continent is not null 
and new_cases > 0
group by date 
order by 1,2




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select death.continent, death.location, death.date, death.population,
       vac.new_vaccinations,
       sum(cast(vac.new_vaccinations as float)) over (partition by death.location order by death.location , death.date) as RollingPeopleVacc

from covidDeaths$ as death
join covidVacination$ as vac
on death.date = vac.date and death.location = vac.location
where death.continent is not null
order by 2,3





-- Using CTE to perform Calculation on Partition By in previous query

with PopVsVac(continent,location,date,population,new_vaccinations, RollingPeopleVacc)
as

(
select death.continent, death.location, death.date, death.population,
       vac.new_vaccinations,

       sum(cast(vac.new_vaccinations as float)) over (partition by death.location order by death.location , death.date) as RollingPeopleVacc

from covidDeaths$ as death
join covidVacination$ as vac
on death.date = vac.date and death.location = vac.location
where death.continent is not null

)

select * , RollingPeopleVacc/population *100 as total_vac
from PopVsVac
order by 1,2


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated(
continent nvarchar(225),
location nvarchar(225),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric )

insert into #PercentPopulationVaccinated

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidDeaths$ death
Join covidVacination$ vac
	On death.location = vac.location
	and death.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated







-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidDeaths$ death
Join covidVacination$ vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 












