/*
1. 
Creating supermarket database locally and tables
for locally testing queries
*/
create database supermarket;

use supermarket;


###create table aisle
create table if not exists aisle (
id                       int(11),
aisle               varchar(100),
primary key (id)
);

load data local infile "/Users/yan/Desktop/capstone/SmallDataset/aisle4.csv" into table aisle
fields terminated by ',' lines terminated by '\n' ignore 1 lines;

#select * from aisle limit 5;

###Create table product

create table if not exists product (
id                       int(11),
name               varchar(200),
aisle_id               int(11),
department_id               int(11),
primary key (id)
);

load data local infile "/Users/yan/Desktop/capstone/SmallDataset/product4.csv" into table product
fields terminated by ',' lines terminated by '\n' ignore 1 lines;

#select * from product limit 5;

###Create table order_product

create table if not exists order_product (
order_id                       int(11),
product_id               int(11),
add_to_cart_order               int(11),
reordered               int(11)
);

load data local infile "/Users/yan/Desktop/capstone/SmallDataset/orders_product4.csv" into table order_product
fields terminated by ',' lines terminated by '\n' ignore 1 lines;

#select * from order_product limit 5;

###Create table department

create table if not exists department (
id                       int(11),
department               varchar(30),
primary key (id)
);

load data local infile "/Users/yan/Desktop/capstone/SmallDataset/department4.csv" into table department
fields terminated by ',' lines terminated by '\n' ignore 1 lines;

#select * from department limit 5;


###Create table orders

create table if not exists orders (
id                       int(11),
user_id                       int(11),
eval_set                       varchar(10),
order_number                       int(11),
order_dow                       int(11),
order_hour_of_day                       int(11),
days_since_prior_order               int(11),
primary key (id)
);

load data local infile "/Users/yan/Desktop/capstone/SmallDataset/orders4.csv" into table orders
fields terminated by ',' lines terminated by '\n' ignore 1 lines;

#select * from orders limit 5;


/*
2.
Selecting top 10 product sales for each day in the week
Including product_id, product_name, total order amount, and day
*/


/*
Hive

use jason_supermarket;

select * 
from (select *, rank() over(partition by day order by sales desc) as rank
from (select product_id, count(orders.id) AS sales,orders.order_dow as day 
	  from order_product
	  join orders
	  where order_product.order_id = orders.id
	  group by product_id, order_dow) as dow_table1) as dow_table2
where rank <= 10;

*/

select product_id, product_name, sales, day
from(
select *,
@day_rank :=if(@dow = day, @day_rank+1, 1) as day_rank,
@dow := day
from(select p.id as product_id, p.name as product_name, count(o.id) as sales, o.order_dow as day
from product as p join order_product as op join orders as o
on p.id = op.product_id and op.order_id = o.id
group by p.id, o.order_dow
order by o.order_dow asc, count(o.id) desc) as dow_table) as dow_table2
where day_rank <=10;


/*
3.
Write a query to display the 5 most popular products in each aisle
from Monday to Friday. Listing product_id, aisle, and day in the week.
*/

/*
Hive:

use jason_supermarket;

select product_id, aisle, day, sales 
from (select *, rank() over(partition by day, aisle order by sales desc) as rank
from (select product_id, count(orders.id) as sales, aisle, orders.order_dow as day
from order_product join orders join product join aisle
on order_product.order_id = orders.id and order_product.product_id = product.id and product.aisle_id = aisle.id
group by product_id, order_dow, aisle) as aisle_table1) as aisle_table2
where rank <= 5 and day not in (0,6);

*/


select aisle, day, product_id
from(
select *,
@rank := If(@aisle_num = aisle_id and @dow = day, @rank + 1, 1) as rank,
@aisle_num := aisle_id,
@dow := day
from
(select p.id as product_id, a.id as aisle_id, a.aisle as aisle, count(o.id) as sales, o.order_dow as day
from order_product as op join orders as o join product as p join aisle as a
on op.order_id = o.id and op.product_id = p.id and p.aisle_id = a.id
group by p.id, o.order_dow,a.id
order by a.id asc, o.order_dow asc, count(o.id) desc) as aisle_table) as aisle_table2
where rank <=5 and day not in (0,6);

/*
4.
Query to select the top 10 products that the users have the most frequent
reorder rate. Only need to give the results with product id.
*/

/*
Hive: 

use jason_supermarket;

select op.product_id, sum(op.reordered)/count(op.order_id) as reorder_rate
from order_product as op
group by op.product_id
order by reorder_rate desc
limit 10;
*/

select op.product_id, sum(op.reordered)/count(op.order_id)
from order_product as op
group by op.product_id
order by sum(op.reordered)/count(op.order_id) desc
limit 10;


/*
5. 
*/
-- Part 1. Please list order id and all unique aisle id in the order.

/*
Hive

use jason_supermarket;

select distinct add_to_cart_order, aisle_id, order_id from 
(select * from order_product as op
join product as p where op.product_id = p.id
order by order_id, aisle_id) as table_1
order by order_id, add_to_cart_order;
*/

create table if not exists order_report1 as 
(select * from order_product as op
join product as p
where op.product_id = p.id
order by order_id, aisle_id);

create table if not exists order_report2 as 
(select distinct add_to_cart_order, aisle_id, order_id from order_report1 
order by order_id, add_to_cart_order);

-- Part 2. Find the most popular shopping path.

/*
Hive:

use jason_supermarket;

select path, count(*) as path_count
from (select order_id, collect_set(aisle) as path
from(select distinct order_id, aisle_id, aisle from order_product
join product join aisle where order_product.product_id = product.id and product.aisle_id = aisle.id 
order by order_id, aisle_id) as table1 group by order_id) as table2
group by path
order by path_count desc;

*/

select path, count(path) as path_count from
(select order_id, GROUP_CONCAT(aisle_id SEPARATOR ' ') as path
from order_report2
group by order_id) as path_temp
group by path
order by path_count desc;

/*
6. Find the pair of items that is most frequently bought together.
*/

/*
Hive:
use jason_supermarket;

select product_1, product_2, count(*) as count
from (select distinct pair1.order_id, pair1.product_id as product_1,
	pair2.product_id as product_2
from (select * from order_product order by order_id, product_id) as pair1
join (select * from order_product order by order_id, product_id desc) AS pair2
where pair1.order_id = pair2.order_id
and pair1.product_id <> pair2.product_id) as pairs
group by product_1, product_2
order by count desc
limit 20;

*/

create table if not exists pairs as(
select pair1.order_id as order_id, pair1.product_id as product_1, pair2.product_id as product_2 from
(select distinct order_id, product_id from order_product order by order_id, product_id asc) as pair1
join
(select distinct order_id, product_id from order_product order by order_id, product_id desc) as pair2
where pair1.order_id = pair2.order_id
and pair1.product_id <> pair2.product_id);

select pair, count(pair) from  
(select *, concat(product_1, " ", product_2) as pair from pairs) as temp
group by pair
order by count(pair) desc;

