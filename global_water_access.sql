
--Descriptive Analysis
--Total Population Analysis

SELECT
  name,
  SUM(pop_n) AS total_population
FROM global_water_access
GROUP BY name;

--Average Population Share with Basic Water Service per region

SELECT
  region,
  AVG(wat_bas_n) AS avg_national_basic_service,
  AVG(wat_bas_r) AS avg_rural_basic_service,
  AVG(wat_bas_u) AS avg_urban_basic_service
FROM global_water_access
GROUP BY region;

--Basic Water access in Sub_Saharan Africa

SELECT 
	  name,
       region,
      wat_bas_n AS Percentage_Basic_waterservice_availability
FROM 
    global_water_access
WHERE
     region= 'Sub-Saharan Africa'
ORDER BY 
       wat_bas_n ASC


--  Trend Analysis
-- Trend of Basic Water Service Over Years per region
SELECT
  year,
  region,
  AVG(wat_bas_n) AS avg_national_basic_service,
  AVG(wat_bas_r) AS avg_rural_basic_service,
  AVG(wat_bas_u) AS avg_urban_basic_service
FROM global_water_access
GROUP BY year, region
ORDER BY year;


--Regional Comparison
-- Compare Water Access Between Regions

SELECT
  region,
  AVG(wat_bas_n) AS avg_national_basic_service,
  AVG(wat_lim_n) AS avg_national_limited_service,
  AVG(wat_unimp_n) AS avg_national_unimproved_service,
  AVG(wat_sur_n) AS avg_national_surface_service
FROM global_water_access
GROUP BY region;

--Urban vs Rural Analysis
--Difference in Water Access Between Urban and Rural Areas

SELECT
  name,
  year,
  (wat_bas_u - wat_bas_r) AS basic_service_difference,
  (wat_lim_u - wat_lim_r) AS limited_service_difference,
  (wat_unimp_u - wat_unimp_r) AS unimproved_service_difference,
  (wat_sur_u - wat_sur_r) AS surface_service_difference
FROM global_water_access

--Top/Bottom Analysis
-- Highest

SELECT
  name,
  year,
  wat_bas_n
FROM global_water_access
ORDER BY wat_bas_n DESC
LIMIT 10;

-- Lowest
SELECT
  name,
  year,
  wat_bas_n
FROM global_water_access
WHERE wat_bas_n != 'NULL'
ORDER BY wat_bas_n ASC
LIMIT 10;



--Correlation Analysis
--Correlation Between Urban and Rural Basic Water Service

SELECT 
  (SUM((wat_bas_u - avg_wat_bas_u) * (wat_bas_r - avg_wat_bas_r)) / 
   (SQRT(SUM((wat_bas_u - avg_wat_bas_u) * (wat_bas_u - avg_wat_bas_u))) * 
    SQRT(SUM((wat_bas_r - avg_wat_bas_r) * (wat_bas_r - avg_wat_bas_r))))) AS correlation_basic_service
FROM 
  (SELECT 
     wat_bas_u, 
     wat_bas_r, 
     (SELECT AVG(wat_bas_u) FROM global_water_access) AS avg_wat_bas_u, 
     (SELECT AVG(wat_bas_r) FROM global_water_access) AS avg_wat_bas_r
   FROM 
     global_water_access) AS subquery;


--Temporal Changes
--Change in Basic Water Service Over Time for a Specific Country

SELECT
  name,
  year,
  region,
  wat_bas_n
FROM global_water_access
WHERE   region = 'Sub-Saharan Africa'
ORDER BY year;


--Subqueries and CTEs for Advanced Analysis
--Countries with Increasing Access to Basic Water Service Over Time

WITH YearlyIncrease AS (
  SELECT
    name,
    year,
    wat_bas_n,
    LAG(wat_bas_n) OVER (PARTITION BY name ORDER BY year) AS prev_year_service
  FROM global_water_access
)
SELECT
  name,
  year,
  wat_bas_n,
  prev_year_service,
  (wat_bas_n - prev_year_service) AS service_increase
FROM YearlyIncrease
WHERE (wat_bas_n - prev_year_service) > 0
ORDER BY name, year;


--Country-Specific Analysis
--Detailed Water Access Breakdown for specific Countries

