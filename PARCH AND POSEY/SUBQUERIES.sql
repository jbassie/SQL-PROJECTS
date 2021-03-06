--1. Find the average number of events a day for each channel.--
SELECT channel, AVG(events)
FROM (Select Date_part('day', occurred_at) as day, Channel, count(*) as events
		FROM web_events
		GROUP BY 1,2
		ORDER BY 1 asc) as t1`
GROUP BY 1

--2. Use DATE_TRUNC to pull month level information about the first order ever placed in the orders table--
Select DATE_TRUNC('Month', min(occurred_at))
FROM orders
 
/* 3. Use the result of the previous query to find the orders that took place in the same month and year as the 
first order and the pull the average of each type of paper qty in this month */
SELECT AVG(standard_qty) as avg_std, AVG(poster_qty) as avg_pos, AVG(gloss_qty) as avg_glos
FROM Orders
Where DATE_TRUNC('Month', occurred_at) = 
	(SELECT DATE_TRUNC('Month', min(occurred_at))
	FROM orders)

/* 4. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales */

SELECT t2.region,t3.sales_rep,t3.total_sales
FROM
	(SELECT region, max(total_Sales) as total_sales
	FROM
		(SELECT r.name as region, sr.name as sales_rep,  sum(total_amt_usd) as total_sales
		from region r
		join sales_reps sr
		on r.id = sr.region_id
		join accounts a
		on sr.id = a.sales_rep_id
		join orders o
		on a.id = o.account_id
		GROUP BY 1,2
		ORDER BY 3 DESC) as t1
	GROUP BY 1) t2
JOIN 
	(SELECT r.name as region, sr.name as sales_rep,  sum(total_amt_usd) as total_sales
	FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		ON sr.id = a.sales_rep_id
		JOIN orders o
		ON a.id = o.account_id
	GROUP BY 1,2
	ORDER BY 3 DESC) as t3
on t2.region = t3.region and t2.total_sales = t3.total_sales

-- 5.For the region with the largest sales total_amt_usd, how many total orders were placed --
SELECT r.name, Count(total_amt_usd)
FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		ON sr.id = a.sales_rep_id
		JOIN orders o
		ON a.id = o.account_id
GROUP BY 1
HAVING sum(total_amt_usd)= (SELECT MAX(total)
		FROM(SELECT r.name, sum(total_amt_usd) as total
			FROM region r
				JOIN sales_reps sr
				ON r.id = sr.region_id
				JOIN accounts a
				ON sr.id = a.sales_rep_id
				JOIN orders o
				ON a.id = o.account_id
			GROUP BY 1) t1)

/* 6 How many accounts had more total purchases than the account name which has bought the most standard_qty paper 
throughout their lifetime as a customer? */
SELECT Count(*)
FROM(
	SELECT a.name, sum(o.total)
	FROM orders o
	JOIN accounts a
	On o.account_id = a.id
	GROUP BY 1
	HAVING sum(o.total) > (SELECT max(total)
							FROM(SELECT a.name, sum(o.standard_qty) as total
								 FROM orders o
									JOIN accounts a
									On o.account_id = a.id
									GROUP BY 1) as t1 ) ) as t2

/* 7 For the customer that spent the most (in total over their lifetime as a customer) 
total_amt_usd, how many web_events did they have for each channel? */
Select account_id, channel, count(*)
FROM web_events
WHERE account_id = (SELECT t1.id
					FROM (
							SELECT a.id, a.name as name, sum(o.total_amt_usd) as total
							FROM orders o
							JOIN accounts a
							On o.account_id = a.id
							GROUP BY 1
							ORDER BY 2 DESC
							LIMIT 1 ) as t1)
GROUP BY 1,2


/* 8. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts */
Select avg(total)
FROM (
Select a.name, sum(o.total_amt_usd) as total
FROM orders o
JOIN accounts a
On o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10 ) t1

/* 9. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent 
more per order, on average, than the average of all orders.*/
SELECT avg(t1.total_amt)
FROM(SELECT a.name,  avg(total) as total, sum(total_amt_usd) as total_amt
		FROM orders o
		JOIN accounts a
		On o.account_id = a.id
		GROUP BY 1
		Having avg(total) > (Select avg(total) 
						from orders)) as t1


-- 10. You need to find the average number of events for each channel per day. --
	SELECT Channel,AVG(cnt)
	FROM(SELECT channel, Date_trunc('day', occurred_at) as day, count(*) as cnt
			FROM web_events
			GROUP BY 1,2) as t1
	GROUP BY 1

--11. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales --
with tab as (Select r.name as region_name, sr.name as sales_rep, sum(total_amt_usd) as total
			FROM sales_reps sr
			JOIN region r
			on r.id  = sr.region_id
			JOIN accounts a
			on sr.id= a.sales_rep_id
			JOIN orders o
			on a.id = o.account_id
			GROUP BY 1,2
			ORDER BY 3 DESC),
tab2 as (SELECT region_name, max(total) as total_amt
		FROM tab
		GROUP BY 1)
SELECT tab.region_name, tab.sales_rep, tab.total
FROM tab
JOIN tab2
on tab.region_name = tab2.region_name and tab.total =tab2.total_amt

--12. For the region with the largest sales total_amt_usd, how many total orders were placed? --
with t1 as (SELECT r.name as region_name, sum(total_amt_usd) as total_order
		   FROM sales_reps sr
			JOIN region r
			on r.id  = sr.region_id
			JOIN accounts a
			on sr.id= a.sales_rep_id
			JOIN orders o
			on a.id = o.account_id 
			GROUP BY 1
			ORDER BY 2 DESC
		   	LIMIT 1),
t2 as (SELECT  r.name as region_name, count(total) as total_order
		   FROM sales_reps sr
			JOIN region r
			on r.id  = sr.region_id
			JOIN accounts a
			on sr.id= a.sales_rep_id
			JOIN orders o
			on a.id = o.account_id 
			GROUP BY 1)
SELECT t1.region_name, t2.total_order
FROM t1
JOIN t2
on t1.region_name  =t2.region_name

/* 13. For the account that purchased the most (in total over their lifetime as a customer) standard_qty paper, 
how many accounts still had more in total purchases? */
with t1 as (SELECT a.name, sum(standard_qty) as total_std
		   FROM accounts a
		   JOIN orders o
		   ON a.id = o.account_id
		   GROUP BY 1
		   ORDER BY 2 DESC
			LIMIT 1
		   ),
t2 as (SELECT a.name, sum(o.total)
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
HAVING sum(o.total) > (SELECT total_std
					  FROM t1)
ORDER BY 2 DESC)
SELECT count(*)
FROM t2

/* 14. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies 
that spent more per order, on average, than the average of all orders */

with t1 as (Select a.name, avg(total_amt_usd) as avg_total
		   FROM orders o
		   JOIN accounts a
		   ON o.account_id = a.id
			GROUP BY 1
			HAVING avg(total_amt_usd) > (SELECT avg(total_amt_usd)
								FROM orders))
Select avg(avg_total)
FROM t1









					





