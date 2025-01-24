SELECT
    companion_full_name,
    email
FROM users
WHERE companion_full_name ILIKE '%aNd%' --- ILIKE NOT CASE SENSITIVE
            AND
    email NOT LIKE '%@gmail' ; -- LIKE = CASE SENSITIVE