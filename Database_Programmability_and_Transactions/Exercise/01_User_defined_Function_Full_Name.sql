CREATE OR REPLACE FUNCTION fn_full_name(
    first_name VARCHAR(50),
    last_name VARCHAR(50)
) RETURNS VARCHAR(101)
AS

$$
    BEGIN
        RETURN INITCAP(LOWER(first_name)) || ' ' || initcap(lower(last_name));

    END
$$
LANGUAGE plpgsql;


--SOLUTION 2

CREATE OR REPLACE FUNCTION fn_full_name_2(
    first_name VARCHAR(50),
    last_name VARCHAR(50)
) RETURNS VARCHAR(101)
AS

$$  DECLARE  full_name varchar(101);
    BEGIN
        full_name := (concat_ws(' ', initcap(lower(first_name)),initcap(lower(last_name))));
        RETURN full_name;

    END
$$
LANGUAGE plpgsql;


SELECT *
FROM fn_full_name_2('JOHN', '');