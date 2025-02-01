UPDATE countries
SET country_name = replace(country_name,'Myanmar','Burma')
;

INSERT INTO monasteries(monastery_name, country_code)
VALUES ('Hanga Abbey',(SELECT
                           country_code
                       FROM countries
                       WHERE country_name = 'Tanzania')),
    ('Myin-Tin-Daik',
     (SELECT
          country_code
      FROM countries
      WHERE country_name = 'Myanmar'))
;


SELECT
    c.continent_name,
    cou.country_name,
    count(m.country_code) AS monasteries_count
FROM continents AS c
JOIN countries AS cou
USING (continent_code)
LEFT JOIN monasteries AS m
USING (country_code)
WHERE NOT cou.three_rivers
GROUP BY c.continent_name, cou.country_name

ORDER BY monasteries_count DESC ,
         cou.country_name;