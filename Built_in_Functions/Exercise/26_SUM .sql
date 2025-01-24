SELECT
    sum(booked_for) AS total_value
FROM bookings
WHERE apartment_id = 90;