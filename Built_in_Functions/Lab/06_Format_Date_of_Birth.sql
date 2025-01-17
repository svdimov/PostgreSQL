SELECT
    last_name AS "Last Name",
    to_char(born,'DD (DY) MON YYYY') AS "Date of Birth"
FROM authors;

SELECT
    last_name AS "Last Name",
    TO_CHAR(born, 'DD (Dy) Mon YYYY') AS "Date of Birth"
FROM
    authors;
