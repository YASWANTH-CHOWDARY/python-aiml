-- =========================================================
-- DAY 6 : INDEXES, KEYS & QUERY FINE TUNING
-- =========================================================

USE sakila;

-- =========================================================
-- INDEXES
-- =========================================================

-- Index:
-- helps MySQL find rows faster

-- without index:
-- MySQL may scan full table row by row

-- with index:
-- MySQL can directly locate data

-- similar to book index page


-- =========================================================
-- CLUSTERED INDEX
-- =========================================================

-- Clustered Index:
-- decides physical order of table data

-- In MySQL InnoDB:
-- PRIMARY KEY acts as clustered index

-- table data is stored based on primary key order


-- Example

SELECT
    customer_id,
    first_name,
    last_name
FROM customer
WHERE customer_id = 10;


-- view indexes

SHOW INDEX FROM customer;


-- =========================================================
-- NON-CLUSTERED INDEX
-- =========================================================

-- separate index created on column

-- does NOT change physical table order

-- stores:
-- indexed value + pointer to actual row


-- create index on last_name

CREATE INDEX idx_customer_last_name
ON customer(last_name);


-- query using indexed column

SELECT
    customer_id,
    first_name,
    last_name
FROM customer
WHERE last_name = 'SMITH';


-- remove index

DROP INDEX idx_customer_last_name
ON customer;


-- =========================================================
-- COMPOSITE INDEX
-- =========================================================

-- index created on multiple columns

-- useful when query uses multiple conditions


CREATE INDEX idx_rental_customer_date
ON rental(customer_id, rental_date);


SELECT
    rental_id,
    customer_id,
    rental_date
FROM rental
WHERE customer_id = 10
ORDER BY rental_date;


-- =========================================================
-- NATURAL KEY
-- =========================================================

-- Natural Key:
-- real-world meaningful value

-- examples:
-- email
-- passport number
-- phone number


SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM customer
WHERE email = 'MARY.SMITH@sakilacustomer.org';


-- Problem:
-- natural values can change

-- example:
-- customer may change email

-- so natural keys are not always good as primary keys


-- =========================================================
-- SURROGATE KEY
-- =========================================================

-- Surrogate Key:
-- artificial ID created for database

-- no real-world meaning

-- examples:
-- customer_id
-- film_id
-- rental_id


SELECT
    c.customer_id,
    c.first_name,
    r.rental_id
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
WHERE c.customer_id = 1;


-- =========================================================
-- QUERY FINE TUNING
-- =========================================================

-- Query Fine Tuning:
-- improving query performance
-- reducing execution time
-- reducing resource usage


-- =========================================================
-- TECHNIQUE 1 : EXPLAIN
-- =========================================================

-- EXPLAIN shows:
-- how MySQL executes query

EXPLAIN

SELECT
    customer_id,
    first_name,
    last_name
FROM customer
WHERE last_name = 'SMITH';


-- Important Columns

-- type
-- possible_keys
-- key
-- rows
-- Extra

-- if key = NULL
-- no index is being used

-- if rows value is huge
-- MySQL is scanning many rows


-- =========================================================
-- TECHNIQUE 2 : AVOID SELECT *
-- =========================================================

-- BAD

SELECT *
FROM customer;


-- BETTER

SELECT
    customer_id,
    first_name,
    email
FROM customer;

-- less data is fetched
-- query becomes faster


-- =========================================================
-- TECHNIQUE 3 : FILTER EARLY USING WHERE
-- =========================================================

-- BAD

SELECT
    payment_id,
    amount
FROM payment;


-- BETTER

SELECT
    payment_id,
    amount
FROM payment
WHERE amount > 8;

-- fewer rows processed


-- =========================================================
-- TECHNIQUE 4 : INDEX FREQUENTLY FILTERED COLUMNS
-- =========================================================

CREATE INDEX idx_payment_amount
ON payment(amount);


SELECT
    payment_id,
    amount
FROM payment
WHERE amount > 8;


-- =========================================================
-- TECHNIQUE 5 : AVOID FUNCTIONS ON INDEXED COLUMNS
-- =========================================================

-- BAD

SELECT
    payment_id,
    payment_date
FROM payment
WHERE DATE(payment_date) = '2005-05-25';

-- function may prevent proper index usage


-- BETTER

SELECT
    payment_id,
    payment_date
FROM payment
WHERE payment_date >= '2005-05-25'
AND payment_date < '2005-05-26';


-- =========================================================
-- TECHNIQUE 6 : USE JOIN INSTEAD OF REPEATED SUBQUERIES
-- =========================================================

-- LESS EFFICIENT

SELECT
    customer_id,
    first_name
FROM customer
WHERE customer_id IN
(
    SELECT customer_id
    FROM payment
    WHERE amount > 10
);


-- BETTER

SELECT DISTINCT
    c.customer_id,
    c.first_name
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
WHERE p.amount > 10;


-- =========================================================
-- TECHNIQUE 7 : USE LIMIT DURING TESTING
-- =========================================================

SELECT
    rental_id,
    rental_date
FROM rental
LIMIT 10;

-- avoids loading huge data unnecessarily


-- =========================================================
-- TECHNIQUE 8 : INDEX JOIN COLUMNS
-- =========================================================

