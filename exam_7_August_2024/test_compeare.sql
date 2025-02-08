CREATE OR REPLACE FUNCTION udf_category_productions_count(category_name VARCHAR(50))
RETURNS VARCHAR AS $$
DECLARE
    productions_count INT;
BEGIN
    SELECT COUNT(cp.production_id) INTO productions_count
    FROM categories c
    LEFT JOIN categories_productions cp ON c.id = cp.category_id
    WHERE c.name = category_name;
    RETURN 'Found ' || productions_count || ' productions.';
END;
$$ LANGUAGE plpgsql;