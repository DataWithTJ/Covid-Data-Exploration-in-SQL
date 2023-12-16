-- 1
-- GLOBAL NUMBERS

select sum(new_cases) as total_new_cases, sum(new_deaths) as total_new_deaths, 
sum(cast(new_deaths as numeric))/sum(new_cases)*100 as death_percentage
from coviddeaths
--Where location like '%Kingdom%'
where continent is not null 
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

select *
from coviddeaths
where location = 'World';

select sum(new_cases) as total_new_cases, sum(new_deaths) as total_new_deaths, 
sum(cast(new_deaths as numeric))/sum(new_cases)*100 as death_percentage
from coviddeaths
where location = 'World' 
order by 1,2;



-- 2
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

select location, sum(cast(new_deaths as int)) as total_new_deaths
from coviddeaths
where continent is null 
and location not in ('World', 'European Union', 'International')
group by location
order by total_new_deaths desc



-- 3
select location, population, max(total_cases) as highest_infection_count,  max((total_cases/population))*100 as percent_population_infected
from coviddeaths 
group by location, population
order by percent_population_infected desc



-- 4
select location, population, date, max(total_cases) as highest_infection_count,  max((total_cases/population))*100 as percent_population_infected
from coviddeaths 
group by location, population, date
order by percent_population_infected desc nulls last

