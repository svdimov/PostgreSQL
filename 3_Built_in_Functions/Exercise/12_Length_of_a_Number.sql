SELECT
    countries.population,
    length(CAST(population AS VARCHAR)) AS "length"
FROM countries;