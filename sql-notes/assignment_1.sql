USE SAKILA;
-- 1. Get all customers whose first name starts with 'J' and who are active.

SELECT * FROM CUSTOMER WHERE first_name LIKE "J%"
AND active = 1;


-- 2. Find all films where the title contains the word 'ACTION'
-- or the description contains 'WAR'.
SELECT * FROM film where title LIKE '%ACTION%' OR description LIKE '%WAR%';


-- 3. List all customers whose last name is not 'SMITH'
-- and whose first name ends with 'a'.

SELECT *
FROM customer
WHERE last_name not like "SMITH"
AND first_name LIKE "%a";



-- 4. Get all films where the rental rate is greater than 3.0
-- and the replacement cost is not null.

SELECT * 
FROM film
where rental_rate > 3.0 and replacement_cost IS NOT NULL;




-- 5. Count how many customers exist in each store
-- who have active status = 1.

SELECT store_id, COUNT(*) AS total_customers
FROM customer
Where active= 1
group by store_id;





-- 6. Show distinct film ratings available in the film table.
SELECT distinct rating
FROM film;




-- 7. Find the number of films for each rental duration
-- where the average length is more than 100 minutes.

SELECT rental_duration, COUNT(*) AS NO_OF_FILMS, AVG(length) AS avg_length
FROM film
group by rental_duration
HAVING AVG(LENGTH)>100;



-- 8. List payment dates and total amount paid per date,
-- but only include days where more than 100 payments were made.


SELECT DATE(payment_date) AS PAYMENT_DATE, SUM(AMOUNT) AS TOTAL_AMOUNT
FROM payment
GROUP BY DATE(payment_date)
HAVING COUNT(*) > 100;



-- 9. Find customers whose email address is null
-- or ends with '.org'.

SELECT * 
FROM customer
WHERE email is NULL 
or email like '%.org';


-- 10. List all films with rating 'PG' or 'G',
-- and order them by rental rate in descending order.


select * 
from film
where rating in ('PG', 'G')
order by rental_rate desc;


-- 11. Count how many films exist for each length
-- where the film title starts with 'T'
-- and the count is more than 5.

select length, count(*) as total_films
from film
where title LIKE 'T%'
group by length
having count(*)>5;



-- 12. List all actors who have appeared in more than 10 films.
select a.actor_id, a.first_name, a.last_name, count(f.film_id) as total_films
from actor a
join film_actor f
ON a.actor_id = f.actor_id
GROUP BY a.actor_id
HAVING COUNT(f.film_id) > 10;



-- 13. Find the top 5 films with the highest rental rates
-- and longest lengths combined.

select title, rental_rate, length
from film
order by rental_rate desc, length desc
limit 5;



-- 14. Show all customers along with the total number
-- of rentals they have made.
select
c.customer_id,
c.first_name,
c.last_name,
count(r.rental_id) as total_rentals
from customer c 
left join rental r 
on c.customer_id=r.customer_id
group by c.customer_id
order by total_rentals desc;



-- 15. List the film titles that have never been rented.

SELECT f.title
FROM film f
LEFT JOIN inventory i
ON f.film_id = i.film_id
LEFT JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;