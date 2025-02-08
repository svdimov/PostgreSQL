--01
CREATE TABLE countries(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(40) NOT NULL UNIQUE ,
    continent VARCHAR(40) NOT NULL ,
    currency VARCHAR(5)

);

CREATE TABLE categories(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(50) NOT NULL UNIQUE

);

CREATE TABLE actors(
    id SERIAL PRIMARY KEY ,
    first_name VARCHAR(50) NOT NULL ,
    last_name VARCHAR(50) NOT NULL ,
    birthdate DATE NOT NULL,
    height INT ,
    awards INT DEFAULT 0 CHECK ( awards >= 0 ) NOT NULL ,
    country_id INT REFERENCES countries ON DELETE CASCADE
                   ON UPDATE CASCADE NOT NULL
);

CREATE TABLE productions_info(
    id SERIAL PRIMARY KEY ,
    rating DECIMAL(4,2) NOT NULL ,
    duration INT CHECK ( duration > 1 ) NOT NULL ,
    budget DECIMAL(10,2),
    release_date DATE NOT NULL ,
    has_subtitles BOOLEAN DEFAULT FALSE NOT NULL ,
    synopsis TEXT

);

CREATE TABLE productions(
    id SERIAL PRIMARY KEY ,
    title VARCHAR(70) NOT NULL UNIQUE,
    country_id INT REFERENCES countries ON UPDATE CASCADE
                        ON DELETE CASCADE NOT NULL ,
    production_info_id INT REFERENCES productions_info ON UPDATE CASCADE
                        ON DELETE CASCADE NOT NULL

);

CREATE TABLE productions_actors(
    production_id INT REFERENCES productions ON UPDATE CASCADE
                               ON DELETE CASCADE NOT NULL ,
    actor_id INT REFERENCES actors ON UPDATE CASCADE
                               ON DELETE CASCADE NOT NULL ,
    PRIMARY KEY (production_id, actor_id)

);

CREATE TABLE categories_productions(
    category_id INT REFERENCES categories ON UPDATE CASCADE
                                   ON DELETE CASCADE NOT NULL ,
    production_id INT REFERENCES productions ON UPDATE CASCADE
                                   ON DELETE CASCADE NOT NULL ,
    PRIMARY KEY (category_id, production_id)
);

--02
INSERT INTO actors(first_name, last_name, birthdate, height, awards,country_id)
SELECT
    REVERSE(first_name) AS first_name,
    REVERSE(last_name) as last_name,
    birthdate - INTERVAL '2 days' AS birthdate ,
    coalesce(height ,0) + 10  AS height,
     country_id as awards,
     (SELECT id FROM countries WHERE name = 'Armenia') AS country_id

FROM actors
WHERE id BETWEEN 10 AND 20;

--03

UPDATE productions_info
SET duration  = duration + CASE
                    WHEN id < 15 THEN  15
                    WHEN  id >= 20 THEN  20
                    ELSE 0
                END
WHERE synopsis IS NULL ;
;
--04

DELETE FROM countries
WHERE id NOT IN (
    SELECT DISTINCT country_id FROM actors
    UNION
    SELECT DISTINCT country_id FROM productions
);
--05


SELECT
    id,
    name,
    continent,
    currency
FROM countries
WHERE continent = 'South America' AND ( SUBSTRING(currency,1,1) = 'P' OR SUBSTRING(currency,1,1) = 'U' )
ORDER BY currency DESC,
         id;

-- 06
SELECT

    p.id,
    p.title,
    pi.duration,
    round(pi.budget, 1) AS budget,
    to_char(pi.release_date, 'MM-YY') as release_date
FROM productions AS p
         JOIN productions_info AS pi ON p.production_info_id = pi.id
WHERE pi.release_date BETWEEN '2023-01-01' AND '2024-12-31'
  AND pi.budget > 1500000.00
ORDER BY budget,
         pi.duration DESC,
         p.id
LIMIT 3
;



SELECT

    p.id,
    p.title,
    pi.duration,
    round(pi.budget, 1) AS budget,
    to_char(pi.release_date, 'MM-YY') as release_date
FROM productions AS p
         JOIN productions_info AS pi ON p.production_info_id = pi.id
WHERE EXTRACT(YEAR FROM pi.release_date) BETWEEN '2023' AND '2024'
  AND pi.budget > 1500000.00
ORDER BY budget,
         pi.duration DESC,
         p.id
LIMIT 3
;
--07


SELECT
    CONCAT_WS(' ',first_name,last_name) AS full_name,
    concat_ws('',lower(left(first_name,1)),
              lower(right(last_name,2)),
              length(last_name),
              '@sm-cast.com') as email,
    awards
FROM actors
    LEFT JOIN productions_actors AS pa on actors.id = pa.actor_id
where  pa.actor_id is null
ORDER BY awards DESC ,
         id
;
--08


SELECT
    c.name AS country_name,
    count(p.id) as productions_count,
    coalesce(avg(po.budget),0) asavg_budget

FROM countries AS c
JOIN productions as p on c.id = p.country_id
LEFT    JOIN productions_info as po on p.production_info_id = po.id
GROUP BY c.name
HAVING count(p.production_info_id) > 0
ORDER BY productions_count DESC ,
         country_name
;
--09
SELECT
    p.title as title,
    case
        when po.rating <= 3.5 then 'poor'
        when po.rating > 3.5 and po.rating <= 8.00 then 'good'
        else 'excellent'
    end as rating,

    CASE
        WHEN po.has_subtitles is true   THEN 'Bulgarian'
        ELSE 'N/A'
    END AS subtitles,
    count(pa.actor_id) as actors_count

from productions as p
    join productions_info as po on p.production_info_id = po.id
        join productions_actors as pa on p.id = pa.production_id
group by p.title, po.rating,po.has_subtitles
order by  rating,
          actors_count desc,
          title;

--10

drop function udf_category_productions_count;
create  or replace function udf_category_productions_count(
    category_name varchar(50)
) returns varchar
as

$$
  declare total_number int;
    begin
        total_number := (select
        count(cr.production_id)
        from categories as c
        join  categories_productions as cr on c.id = cr.category_id
        where c.name = category_name);

        return 'Found ' || total_number || ' productions.';
    end;

$$
language plpgsql;

SELECT udf_category_productions_count('History') ;

--11


CREATE PROCEDURE udp_awarded_production (
    production_title VARCHAR(70))
AS
$$
BEGIN
    UPDATE actors
    SET awards = awards + 1
    WHERE id IN (
    SELECT pa.actor_id
    FROM productions_actors as pa
    JOIN productions as p on pa.production_id = p.id
    WHERE p.title = production_title);
END;
$$
LANGUAGE plpgsql;