SELECT
    f.film_id,
    f.title,
    i.inventory_id
FROM film f
JOIN inventory i
ON f.film_id = i.film_id;

-- join columns should usually be indexed


-- =========================================================
-- TECHNIQUE 9 : COMPOSITE INDEX FOR MULTIPLE CONDITIONS
-- =========================================================

CREATE INDEX idx_payment_customer_amount
ON payment(customer_id, amount);


SELECT
    payment_id,
    customer_id,
    amount
FROM payment
WHERE customer_id = 10
AND amount > 5;


-- =========================================================
-- TECHNIQUE 10 : BE CAREFUL WITH OR
-- =========================================================

-- LESS EFFICIENT

SELECT
    customer_id,
    first_name,
    last_name
FROM customer
WHERE first_name = 'MARY'
OR last_name = 'SMITH';


-- SOMETIMES BETTER

SELECT
    customer_id,
    first_name,
    last_name
FROM customer
WHERE first_name = 'MARY'

UNION

SELECT
    customer_id,
    first_name,
    last_name
FROM customer
WHERE last_name = 'SMITH';


-- =========================================================
-- TECHNIQUE 11 : USE EXISTS
-- =========================================================

-- checks whether matching row exists

SELECT
    c.customer_id,
    c.first_name
FROM customer c
WHERE EXISTS
(
    SELECT 1
    FROM payment p
    WHERE p.customer_id = c.customer_id
);


-- =========================================================
-- TECHNIQUE 12 : AVOID UNNECESSARY DISTINCT
-- =========================================================

-- DISTINCT adds extra work

SELECT DISTINCT
    first_name
FROM customer;

-- use only when unique rows are needed


-- =========================================================
-- TECHNIQUE 13 : FILTER BEFORE GROUP BY
-- =========================================================

-- BETTER

SELECT
    customer_id,
    SUM(amount) AS total_amount
FROM payment
WHERE amount > 5
GROUP BY customer_id
HAVING SUM(amount) > 100;

-- WHERE filters rows first
-- HAVING filters groups after GROUP BY


-- =========================================================
-- TECHNIQUE 14 : AVOID LEADING WILDCARD
-- =========================================================

-- BAD

SELECT
    film_id,
    title
FROM film
WHERE title LIKE '%ACADEMY%';

-- index may not be used


-- BETTER

SELECT
    film_id,
    title
FROM film
WHERE title LIKE 'ACADEMY%';


-- =========================================================
-- TECHNIQUE 15 : USE PROPER DATA TYPES
-- =========================================================

-- Better Choices

-- amount -> DECIMAL
-- date   -> DATE / DATETIME
-- id     -> INT
-- name   -> VARCHAR

-- wrong data types can reduce performance


-- =========================================================
-- TECHNIQUE 16 : AVOID UNNECESSARY SORTING
-- =========================================================

-- LESS EFFICIENT

SELECT
    rental_id,
    rental_date
FROM rental
ORDER BY rental_date;


-- BETTER

SELECT
    rental_id,
    rental_date
FROM rental
ORDER BY rental_date
LIMIT 20;


-- index on sorting column helps

CREATE INDEX idx_rental_date
ON rental(rental_date);


-- =========================================================
-- TECHNIQUE 17 : COVERING INDEX
-- =========================================================

-- covering index:
-- index contains all required columns


CREATE INDEX idx_customer_name_email
ON customer(last_name, first_name, email);


SELECT
    first_name,
    email
FROM customer
WHERE last_name = 'SMITH';

-- MySQL may fetch data directly from index


-- =========================================================
-- TECHNIQUE 18 : AVOID TOO MANY INDEXES
-- =========================================================

-- too many indexes slow:
-- INSERT
-- UPDATE
-- DELETE

-- because every index must also be updated


-- Good Columns for Indexes

-- columns used in WHERE
-- columns used in JOIN
-- columns used in ORDER BY
-- columns used in GROUP BY
-- foreign key columns


-- Bad Columns for Indexes

-- rarely used columns
-- columns with few unique values
-- very small tables


-- =========================================================
-- CHECK EXISTING INDEXES
-- =========================================================

SHOW INDEX FROM customer;

SHOW INDEX FROM rental;

SHOW INDEX FROM payment;

-- =========================================================
-- QUICK REVISION
-- =========================================================

-- Index
-- helps MySQL find rows faster

-- Clustered Index
-- PRIMARY KEY based physical data order

-- Non-Clustered Index
-- separate index with pointers to rows

-- Composite Index
-- index on multiple columns

-- Natural Key
-- real-world meaningful unique value

-- Surrogate Key
-- artificial database ID

-- EXPLAIN
-- shows query execution plan

-- Avoid SELECT *
-- fetch only needed columns

-- WHERE before GROUP BY
-- filters rows earlier

-- HAVING
-- filters grouped data

-- EXISTS
-- checks if matching row exists

-- JOIN usually better than repeated subqueries

-- Avoid functions on indexed columns

-- Avoid leading wildcard LIKE '%text%'

-- Too many indexes slow INSERT/UPDATE/DELETE

-- Good index columns:
-- WHERE, JOIN, ORDER BY, GROUP BY columns