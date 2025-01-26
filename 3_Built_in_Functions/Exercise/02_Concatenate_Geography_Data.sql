CREATE VIEW view_continents_countries_currencies_details
AS
SELECT
    concat_ws(': ',con.continent_name,con.continent_code) AS continent_details,
    concat_ws(' - ',coun.country_name,coun.capital,coun.area_in_sq_km,'km2') AS country_information,
    concat(curr.description, ' (',curr.currency_code,')') AS currencies
FROM continents AS con,
     countries AS  coun,
     currencies AS curr
WHERE
    con.continent_code = coun.continent_code
                AND
    coun.currency_code = curr.currency_code

ORDER BY
    country_information,
         currencies;
