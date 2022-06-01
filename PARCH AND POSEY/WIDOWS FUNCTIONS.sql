/* 1. create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
Your final table should have two columns: one with the amount being added for each new row, and a second with the
running total.*/

SELECT
	standard_amt_usd,
	SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders

/* 2. modify your query from the previous quiz to include partitions. Still create a running total of 
standard_amt_usd (in the orders table) */

SELECT
	standard_amt_usd,
	SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at ) AS occurred_at
FROM orders

/* 3. Select the id, account_id, and total variable from the orders table, then create a column called total_rank 
that ranks this total amount of paper ordered (from highest to lowest) for each account using a partition. Your final 
table should have these four columns. */

SELECT 
	id, account_id, total,
	Rank()over (partition by account_id order by total desc) as total_rank
FROM orders

/*4. */
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders

/* Now remove ORDER BY DATE_TRUNC('month',occurred_at) in each line of the query that contains it in the SQL
Explorer below. Evaluate your new query, compare it to the results in the SQL Explorer above */

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER win AS dense_rank,
       SUM(standard_qty) OVER win AS sum_std_qty,
       COUNT(standard_qty) OVER win AS count_std_qty,
       AVG(standard_qty) OVER win AS avg_std_qty,
       MIN(standard_qty) OVER win AS min_std_qty,
       MAX(standard_qty) OVER win AS max_std_qty
FROM orders
WINDOW win as(PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) 