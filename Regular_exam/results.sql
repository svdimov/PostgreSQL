CREATE TABLE brands(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE classifications(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE customers(
    id SERIAL PRIMARY KEY ,
    first_name VARCHAR(30) NOT NULL ,
    last_name VARCHAR(30) NOT NULL ,
    address VARCHAR(150) NOT NULL ,
    phone VARCHAR(30) UNIQUE NOT NULL ,
    loyalty_card BOOLEAN DEFAULT FALSE NOT NULL

);

CREATE TABLE items(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(50) NOT NULL ,
    quantity INT CHECK ( quantity >= 0 ) NOT NULL ,
    price DECIMAL(12,2) CHECK ( price > 0.00 ) NOT NULL ,
    description TEXT,
    brand_id INT REFERENCES brands ON UPDATE CASCADE
                  ON DELETE CASCADE NOT NULL ,
    classification_id INT REFERENCES classifications ON UPDATE CASCADE
                  ON DELETE CASCADE NOT NULL

);

CREATE TABLE orders(
    id SERIAL PRIMARY KEY ,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL ,
    customer_id INT REFERENCES customers ON UPDATE CASCADE
                   ON DELETE CASCADE NOT NULL
);

CREATE TABLE reviews(
    customer_id INT REFERENCES customers ON UPDATE CASCADE
                    ON DELETE CASCADE NOT NULL ,
    item_id INT REFERENCES items ON UPDATE CASCADE
                    ON DELETE CASCADE NOT NULL ,
    PRIMARY KEY (customer_id,item_id) ,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL ,
    rating DECIMAL(3,1) DEFAULT 0.0 CHECK ( rating <= 10.0 ) NOT NULL

);

CREATE TABLE orders_items(
    order_id INT REFERENCES orders ON UPDATE CASCADE
                         ON DELETE CASCADE NOT NULL ,
    item_id INT REFERENCES items ON UPDATE CASCADE
                         ON DELETE CASCADE NOT NULL ,
    PRIMARY KEY (order_id,item_id),
    quantity INT CHECK ( quantity >= 0 ) NOT NULL

);

--02
INSERT INTO items (name, quantity, price, description, brand_id, classification_id)
SELECT
    CONCAT('Item', created_at) AS name,
    customer_id AS quantity,
    (rating * 5) AS price,
    NULL AS description,
    item_id AS brand_id,
    (SELECT MIN(item_id) FROM reviews) AS classification_id
FROM reviews
ORDER BY item_id
LIMIT 10;

--03

UPDATE reviews
SET rating = CASE
    WHEN item_id = customer_id THEN 10.0
    WHEN customer_id > item_id THEN 5.5
    ELSE rating
END;

--04
DELETE FROM customers
WHERE id NOT IN (
    SELECT
    customer_id
    FROM orders
    );

--05

SELECT
    id,
    last_name,
    loyalty_card
FROM customers
WHERE loyalty_card = TRUE AND  last_name ILIKE '%m%'
ORDER BY last_name DESC ,
         id
;

--06
SELECT
    id,
    to_char(Date(created_at),'DD-MM-YYYY') as created_at,
    customer_id

FROM orders
where created_at > '01-01-2025 ' AND customer_id BETWEEN 15 AND 30
ORDER BY
    created_at,
    customer_id DESC ,
    id
LIMIT 5
;

--07
SELECT
    i.name,
    CONCAT(UPPER(b.name), '/', LOWER(c.name)) AS promotion,
    CONCAT('On sale: ', COALESCE(i.description, '')) AS description,
    i.quantity
FROM
    items i
JOIN brands as b on i.brand_id = b.id
join classifications as c on i.classification_id = c.id
left join orders_items as oi on i.id = oi.item_id
where oi.item_id is null
ORDER BY
    i.quantity DESC, i.name ASC;

--08




SELECT
    c.id AS customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(o.customer_id) AS total_orders,
    CASE
        WHEN c.loyalty_card = 'true' THEN 'Loyal Customer'
        ELSE 'Regular Customer'
    END AS loyalty_status
FROM
    customers c
JOIN
    orders o ON c.id = o.customer_id
LEFT JOIN
    reviews r ON c.id = r.customer_id
WHERE
    r.customer_id IS NULL
GROUP BY
    c.id
ORDER BY
    total_orders DESC, customer_id;
--09


SELECT
    i.name AS item_name,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.rating) AS total_reviews,
    b.name AS brand_name,
    c.name AS classification_name
FROM items AS i
JOIN reviews AS r ON i.id = r.item_id
JOIN brands AS b ON i.brand_id = b.id
JOIN classifications AS c ON i.classification_id = c.id
GROUP BY i.name, b.name, c.name
HAVING COUNT(r.rating) >= 3
ORDER BY average_rating DESC, i.name
LIMIT 3;


--10
CREATE FUNCTION udf_classification_items_count(
    classification_name VARCHAR(30))
RETURNS VARCHAR
AS
$$
DECLARE total_numbers int;
BEGIN

    SELECT
    into total_numbers
    count(i.id)
    FROM classifications AS c
    JOIN items as i on c.id = i.classification_id
    where c.name = classification_name;
    if total_numbers = 0 then  return 'No items found.';
    else return 'Found ' || total_numbers || ' items.';
    end if;
END;
$$
LANGUAGE plpgsql;



CREATE FUNCTION udf_classification_items_count(
    classification_name VARCHAR(30))
RETURNS VARCHAR
AS
$$
DECLARE
    total_numbers INT;
BEGIN

    SELECT count(i.id)
    INTO total_numbers
    FROM classifications AS c
    JOIN items AS i ON c.id = i.classification_id
    WHERE c.name = classification_name;


    IF total_numbers = 0 THEN
        RETURN 'No items found.';
    ELSE
        RETURN 'Found ' || total_numbers || ' items.';
    END IF;
END;
$$
LANGUAGE plpgsql;

SELECT udf_classification_items_count('Laptops') AS message_text;
SELECT udf_classification_items_count('Nonexistent') AS message_text;

--11
CREATE OR REPLACE PROCEDURE udp_update_loyalty_status(
    min_orders INT)
AS

$$
BEGIN
    update customers
    set loyalty_card = TRUE
    where id in (select
                     customer_id
                 from orders
                 group by customer_id
                 having count(*) >= min_orders);
END;
$$

LANGUAGE plpgsql;

SELECT
    c.id,
    c.first_name,
    c.last_name,
    c.loyalty_card


FROM customers as c
join orders as o on c.id = o.customer_id
group by c.id, c.last_name, c.loyalty_card , c.first_name , c.first_name, c.last_name, c.loyalty_card
having  count(*) >= 4

;


CREATE OR REPLACE PROCEDURE udp_update_loyalty_status(
    min_orders INT)
AS
$$
BEGIN

    UPDATE customers
    SET loyalty_card = TRUE
    WHERE id IN (
        SELECT customer_id
        FROM orders
        GROUP BY customer_id
        HAVING COUNT(*) >= min_orders
    );
END;
$$
LANGUAGE plpgsql;
