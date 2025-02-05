-- CREATE TABLE bank(
--     id INT PRIMARY KEY ,
--     name VARCHAR(20),
--     bgn INT
-- );
--
-- INSERT INTO bank(id, name, bgn)
-- VALUES (1,'Ivan',1000),
--        (2,'Mimi',2000);


CREATE OR REPLACE PROCEDURE sp_transaction_money(
    IN sender_id INT,
    IN receiver_id INT,
    IN transfer_amount INT,
    OUT status VARCHAR(50)
)
AS
$$
    DECLARE
        sender_amount int;
        receiver_amount int;
        temp_val int;
    BEGIN
        SELECT bgn FROM bank WHERE id = sender_id INTO sender_amount;
        if sender_amount < transfer_amount THEN
            status := 'The sender does not have enough money ';
            return ;
        end if;
        select bgn from bank where id = receiver_id INTO receiver_amount;
        UPDATE bank SET bgn = bgn + transfer_amount WHERE id = receiver_id;
        UPDATE bank SET bgn = bgn - transfer_amount where id = sender_id;
        SELECT bgn FROM bank WHERE id = sender_id INTO temp_val;
        if sender_amount - transfer_amount <> temp_val THEN
            status := 'Error transfer from sender ';
            ROLLBACK ;
            RETURN ;
        end if;
        select bgn from bank where id = receiver_id INTO temp_val;
        IF receiver_amount + transfer_amount <> temp_val THEN
            status := 'Error when transfer to receiver';
            ROLLBACK ;
            RETURN ;
        end if;
        status := 'Success';
        COMMIT ;
    END
$$

LANGUAGE plpgsql;

select *
from bank;

call sp_transaction_money(1,2,1000,'');
