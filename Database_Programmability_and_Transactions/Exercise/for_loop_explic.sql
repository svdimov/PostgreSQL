DO
$$
    DECLARE
        i INT;
    BEGIN
        FOR i IN 1..5
            LOOP
                RAISE NOTICE 'Value of i: %', i;
            END LOOP;
    END
$$;



CREATE TABLE my_test_seroal
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50)
);



INSERT INTO my_test_seroal(name)
values ('STEFAN'),
       ('  GOSHO'),
       ('IVAN')
;

INSERT INTO my_test_seroal(id, name)
values (6, 'DOKO');


SELECT *
FROM my_test_seroal;