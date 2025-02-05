
CREATE PROCEDURE sp_retrieving_holders_with_balance_higher_than(
    searched_balance NUMERIC
)
AS

$$
    DECLARE holder_info RECORD;
    BEGIN
        FOR holder_info IN
        SELECT
            CONCAT_WS(' ',ah.first_name,ah.last_name) as full_name,
            sum(a.balance) as total_balance
        FROM account_holders AS ah
        JOIN accounts  AS a
        ON aH.id = a.account_holder_id
        GROUP BY full_name
        HAVING sum(a.balance) > searched_balance
        ORDER BY full_name

    LOOP
            RAISE NOTICE '% - %', holder_info.full_name,holder_info.total_balance;
    END LOOP ;

    END
$$

LANGUAGE plpgsql;


call sp_retrieving_holders_with_balance_higher_than(200000);




 SELECT
            CONCAT_WS(' ',ah.first_name,ah.last_name) as full_name,
            sum(a.balance) as total_balance
        FROM account_holders AS aH
        JOIN accounts  AS a
        ON aH.id = a.account_holder_id
        GROUP BY full_name
        HAVING sum(a.balance) > 200000
        ORDER BY full_name;