CREATE TABLE logs(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    account_id INT,
    old_sum NUMERIC(10,4),
    new_sum NUMERIC(10,4)
);

CREATE OR REPLACE FUNCTION trigger_fn_insert_new_entry_into_logs()
RETURNS TRIGGER
AS
    $$
        BEGIN
            INSERT INTO logs(account_id, old_sum, new_sum)
            VALUES (old.id,old.balance,new.balance);
            RETURN NEW;
        END;
    $$
LANGUAGE plpgsql;


CREATE TRIGGER tr_account_balance_change
    AFTER UPDATE OF balance on accounts
    FOR EACH ROW
    WHEN ( old.balance <> new.balance )
EXECUTE FUNCTION trigger_fn_insert_new_entry_into_logs();

select *
from logs;

call sp_deposit_money(11,100);