SELECT
    min(averege)
FROM
    (
SELECT
    avg(area_in_sq_km) AS averege
FROM countries
GROUP BY continent_code) AS averege_area