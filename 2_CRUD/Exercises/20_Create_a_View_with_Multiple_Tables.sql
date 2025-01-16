CREATE VIEW view_addresses
AS

SELECT
    concat_ws(' ', e.first_name,last_name) AS full_name,
    e.department_id,
    concat_ws(' ', a.number,a.street) AS address

FROM employees AS e
JOIN
     addresses AS a
ON
    a.id = e.address_id
ORDER BY address;