SELECT
  year,
  name,
  pop_n,
  wat_bas_n,
  wat_lim_n,
  wat_unimp_n,
  wat_sur_n,
  wat_bas_r,
  wat_lim_r,
  wat_unimp_r,
  wat_sur_r,
  wat_bas_u,
  wat_lim_u,
  wat_unimp_u,
  wat_sur_u
FROM global_water_access
WHERE name IN ('INDIA','CHINA')
ORDER BY year;

--Percent Change Over Time
--Percentage Change in Basic Water Service Over Time
-- Top 30 countries globally in increase of basic water services

WITH PercentChange AS (
  SELECT
    name,
    year,
    wat_bas_n,
    LAG(wat_bas_n) OVER (PARTITION BY name ORDER BY year) AS prev_year_service
  FROM global_water_access
)
SELECT
  name,
  year,
  wat_bas_n,
  prev_year_service,
  ((wat_bas_n - prev_year_service) / prev_year_service) * 100 AS percent_change
FROM 
    PercentChange
WHERE 
    prev_year_service IS NOT NULL
AND 
((wat_bas_n - prev_year_service) / prev_year_service) != 0
ORDER BY 
       percent_change DESC
LIMIT 30

--Regional Performance Over Time
--Tracking Performance of Regions Over Time

SELECT
  region,
  year,
  AVG(wat_bas_n) AS avg_national_basic_service,
  AVG(wat_lim_n) AS avg_national_limited_service,
  AVG(wat_unimp_n) AS avg_national_unimproved_service,
  AVG(wat_sur_n) AS avg_national_surface_service
FROM global_water_access
GROUP BY region, year
ORDER BY region, year;


--Highest/Lowest Increase in Water Service
--Countries with the Highest Increase in Basic Water Service

WITH YearlyIncrease AS (
  SELECT
    name,
    year,
    wat_bas_n,
    LAG(wat_bas_n) OVER (PARTITION BY name ORDER BY year) AS prev_year_service
  FROM global_water_access
)
SELECT
  name,
  year,
  (wat_bas_n - prev_year_service) AS service_increase
FROM YearlyIncrease
WHERE prev_year_service IS NOT NULL
ORDER BY service_increase DESC
LIMIT 10;

--Disparity Analysis
--Disparity Between Urban and Rural Water Access

SELECT
  name,
  year,
  ABS(wat_bas_u - wat_bas_r) AS disparity_basic_service,
  ABS(wat_lim_u - wat_lim_r) AS disparity_limited_service,
  ABS(wat_unimp_u - wat_unimp_r) AS disparity_unimproved_service,
  ABS(wat_sur_u - wat_sur_r) AS disparity_surface_service
FROM global_water_access
ORDER BY disparity_basic_service DESC;

--Water Access Categories by Region
--Categorize Regions Based on Water Access Levels

SELECT
  region,
  CASE
    WHEN AVG(wat_bas_n) >= 80 THEN 'High Access'
    WHEN AVG(wat_bas_n) BETWEEN 50 AND 79 THEN 'Moderate Access'
    ELSE 'Low Access'
  END AS access_category
FROM global_water_access
GROUP BY region;

--Water Access Improvement Rates
--Annual Improvement Rates for Basic Water Service

WITH AnnualImprovement AS (
  SELECT
    name,
    year,
    wat_bas_n,
    LAG(wat_bas_n) OVER (PARTITION BY name ORDER BY year) AS prev_year_service
  FROM global_water_access
)
SELECT
  name,
  year,
  ((wat_bas_n - prev_year_service) / prev_year_service) * 100 AS annual_improvement_rate
FROM AnnualImprovement
WHERE prev_year_service IS NOT NULL
ORDER BY annual_improvement_rate DESC;

--Advanced Join Analysis
--Combining Data from Multiple Years

SELECT
  a.name,
  a.year AS year_2015,
  b.year AS year_2020,
  a.wat_bas_n AS basic_service_2015,
  b.wat_bas_n AS basic_service_2020,
  (b.wat_bas_n - a.wat_bas_n) AS increase_in_basic_service
FROM global_water_access a
JOIN global_water_access b
  ON a.name = b.name
  AND a.year = 2015
  AND b.year = 2020
ORDER BY increase_in_basic_service DESC;
