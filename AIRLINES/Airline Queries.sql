-- BASIC SELECT
--1. List the Cities in which there is no flight from Moscow--

	Select distinct(city)
	from airports 
	where city ->>'en' <> 'Moscow'
	order by city

--2. Select Airports where the time zone is in Asia/Novokuznetsk and Asia/Krasnoyark

	select (airport_name ->> 'en') as airport_name
	from airports
	where timezone  in  ('Asia/Novokuznetsk','Asia/Krasnoyarsk')


/*3.Get Model, range, and miles of every aircraft that exists in the airlines Database, notice that 
miles = range/1.609 and round the result to 2 numbers after the float point */

	select model, range, round((range/1.609), 2) as Miles 
	from aircrafts

--4. Return all information about aircraft that has aircraft_code SU9 and its range in miles

	Select aircraft_code, model,  round((range/1.609), 2) as Miles 
	from aircrafts
	where aircraft_code = 'SU9'


--AGGREGATION --
--5. Calculate the Average Tickets Sales ---
	Select avg(amount) from ticket_flights

--6. Return the number of seats in the aircraft that has aircfraft code = 'CN1' --
	select  count(*)
	from seats
	where aircraft_code  = 'CN1'

--7. Return the number of seats in the aircraft that has aircfraft code = 'SU9' --
	select  count(*)
	from seats
	where aircraft_code  = 'SU9'

--8. Write a query to return the aircraft_code and the number of seats of each aircraft ordered ascending --
	select  aircraft_code, count(*)
	from seats
	group by 1
	order by 2 asc;

/* 9. Calculate the number of seats in the salons for all aircfraf models, but now taking into account the clas
of Service(Business and Economic Class) */
	select  aircraft_code,fare_conditions, count(*)
	from seats
	group by 1,2
	order by 1,2;

-- 10. Which day has the least booking amount --
	select book_date, sum(total_amount)
	from bookings
	group by 1 
	order by 2
	limit 1
	
	select * from airports
/* 11. Determine how many flights from each city to other cities, return the name of the city and  count of 
flights more than 50 order the data from largest no of flights to the least*/
	select(select city->> 'en' from airports where airport_code = departure_airport) as departure_city,
	count(*)
	from flights
	group by 1
	having count(*) > 50
	order by 2 desc
	
	--OR---
	
	select (a.city->> 'en') as departure_city, count(f.flight_id)
	from flights f
	join airports a
	on f.departure_airport = a.airport_code
	group by 1
	having count(f.flight_id) > 50
	order by 2 desc

/* 12. Return all flight details in the indicated day 2017-08-28 include flight count ascending order,
departures count, time of departure and arrival time*/
	
	Select flight_no, scheduled_departure :: time as dep_time, scheduled_arrival :: time as arrival_time,
	departure_airport as departures, arrival_airport as arrival, count(flight_id) as No_of_flight
	from flights
	where scheduled_departure >= '2017-08-28'::date and scheduled_departure < '2017-08-29':: date
	group by 1,2,3,4,5
	order by 4 asc

/* 13. Write a Query ti arange the ange of model of aircrafts so short range is less than 2000. Middle range is more
than 2000 and less than 5000 & any range above 5000 is long range*/

	Select * from aircrafts
	Select model ->> 'en', case when range < 2000 then 'Short Range'
							when range > 2000 and range < 5000 then 'Middle Range'
							else 'Long_Range' end as Range
	from aircrafts

/* 14. What is the shortest flight duration for each possible flight from Moscow to St. Petersburg, ann how
many tiems was the flight delayed for more than an hour */
	Select f.flight_no, (f.scheduled_arrival  - f.scheduled_departure) as Scheduled_duration,
		min(f.scheduled_arrival - f.scheduled_departure), max(f.scheduled_arrival - f.scheduled_departure),
		Sum(Case when f.actual_departure > f.scheduled_departure + INTERVAL '1 hour' then 1
			Else 0  End) delays
	from flights f
	where(select city ->> 'en' from airports where airport_code = departure_airport) = 'Moscow'
	and (select city ->> 'en' from airports where airport_code = arrival_airport) = 'St. Petersburg'
	and f.status = 'Arrived'
	Group by 1, (f.scheduled_arrival  - f.scheduled_departure);

--15. Who travelled from Moscow(SVO) to Novosibirsk(OVB) on seat 1A , and when was the ticket booked?--

Select t.passenger_name, b.book_date, bp.seat_no
from bookings b
	join tickets t
		on b.book_ref = t.book_ref
	join boarding_passes bp
		on t.ticket_no = bp.ticket_no
	join flights f
		on bp.flight_id = f.flight_id
where departure_airport = 'SVO' and arrival_airport = 'OVB' and bp.seat_no = '1A'
	and f.scheduled_departure::date = public.now()::date - INTERVAL '2 day'

/*16. Find the most disciplined passengers who checked in frst for all thier flights. 
Take into account only those pssengers who took atleast two flights  */

	Select t.passenger_name, t.ticket_no
	from tickets t
		join boarding_passes bp
			on bp.ticket_no = t.ticket_no
	group by t.passenger_name, t.ticket_no
	having max(bp.boarding_no) = 1 and count(*) > 1

/* 17. Calculate the number of passengers and number of flights departing from one airport (SVO) during each 
hour on 2017-08-02 */
	
	Select  date_part('hour', f.scheduled_departure) as hour, 
		count(distinct(f.flight_id)) as flight_count, count(tf.ticket_no) as no_o_passengers
	from flights f
		join ticket_flights tf
			on f.flight_id = tf.flight_id
	where f.departure_airport = 'SVO' and f.scheduled_departure >= '2017-08-02' :: date 
		and f.scheduled_departure < '2017-08-03' :: date 
	group by 1
	order by 1 asc

/* 18. Using Exists function in the subqueries return the ticket_no, boarding_no and seat_no who used the 
Business class */
select ticket_no, boarding_no, seat_no
from boarding_passes
where Exists (Select flight_id from ticket_flights where fare_conditions = 'Business')

--19. Write a query to return the number of flights where aircraft is greater than 7000
With long_range as (select * from aircrafts where range > 7000)
Select count(*)
from flights f
join long_range l on f.aircraft_code = l.aircraft_code


--20. Get the passenger_name departure_time, arrival_airport and departure_airport with book_ref A55664--
With booking_number as (select passenger_name,  ticket_no from tickets where book_ref = 'A55664')
select b.passenger_name, f.actual_departure, f.arrival_airport, f.departure_airport
from flights f
join ticket_flights tf
on f.flight_id = tf.flight_id
join booking_number b
on tf.ticket_no = b.ticket_no

With t1 as (select f.flight_id, f.flight_no, f.scheduled_departure,
				(Select city ->> 'en' from airports where airport_code = f.departure_airport) as departure_city,
				(Select city ->> 'en' from airports where airport_code = f.arrival_airport) as arrival_city,
				f.aircraft_code, count(tf.ticket_no) as No_of_Passengers,
				(Select count(s.seat_no) from seats s where s.aircraft_code = f.aircraft_code) as total_seat
			From flights f
			join ticket_flights tf
			on f.flight_id = tf.flight_id
			where f.status = 'Arrived'
			Group by 1,2,3,4,5,6)
Select t1.flight_id, t1.flight_no, t1.scheduled_departure, t1.departure_city,
		t1.arrival_city, a.model ->> 'en' as Model, t1.total_seat,
		round(t1.No_of_Passengers :: numeric / t1.total_seat :: numeric, 2) as Passengers
from t1
join aircrafts as a
on t1.aircraft_code = a.aircraft_code
Order by t1.scheduled_departure
		













