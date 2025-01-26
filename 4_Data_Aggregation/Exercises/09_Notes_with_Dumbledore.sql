SELECT
    last_name,
    count(notes) AS notes_with_dumbledore

FROM wizard_deposits
WHERE  notes LIKE '%Dumbledore%'
GROUP BY last_name;


