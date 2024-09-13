create database if not exists zomato;
use zomato;
-- Drop table if exists and create goldusers_signup table
DROP TABLE IF EXISTS goldusers_signup;
CREATE TABLE goldusers_signup(userid INTEGER, gold_signup_date DATE);

-- Insert values into goldusers_signup
INSERT INTO goldusers_signup(userid, gold_signup_date) 
VALUES (1, '2017-09-22'),
       (3, '2017-04-21');

-- Drop table if exists and create users table
DROP TABLE IF EXISTS users;
CREATE TABLE users(userid INTEGER, signup_date DATE);

-- Insert values into users
INSERT INTO users(userid, signup_date) 
VALUES (1, '2014-09-02'),
       (2, '2015-01-15'),
       (3, '2014-04-11');

-- Drop table if exists and create sales table
DROP TABLE IF EXISTS sales;
CREATE TABLE sales(userid INTEGER, created_date DATE, product_id INTEGER);

-- Insert values into sales
INSERT INTO sales(userid, created_date, product_id) 
VALUES (1, '2017-04-19', 2),
       (3, '2019-12-18', 1),
       (2, '2020-07-20', 3),
       (1, '2019-10-23', 2),
       (1, '2018-03-19', 3),
       (3, '2016-12-20', 2),
       (1, '2016-11-09', 1),
       (1, '2016-05-20', 3),
       (2, '2017-09-24', 1),
       (1, '2017-03-11', 2),
       (1, '2016-03-11', 1),
       (3, '2016-11-10', 1),
       (3, '2017-12-07', 2),
       (3, '2016-12-15', 2),
       (2, '2017-11-08', 2),
       (2, '2018-09-10', 3);

-- Drop table if exists and create product table
DROP TABLE IF EXISTS product;
CREATE TABLE product(product_id INTEGER, product_name TEXT, price INTEGER);

-- Insert values into product
INSERT INTO product(product_id, product_name, price) 
VALUES (1, 'p1', 980),
       (2, 'p2', 870),
       (3, 'p3', 330);
-- Drop table if exists and create goldusers_signup table
DROP TABLE IF EXISTS goldusers_signup;
CREATE TABLE goldusers_signup(userid INTEGER, gold_signup_date DATE);

-- Insert values into goldusers_signup
INSERT INTO goldusers_signup(userid, gold_signup_date) 
VALUES (1, '2017-09-22'),
       (3, '2017-04-21');

-- Drop table if exists and create users table
DROP TABLE IF EXISTS users;
CREATE TABLE users(userid INTEGER, signup_date DATE);

-- Insert values into users
INSERT INTO users(userid, signup_date) 
VALUES (1, '2014-09-02'),
       (2, '2015-01-15'),
       (3, '2014-04-11');

-- Drop table if exists and create sales table
DROP TABLE IF EXISTS sales;
CREATE TABLE sales(userid INTEGER, created_date DATE, product_id INTEGER);

-- Insert values into sales
INSERT INTO sales(userid, created_date, product_id) 
VALUES (1, '2017-04-19', 2),
       (3, '2019-12-18', 1),
       (2, '2020-07-20', 3),
       (1, '2019-10-23', 2),
       (1, '2018-03-19', 3),
       (3, '2016-12-20', 2),
       (1, '2016-11-09', 1),
       (1, '2016-05-20', 3),
       (2, '2017-09-24', 1),
       (1, '2017-03-11', 2),
       (1, '2016-03-11', 1),
       (3, '2016-11-10', 1),
       (3, '2017-12-07', 2),
       (3, '2016-12-15', 2),
       (2, '2017-11-08', 2),
       (2, '2018-09-10', 3);

-- Drop table if exists and create product table
DROP TABLE IF EXISTS product;
CREATE TABLE product(product_id INTEGER, product_name TEXT, price INTEGER);

-- Insert values into product
INSERT INTO product(product_id, product_name, price) 
VALUES (1, 'p1', 980),
       (2, 'p2', 870),
       (3, 'p3', 330);
