CREATE TABLE addresses
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE categories
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(10) NOT NULL
);

CREATE TABLE clients
(
    id           SERIAL PRIMARY KEY,
    full_name    VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL

);

CREATE TABLE drivers
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name   VARCHAR(30) NOT NULL,
    age        INT         NOT NULL CHECK ( age > 0 ),
    rating NUMERIC(3,2) DEFAULT 5.5
);

CREATE TABLE cars(
    id SERIAL PRIMARY KEY ,
    make VARCHAR(20) NOT NULL ,
    model VARCHAR(20),
    year INT DEFAULT 1 CHECK ( year > 0 ) NOT NULL ,
    mileage INT DEFAULT 1 CHECK ( mileage > 0 ),
    condition CHAR(1) NOT NULL ,
    category_id INT REFERENCES categories
        ON DELETE CASCADE ON UPDATE CASCADE NOT NULL

);
CREATE TABLE courses(
    id SERIAL PRIMARY KEY ,
    from_address_id INT REFERENCES addresses
        ON  DELETE CASCADE ON UPDATE CASCADE NOT NULL ,
    start TIMESTAMP NOT NULL ,
    bill NUMERIC(10,2) DEFAULT 10 CHECK ( bill > 0),
    car_id INT REFERENCES cars ON DELETE CASCADE
                    ON UPDATE CASCADE NOT NULL ,
    client_id INT REFERENCES clients ON UPDATE CASCADE
                    ON DELETE CASCADE NOT NULL
);


CREATE TABLE cars_drivers(
    car_id INT REFERENCES cars ON DELETE CASCADE
                         ON UPDATE CASCADE NOT NULL ,
    driver_id INT REFERENCES drivers ON DELETE CASCADE
                         ON UPDATE CASCADE NOT NULL
);

--02
INSERT INTO
    clients(full_name, phone_number)
SELECT
    concat_ws(' ',first_name,last_name) AS full_name,
    '(088) 9999' ||  id * 2 as phone_number
FROM drivers
WHERE id between 10 and 20
;

--03
UPDATE cars
SET condition = 'C'
WHERE (mileage >= 800000 OR mileage IS NULL)
                AND
    year <= 2010  AND make <> 'Mercedes-Benz';

--04
DELETE FROM clients

WHERE LENGTH(full_name) > 3
AND  id  NOT IN (SELECT
    client_id
FROM courses) ;


--05
SELECT
    make,
    model,
    condition
FROM cars
ORDER BY id;

--06
SELECT
    d.first_name,
    d.last_name,
    c.make,
    c.model,
    c.mileage
FROM cars AS c
JOIN cars_drivers AS cd ON c.id = cd.car_id
JOIN drivers  AS d ON cd.driver_id = d.id
WHERE c.mileage IS NOT NULL
ORDER BY c.mileage DESC ,
         d.first_name
;

--07


SELECT
    c.id AS car_id,
    c.make,
    c.mileage,
    count(co.id) AS count_of_courses,
    ROUND(avg(co.bill),2)  AS average_bill

FROM courses AS co
RIGHT  JOIN cars AS c ON co.car_id = c.id
GROUP BY c.id, c.make, c.mileage
HAVING count(co.id) <> 2
ORDER BY count_of_courses DESC ,
         car_id

--08



SELECT
    cl.full_name,
    count(co.car_id) as count_of_cars,
    sum(co.bill)  AS total_sum
FROM clients AS cl
    JOIN courses AS co ON cl.id = co.client_id
WHERE SUBSTRING(full_name,2,1) = 'a'
GROUP BY cl.full_name
HAVING count(co.car_id) > 1
ORDER BY cl.full_name
;

--09


SELECT
    a.name AS address,
    CASE
        WHEN extract(HOUR FROM cou.start) between 6 and 20 THEN 'Day'
        ELSE 'Night'
    END AS day_time,
    cou.bill,
    cl.full_name,
    c.make,
    c.model,
    cat.name AS category_name

FROM courses AS cou
    JOIN addresses AS a ON cou.from_address_id = a.id
        JOIN clients AS cl ON cou.client_id = cl.id
            JOIN cars AS c ON cou.car_id = c.id
                JOIN categories as cat On c.category_id = cat.id
ORDER BY cou.id
;

--10
CREATE OR REPLACE FUNCTION fn_courses_by_client(
    phone_num VARCHAR(20)
) RETURNS INT
AS

    $$  DECLARE num_courses INT;
        BEGIN
            num_courses := (SELECT
            count(*)
        FROM clients AS c
        JOIN courses  AS cou ON c.id = cou.client_id
        WHERE c.phone_number = phone_num);

        RETURN num_courses;

        END;
    $$
LANGUAGE plpgsql;

--11

CREATE TABLE search_results(
    id SERIAL PRIMARY KEY ,
    address_name VARCHAR(50),
    full_name VARCHAR(100),
    level_of_bill VARCHAR(20),
    make VARCHAR(30),
    condition CHAR(1),
    category_name VARCHAR(50)
);


CREATE PROCEDURE sp_courses_by_address(
    address_name VARCHAR(100)
)

AS

    $$
        BEGIN
            TRUNCATE  search_results;
            INSERT INTO search_results
                (address_name, full_name, level_of_bill, make, condition, category_name)
            SELECT
                a.name AS address_name,
                cl.full_name,
            CASE
                WHEN cou.bill <= 20 THEN 'Low'
                WHEN  cou.bill <= 30 THEN 'Medium'
                ELSE 'High'
            END AS level_of_bill,
                c.make,
                c.condition,
                cat.name AS category_name

            FROM addresses AS a
                JOIN courses AS cou ON a.id = cou.from_address_id
                    JOIN cars  AS c ON cou.car_id = c.id
                        JOIN categories AS cat ON c.category_id = cat.id
                            JOIN clients AS cl ON cou.client_id = cl.id
            WHERE a.name = address_name
            ORDER BY c.make,
                    cl.full_name;
        END;
    $$

LANGUAGE plpgsql;

CALL sp_courses_by_address('66 Thompson Drive') ;
SELECT * FROM search_results;


