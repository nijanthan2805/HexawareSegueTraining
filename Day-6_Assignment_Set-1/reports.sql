-- day 6 assignment
-- set 1 - retail sales reporting


-- create database
create database retail_sales;

use retail_sales;


-- create tables

-- customers table
create table customers (
    customer_id int primary key,
    customer_name varchar(50),
    city varchar(50)
);

-- products table
create table products (
    product_id int primary key,
    product_name varchar(50),
    category varchar(50)
);

-- orders table
create table orders (
    order_id int primary key,
    customer_id int,
    order_date date,
    foreign key (customer_id) references customers(customer_id)
);

-- order_items table
create table order_items (
    order_id int,
    product_id int,
    quantity int,
    unit_price decimal(10,2),
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);

-- payments table
create table payments (
    payment_id int primary key,
    order_id int,
    amount decimal(10,2),
    payment_date date,
    foreign key (order_id) references orders(order_id)
);


-- insert values

-- insert customers
insert into customers values
(1, 'rahul', 'chennai'),
(2, 'priya', 'bangalore'),
(3, 'amit', 'chennai'),
(4, 'sneha', 'mumbai'),
(5, 'rohit', 'bangalore'),
(6, 'neha', 'hyderabad');


-- insert products
insert into products values
(101, 'laptop', 'electronics'),
(102, 'mouse', 'accessories'),
(103, 'keyboard', 'accessories'),
(104, 'monitor', 'electronics'),
(105, 'printer', 'electronics'),
(106, 'headphones', 'accessories');


-- insert orders
insert into orders values
(1001, 1, '2026-11-01'),
(1002, 1, '2026-11-03'),
(1003, 1, '2026-11-05'),
(1004, 1, '2026-11-08'),
(1005, 1, '2026-11-12'),
(1006, 2, '2026-11-02'),
(1007, 2, '2026-11-06'),
(1008, 3, '2026-11-04'),
(1009, 3, '2026-11-10'),
(1010, 4, '2026-11-15'),
(1011, 5, '2026-10-20');


-- insert order items
insert into order_items values
(1001, 101, 1, 50000),
(1001, 102, 2, 500),
(1002, 103, 1, 1200),
(1002, 104, 1, 12000),
(1003, 101, 1, 50000),
(1004, 105, 2, 8000),
(1005, 106, 2, 2000),
(1006, 102, 3, 500),
(1006, 103, 1, 1200),
(1007, 104, 2, 12000),
(1008, 101, 1, 50000),
(1009, 106, 1, 2000),
(1010, 105, 1, 8000),
(1011, 103, 2, 1200);


-- insert payments
insert into payments values
(1, 1001, 51000, '2026-11-01'),
(2, 1002, 13200, '2026-11-03'),
(3, 1003, 50000, '2026-11-05'),
(4, 1006, 2700, '2026-11-02'),
(5, 1007, 24000, '2026-11-06'),
(6, 1008, 50000, '2026-11-04'),
(7, 1010, 8000, '2026-11-15');


-- check table values

select * from customers;
select * from products;
select * from orders;
select * from order_items;
select * from payments;


-- task 1: retail sales reports

-- 1. top 5 products by revenue
select product_id,sum(quantity * unit_price) as revenue
from order_items
group by product_id
order by revenue desc
limit 5;


-- 2. month-wise sales
select month(order_date),sum(quantity * unit_price)
from orders
join order_items using(order_id)
group by month(order_date);


-- 3. customers with more than 3 orders
select customer_id,count(*)
from orders
group by customer_id
having count(*) > 3;


-- 4. average basket value per city
select city, avg(quantity *unit_price)
from customers
join orders using(customer_id)
join order_items using(order_id)
group by city;


-- 5. orders without payment
select order_id
from orders
left join payments using(order_id)
where payment_id is null;


-- 6. customers with no orders
select customer_name
from customers
left join orders using(customer_id)
where order_id is null;


-- 7. revenue by product category
select category,sum(quantity *unit_price)
from products
join order_items using(product_id)
group by category;


-- 8. day with highest sales
select order_date, sum(quantity* unit_price) as sales
from orders
join order_items using(order_id)
group by order_date
order by sales desc
limit 1;


-- task 2: string, date and math functions

-- 1. customer name in uppercase
select upper(customer_name) from customers;

-- 2. combine customer name and city
select concat(customer_name, city) from customers;

-- 3. find days since order date
select datediff(curdate(), order_date) from orders;

-- 4. change date format
select date_format(order_date, '%d-%m-%Y') from orders;

-- 5. round a number
select round(125.678, 2);


-- task 3: null functions

-- 1. count all payment rows
select count(*) from payments;

-- 2. count non-null payment amounts
select count(amount) from payments;

-- 3. calculate total payment
select sum(amount) from payments;

-- 4. calculate average payment
select avg(amount) from payments;


-- task 4: where vs having

-- where filters individual rows
select * from orders
where customer_id = 1;

-- having filters grouped records
select customer_id,count(*)
from orders
group by customer_id
having count(*) >3;