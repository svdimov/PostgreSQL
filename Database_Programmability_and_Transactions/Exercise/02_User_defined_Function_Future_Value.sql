CREATE OR REPLACE FUNCTION fn_calculate_future_value(
    initial_sum DECIMAL,
    yearly_interest_rate DECIMAL,
    number_of_years INT
) RETURNS DECIMAL
AS

$$  DECLARE final_sum NUMERIC;
    BEGIN
        final_sum:= initial_sum * power(yearly_interest_rate+1,number_of_years);
        return TRUNC(final_sum,4);
    END
$$

LANGUAGE plpgsql;

