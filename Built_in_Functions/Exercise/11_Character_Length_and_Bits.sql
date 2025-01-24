SELECT
    concat_ws(' ', mountain_range, p.peak_name) AS mountain_information,
    char_length(concat_ws(' ', mountain_range,peak_name)) AS characters_length,
    bit_length(concat_ws(' ',mountain_range,peak_name)) AS bits_of_a_tring

FROM mountains  AS m,
     peaks AS p
WHERE m.id = p.mountain_id;