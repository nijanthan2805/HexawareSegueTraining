create database if not exists retail_db;
use retail_db;

create table stores (
    store_id int primary key,
    store_name varchar(50),
    region varchar(30)
);

create table employees (
    emp_id int primary key,
    emp_name varchar(50),
    manager_id int,
    store_id int,
    foreign key (manager_id) references employees(emp_id),
    foreign key (store_id) references stores(store_id)
);

create table products (
    product_id int primary key,
    product_name varchar(50)
);

create table customers (
    customer_id int primary key,
    customer_name varchar(50)
);

create table sales (
    sale_id int primary key,
    product_id int,
    customer_id int,
    store_id int,
    sale_date date,
    foreign key (product_id) references products(product_id),
    foreign key (customer_id) references customers(customer_id),
    foreign key (store_id) references stores(store_id)
);

create table returns (
    return_id int primary key,
    sale_id int,
    return_date date,
    foreign key (sale_id) references sales(sale_id)
);

create table refunds (
    refund_id int primary key,
    return_id int,
    refund_amount decimal(10,2),
    foreign key (return_id) references returns(return_id)
);

insert into stores values
(1, 'chennai central', 'south'),
(2, 'coimbatore', 'south'),
(3, 'bangalore', 'south'),
(4, 'mumbai', 'west');

insert into employees values
(1, 'arun', null, 1),
(2, 'priya', 1, 1),
(3, 'kumar', 1, 2),
(4, 'meena', null, 3),
(5, 'ravi', 4, 3),
(6, 'divya', null, 4);

insert into products values
(1, 'laptop'),
(2, 'mobile'),
(3, 'headphones'),
(4, 'keyboard');

insert into customers values
(1, 'sona'),
(2, 'rahul'),
(3, 'kavi'),
(4, 'maya'),
(5, 'naveen');

insert into sales values
(101, 1, 1, 1, '2026-01-05'),
(102, 1, 2, 1, '2026-01-06'),
(103, 1, 3, 2, '2026-01-07'),
(104, 1, 4, 2, '2026-01-08'),
(105, 1, 5, 3, '2026-01-09'),
(106, 2, 1, 1, '2026-01-10'),
(107, 2, 2, 2, '2026-01-11'),
(108, 2, 3, 3, '2026-01-12'),
(109, 3, 4, 3, '2026-01-13'),
(110, 3, 5, 4, '2026-01-14'),
(111, 4, 1, 4, '2026-01-15'),
(112, 4, 2, 4, '2026-01-16');

insert into returns values
(201, 101, '2026-01-20'),
(202, 102, '2026-01-21'),
(203, 103, '2026-01-22'),
(204, 106, '2026-01-23'),
(205, 109, '2026-01-24'),
(206, 110, '2026-01-25'),
(207, 111, '2026-01-26');

insert into refunds values
(301, 201, 500.00),
(302, 202, 450.00),
(303, 204, 200.00),
(304, 205, 150.00),
(305, 206, 250.00);

-- task 1: ten report queries

-- 1. products with a return rate above 10 percent
select p.product_name,count(r.return_id) * 100.0 / count(s.sale_id) as return_rate
from products p
join sales s on p.product_id = s.product_id
left join returns r on s.sale_id = r.sale_id
group by p.product_id, p.product_name
having return_rate > 10;

-- 2. customers who returned products but did not receive a refund
select distinct c.customer_name
from customers c
join sales s on c.customer_id = s.customer_id
join returns r on s.sale_id = r.sale_id
where not exists (
    select 1 from refunds f
    where f.return_id = r.return_id
);

-- 3. store or stores with the highest total refund value
select st.store_name, sum(f.refund_amount) as total_refund
from stores st
join sales s on st.store_id = s.store_id
join returns r on s.sale_id = r.sale_id
join refunds f on r.return_id = f.return_id
group by st.store_id, st.store_name
having total_refund = (
    select max(store_total)
    from (
        select sum(f2.refund_amount) as store_total
        from sales s2
        join returns r2 on s2.sale_id = r2.sale_id
        join refunds f2 on r2.return_id = f2.return_id
        group by s2.store_id
    ) as totals
);