select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- 1) What is the total amount each customer spent on zomato?

select s.userid,sum(price) as "total_amount_spent" from sales s inner join product p on s.product_id=p.product_id
group by userid order by sum(price) desc;

-- 2)How many days each customer visited zomato?
SELECT 
    userid, COUNT(distinct(created_date)) AS 'days_visited'
FROM
    sales
GROUP BY userid;
-- 3)what was the first product purchased by each customer?
with cte as (select userid,product_id, rank() over(partition by userid order by created_date asc) as rnk from sales
)
select userid,product_id,rnk from cte where rnk =1;
-- 4)what is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    userid, COUNT(created_date) AS no_of_times_purchased
FROM
    sales
WHERE
    product_id = (SELECT 
            product_id
        FROM
            sales
        GROUP BY product_id
        ORDER BY COUNT(created_date) DESC
        LIMIT 1)
GROUP BY userid;
-- 5)which item was most popular for each customer?
with cte as (select a.*, rank() over(partition by userid order by c desc)  as rnk  from (select userid,product_id,count(created_date) as c from sales
 group by userid,product_id order by userid,product_id desc)as a)
 select cte.userid,cte.product_id from cte where rnk =1;
 -- 6) Which item was purchased first by the customer after they become a member?
with cte as(select s.* from sales s inner join goldusers_signup g on s.userid=g.userid where s.created_date>=g.gold_signup_date)
select t.userid,t.product_id from (select userid,product_id, rank() over (partition by userid order by created_date asc ) as rnk from cte )t where rnk =1;

-- 7)which item was purshased just before the customer become the  a member?
with cte as(select s.* from sales s inner join goldusers_signup g on s.userid=g.userid where s.created_date< g.gold_signup_date)
select t.userid,t.product_id from (select userid,product_id, rank() over (partition by userid order by created_date desc ) as rnk from cte )t where rnk =1;
-- 8)what is the total orders and amount spent for each member before they become a member?
          with cte as (select s.*,p.price from sales s inner join goldusers_signup g on s.userid=g.userid  inner join product p on s.product_id =p.product_id where s.created_date< g.gold_signup_date 
         ) select userid,count(created_date) as total_orders,sum(price) as amount_spent from cte group by userid ;
-- 9)if buying each product generates point for eg 5rs=2  zomato point and each product has different purchsing points for eg for p1 5rs=1 zomato point,for p2 10rs= 5zomato point and for 
-- p3 5rs = 1 zomato point
-- calculate points collected by each customer and for which product most point have been given till now.
with cte as (select s.*,p.product_name,p.price,case when product_name ="p1" then price* 0.2
when product_name ="p2" then price *0.5
when product_name ="p3" then price*0.2 end as points from sales s inner join product p on s.product_id =p.product_id)
select   userid,sum(points) as overall_point from cte group by userid;
with cte1 as (select s.*,p.product_name,p.price,case when product_name ="p1" then price* 0.2
when product_name ="p2" then price *0.5
when product_name ="p3" then price*0.2 end as points from sales s inner join product p on s.product_id =p.product_id),
cte2 as (select product_name,sum(points) as pts from cte1 group by product_name )
select product_name from cte2 where pts=(select max(pts) from cte2);
-- 10)in the first one year after a customer joins the gold program (including their joining date)
-- irrespective of what the customer have  purchased they earn 5 zomato points for every 10rs spent ,what was their points earning in their first year after membership?
with cte as(SELECT 
    s.*,g.gold_signup_date,p.product_name,p.price,price*0.5 as points
FROM
    sales s
        INNER JOIN
    goldusers_signup g ON s.userid = g.userid inner join product p on s.product_id=p.product_id
WHERE
    s.created_date <= DATE_ADD(g.gold_signup_date,
        INTERVAL 365 DAY) )
        select userid,sum(points) from cte group by userid;
-- 11)rank all the transactions of the customers.
select *,rank() over(partition by userid order by  created_date asc) as rnk from sales ;
