-- CROSS JOIN
select * from sql_cx.users1 t1
CROSS JOIN sql_cx.groups t2;
-- INNER JOIN
select * from sql_cx.membership t1
INNER JOIN sql_cx.users1 t2
ON t1.user_id = t2.user_id;

select * from sql_cx.membership t1
LEFT JOIN sql_cx.users1 t2
ON t1.user_id = t2.user_id;

select * from sql_cx.membership t1
right JOIN sql_cx.users1 t2
ON t1.user_id = t2.user_id;

select * from sql_cx.membership t1
LEFT JOIN sql_cx.users1 t2
ON t1.user_id = t2.user_id
UNION
select * from sql_cx.membership t1
RIGHT JOIN sql_cx.users1 t2
ON t1.user_id = t2.user_id;

select * from sql_cx.students t1
JOIN sql_cx.class t2
ON t1.class_id = t2.class_id AND t1.enrollment_year = t2.class_year;

