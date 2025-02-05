
CREATE OR REPLACE FUNCTION fn_count_employees_by_town(town_name VARCHAR(20)
)
RETURNS INT
AS

$$
    DECLARE e_count INT;
    BEGIN
        e_count := (SELECT
                count(t.name)
                FROM employees AS e
                JOIN addresses AS a
                USING (address_id)
                JOIN towns AS t
                USING (town_id)
                WHERE t.name = town_name);
        RETURN e_count;
    END
$$
LANGUAGE plpgsql;

