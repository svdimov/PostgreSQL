SELECT
    COUNT(e.salary) AS "count"
FROM employees AS e
WHERE e.salary > (
    SELECT
        AVG(employees.salary) AS average_salary
    FROM employees
    );

