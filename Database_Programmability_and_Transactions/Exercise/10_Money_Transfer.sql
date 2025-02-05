
CREATE OR REPLACE PROCEDURE sp_transfer_money(
    sender_id INT,
    receiver_id INT,
    amount NUMERIC(10,4)
)
AS

    $$
        DECLARE current_amount NUMERIC(10,4);
        BEGIN
            SELECT balance INTO current_amount FROM accounts WHERE id = sender_id;
            IF current_amount >= amount THEN
                CALL sp_withdraw_money(sender_id,amount);
                CALL sp_deposit_money(receiver_id,amount);
            END IF;
        END;
    $$

LANGUAGE plpgsql;


CALL sp_transfer_money(5,1,5000);
SELECT
    id,
    account_holder_id,
    balance
FROM accounts
WHERE id = 5 or id  = 1;