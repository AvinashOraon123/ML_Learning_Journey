USE day16;
SELECT * FROM movies
WHERE (GROSS - BUDGET) = (SELECT MAX(GROSS - BUDGET) FROM movies);

SELECT COUNT(*) FROM MOVIES
WHERE SCORE>(SELECT AVG(SCORE) FROM MOVIES);
-- HIGHEST RATED MOVIE OF 2000
SELECT * FROM MOVIES
WHERE YEAR = 2000 AND SCORE = (SELECT MAX(SCORE) FROM MOVIES 
WHERE YEAR = 2000);

SELECT * FROM MOVIES where SCORE =(SELECT MAX(SCORE) FROM MOVIES WHERE VOTES > (SELECT AVG(VOTES)
 FROM MOVIES));
 -- Never placed an order on zomato
SELECT * FROM users WHERE user_id NOT IN(SELECT DISTINCT(user_id) FROM ORDERS);
 -- all movies by top 3 directors
 
with top_directors as (select DIRECTOR FROM MOVIES GROUP BY director ORDER BY sum(gross)
desc limit 3)
SELECT * FROM MOVIES
WHERE director in  ( select * FROM top_directors);

-- Table subqueries
SELECT * FROM movies WHERE (genre,score) IN
((SELECT genre,MAX(score) from	movies
WHERE votes > 25000
group by genre));

with top_duos as (SELECT star,director,max(gross) from	movies
group by star,director
order by sum(gross) DESC LIMIT 5)
SELECT * FROM movies WHERE (star,director,gross) IN (select * from top_duos);

select * from movies m1
where score > (select avg(score) from movies m2 where m2.genre = m1.genre);

with temp as (
select t2.user_id,name, f_name, COUNT(*) as 'count' from users t1
JOIN orders t2 on t1.user_id = t2.user_id
join order_details t3 on t2.order_id = t3.order_id
join food t4 on t3.f_id = t4.f_id
group by t2.user_id, t3.f_id)

select * from temp f1
where count = (select max(count) from temp f2 
			where f2.user_id = f1.user_id);
            
-- usage with select
select name, (votes/(select sum(votes) from movies))*100 from movies;
-- SUBQUERIES UNDER SELECT
select name , genre, score, (select avg(score) from movies m2 where m2.genre = m1.genre ) as 'avg'
 from movies m1;
-- SUBQUERIES UNDER FROM
select r_name, avg_rating
from (select r_id, avg(restaurant_rating) as 'avg_rating'
	from orders
    group by r_id) t1 join restaurants t2
    on t1.r_id = t2.r_id;
-- SUBQUERIES UNDER HAVING
select genre, avg(score)
from movies 
group by genre
having avg(score) >(select avg(score) from movies);





