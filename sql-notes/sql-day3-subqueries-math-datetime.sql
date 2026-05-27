-- =========================================================
-- DAY 3 : MATH, DATE/TIME FUNCTIONS & SUBQUERIES
-- =========================================================

USE sakila;

-- =========================================================
-- MATH FUNCTIONS
-- =========================================================

-- POWER() : raises number to given power
-- syntax : POWER(number,power)

SELECT title,
       rental_duration,
       POWER(rental_duration,2) AS duration_square
FROM film
LIMIT 5;


-- FLOOR() : rounds DOWN to nearest integer

SELECT amount,
       FLOOR(amount) AS rounded_down
FROM payment
LIMIT 10;


-- CEIL() : rounds UP to nearest integer

SELECT amount,
       CEIL(amount) AS rounded_up
FROM payment
LIMIT 10;


-- ROUND() : rounds normally. 1 → keep 1 digit after decimal point   0-> ROUNDS TO NEAREST WHOLE NUMBER

SELECT replacement_cost,
       ROUND(replacement_cost,1) AS rounded_cost
FROM film
LIMIT 10;


-- RAND() : generates random number

SELECT RAND();


-- MOD() : returns remainder after division

SELECT MOD(10,3);


-- ABS() : converts negative value to positive

SELECT ABS(-50);


-- =========================================================
-- AGGREGATE FUNCTIONS
-- =========================================================

-- Aggregate functions work on multiple rows
-- and return single output value


-- AVG() : average value

SELECT AVG(amount) AS average_payment
FROM payment;


-- MIN() and MAX()

SELECT MIN(replacement_cost) AS lowest_cost,
       MAX(replacement_cost) AS highest_cost
FROM film;


-- SUM() : total
-- COUNT() : total rows

SELECT COUNT(*) AS total_payments,
       SUM(amount) AS total_amount,
       AVG(amount) AS average_amount
FROM payment;


-- =========================================================
-- GROUP BY
-- =========================================================

-- GROUP BY groups similar values together
-- mostly used with aggregate functions

SELECT customer_id,
       COUNT(*) AS total_payments,
       SUM(amount) AS total_paid,
       AVG(amount) AS average_payment,
       MAX(amount) AS highest_payment
FROM payment
GROUP BY customer_id
LIMIT 10;


-- Top customers based on payment

SELECT customer_id,
       SUM(amount) AS total_paid
FROM payment
GROUP BY customer_id
ORDER BY total_paid DESC
LIMIT 10;


-- =========================================================
-- CONCAT()
-- =========================================================

-- CONCAT() combines strings

SELECT CONCAT(first_name,' ',last_name) AS full_name
FROM customer;


-- =========================================================
-- DATE & TIME FUNCTIONS
-- =========================================================

-- NOW() : current date and time

SELECT NOW();


-- CURDATE() : current date only

SELECT CURDATE();


-- CURRENT_TIME() : current time only

SELECT CURRENT_TIME();


-- DATE() : extracts only date from datetime

SELECT payment_date,
       DATE(payment_date) AS only_date
FROM payment
LIMIT 10;


-- DATE_ADD(date, INTERVAL value unit)

-- adds days/months/years to date

-- DATE_ADD()
SELECT NOW() AS current_datetime,
       DATE_ADD(NOW(), INTERVAL 7 DAY) AS after_7_days,
       DATE_ADD(NOW(), INTERVAL 1 MONTH) AS after_1_month,
       DATE_ADD(NOW(), INTERVAL 1 YEAR) AS after_1_year;

-- Explanation:
-- NOW() gives current date and time
-- INTERVAL 7 DAY adds 7 days
-- INTERVAL 1 MONTH adds 1 month
-- INTERVAL 1 YEAR adds 1 year



-- Example using table column

SELECT payment_id,
       payment_date,
       DATE_ADD(payment_date, INTERVAL 7 DAY) AS payment_plus_7_days
FROM payment
LIMIT 10;

-- Explanation:
-- takes payment_date
-- adds 7 days
-- shows new calculated date



-- DATE_SUB(date, INTERVAL value unit)

-- subtracts days/months/years from date
SELECT NOW() AS current_datetime,
       DATE_SUB(NOW(), INTERVAL 7 DAY) AS before_7_days,
       DATE_SUB(NOW(), INTERVAL 1 MONTH) AS before_1_month;

-- Explanation:
-- DATE_SUB subtracts date values
-- INTERVAL 7 DAY subtracts 7 days
-- INTERVAL 1 MONTH subtracts 1 month
-- DATEDIFF() : difference between two dates

SELECT rental_id,
       rental_date,
       return_date,
       DATEDIFF(return_date,rental_date) AS rented_days
FROM rental
WHERE return_date IS NOT NULL
LIMIT 10;


-- DATE_FORMAT() : changes display format of date

SELECT payment_date,
       DATE_FORMAT(payment_date,'%d-%m-%Y') AS formatted_date,
       DATE_FORMAT(payment_date,'%W') AS day_name,
       DATE_FORMAT(payment_date,'%M') AS month_name
FROM payment
LIMIT 10;


-- Common DATE_FORMAT symbols

-- %Y = 4 digit year
-- %y = 2 digit year
-- %m = month number
-- %M = month name
-- %d = day number
-- %W = weekday name
-- %H = hour
-- %i = minutes
-- %s = seconds


-- =========================================================
-- GROUP BY + DATE
-- =========================================================

-- Total revenue collected each day

