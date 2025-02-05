
---01
CREATE TABLE owners(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(50) NOT NULL ,
    phone_number VARCHAR(15) NOT NULL ,
    address VARCHAR(50)
);

CREATE TABLE animal_types(
    id SERIAL PRIMARY KEY ,
    animal_type VARCHAR(30) NOT NULL
);

CREATE TABLE cages(
    id SERIAL PRIMARY KEY ,
    animal_type_id INT REFERENCES animal_types
        ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE animals(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(30) NOT NULL ,
    birthdate DATE NOT NULL ,
    owner_id INT REFERENCES owners
        ON DELETE CASCADE ON UPDATE CASCADE ,
    animal_type_id INT REFERENCES animal_types
        ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE volunteers_departments(
    id  SERIAL PRIMARY KEY ,
    department_name VARCHAR(30) NOT NULL
);

CREATE TABLE volunteers(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(50) NOT NULL ,
    phone_number VARCHAR(15) NOT NULL ,
    address VARCHAR(50),
    animal_id INT REFERENCES animals
        ON DELETE CASCADE ON UPDATE CASCADE,
    department_id INT REFERENCES volunteers_departments
        ON DELETE CASCADE ON UPDATE CASCADE  NOT NULL


);

CREATE TABLE animals_cages(
    cage_id INT REFERENCES cages
        ON DELETE CASCADE ON UPDATE CASCADE NOT NULL ,
    animal_id INT REFERENCES animals
        ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

--02


INSERT INTO volunteers(name, phone_number, address, animal_id, department_id)
VALUES ('Anita Kostova', '0896365412	', 'Sofia, 5 Rosa str.', 15, 1),
       ('Dimitur Stoev', '0877564223', NULL, 42, 4),
       ('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7),
       ('Stoyan Tomov ', '0898564100', 'Montana, 1 Bor str.', 18, 8),
       ('Boryana Mileva', '0888112233', NULL, 31, 5)
;


INSERT INTO animals(name, birthdate, owner_id, animal_type_id)

VALUES ('Giraffe', '2018-09-21', 21, 1),
       ('Harpy Eagle', '2015-04-17', 15, 3),
       ('Hamadryas Baboon', '2017-11-02', NULL, 1),
       ('Tuatara', '2021-06-30', 2, 4)

;

--03



UPDATE animals
SET owner_id = (SELECT
            id
            FROM owners
        WHERE name = 'Kaloqn Stoqnov')
WHERE owner_id IS NULL ;

--04


DELETE FROM volunteers_departments
WHERE department_name = 'Education program assistant';

--05
SELECT
    name,
    phone_number,
    address,
    animal_id,
    department_id
FROM volunteers

ORDER BY name ASC, animal_id ASC ,department_id ASC;

--06
SELECT
    a.name,
    at.animal_type,
    TO_CHAR(a.birthdate,'DD.MM.YYYY' )
FROM animal_types AS at

JOIN animals AS a ON at.id = a.animal_type_id

ORDER BY a.name;

--07

SELECT
    o.name AS owner,
    count(*) count_of_animals
FROM owners AS o
    JOIN animals AS a ON o.id = a.owner_id
GROUP BY o.name
ORDER BY count_of_animals DESC ,
         o.name
LIMIT 5;

--8

SELECT
    concat_ws(' ',o.name,'-',a.name) AS "owners-animals",
    O.phone_number,
    ac.cage_id

FROM owners AS o
    JOIN animals AS a ON o.id = a.owner_id
        JOIN animals_cages AS ac ON a.id = ac.animal_id
            JOIN animal_types AS at ON a.animal_type_id = at.id


WHERE at.animal_type = 'Mammals'
ORDER BY O.name,
         a.name DESC ;
--09
SELECT
    v.name AS volunteers,
    v.phone_number,
    trim(v.address, 'Sofia, ') AS address
FROM volunteers AS v
    JOIN volunteers_departments AS vd ON v.department_id = vd.id
WHERE vd.department_name = 'Education program assistant' AND v.address LIKE '%Sofia%'


ORDER BY v.name;
--10

SELECT
    a.name AS animal,
    extract('YEAR' FROM a.birthdate ) AS birth_year,
    at.animal_type

FROM animals as a
JOIN animal_types AS at ON a.animal_type_id = at.id
WHERE at.animal_type <> 'Birds'
AND  AGE('01/01/2022',a.birthdate) < '5 YEAR' AND a.owner_id IS NULL
ORDER BY a.name;
--11
CREATE OR REPLACE FUNCTION fn_get_volunteers_count_from_department(
    searched_volunteers_department VARCHAR(30)
) RETURNS INT

AS
    $$
    DECLARE volunteers VARCHAR(30);
    BEGIN
        volunteers :=
            (SELECT
                count(*)
            FROM volunteers_departments AS vd
            JOIN volunteers AS v on vd.id = v.department_id
            WHERE VD.department_name = searched_volunteers_department);
        RETURN volunteers;
    END;

    $$
LANGUAGE plpgsql;

--12
CREATE OR REPLACE PROCEDURE sp_animals_with_owners_or_not(
     IN animal_name VARCHAR(30),
     OUT result VARCHAR(30)
)

AS
    $$
        BEGIN
            SELECT
                o.name
            FROM owners AS o
            JOIN animals AS a on o.id = a.owner_id
            WHERE a.name = animal_name  INTO result;
            IF result IS NULL THEN
                result:= 'For adoption';
            end if;

        END
    $$
LANGUAGE plpgsql;

-- OR

CREATE OR REPLACE PROCEDURE sp_animals_with_owners_or_not(
    IN animal_name VARCHAR(30),
    OUT result VARCHAR(30)
)
LANGUAGE plpgsql
AS
$$
BEGIN
    SELECT COALESCE(o.name, 'For adoption')
    INTO result
    FROM animals AS a
    LEFT JOIN owners AS o ON o.id = a.owner_id
    WHERE a.name = animal_name
    LIMIT 1; -- Ensures only one result is assigned
END;
$$;


CALL sp_animals_with_owners_or_not('Hippo','');