/*1   */
	SELECT tf.ticket_no, f.departure_airport, 
			f.arrival_airport, f.scheduled_arrival,
			LEAD(f.scheduled_departure) OVER win as next_departure,
			LEAD(f.scheduled_departure) OVER win - f.scheduled_arrival as gap
	FROM bookings b
		JOIN tickets t
		ON t.book_ref = b.book_ref
		JOIN ticket_flights tf
		ON tf.ticket_no = t.ticket_no
		JOIN flights f
		ON tf.flight_id = f.flight_id
	where b.book_date = PUBLIC.NOW():: date - INTERVAL '7 day'
	WINDOW win as (PARTITION BY tf.ticket_no ORDER BY f.scheduled_departure)

/*2 Which flights had the longest delays, return only 5 flights*/

SELECT f.flight_no, f.scheduled_departure, f.actual_departure,
		(f.actual_departure-f.scheduled_departure) as delay
FROM flights f
WHERE f.actual_departure IS NOT NULL
order by 4 desc
LIMIT 5


/*3 How many flights remained free on flight PG0404 in the day before the last in the airlines database? */
SELECT count(*)
FROM (SELECT s.seat_no FROM seats s
	 WHERE s.aircraft_code = (SELECT aircraft_code
							 FROM flights
							 WHERE flight_no = 'PG0404'
							 AND scheduled_departure::date = PUBLIC.NOW()::date - INTERVAL '1 day'
							 )
	 						EXCEPT
							SELECT bp.seat_no
							 FROM boarding_passes bp
							  WHERE bp.flight_id =(SELECT flight_id
												   FROM flights
												   WHERE flight_no = 'PG0404'
							 		 AND scheduled_departure::date = public.now()::date - INTERVAL '1 day')) as t
	
