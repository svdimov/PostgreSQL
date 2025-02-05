CREATE OR REPLACE PROCEDURE sp_increase_salary_by_id(id INT)
AS

$$
    BEGIN
        if(SELECT employee_id FROM employees WHERE employee_id = id)  IS NULL THEN
            RETURN ;
        END IF ;
        UPDATE employees
        SET salary = salary + salary * 0.05
        WHERE employee_id = id;
        COMMIT ;
    END
$$

LANGUAGE plpgsql;

CALL sp_increase_salary_by_id(17);

select *
from employees
where employee_id = 17;