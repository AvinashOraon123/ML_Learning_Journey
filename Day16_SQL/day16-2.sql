USE day16;
-- WINDOW FUNCTIONS
CREATE TABLE marks (
 student_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    branch VARCHAR(255),
    marks INTEGER
);

INSERT INTO marks (name, branch, marks) VALUES 
('Nitish','EEE',82),
('Rishabh','EEE',91),
('Anukant','EEE',69),
('Rupesh','EEE',55),
('Shubham','CSE',78),
('Ved','CSE',43),
('Deepak','CSE',98),
('Arpan','CSE',95),
('Vinay','ECE',95),
('Ankit','ECE',88),
('Anand','ECE',81),
('Rohit','ECE',95),
('Prashant','MECH',75),
('Amit','MECH',69),
('Sunny','MECH',39),
('Gautam','MECH',51)
;
-- Aggregate Function with OVER()
select *,
AVG(MARKS) OVER(partition by branch) from marks;
-- Window functiosn Per row basis whereas group by gives per group basis
select *, min(marks) over(partition by branch), max(marks) over(partition by branch) from marks;

-- Find all the students who have marks higher than avg marks of the respective branch
select * from (select * , avg(marks) over(partition by branch) as 'branch_avg' from marks) t
where t.marks > t.branch_avg;

-- rank/dense_rank/row number
select * , rank() over(partition by branch order by marks desc) as 'rank',
dense_rank() over(partition by branch order by marks desc) as 'dense_rank',
concat(branch,'-',row_number() over(partition by branch))
from marks;

-- 1. Find top 2 paying customers every month
select * from (select user_id, sum(amount) ,month(date),
rank() over(partition by month(date) order by sum(amount) desc) as 'month_rank' from orders
group by month(date), user_id
order by month(date)) t
where t.month_rank <3 
order by  month_rank asc;

-- FIRST_VALUE/ LAST_VALUE/NTH_VALUE
-- 1. Find the 1st toppers
select * from (SELECT *,first_value(marks) over(partition by branch order by marks desc) as 'topper_marks',
		first_value(name) over(partition by branch order by marks desc) as 'topper_name'FROM MARKS)  t
        where t.marks = t.topper_marks and t.name = t.topper_name; -- This works expectedly
-- 2. Find the last rankers
SELECT *,last_value(marks) over(partition by branch order by marks desc
								rows between unbounded preceding and unbounded following ) FROM MARKS; -- frame concept is used in this query
-- default frame : unbounded preceding and current row
-- 3. nth_ value
SELECT *,nth_value(marks,2) over(partition by branch order by marks desc
								rows between unbounded preceding and unbounded following ) FROM MARKS;

-- CLEAN QUERY by using window function
SELECT *
FROM (
    SELECT *,
           FIRST_VALUE(marks) OVER w AS topper_marks,
           FIRST_VALUE(name) OVER w AS topper_name
    FROM MARKS
    WINDOW w AS (partition by BRANCH order by marks DESC)
) t -- window function will come inside temp table
WHERE t.marks = t.topper_marks;

-- LAG AND LEAD FUNCTION
SELECT *,
LAG(marks)  OVER(partition by branch order by student_id) as 'lag',
LEAD(marks)  OVER(partition by branch order by student_id) as 'lead'
FROM MARKS;

-- use case
SELECT 
	MONTHNAME(date) as mnth,
	SUM(amount),
((SUM(AMOUNT)-LAG(SUM(amount)) OVER w)/LAG(SUM(amount)) over w)*100 as growth_pct
FROM orders
group by mnth
WINDOW w as (ORDER BY month(DATE))
order by month(date) asc;

SELECT * from (select battingteam, batter, sum(batsman_run) as total_runs,
dense_rank() over(partition by battingteam order by sum(batsman_run) desc) as ranking
FROM IPL
group by battingteam ,batter) t
where t.ranking <6
order by t.battingteam,t.ranking ;

select * from (select CONCAT("MATCH-",CAST(row_number() OVER (ORDER BY ID) AS CHAR)) AS MATCHNO,
SUM(batsman_run) AS RUNS,
SUM(SUM(batsman_run)) OVER w AS 'CAREER_RUNS' from ipl 
where batter = 'V Kohli'
group by ID
WINDOW w as (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) t
where matchno = 'match-14';

select CAST(row_number() OVER (ORDER BY ID) AS CHAR) AS MATCHNO,
SUM(batsman_run) AS RUNS,
SUM(SUM(batsman_run)) OVER(ORDER BY ID) AS 'CAREER_RUNS',
AVG(SUM(batsman_run)) OVER(order by ID) AS 'CUM_AVG',
AVG(SUM(batsman_run)) OVER(rows between 3 preceding and current row) AS 'RUNNING_AVG' 
from ipl
where batter = 'V Kohli'
group by ID;

-- PERCENT OF TOTAL
select f_name , 
(total_value/sum(total_value) over())*100
from
(SELECT f_id, sum(amount)as 'total_value' FROM  ORDERS T1
JOIN order_details T2
ON T1.ORDER_ID = T2.ORDER_ID
WHERE R_ID =1
GROUP BY f_id) t
JOIN food t3
on t.f_id = t3.f_id 
order by (total_value/sum(total_value) over())*100 desc ;

select *, 
percentile_disc(0.5) within group(order by marks) over() as 'median_marks'
from marks;

select *, 
percentile_disc(0.5) within group(order by marks) over(partition by branch) as 'median_marks'
from marks;

select *, 
percentile_cont(0.5) within group(order by marks) over(partition by branch) as 'median_marks'
from marks;

select * from (select *, 
percentile_cont(0.25) within group(order by marks) over(partition by branch) as 'q1',
percentile_cont(0.75) within group(order by marks) over(partition by branch) as 'q3'
from marks) t
where t.marks <= t.q1 -(1.5 *(t.q3 - t.q1)) or t.marks > t.q3 + (1.5 *(t.q3 - t.q1))
;

-- Segmentation
select *,
NTILE(3) OVER() AS 'BUCKETS'
from marks;

USE avinash;
select brand_name, model, price,
case
	when bucket = 1 then 'budget'
    when bucket = 2 then 'mid'
    when bucket = 3 then 'premium'
end as 'phone_type'
from (select brand_name, model, price, ntile(3)
over(partition by brand_name order by price) as 'bucket'
from smartphones) t; 

select * from (select *,
CUME_DIST() 
OVER(ORDER BY MARKS) AS 'Percentile_score'
from day16.marks) t
where t.Percentile_score > 0.90
;
-- There might be some cases where we need to partition by multiple columns
select * from (select source, destination,airline, avg(price),
dense_rank() over(partition by source, destination order by avg(price)) as 'rank'
from flights
group by source , destination, airline) t
where t.rank <2;