SELECT DATE(payment_date) AS payment_day,
       COUNT(*) AS total_payments,
       SUM(amount) AS total_amount
FROM payment
GROUP BY DATE(payment_date)
ORDER BY payment_day;


-- Latest payment date of customers

SELECT customer_id,
       MAX(payment_date) AS latest_payment
FROM payment
GROUP BY customer_id
ORDER BY latest_payment DESC
LIMIT 10;


-- =========================================================
-- CASE WITH DATE LOGIC
-- =========================================================

-- CASE works like IF ELSE

SELECT rental_id,
       rental_date,
       return_date,
       CASE
           WHEN return_date IS NULL THEN 'Not Returned'
           WHEN DATEDIFF(return_date,rental_date) <= 3 THEN 'Quick Return'
           WHEN DATEDIFF(return_date,rental_date) BETWEEN 4 AND 7 THEN 'Normal Return'
           ELSE 'Late Return'
       END AS rental_status
FROM rental
LIMIT 20;


-- =========================================================
-- SUBQUERIES
-- =========================================================

-- Subquery = query inside another query

-- Main query = Outer Query
-- Query inside brackets = Inner Query


-- =========================================================
-- 1. WHERE CLAUSE SUBQUERY
-- =========================================================

-- inner query calculates average rental_rate
-- outer query finds films above average

SELECT title,
       rental_rate
FROM film
WHERE rental_rate >
(
    SELECT AVG(rental_rate)
    FROM film
);


-- Another example

SELECT payment_id,
       customer_id,
       amount
FROM payment
WHERE amount >
(
    SELECT AVG(amount)
    FROM payment
);


-- =========================================================
-- 2. SELECT SUBQUERY
-- =========================================================

-- subquery written inside SELECT column

SELECT customer_id,
       first_name,
       last_name,
       (
           SELECT SUM(amount)
           FROM payment
           WHERE payment.customer_id = customer.customer_id
       ) AS total_paid
FROM customer;


-- =========================================================
-- 3. DERIVED TABLE SUBQUERY
-- =========================================================

-- subquery inside FROM clause
-- acts like temporary table

SELECT *
FROM
(
    SELECT customer_id,
           SUM(amount) AS total_paid
    FROM payment
    GROUP BY customer_id
) AS customer_totals
WHERE total_paid > 150;


-- Another example

SELECT *
FROM
(
    SELECT rating,
           AVG(rental_duration) AS avg_rental_days
    FROM film
    GROUP BY rating
) AS rating_summary
WHERE avg_rental_days > 5;


-- =========================================================
-- 4. CORRELATED SUBQUERY
-- =========================================================

-- Normal subquery:
-- inner query runs independently

-- Correlated subquery:
-- inner query depends on outer query values

SELECT customer_id,
       first_name,
       last_name
FROM customer c
WHERE
(
    SELECT SUM(amount)
    FROM payment p
    WHERE p.customer_id = c.customer_id
)
>
(
    SELECT AVG(amount)
    FROM payment
);


-- Another correlated subquery example

SELECT actor_id,
       first_name,
       last_name
FROM actor a
WHERE
(
    SELECT COUNT(*)
    FROM film_actor fa
    WHERE fa.actor_id = a.actor_id
) > 20;


-- =========================================================
-- BRIDGE TABLE
-- =========================================================

-- Bridge table connects many-to-many relationships

-- Example:
-- film
-- film_actor   <-- bridge table
-- actor

-- bridge table stores foreign keys from both tables


-- =========================================================
-- SUBQUERY WITH BRIDGE TABLE
-- =========================================================

-- Find films in Action category

SELECT film_id,
       title
FROM film
WHERE film_id IN
(
    SELECT film_id
    FROM film_category
    WHERE category_id =
    (
        SELECT category_id
        FROM category
        WHERE name = 'Action'
    )
);


-- Find films acted by NICK WAHLBERG

SELECT film_id,
       title
FROM film
WHERE film_id IN
(
    SELECT fa.film_id
    FROM film_actor fa
    WHERE fa.actor_id =
    (
        SELECT actor_id
        FROM actor
        WHERE first_name = 'NICK'
          AND last_name = 'WAHLBERG'
    )
);


-- =========================================================
-- WHEN SUBQUERIES FAIL
-- =========================================================

-- 1. Multiple rows returned

-- WRONG
SELECT title
FROM film
WHERE film_id =
(
    SELECT film_id
    FROM film_category
);

-- '=' expects single value
-- but subquery returns many rows


-- Correct Version

SELECT title
FROM film
WHERE film_id IN
(
    SELECT film_id
    FROM film_category
);


-- =========================================================
-- 2. Multiple columns returned
-- =========================================================

-- WRONG

SELECT title
FROM film
WHERE film_id =
(
    SELECT film_id, category_id
    FROM film_category
);

-- subquery should return only one column


-- =========================================================
-- 3. Missing alias in derived table
-- =========================================================

-- WRONG

SELECT *
FROM
(
    SELECT *
    FROM actor
);

-- derived tables MUST have alias


-- Correct Version

SELECT *
FROM
(
    SELECT *
    FROM actor
) AS actor_table;


-- =========================================================
-- 4. Data type mismatch
-- =========================================================

-- comparing incompatible data types causes errors


-- =========================================================
-- 5. Aggregate function used incorrectly
-- =========================================================

-- WRONG

SELECT first_name
FROM customer
WHERE SUM(store_id) > 1;

-- aggregate functions cannot be directly used in WHERE