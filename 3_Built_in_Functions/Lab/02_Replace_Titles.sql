-- SELECT
--     replace(title,'The','***') AS title
-- FROM books
-- WHERE substring(title,1,3) = 'The'
-- ORDER BY id;


select
    title
from books
where substring(title,1,3) = 'The'
order by id;