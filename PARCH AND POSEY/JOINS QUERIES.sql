--------------JOINS ------------------------------
/* 1. Try pulling all the data from the accounts table, and all the data from the orders table. */
	SELECT * 
	FROM accounts a
		JOIN orders o
		ON a.id = o.account_id

/* 2. Try pulling standard_qty, gloss_qty, and poster_qty from the orders table, and the website and 
the primary_poc from the accounts table. */
	SELECT o.standard_qty, o.gloss_qty, o.poster_qty, a.website, a.primary_poc
	FROM accounts a
		JOIN orders o
		ON a.id = o.account_id

/* 3. Provide a table for all web_events associated with account name of Walmart. There should be three columns. 
Be sure to include the primary_poc, time of the event, and the channel for each event. Additionally, you might choose
to add a fourth column to assure only Walmart events were chosen */
	SELECT a.primary_poc, w.occurred_at, w.channel, a.name
	FROM accounts a
		JOIN web_events w
		ON a.id = w.account_id
	WHERE a.name = 'Walmart'


/* 4.Provide a table that provides the region for each sales_rep along with their associated accounts. Your final table 
should include three columns: the region name, the sales rep name, and the account name.
Sort the accounts alphabetically (A-Z) according to account name. */

	SELECT  r.name, sr.name as region, a.name as account_name
	FROM accounts a
		JOIN sales_reps sr 
		ON a.sales_rep_id = sr.id
		JOIN region r
		ON sr.region_id = r.id
	ORDER BY 3 asc;

/* 4. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) 
for the order. Your final table should have 3 columns: region name, account name, and unit price. A few accounts have
0 for total, so I divided by (total + 0.01) to assure not dividing by zero */

	SELECT r.name as region, a.name as account_name, (o.total_amt_usd/(o.total + 0.01)) as Unit_price
	FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		on sr.id = a.sales_rep_id
		JOIN orders o
		ON a.id = o.account_id
		
/* 5. Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for the Midwest region. Your final table should include three columns: the region name, the sales rep name, 
and the account name. Sort the accounts alphabetically (A-Z) according to account name */

	SELECT  r.name as region, sr.name as Sales_Rep, a.name as name
	FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		on sr.id = a.sales_rep_id
	WHERE r.name = 'Midwest'
	ORDER BY 3 asc
		
/* 6. Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts
where the sales rep has a first name starting with S and in the Midwest region. Your final table should include three columns: 
the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name. */
	
	SELECT  r.name as region, sr.name as Sales_Rep, a.name as name
	FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		on sr.id = a.sales_rep_id
	WHERE r.name = 'Midwest' and sr.name like 'S%'
	ORDER BY 3 asc

/* 7. Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for accounts where the sales rep has a last name starting with K and in the Midwest region. Your final table should
include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according 
to account name */
	SELECT  r.name as region, sr.name as Sales_Rep, a.name as name
	FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		on sr.id = a.sales_rep_id
	WHERE r.name = 'Midwest' and sr.name like '% K%'
	ORDER BY 3 asc

/* 8. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) 
for the order. However, you should only provide the results if the standard order quantity exceeds 100. Your final table should 
have 3 columns: region name, account name, and unit price. In order to avoid a division by zero error, adding .01 to the 
denominator here is helpful total_amt_usd/(total+0.01) */

	SELECT r.name as region, a.name as account_name, (o.total_amt_usd/(o.total + 0.01)) as Unit_price
	FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		on sr.id = a.sales_rep_id
		JOIN orders o
		ON a.id = o.account_id
	WHERE o.standard_qty > 100;
	
/* 9. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total)
for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order 
quantityexceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the 
smallest unit price first.In order to avoid a division by zero error, adding .01 to the denominator here is helpful 
(total_amt_usd/(total+0.01) */
	SELECT r.name as region, a.name as account_name, (o.total_amt_usd/(o.total + 0.01)) as Unit_price
	FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		on sr.id = a.sales_rep_id
		JOIN orders o
		ON a.id = o.account_id
	WHERE o.standard_qty > 100 and poster_qty > 50
	ORDER By 3 asc;

/* 10. What are the different channels used by account id 1001? Your final table should have only 2 columns: 
account name and the different channels*/
	SELECT a.name, w.channel
	FROM accounts a
		JOIN web_events w
		ON a.id = w.account_id
	WHERE a.id =  1001
	group by 1,2

/* 11. Find all the orders that occurred in 2015. Your final table should have 4 columns: occurred_at, account name, 
order total, and order total_amt_usd */

	SELECT w.occurred_at, a.name, o.total, 0.total_amount_usd
	FROM web_events w
		JOIN accounts a
		ON w. account_id = a.id
		JOIN orders o
		ON a.id = o.account_id
	WHERE w.occurred_at BETWEEN '01-01-2015' and '01-01-2016'
		
		
