--01
CREATE TABLE categories
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE addresses
(
    id            SERIAL PRIMARY KEY,
    street_name   VARCHAR(100) NOT NULL,
    street_number INT          NOT NULL CHECK ( street_number > 0 ),
    town          VARCHAR(30)  NOT NULL,
    country       VARCHAR(50)  NOT NULL,
    zip_code      INT          NOT NULL CHECK ( zip_code > 0 )
);

CREATE TABLE publishers
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(30) NOT NULL,
    address_id INT REFERENCES addresses ON UPDATE CASCADE
        ON DELETE CASCADE  NOT NULL,
    website    VARCHAR(40),
    phone      VARCHAR(20)
);

CREATE TABLE players_ranges
(
    id          SERIAL PRIMARY KEY,
    min_players INT NOT NULL CHECK ( min_players > 0 ),
    max_players  INT NOT NULL CHECK ( max_players > 0 )
);

CREATE TABLE creators
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL  ,
    last_name  VARCHAR(30) NOT NULL  ,
    email      VARCHAR(30) NOT NULL
);


CREATE TABLE board_games
(
    id               SERIAL PRIMARY KEY,
    name             VARCHAR(30) NOT NULL,
    release_year     INT         NOT NULL CHECK ( release_year > 0 ),
    rating           NUMERIC(10, 2) NOT NULL ,
    category_id      INT REFERENCES categories ON DELETE CASCADE
        ON UPDATE CASCADE        NOT NULL,
    publisher_id     INT REFERENCES publishers ON DELETE CASCADE
        ON UPDATE CASCADE NOT NULL ,
    players_range_id INT REFERENCES players_ranges ON DELETE CASCADE
        ON UPDATE CASCADE        NOT NULL
);

CREATE TABLE creators_board_games
(
    creator_id    INT REFERENCES creators ON DELETE CASCADE
        ON UPDATE CASCADE NOT NULL,
    board_game_id INT REFERENCES board_games ON DELETE CASCADE
        ON UPDATE CASCADE NOT NULL
);

--02

INSERT INTO board_games(name, release_year, rating, category_id, publisher_id, players_range_id)
VALUES
    ('Deep Blue',	2019,	5.67,	1,	15,	7),
    ('Paris',	2016,	9.78,	7,	1,	5),
    ('Catan: Starfarers',	2021,	9.87,	7,	13,	6),
    ('Bleeding Kansas',	2020,	3.25,	3,	7,	4),
    ('One Small Step',	2019,	5.75,	5,	9,	2)
;

INSERT INTO publishers(name, address_id, website, phone)
VALUES
        ('Agman Games',	5,	'www.agmangames.com',	'+16546135542'),
        ('Amethyst Games',	7,	'www.amethystgames.com',	'+15558889992'),
        ('BattleBooks',	13,	'www.battlebooks.com',	'+12345678907')
;

--03

UPDATE players_ranges
SET max_players = max_players + 1
WHERE min_players = 2 and max_players = 2;

UPDATE board_games
SET name = CONCAT_WS(' ', name,'V2')
WHERE release_year >= 2020;

--04




DELETE FROM board_games
WHERE publisher_id IN (SELECT id FROM publishers WHERE address_id IN (SELECT id FROM addresses WHERE town LIKE 'L%'));

DELETE FROM publishers
WHERE address_id IN (SELECT id FROM addresses WHERE town LIKE 'L%');

DELETE FROM addresses
WHERE town LIKE 'L%';


--05
SELECT
    name,
    rating
FROM board_games
ORDER BY release_year,
         name DESC ;
--06
SELECT
    bg.id,
    bg.name,
    bg.release_year,
    cat.name AS category_name

FROM board_games as bg
    JOIN categories as cat on bg.category_id = cat.id
WHERE (cat.name = 'Strategy Games' OR cat.name = 'Wargames')
ORDER BY BG.release_year DESC ;
--07
SELECT
    cr.id,
    concat_ws(' ', cr.first_name,cr.last_name) as creator_name,
    cr.email
FROM creators AS cr
    LEFT JOIN creators_board_games as cbg on cr.id = cbg.creator_id

