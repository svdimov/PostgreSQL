create table test_employees(
    id serial primary key ,
    first_name VARCHAR(20),
    last_name VARCHAR(20)

);


INSERT INTO test_employees(FIRST_NAME, LAST_NAME)
VALUES ('Stefan','Dimov'),
       ('Ivan','Ivanov'),
       ('Mimi','Ivanova')

;

SELECT *
FROM test_employees;