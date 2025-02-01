SELECT
    a.name,
    a.country,
    b.booked_at ::DATE
FROM apartments as a
LEFT JOIN bookings AS b
USING (booking_id)
LIMIT 10;

