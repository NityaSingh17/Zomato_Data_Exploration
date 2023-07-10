CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

CREATE TABLE sales(userid integer,created_date date,product_id integer); 
INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

SELECT * FROM goldusers_signup;
SELECT * FROM sales;
SELECT* FROM product;
SELECT * FROM users;

QUESTION :- 

1) What is the total amount each customer spent on zomato?

SELECT U.userid, SUM(P.price) Total_Amount
FROM sales U INNER JOIN product P ON U.product_id = P.product_id 
GROUP BY U.userid;


2) How many days has each customer visited zomato?

SELECT userid, count(created_date) Total_Days
FROM sales GROUP BY userid;


3) What was the first product purchased by each customer?

SELECT * FROM
(SELECT *, rank() OVER(PARTITION	BY userid ORDER BY created_date ) Rank_NO
FROM sales)
a WHERE Rank_NO = 1;


4) What is the most purchased item on the menu and how many times it was purche=ased by all customers?
 
 SELECT TOP 1 product_id, COUNT(product_id) Number
 FROM sales GROUP BY product_id ORDER BY COUNT(product_id) DESC;

 SELECT userid, COUNT(product_id) mx_product
 FROM sales WHERE product_id = (
 SELECT TOP 1 product_id
 FROM sales GROUP BY product_id ORDER BY COUNT(product_id) DESC)
 GROUP BY userid;


 5) Which item was the most popular for each customer?

 SELECT * FROM 
 ( SELECT *, RANK() OVER(PARTITION BY userid ORDER BY cnt DESC) rnk FROM
 ( SELECT userid, product_id,COUNT(product_id) cnt
 FROM sales GROUP BY userid, product_id) a)b
 WHERE rnk = 1;

 PART 2: 
 1) Which item was purchased first by the customer after they became a member?

 SELECT * FROM
 (SELECT *, RANK() OVER(PARTITION BY userid ORDER BY created_date) Rnk FROM
 (SELECT G.userid, S.created_date, S.product_id
 FROM goldusers_signup G INNER JOIN sales S  ON G.userid = S.userid and S.created_date >= G.gold_signup_date)a)b 
 WHERE Rnk = 1;
 

 2) Which item was purchased just befoe the customer became a member?

 SELECT * FROM
 (SELECT *, RANK() OVER(PARTITION BY userid ORDER BY created_date DESC) Rnk FROM
 (SELECT G.userid, S.created_date, S.product_id, P.product_name, G.gold_signup_date
 FROM goldusers_signup G LEFT JOIN sales S  ON G.userid = S.userid and S.created_date <= G.gold_signup_date INNER JOIN product P ON S.product_id = P.product_id)a)b 
 WHERE Rnk = 1;

 3) What is the total orders and amount spent by each member before they became a member?

 SELECT userid, COUNT(created_date) Total_Orders, SUM(price) Total_Amount FROM
 (SELECT G.userid, S.created_date, S. product_id, P.price FROM goldusers_signup G INNER JOIN sales S ON G.userid = S.userid AND S.created_date <= G.gold_signup_date INNER JOIN product P ON S.product_id = P.product_id)a
 GROUP BY userid;