-- =========================================================
-- SQL DAY 2 NOTES - 20 MAY 2026
-- =========================================================

USE sakila;

-- =========================================================
-- DQL COMMANDS
-- =========================================================

-- SELECT:
-- Used to retrieve all columns from a table
SELECT * FROM customer;

-- SELECT specific columns only
SELECT first_name, last_name
FROM customer;


-- DISTINCT:
-- Removes duplicate values
-- Shows only unique values
SELECT DISTINCT rating
FROM film;


-- WHERE:
-- Filters rows based on condition
-- Filters rows before grouping
SELECT title, rating
FROM film
WHERE rating = 'PG';


-- WHERE with numeric condition
SELECT title, rental_rate
FROM film
WHERE rental_rate > 3.99;


-- COUNT(*):
-- Counts total rows
SELECT COUNT(*)
FROM actor;


-- COUNT(column_name):
-- Counts non-null values
SELECT COUNT(email)
FROM customer;


-- COUNT DISTINCT:
-- Counts only unique values
SELECT COUNT(DISTINCT rating)
FROM film;


-- LIMIT:
-- Restricts output rows
SELECT *
FROM actor
LIMIT 5;


-- ORDER BY:
-- Sorts values in ascending order
SELECT title, release_year
FROM film
ORDER BY release_year;


-- ORDER BY DESC:
-- Sorts values in descending order
SELECT title, rental_rate
FROM film
ORDER BY rental_rate DESC;


-- AND:
-- Both conditions must be true
SELECT title, rating, rental_rate
FROM film
WHERE rating='PG'
AND rental_rate=2.99;


-- OR:
-- Any one condition can be true
SELECT title, rating
FROM film
WHERE rating='PG'
OR rating='G';


-- NOT:
-- Excludes matching condition
SELECT title, rating
FROM film
WHERE NOT rating='R';


-- BETWEEN:
-- Includes start and end values
SELECT title, length
FROM film
WHERE length BETWEEN 60 AND 120;


-- IS NULL:
-- Finds NULL values
SELECT title, original_language_id
FROM film
WHERE original_language_id IS NULL;


-- IS NOT NULL:
-- Finds non-null values
SELECT address, address2
FROM address
WHERE address2 IS NOT NULL;


-- LIKE:
-- Used for pattern matching

-- % :
-- Represents multiple characters

-- Starts with C
SELECT first_name
FROM customer
WHERE first_name LIKE 'C%';


-- Ends with N
SELECT first_name
FROM customer
WHERE first_name LIKE '%N';


-- _ :
-- Represents exactly one character

-- Second letter should be A
SELECT first_name
FROM customer
WHERE first_name LIKE '_A%';


-- GROUP BY:
-- Groups similar values together
SELECT rating,
       COUNT(*) AS total_movies
FROM film
GROUP BY rating;


-- HAVING:
-- Filters grouped data
-- Filters grouped rows after GROUP BY
SELECT rating,
       COUNT(*) AS total_movies
FROM film
GROUP BY rating
HAVING COUNT(*) > 200;


-- GROUP BY + ORDER BY
SELECT rating,
       COUNT(*) AS total_movies
FROM film
GROUP BY rating
ORDER BY total_movies DESC;


-- WHERE vs HAVING

-- WHERE filters rows before grouping
-- HAVING filters groups after grouping

SELECT rating,
       COUNT(*) AS total_movies
FROM film
WHERE rental_rate > 2.99
GROUP BY rating
HAVING COUNT(*) > 50;


-- =========================================================
-- SQL EXECUTION ORDER
-- =========================================================

-- FROM
-- WHERE
-- GROUP BY
-- HAVING
-- SELECT
-- ORDER BY
-- LIMIT


-- =========================================================
-- STRING BUILT-IN FUNCTIONS
-- =========================================================

-- CONCAT:
-- Combines multiple strings
SELECT CONCAT(first_name,' ',last_name)
AS full_name
FROM actor;


-- UPPER:
-- Converts text into uppercase
SELECT UPPER(first_name)
FROM actor;


-- LOWER:
-- Converts text into lowercase
SELECT LOWER(last_name)
FROM actor;


-- LENGTH:
-- Returns total characters
SELECT title,
       LENGTH(title) AS title_length
FROM film;


-- LEFT:
-- Extracts characters from left side
SELECT first_name,
       LEFT(first_name,3) AS short_name
FROM customer;


-- RIGHT:
-- Extracts characters from right side
SELECT last_name,
       RIGHT(last_name,4) AS end_letters
FROM customer;


-- SUBSTRING:
-- Extracts part of string
SELECT title,
       SUBSTRING(title,1,5) AS short_title
FROM film;


-- REVERSE:
-- Reverses text
SELECT first_name,
       REVERSE(first_name) AS reversed_name
FROM actor;


-- REPLACE:
-- Replaces old text with new text
SELECT email,
       REPLACE(email,'.org','.com') AS updated_email
FROM customer;


-- LPAD:
-- Adds characters on left side
SELECT customer_id,
       LPAD(customer_id,5,'0') AS formatted_id
FROM customer;


-- RPAD:
-- Adds characters on right side
SELECT first_name,
       RPAD(first_name,10,'*') AS padded_name
FROM actor;


-- LOCATE:
-- Finds position of character/string
SELECT title,
       LOCATE('A',title) AS position_of_A
FROM film;


-- SUBSTRING_INDEX:
-- Splits string using delimiter

-- Text before @
SELECT email,
       SUBSTRING_INDEX(email,'@',1) AS username
FROM customer;


-- Text after @
SELECT email,
       SUBSTRING_INDEX(email,'@',-1) AS domain
FROM customer;


-- CASE:
-- Creates conditional output
-- Works like IF ELSE in SQL

SELECT title,
       rental_rate,
       CASE
            WHEN rental_rate=0.99 THEN 'Cheap'
            WHEN rental_rate=2.99 THEN 'Medium'
            ELSE 'Expensive'
       END AS movie_price
FROM film;


-- REGEXP:
-- Used for pattern matching

-- Titles containing LOVE or NIGHT
SELECT title
FROM film
WHERE title REGEXP 'LOVE|NIGHT';


-- NOT REGEXP:
-- Excludes pattern matching

SELECT first_name
FROM actor
WHERE first_name NOT REGEXP '^[AEIOUaeiou]';


-- =========================================================
-- COMBINED PRACTICE QUERY
-- =========================================================

-- Filters rows first using WHERE
-- Groups data using GROUP BY
-- Filters groups using HAVING
-- Sorts result using ORDER BY

SELECT rating,
       COUNT(*) AS total_movies
FROM film
WHERE rental_rate > 2.99
GROUP BY rating
HAVING COUNT(*) > 50
ORDER BY total_movies DESC;


-- =========================================================
-- GROUP BY RULE
-- =========================================================

-- With GROUP BY use:
-- 1) Grouped columns
-- 2) Aggregate functions like COUNT(), AVG(), SUM()

-- Correct
SELECT rating,
       COUNT(*)
FROM film
GROUP BY rating;


-- Wrong
-- SELECT *
-- FROM film
-- GROUP BY rating;

-- SQL gets confused which row values to display.