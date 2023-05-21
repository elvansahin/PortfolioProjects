

Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4 

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4 

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths 

Select Location, date, total_cases, total_deaths
From PortfolioProject..CovidDeaths
Where Location like '%turkey%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Percentage
From PortfolioProject..CovidDeaths
--Where Location like '%turkey%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%turkey%'
group by Location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

Select Location, MaX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%turkey%'
where continent is not null
group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%turkey%'
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is null 
order by 1,2

--Looking at Total population and vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
 dea.Date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3



  With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
  as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
 dea.Date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
 dea.Date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  
Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store for later 
Drop view if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
 dea.Date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3