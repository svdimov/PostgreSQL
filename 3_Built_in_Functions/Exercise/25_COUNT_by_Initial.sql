SELECT
    substring(first_name,1,2) AS initials,
    count('initials')  AS user_count
FROM users
GROUP BY initials
ORDER BY user_count DESC ,
         initials;
