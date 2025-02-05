CREATE OR REPLACE PROCEDURE
sp_increase_salaries(department_name VARCHAR(50))
AS

$$

    BEGIN
        UPDATE employees
        SET salary = salary + salary * 0.05
        WHERE department_id = (SELECT
                                   departments.department_id
                               FROM departments
                               WHERE name = department_name);

    END

$$

LANGUAGE plpgsql;


call sp_increase_salaries('Finance');






SELECT
    e.first_name,
    e.salary
from employees AS  e
JOIN departments AS d
USING (department_id)
WHERE d.name = 'Finance'
ORDER BY first_name;
