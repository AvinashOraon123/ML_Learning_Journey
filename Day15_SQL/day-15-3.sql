SELECT t1.order_id, t1.amount , t1.profit , t3.name FROM flipkart.order_details t1
JOIN flipkart.orders t2
ON t1.order_id = t2.order_id
JOIN flipkart.users t3
ON t2.user_id = t3.user_id;

SELECT t1.order_id, t2.name , t2.city
FROM flipkart.orders t1
JOIN flipkart.users t2
ON T1.USER_ID = T2.USER_ID;

SELECT t1.order_id, t2.category from flipkart.order_details t1
JOIN flipkart.category t2
ON t1.category_id = t2.category_id;

SELECT t1.order_id, SUM(t2.profit) from flipkart.orders t1
JOIN flipkart.order_details t2
ON t1.order_id = t2.order_id
GROUP BY t1.order_id
having SUM(t2.profit)> 0;

SELect name, COUNT(*) AS 'num_orders' from flipkart.orders t1
JOIN flipkart.users t2
ON t1.user_id = t2.user_id
GROUP BY t2.name
order by NUM_ORDERS DESC LIMIT 1;

SELECT t3.state, SUM(t1.profit) FROM flipkart.order_details t1 
JOIN flipkart.orders t2
on t1.order_id = t2.order_id
JOIN flipkart.users t3
ON t2.user_id = t3.user_id
group by state
ORDER BY SUM(profit) ASC



