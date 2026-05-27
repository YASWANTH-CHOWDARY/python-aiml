-- =========================================================
-- DAY 4 : CARDINALITY & JOINS
-- =========================================================

USE sakila;

-- =========================================================
-- CARDINALITY
-- =========================================================

-- Cardinality:
-- how rows from one table relate to rows in another table

-- Example:
-- one customer can make many rentals
-- one film can belong to many categories

-- Cardinality helps:
-- understand relationships
-- avoid duplicate data
-- write proper JOIN queries


-- =========================================================
-- TYPES OF CARDINALITY
-- =========================================================

-- 1 : 1  (One to One)
-- one row connects to one row

-- Example:
-- one user -> one profile


-- 1 : MANY
-- one row connects to many rows

-- Example:
-- one customer -> many rentals


-- MANY : 1
-- many rows connect to one row

-- Example:
-- many rentals -> one customer


-- MANY : MANY
-- many rows connect to many rows
-- usually needs bridge table

-- Example:
-- many actors -> many films

-- bridge table:
-- film_actor


-- =========================================================
-- JOINS
-- =========================================================

-- JOIN:
-- combines data from multiple tables

-- usually:
-- primary key joins with foreign key


-- =========================================================
-- INNER JOIN
-- =========================================================

-- returns ONLY matching rows

SELECT
    c.customer_id,
    c.first_name,
    r.rental_id
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id;

-- only customers with rentals appear


-- Example 2

SELECT
    f.title,
    l.name AS language_name
FROM film f
INNER JOIN language l
ON f.language_id = l.language_id;

-- only matching language records appear


-- =========================================================
-- LEFT JOIN
-- =========================================================

-- returns ALL rows from left table
-- unmatched right rows become NULL

SELECT
    c.customer_id,
    c.first_name,
    r.rental_id
FROM customer c
LEFT JOIN rental r
ON c.customer_id = r.customer_id;

-- all customers appear
-- customers without rentals get NULL


-- Example 2

SELECT
    a.actor_id,
    a.first_name,
    f.title
FROM actor a
LEFT JOIN film_actor fa
ON a.actor_id = fa.actor_id
LEFT JOIN film f
ON fa.film_id = f.film_id;


-- =========================================================
-- LEFT JOIN EXCLUDING INNER JOIN
-- =========================================================

-- shows unmatched rows from left table only

-- customers with NO rentals

SELECT
    c.customer_id,
    c.first_name
FROM customer c
LEFT JOIN rental r
ON c.customer_id = r.customer_id
WHERE r.rental_id IS NULL;


-- IMPORTANT NOTE

-- WRONG:
-- this condition removes NULL rows
-- LEFT JOIN behaves like INNER JOIN

SELECT *
FROM customer c
LEFT JOIN rental r
ON c.customer_id = r.customer_id
WHERE r.customer_id = 1;


-- =========================================================
-- RIGHT JOIN
-- =========================================================

-- returns ALL rows from right table

SELECT
    c.first_name,
    r.rental_id
FROM customer c
RIGHT JOIN rental r
ON c.customer_id = r.customer_id;

-- all rentals appear
-- unmatched customer rows become NULL


-- WRONG JOIN EXAMPLE

SELECT *
FROM customer c
RIGHT JOIN payment p
ON c.store_id = p.customer_id;

-- unrelated columns should not be joined


-- =========================================================
-- FULL OUTER JOIN
-- =========================================================

-- returns:
-- matching rows
-- left unmatched rows
-- right unmatched rows

-- MySQL does NOT support FULL JOIN directly

-- simulate using:
-- LEFT JOIN + UNION + RIGHT JOIN

SELECT
    c.customer_id,
    r.rental_id
FROM customer c
LEFT JOIN rental r
ON c.customer_id = r.customer_id

UNION

SELECT
    c.customer_id,
    r.rental_id
FROM customer c
RIGHT JOIN rental r
ON c.customer_id = r.customer_id;


-- THIS FAILS IN MYSQL

SELECT *
FROM customer c
FULL JOIN rental r
ON c.customer_id = r.customer_id;


-- =========================================================
-- RIGHT JOIN EXCLUDING INNER JOIN
-- =========================================================

-- shows unmatched rows from right table only

SELECT
    f.film_id,
    f.title,
    i.inventory_id
FROM film f
RIGHT JOIN inventory i
ON f.film_id = i.film_id
WHERE f.film_id IS NULL;


-- =========================================================
-- FULL OUTER JOIN EXCLUDING INNER JOIN
-- =========================================================

-- shows only unmatched rows from both tables

SELECT
    f.film_id,
    f.title,
    i.inventory_id
FROM film f
LEFT JOIN inventory i
ON f.film_id = i.film_id
WHERE i.inventory_id IS NULL

UNION

SELECT
    f.film_id,
    f.title,
    i.inventory_id
FROM film f
RIGHT JOIN inventory i
ON f.film_id = i.film_id
WHERE f.film_id IS NULL;


-- =========================================================
-- CROSS JOIN
-- =========================================================

-- returns every possible combination

SELECT
    c.first_name,
    s.store_id
FROM customer c
CROSS JOIN store s;

-- Example:
-- 100 customers
-- 2 stores
-- result = 200 rows


-- NOTE:
-- CROSS JOIN can create huge data


-- =========================================================
-- SELF JOIN
-- =========================================================

-- joining table with itself

-- aliases are required

SELECT
    c1.customer_id AS customer_1_id,
    c1.first_name AS customer_1_name,
    c2.customer_id AS customer_2_id,
    c2.first_name AS customer_2_name,
    c1.store_id
FROM customer c1
INNER JOIN customer c2
ON c1.store_id = c2.store_id
WHERE c1.customer_id <> c2.customer_id;

-- finds customers from same store


-- =========================================================
-- QUICK REVISION
-- =========================================================

-- INNER JOIN
-- only matching rows

-- LEFT JOIN
-- all left rows + matching right rows

-- RIGHT JOIN
-- all right rows + matching left rows

-- FULL OUTER JOIN
-- everything from both tables

-- CROSS JOIN
-- every possible combination

-- SELF JOIN
-- table joined with itself

-- LEFT JOIN EXCLUDING INNER JOIN
-- unmatched left rows only

-- RIGHT JOIN EXCLUDING INNER JOIN
-- unmatched right rows only

-- FULL OUTER JOIN EXCLUDING INNER JOIN
-- unmatched rows from both sides