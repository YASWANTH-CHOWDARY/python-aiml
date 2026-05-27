-- =========================================================
-- ASSIGNMENT 2 : BUILT-IN FUNCTIONS
-- =========================================================


-- 1. Identify duplicates in customer table
-- (without using customer_id)

SELECT first_name,
       last_name,
       email,
       COUNT(*) AS duplicate_count
FROM customer
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;



-- 2. Number of times letter 'a' is repeated
-- in film descriptions

SELECT SUM(
       LENGTH(description) -
       LENGTH(REPLACE(LOWER(description), 'a', ''))
       ) AS total_a_count
FROM film;



-- 3. Number of times each vowel is repeated
-- in film descriptions

SELECT
SUM(LENGTH(LOWER(description)) -
    LENGTH(REPLACE(LOWER(description), 'a', ''))) AS a_count,

SUM(LENGTH(LOWER(description)) -
    LENGTH(REPLACE(LOWER(description), 'e', ''))) AS e_count,

SUM(LENGTH(LOWER(description)) -
    LENGTH(REPLACE(LOWER(description), 'i', ''))) AS i_count,

SUM(LENGTH(LOWER(description)) -
    LENGTH(REPLACE(LOWER(description), 'o', ''))) AS o_count,

SUM(LENGTH(LOWER(description)) -
    LENGTH(REPLACE(LOWER(description), 'u', ''))) AS u_count
FROM film;



-- 4. Display payments made by each customer

-- 4.1 Month wise

select 
customer_id,
month(payment_date) as payment_month,
sum(amount) as total_payment
from payment
group by customer_id, month(payment_date);



-- 4.2 Year wise
select 
customer_id,
year(payment_date) as payment_month,
sum(amount) as total_payment
from payment
group by customer_id, year(payment_date);




-- 4.3 Week wise

select 
customer_id,
week(payment_date) as payment_month,
sum(amount) as total_payment
from payment
group by customer_id, week(payment_date);



-- 5. Check if a given year is leap year or not

-- IS NOT is used with NULL, not numbers. use <> 0
SELECT
CASE
    WHEN (2024 % 400 = 0)
      OR (2024 % 4 = 0 AND 2024 % 100 <> 0)
    THEN 'Leap Year'
    ELSE 'Not a Leap Year'
END AS leap_year_check;



-- 6. Display number of days remaining
-- in current year from today

SELECT DATEDIFF(
       CONCAT(YEAR(CURDATE()), '-12-31'),
       CURDATE()
       ) AS remaining_days;



-- 7. Display quarter number for payment dates

SELECT payment_id,
       payment_date,
       CONCAT('Q', QUARTER(payment_date)) AS quarter_number
FROM payment;



-- 8. Display age in years, months, days
-- Replace DOB with your actual date of birth

SELECT
TIMESTAMPDIFF(YEAR, '2002-11-27', CURDATE()) AS years,
TIMESTAMPDIFF(MONTH, '2002-11-27', CURDATE()) % 12 AS months,
DATEDIFF(CURDATE(), DATE_ADD('2002-11-27',
INTERVAL TIMESTAMPDIFF(MONTH, '2002-11-27', CURDATE()) MONTH)) AS days;