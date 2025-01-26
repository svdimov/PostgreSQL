SELECT
    department_id,
    count(department_id) AS numb_employees,
    CASE
        WHEN AVG(salary) > 50000 THEN 'Above average'
        WHEN avg(salary) < 50000 THEN 'Below average'

    END AS salary_level


FROM employees

GROUP BY department_id
HAVING avg(salary) > 30000
ORDER BY department_id;