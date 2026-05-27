-- =========================================================
-- DAY 5 : TEMPORARY TABLES, VIEWS & STORED PROCEDURES
-- =========================================================

USE sakila;

-- =========================================================
-- TEMPORARY TABLES
-- =========================================================

-- Temporary Table:
-- table created only for current session

-- once MySQL closes:
-- temporary table gets deleted automatically

-- useful for:
-- breaking large queries
-- storing intermediate results
-- avoiding repeated calculations
-- simplifying logic


-- Basic Syntax

-- CREATE TEMPORARY TABLE table_name AS
-- SELECT ...


-- =========================================================
-- EXAMPLE 1 : TEMPORARY TABLE
-- =========================================================

-- remove old temp table if exists

DROP TEMPORARY TABLE IF EXISTS temp_top_customers;

-- create temporary table

CREATE TEMPORARY TABLE temp_top_customers AS

SELECT
    customer_id,
    first_name,
    last_name
FROM customer
LIMIT 5;


-- check contents

SELECT *
FROM temp_top_customers;


-- =========================================================
-- EXAMPLE 2 : TEMPORARY TABLE
-- =========================================================

DROP TEMPORARY TABLE IF EXISTS temp_pg_movies;

CREATE TEMPORARY TABLE temp_pg_movies AS

SELECT
    film_id,
    title,
    rental_rate
FROM film
WHERE rating = 'PG';


SELECT *
FROM temp_pg_movies;


-- Important Points

-- temporary table exists temporarily
-- visible only to your session
-- other users cannot see it
-- helps avoid repeating queries


-- =========================================================
-- VIEWS
-- =========================================================

-- View:
-- saved SQL query

-- behaves like virtual table

-- view stores ONLY query
-- not actual data

-- useful for:
-- simplifying joins
-- reusable queries
-- hiding columns
-- cleaner reporting


-- Basic Syntax

-- CREATE VIEW view_name AS
-- SELECT ...


-- =========================================================
-- EXAMPLE 1 : VIEW
-- =========================================================

DROP VIEW IF EXISTS active_customers_view;

CREATE VIEW active_customers_view AS

SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM customer
WHERE active = 1;


-- use the view

SELECT *
FROM active_customers_view;


-- instead of writing:
-- SELECT customer_id, first_name...
-- FROM customer
-- WHERE active = 1
-- again and again


-- =========================================================
-- EXAMPLE 2 : VIEW WITH JOIN
-- =========================================================

DROP VIEW IF EXISTS customer_payment_view;

CREATE VIEW customer_payment_view AS

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_paid
FROM customer c

JOIN payment p
ON c.customer_id = p.customer_id

GROUP BY c.customer_id,
         c.first_name,
         c.last_name;


-- use the view

SELECT *
FROM customer_payment_view;


-- Important Points

-- view = virtual table
-- stores query only
-- reusable anytime
-- simplifies complex joins
-- saves storage


-- =========================================================
-- STORED PROCEDURES
-- =========================================================

-- Stored Procedure:
-- saved block of SQL code

-- reusable SQL program

-- useful for:
-- reducing repeated code
-- organizing queries
-- reusing logic
-- accepting parameters


-- Basic Structure

-- DELIMITER $$

-- CREATE PROCEDURE procedure_name()
-- BEGIN
--     SQL statements
-- END $$

-- DELIMITER ;


-- Why DELIMITER?

-- normally MySQL ends query using ';'
-- procedure contains many semicolons
-- so delimiter is temporarily changed


-- =========================================================
-- EXAMPLE 1 : SIMPLE PROCEDURE
-- =========================================================

DROP PROCEDURE IF EXISTS get_movies;

DELIMITER $$

CREATE PROCEDURE get_movies()
BEGIN

    SELECT
        film_id,
        title,
        rating
    FROM film
    LIMIT 5;

END $$

DELIMITER ;


-- call procedure

CALL get_movies();


-- =========================================================
-- PROCEDURE PARAMETERS
-- =========================================================

-- IN
-- value goes INTO procedure

-- OUT
-- procedure returns value

-- INOUT
-- takes value, modifies it, returns updated value


-- =========================================================
-- EXAMPLE 2 : IN PARAMETER
-- =========================================================

DROP PROCEDURE IF EXISTS get_customer;

DELIMITER $$

CREATE PROCEDURE get_customer(IN cust_id INT)
BEGIN

    SELECT
        customer_id,
        first_name,
        last_name
    FROM customer
    WHERE customer_id = cust_id;

END $$

DELIMITER ;


-- call procedure

CALL get_customer(10);


-- =========================================================
-- EXAMPLE 3 : OUT PARAMETER
-- =========================================================

DROP PROCEDURE IF EXISTS total_movies;

DELIMITER $$

CREATE PROCEDURE total_movies(OUT total INT)
BEGIN

    SELECT COUNT(*)
    INTO total
    FROM film;

END $$

DELIMITER ;


-- call procedure

CALL total_movies(@movie_count);

SELECT @movie_count;


-- =========================================================
-- EXAMPLE 4 : INOUT PARAMETER
-- =========================================================

DROP PROCEDURE IF EXISTS increase_number;

DELIMITER $$

CREATE PROCEDURE increase_number(INOUT num INT)
BEGIN

    SET num = num + 100;

END $$

DELIMITER ;


-- call procedure

SET @value = 50;

CALL increase_number(@value);

SELECT @value;


-- =========================================================
-- DYNAMIC SQL
-- =========================================================

-- Dynamic SQL:
-- query built during runtime

-- useful when:
-- table names change
-- conditions change
-- columns change


-- Important Commands

-- PREPARE            -> prepares SQL
-- EXECUTE            -> runs SQL
-- DEALLOCATE PREPARE -> clears memory


-- =========================================================
-- EXAMPLE 1 : DYNAMIC SQL
-- =========================================================

DROP PROCEDURE IF EXISTS dynamic_movies;

DELIMITER $$

CREATE PROCEDURE dynamic_movies()
BEGIN

    -- store query inside variable

    SET @sql_query =
    'SELECT title, rental_rate FROM film LIMIT 5';

    -- prepare query

    PREPARE stmt FROM @sql_query;

    -- execute query

    EXECUTE stmt;

    -- clear memory

    DEALLOCATE PREPARE stmt;

END $$

DELIMITER ;


CALL dynamic_movies();


-- =========================================================
-- EXAMPLE 2 : DYNAMIC TABLE NAME
-- =========================================================

DROP PROCEDURE IF EXISTS dynamic_table_fetch;

DELIMITER $$

CREATE PROCEDURE dynamic_table_fetch(IN table_name VARCHAR(50))
BEGIN

    SET @sql_query =
    CONCAT('SELECT * FROM ', table_name, ' LIMIT 5');

    PREPARE stmt FROM @sql_query;

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;

END $$

DELIMITER ;


-- call procedure

CALL dynamic_table_fetch('customer');

CALL dynamic_table_fetch('film');


-- =========================================================
-- QUICK REVISION
-- =========================================================

-- Temporary Table
-- temporary storage table

-- View
-- saved query / virtual table

-- Stored Procedure
-- reusable SQL program

-- IN parameter
-- input value

-- OUT parameter
-- returns value

-- INOUT parameter
-- input + output

-- Dynamic SQL
-- query built during runtime