-- 4. employees and their managers
select e.emp_name as employee, m.emp_name as manager
from employees e
left join employees m on e.manager_id = m.emp_id;

-- 5. total number of returns for each product
select p.product_name, count(r.return_id) as total_returns
from products p
left join sales s on p.product_id = s.product_id
left join returns r on s.sale_id = r.sale_id
group by p.product_id, p.product_name;

-- 6. total refund amount for each customer
select c.customer_name, coalesce(sum(f.refund_amount), 0) as total_refund
from customers c
left join sales s on c.customer_id = s.customer_id
left join returns r on s.sale_id = r.sale_id
left join refunds f on r.return_id = f.return_id
group by c.customer_id, c.customer_name;

-- 7. stores that have at least two returns
select st.store_name, count(r.return_id) as total_returns
from stores st
join sales s on st.store_id = s.store_id
join returns r on s.sale_id = r.sale_id
group by st.store_id, st.store_name
having count(r.return_id) >= 2;

-- 8. products that have never been returned
select p.product_name
from products p
where not exists (
    select 1 from sales s
    join returns r on s.sale_id = r.sale_id
    where s.product_id = p.product_id
);

-- 9. customers with more than one purchase
select c.customer_name, count(s.sale_id) as purchase_count
from customers c
join sales s on c.customer_id = s.customer_id
group by c.customer_id, c.customer_name
having count(s.sale_id) > 1;

-- 10. refund amount by region
select st.region, sum(f.refund_amount) as total_refund
from stores st
join sales s on st.store_id = s.store_id
join returns r on s.sale_id = r.sale_id
join refunds f on r.return_id = f.return_id
group by st.region;

-- task 2: show the null problem with not in
-- manager_id contains null values, so this not in query returns no rows
select emp_name
from employees
where emp_id not in (
    select manager_id from employees
);

-- corrected query using not exists
select e.emp_name
from employees e
where not exists (
    select 1 from employees m
    where m.manager_id = e.emp_id
);

-- task 3: compare each store's refund with other stores in the same region
-- greater than any means greater than at least one other store
select st.store_name, sum(f.refund_amount) as total_refund
from stores st
join sales s on st.store_id = s.store_id
join returns r on s.sale_id = r.sale_id
join refunds f on r.return_id = f.return_id
group by st.store_id, st.store_name, st.region
having sum(f.refund_amount) > any (
    select sum(f2.refund_amount) from stores st2
    join sales s2 on st2.store_id = s2.store_id
    join returns r2 on s2.sale_id = r2.sale_id
    join refunds f2 on r2.return_id = f2.return_id
    where st2.region = st.region
      and st2.store_id <> st.store_id
    group by st2.store_id
);

-- less than all means lower than every other store in the same region
select st.store_name, sum(f.refund_amount) as total_refund
from stores st
join sales s on st.store_id = s.store_id
join returns r on s.sale_id = r.sale_id
join refunds f on r.return_id = f.return_id
group by st.store_id, st.store_name, st.region
having sum(f.refund_amount) < all (
    select sum(f2.refund_amount)
    from stores st2
    join sales s2 on st2.store_id = s2.store_id
    join returns r2 on s2.sale_id = r2.sale_id
    join refunds f2 on r2.return_id = f2.return_id
    where st2.region = st.region
      and st2.store_id <> st.store_id
    group by st2.store_id
);

-- task 4: two nested subqueries with their results

-- nested query 1: customers who purchased a product that was returned
select customer_name
from customers
where customer_id in (
    select customer_id from sales
    where sale_id in (
        select sale_id from returns
    )
);

-- nested query 2: products whose return count is above the average return count
select product_name
from products
where product_id in (
    select product_id from sales
    where sale_id in (
        select sale_id from returns
        group by sale_id
    )
    group by product_id
    having count(*) > (
        select avg(return_count) from (
            select count(*) as return_count from sales s
            join returns r on s.sale_id = r.sale_id
            group by s.product_id
        ) as average_returns
    )
);