WHERE cbg.board_game_id IS  NULL

ORDER BY creator_name;

--08


SELECT
    bg.name,
    bg.rating,
    c.name AS category_name
FROM
    board_games as bg
JOIN
    categories as c
ON bg.category_id = c.id
JOIN
    players_ranges AS pr
ON bg.players_range_id = pr.id

WHERE
    (bg.rating > 7.00 and bg.name ILIKE '%a%')
            or
    (bg.rating > 7.50 and pr.min_players >= 2 AND pr.max_players <= 5)

ORDER BY
    bg.name asc,
    bg.rating desc
LIMIT 5;
--09

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    MAX(bg.rating) AS rating
FROM
    creators c
JOIN
    creators_board_games cbg ON c.id = cbg.creator_id
JOIN
    board_games bg ON cbg.board_game_id = bg.id
WHERE
    c.email LIKE '%.com'
GROUP BY
    c.id
ORDER BY
    full_name ASC;

--10


SELECT
    cr.last_name,
    ceiling(avg(bg.rating)) AS average_rating,
    p.name
FROM creators AS cr
JOIN creators_board_games as cbg on cr.id = cbg.creator_id
    JOIN board_games as bg on cbg.board_game_id = bg.id
        JOIN publishers as p on bg.publisher_id = p.id
WHERE P.name = 'Stonemaier Games'
group by cr.last_name, p.name
ORDER BY average_rating desc ;

--11
CREATE OR REPLACE FUNCTION fn_creator_with_board_games(
    first_name_creator VARCHAR(30)
)  RETURNS INT

AS

$$  DECLARE total_number INT;
    BEGIN
        total_number :=
            (SELECT
                count(*)
                FROM creators_board_games AS cbd
                JOIN creators AS c ON cbd.creator_id = c.id
                    JOIN board_games AS bg ON cbd.board_game_id = bg.id
            WHERE  c.first_name = first_name_creator);
        RETURN total_number;
    END ;
$$
LANGUAGE plpgsql;


SELECT
    count(*)
FROM creators_board_games AS cbd
    JOIN creators AS c ON cbd.creator_id = c.id
        JOIN board_games AS bg ON cbd.board_game_id = bg.id
WHERE  c.first_name = 'Alexander'

--12

CREATE TABLE search_results(

    id             SERIAL PRIMARY KEY,
    name           VARCHAR(50),
    release_year   INT,
    rating         FLOAT,
    category_name  VARCHAR(50),
    publisher_name VARCHAR(50),
    min_players    VARCHAR(50),
    max_players    VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE usp_search_by_category(
    category VARCHAR(50)
)
AS

    $$
        BEGIN
            INSERT INTO search_results
                (name, release_year, rating, category_name, publisher_name, min_players, max_players)
            SELECT
                bg.name,
                bg.release_year,
                bg.rating,
                cat.name as category_name,
                p.name as publisher_name,
                CONCAT(pr.min_players, ' people') AS min_players,
                CONCAT(pr.max_players, ' people') AS max_players
            FROM board_games AS bg
                JOIN categories as cat on bg.category_id = cat.id
                    JOIN publishers as p on bg.publisher_id = p.id
                        JOIN players_ranges as pr on bg.players_range_id = pr.id

            WHERE cat.name = category
            ORDER BY publisher_name,
                    bg.release_year DESC ;

        END ;
    $$
LANGUAGE plpgsql;


CALL usp_search_by_category('Wargames');

SELECT * FROM search_results;



SELECT
    bg.name,
    bg.release_year,
    bg.rating,
    cat.name as category_name,
    p.name as publisher_name,
    CONCAT(pr.min_players, ' people') AS min_players,
    CONCAT(pr.max_players, ' people') AS max_players

FROM board_games AS bg
    JOIN categories as cat on bg.category_id = cat.id
        JOIN publishers as p on bg.publisher_id = p.id
            JOIN players_ranges as pr on bg.players_range_id = pr.id

WHERE cat.name = 'Wargames'
ORDER BY publisher_name,
         BG.release_year DESC ;






