-- =========================================================
-- SQL SUBQUERY ASSIGNMENT
-- =========================================================


-- 1. Display all customer details
-- who have made more than 5 payments

select customer_id
from customer
where customer_id in (
       select customer_id
       from payment
       group by customer_id
       having count(*)>5
);


-- 2. Find the names of actors
-- who have acted in more than 10 films

select first_name, last_name
from actor 
where actor_id in (
select actor_id
from film
group by actor_id
having count(*)>10
);


-- 3. Find the names of customers
-- who never made a payment

select first_name, last_name
from customer
where customer_id not in (
select distinct customer_id 
from payment);


-- 4. List all films whose rental rate
-- is higher than average rental rate

SELECT title, rental_rate
FROM film
WHERE rental_rate > (
SELECT AVG(rental_rate)
FROM film
);


-- 5. List titles of films
-- that were never rented

SELECT title
from film
where film_id not in (
select distinct i.film_id
from inventory i
left join rental r
on i.inventory_id=r.inventory_id
);


-- 6. Display customers who rented films
-- in the same month as customer ID 5

SELECT DISTINCT customer_id
FROM rental
WHERE MONTH(rental_date) IN (
SELECT MONTH(rental_date)
FROM rental
WHERE customer_id = 5
);



-- 7. Find staff members who handled
-- a payment greater than average payment amount

SELECT 
DISTINCT s.staff_id,
s.first_name,
s.last_name
FROM staff s
JOIN payment p
ON s.staff_id = p.staff_id
WHERE p.amount > (
SELECT AVG(amount)
FROM payment
);



-- 8. Show title and rental duration
-- of films whose rental duration is greater than average

SELECT title, rental_duration
FROM film
WHERE rental_duration > (
SELECT AVG(rental_duration)
FROM film
);



-- 9. Find customers who have the same address
-- as customer with ID 1

SELECT first_name, last_name
FROM customer
WHERE address_id = (
SELECT address_id
FROM customer
WHERE customer_id = 1
)
AND customer_id <> 1;



-- 10. List all payments greater than
-- average of all payments

SELECT *
FROM payment
WHERE amount > (
SELECT AVG(amount)
FROM payment
);