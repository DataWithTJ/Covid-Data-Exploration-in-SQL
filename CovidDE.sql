create table coviddeaths (
    iso_code varchar(20),
    continent varchar(50),
    location varchar(50),
    date date,
	population numeric(50),
    total_cases integer,
    new_cases integer,
    new_cases_smoothed float,
    total_deaths integer,
    new_deaths integer,
    new_deaths_smoothed float,
    total_cases_per_million float,
    new_cases_per_million float,
    new_cases_smoothed_per_million float,
    total_deaths_per_million float,
    new_deaths_per_million float,
    new_deaths_smoothed_per_million float,
    reproduction_rate float,
    icu_patients integer,
    icu_patients_per_million float,
    hosp_patients integer,
    hosp_patients_per_million float,
    weekly_icu_admissions float,
    weekly_icu_admissions_per_million float,
    weekly_hosp_admissions float,
    weekly_hosp_admissions_per_million float
);

set DateStyle = 'DMY';
copy coviddeaths 
from '/Applications/PostgreSQL 16/Documentation/SQL FIles/CovidDeaths.csv' 
delimiter ',' csv header


select * 
from coviddeaths
where continent is not null
order by 3,4;

create table covidvaccinations (
    iso_code varchar(20),
    continent varchar(50),
    location varchar(50),
    date date,
    new_tests integer,
    total_tests integer,
    total_tests_per_thousand float,
    new_tests_per_thousand float,
    new_tests_smoothed integer,
    new_tests_smoothed_per_thousand float,
    positive_rate float,
    tests_per_case float,
    tests_units varchar(50),
    total_vaccinations integer,
    people_vaccinated integer,
    people_fully_vaccinated integer,
    new_vaccinations integer,
    new_vaccinations_smoothed integer,
    total_vaccinations_per_hundred float,
    people_vaccinated_per_hundred float,
    people_fully_vaccinated_per_hundred float,
    new_vaccinations_smoothed_per_million integer,
    stringency_index float,
    population_density float,
    median_age float,
    aged_65_older float,
    aged_70_older float,
    gdp_per_capita float,
    extreme_poverty float,
    cardiovasc_death_rate float,
    diabetes_prevalence float,
    female_smokers float,
    male_smokers float,
    handwashing_facilities float,
    hospital_beds_per_thousand float,
    life_expectancy float,
    human_development_index float
);

set DateStyle = 'DMY';
copy covidvaccinations 
from '/Applications/PostgreSQL 16/Documentation/SQL FIles/CovidVaccinations.csv' 
delimiter ',' csv header

select * 
from covidvaccinations


-- Selecting data to be used 
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;



-- Looking at the Total Cases vs Total Deaths
-- Shows likelyhood of dying if covid is contacted 
select location, date, total_cases, total_deaths, 
(cast(total_deaths as numeric)/total_cases)*100 as death_percentage 
from coviddeaths
order by 1,2;
-- Checking the Death Percentage for UK 
select location, date, total_cases, total_deaths, 
(cast(total_deaths as numeric)/total_cases)*100 as death_percentage 
from coviddeaths
where location like '%Kingdom%'
order by 1,2;



-- Looking at the Total Cases vs Poulation
-- Shows what % of the population got covid
select location, date, population, total_cases,  
(total_cases/population)*100 as infected_percentage 
from coviddeaths
-- where location like '%Kingdom%'
order by 1,2;

-- Breaking infected percentage down by continent 
select location, sum(population) as total_population, sum(total_cases) as total_cases,  
(sum(total_cases)/sum(population))*100 as infected_percentage 
from coviddeaths
where continent is null
and total_cases is not null
and population is not null
group by location
order by infected_percentage desc;


-- Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_cases,  
max((total_cases/population))*100 as infected_percentage 
from coviddeaths
-- where location like '%Kingdom%'
group by location, population
order by infected_percentage desc;

-- Showing countries with highest death count
select location, max(total_deaths) as highest_deaths  
from coviddeaths
-- where location like '%Kingdom%'
where continent is not null
and total_deaths is not null
group by location
order by highest_deaths desc;

-- Breaking it down by continent 
-- Showing contintents with the highest death count 
select location, max(total_deaths) as highest_deaths  
from coviddeaths
-- where location like '%Kingdom%'
where continent is null
and total_deaths is not null
group by location 
order by highest_deaths desc;

select continent, max(total_deaths) as highest_deaths  
from coviddeaths
-- where location like '%Kingdom%'
where continent is not null
and total_deaths is not null
group by continent 
order by highest_deaths desc;



-- GLOBAL NUMBERS

select sum(new_cases) as total_new_cases, sum(new_deaths) as total_new_deaths, 
sum(cast(new_deaths as numeric))/sum(new_cases)*100 as death_percentage
from coviddeaths
--Where location like '%Kingdom%'
where continent is not null 
order by 1,2


select date, sum(new_cases) as total_new_cases, sum(new_deaths) as total_new_deaths, 
round(sum(cast(new_deaths as numeric))/sum(new_cases)*100, 2) as death_percentage
from coviddeaths
--Where location like '%Kingddom%'
where continent is not null
and new_cases is not null
and new_deaths is not null
group by date
order by 1,2


select *
from covidvaccinations;

select * 
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date;


--- Looking at Total Population vs Vaccination 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rollingpplvaccinated
-- (rollingpplvaccinated/population*100)
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
with popvsvac (continent, location, date, population, new_vaccinations, rollingpplvaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rollingpplvaccinated
-- (rollingpplvaccinated/population*100)
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3;
)
select *, (rollingpplvaccinated/population)*100 as rpvpercentage
from popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists percentpopvaccinated;

create table percentpopvaccinated
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
rollingpplvaccinated numeric
);

insert into percentpopvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rollingpplvaccinated
-- (rollingpplvaccinated/population*100)
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

select *, (rollingpplvaccinated/population)*100 as rpvpercentage
from percentpopvaccinated;



-- Creating View to store data for later visualizations
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpplvaccinated
--, (rollingpplvaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3