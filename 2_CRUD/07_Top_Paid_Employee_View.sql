CREATE VIEW top_payed_employee_set
AS SELECT
    *
FROM employees
ORDER BY salary DESC
LIMIT 1;



SELECT * FROM top_payed_employee_set;


