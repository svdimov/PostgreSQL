CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    status INT,
    created DATE DEFAULT NOW()
);

CREATE TABLE items_log (
    id SERIAL PRIMARY KEY,
    status INT,
    created DATE DEFAULT NOW()
);


-- Function to log items
CREATE OR REPLACE FUNCTION log_items()
RETURNS TRIGGER AS
$$
    BEGIN
        INSERT INTO items_log(id, status, created)
        VALUES (NEW.id, NEW.status, NEW.created);
        RETURN NEW;
    END;
$$
LANGUAGE plpgsql;




-- Trigger to log item insertions
CREATE TRIGGER log_items_trigger
    AFTER INSERT ON items
    FOR EACH ROW EXECUTE FUNCTION log_items();

-- Insert initial data into items_log
INSERT INTO items(status)
VALUES (floor(random() * 100)),
       (floor(random() * 100)),
       (floor(random() * 100)),
       (floor(random() * 100)),
       (floor(random() * 100)),
       (floor(random() * 100));

-- Function to maintain only the last 8 records
CREATE OR REPLACE FUNCTION delete_excess_items_log()
RETURNS TRIGGER AS
$$
    BEGIN
        DELETE FROM items_log
        WHERE id IN (
            SELECT id FROM items_log
            ORDER BY id ASC
            OFFSET 8
        );
        RETURN NULL;
    END;
$$
LANGUAGE plpgsql;

-- Trigger to clean up old logs
CREATE TRIGGER clear_items_log_trigger
    AFTER INSERT ON items_log
    FOR EACH ROW EXECUTE FUNCTION delete_excess_items_log();


SELECT *
FROM items_log;