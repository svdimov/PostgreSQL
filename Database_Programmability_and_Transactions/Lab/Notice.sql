--sofuni_db
CREATE OR REPLACE FUNCTION fn_get_initials(first_name varchar,last_name varchar)
RETURNS VARCHAR(5) AS
$$

    BEGIN
        RETURN concat(left(first_name,1),'.',left(last_name,1),'.');
    END

$$
LANGUAGE plpgsql;

select fn_get_initials('Boko','Choko');

-- function with if - else statement - sofuni_db
CREATE OR REPLACE FUNCTION fun_get_full_name(first_name varchar,last_name varchar)
RETURNS VARCHAR AS
$$
    DECLARE
        full_name VARCHAR;
--         full_name VARCHAR := 'No name';
    BEGIN
        IF first_name IS NULL  AND last_name IS NULL THEN
            full_name := NULL;
--             full_name := 'No name';
        ELSIF first_name IS NULL THEN
            full_name:=last_name;
        ELSIF last_name IS NULL THEN
            full_name := first_name;
        ELSE
            full_name := CONCAT_WS(' ',first_name,last_name);
        END IF;
        RETURN full_name;
    END
$$

LANGUAGE plpgsql;
CREATE TABLE countries(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    countries_name VARCHAR(20)
);

SELECT
  fun_get_full_name(first_name,last_name)
FROM employees;

-- FUNCTIONS WITH EXCEPTION -- geography_db
 CREATE OR REPLACE FUNCTION fn_add_country(c_name varchar)
RETURNS  bool AS

$$
    BEGIN
        INSERT INTO countries (countries_name)
        VALUES (c_name);
        RETURN TRUE;
        EXCEPTION
            WHEN UNIQUE_VIOLATION THEN RETURN FALSE;
    END
$$


LANGUAGE plpgsql;


SELECT fn_add_country('Albania');
SELECT fn_add_country('Bulgaria');
SELECT fn_add_country('Germany');


-- STORED PROCEDURES
CREATE OR REPLACE FUNCTION fn_full_name(
    first_name varchar(50),
    last_name varchar(50)
) returns varchar(101)
AS
$$
    BEGIN
        RETURN INITCAP(LOWER(first_name)) || ' ' || INITCAP(LOWER(last_name));
    END;
$$
LANGUAGE plpgsql;


SELECT fn_full_name(first_name,last_name) FROM employees;


