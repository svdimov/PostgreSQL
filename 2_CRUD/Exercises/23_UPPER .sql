UPDATE projects
SET name = UPPER(name);


UPDATE projects
SET name = lower(name);

select *
from projects;
