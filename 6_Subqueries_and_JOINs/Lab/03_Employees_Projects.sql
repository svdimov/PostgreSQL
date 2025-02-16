SELECT
    e.employee_id,
    concat_ws(' ',e.first_name,e.last_name) AS full_name,
    p.project_id,
    p.name AS project_name

FROM employees AS e
JOIN employees_projects AS ep
ON e.employee_id = ep.employee_id
JOIN projects AS p
ON ep.project_id = p.project_id
WHERE p.project_id = 1;