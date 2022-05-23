/*1. In the accounts table, there is a column holding the website for each company. The last three digits 
specify what type of web address they are using. A list of extensions (and pricing) is provided here. 
Pull these extensions and provide how many of each website type exist in the accounts table. */

SELECT RIGHT(website,3), count(*)
FROM accounts
GROUP BY 1
ORDER BY 2 desc

/*2. There is much debate about how much the name (or even the first letter of a company name) matters. 
Use the accounts table to pull the first letter of each company name to see the distribution of company names that
begin with each letter (or number). */
SELECT LEFT(name,1), count(*)
FROM accounts
GROUP BY 1
ORDER BY 1 

/* 3. Use the accounts table and a CASE statement to create two groups: one group of company names that start with a 
number and a second group of those company names that start with a letter.What proportion of company names 
start with a letter? */
SELECT sum(numbers) as numbers, SUM(letters) as letters
FROM(
	SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
			 THEN 1 ELSE 0 END AS numbers,
			 CASE WHEN LEFT(UPPER(name), 1) NOT IN ('0','1','2','3','4','5','6','7','8','9')
			 THEN 1 ELSE 0 END AS letters
	FROM accounts) as t1

/* 4. Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start
with anything else? */
SELECT SUM(vowels) as vowels, SUM(not_vowels) as not_vowels
FROM(
	SELECT name, CASE WHEN LEFT(UPPER(NAME), 1) IN ('A', 'E', 'I', 'O', 'U')
				THEN 1 Else 0 END AS vowels,
			CASE WHEN LEFT(UPPER(NAME), 1) NOT IN ('A', 'E', 'I', 'O', 'U')
				THEN 1 Else 0 END AS not_vowels
	FROM accounts) as t1

/* 5. Use the accounts table to create first and last name columns that hold the first and last names 
for the primary_poc */
SELECT primary_poc, LEFT(primary_poc, STRPOS(primary_poc, ' ') -1) as first_name,
		RIGHT(primary_poc, Length(primary_poc) - STRPOS(primary_poc, ' ')) as last_name
FROM accounts

/* 6.  Now see if you can do the same thing for every rep name in the sales_reps table. 
Again provide first and last name columns */

SELECT name, LEFT(name, STRPOS(name, ' ')-1) as first_name,
		RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) as last_name
FROM Sales_reps

/* 7. Each company in the accounts table wants to create an email address for each primary_poc. The email address
should be the first name of the primary_poc . last name primary_poc @ company name .com. */
with t1 as (SELECT name, LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) as first_name,
		RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) as last_name
		FROM accounts)
SELECT CONCAT(first_name,'.',last_name,'@', name,'.com') as email
FROM t1

/* 8.You may have noticed that in the previous solution some of the company namesinclude spaces, which will 
certainly not work in an email address. See if you can create an email address that will work by removing 
all of the spaces in the account name, but otherwise your solution should be just as in question 3. */
with t1 as (SELECT name, LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) as first_name,
		RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) as last_name
		FROM accounts)
SELECT CONCAT(first_name,'.',last_name,'@', REPLACE(name, ' ', ''),'.com') as email
FROM t1

/* 9. We would also like to create an initial password, which they will change after their first log in. 
The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of 
their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name 
(lowercase), the number of letters in their first name, the number of letters in their last name, and then the name 
of the company they are working with, all capitalized with no spaces.*/
with t1 as (SELECT name, LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) as first_name,
		RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) as last_name
		FROM accounts)
SELECT first_name,last_name,CONCAT(first_name, '.', last_name, '@', name, '.com') as email,
		LEFT(LOWER(first_name),1) || RIGHT(LOWER(first_name),1) || LEFT(LOWER(last_name),1) || RIGHT(LOWER(last_name),1)
		|| LENGTH(first_name) || LENGTH(last_name) || name as password
FROM t1
 			
 