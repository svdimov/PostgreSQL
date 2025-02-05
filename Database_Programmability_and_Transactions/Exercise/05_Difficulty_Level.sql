CREATE OR REPLACE FUNCTION fn_difficulty_level(
    level INT
)RETURNS VARCHAR
AS

$$
    DECLARE difficulty_level varchar(100);
    BEGIN
        IF level <= 40 THEN
            difficulty_level := 'Normal Difficulty';
        ELSIF level BETWEEN 41 AND 60 THEN
            difficulty_level := 'Nightmare Difficulty';
        ELSIF level > 60 THEN
            difficulty_level := 'Hell Difficulty';
        end if;
        RETURN difficulty_level;


    END

$$
LANGUAGE plpgsql;


SELECT
    user_id,
    level,
    cash,
    fn_difficulty_level(level)

FROM users_games
ORDER BY user_id;