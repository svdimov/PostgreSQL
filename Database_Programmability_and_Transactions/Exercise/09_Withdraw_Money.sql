CREATE OR REPLACE PROCEDURE sp_withdraw_money(
    account_id INT,
    money_amount NUMERIC(10,4)

)

AS

    $$  DECLARE  current_balance NUMERIC;
        BEGIN
            current_balance := (SELECT balance FROM accounts WHERE id = account_id);

            IF current_balance >= money_amount THEN
                UPDATE accounts
                SET balance = balance - money_amount
                WHERE id = account_id;
            ELSE
                RAISE NOTICE 'Insufficient balance to withdraw %' ,money_amount;
            END IF;


        END;
    $$
LANGUAGE plpgsql;

call sp_withdraw_money(6,5436.34);

drop procedure sp_withdraw_money(account_id integer, money_amount numeric);

select
    id,
    account_holder_id,
    balance
from accounts
where id = 6;

CREATE OR REPLACE PROCEDURE sp_withdraw_money_messages(
    IN account_id INT,
    IN money_amount NUMERIC(10,4),
    OUT msg VARCHAR(50)

)

AS

    $$  DECLARE  current_balance NUMERIC;
        BEGIN
            current_balance := (SELECT balance FROM accounts WHERE id = account_id);

            IF current_balance >= money_amount THEN
                UPDATE accounts
                SET balance = balance - money_amount
                WHERE id = account_id;
            ELSE
                msg:= concat_ws(' ','Insufficient balance to withdraw',money_amount);
            END IF;


        END;
    $$
LANGUAGE plpgsql;

CALL sp_withdraw_money_messages(6,1000,'');


SELECT
    id,
    balance
FROM accounts
where id = 6;
