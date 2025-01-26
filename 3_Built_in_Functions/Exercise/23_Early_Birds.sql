SELECT
    user_id,
    age(starts_at,booked_at) AS "Early Birds"
FROM bookings
WHERE starts_at - booked_at >= '10 MONTHS';