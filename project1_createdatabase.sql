
DROP DATABASE IF EXISTS project;

CREATE DATABASE project;
USE project2;


#Q1 

CREATE TABLE IF NOT EXISTS aisle (
  id                INT (11)       not null      ,
  aisle           VARCHAR(100) not null ,
 PRIMARY KEY (id)
);


CREATE TABLE IF NOT EXISTS department (
  id                INT (11)                    NOT NULL,
  department          VARCHAR(30)        NOT NULL,
 PRIMARY KEY (id)
);


CREATE TABLE IF NOT EXISTS product(
  id                INT   not null,
  name          VARCHAR(200)    NOT NULL,
  aisle_id    	 INT(11)				NOT NULL,
  department_id INT(11)			NOT NULL,
  PRIMARY KEY (id),
  foreign key (aisle_id) references aisle(id),
  foreign key (department_id) references department(id)
);


create table if not exists orders (
id                   int(11)  	not null,
user_id          int(11)	 not null,
eval_set VARCHAR(10) not null,
order_number  int(11)   not null,
order_dow INT(11),
order_hour_of_day INT(11),
days_since_prior_order INT(11),
primary key (id)
);


create table if not exists order_product(
order_id                   int(11) not null,
product_id               int(11) not null,
add_to_cart_order INT(11) not null,
reordered                int(11) not null,
foreign key (order_id) references orders(id),
foreign key (product_id) references product(id)
);



LOAD DATA LOCAL INFILE '/Users/wangmodan/Documents/demo/database/Archive/aisles.csv' INTO TABLE aisle
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '/Users/wangmodan/Documents/demo/database/Archive/departments.csv' INTO TABLE department
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '/Users/wangmodan/Documents/demo/database/Archive/products.csv' INTO TABLE product
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '/Users/wangmodan/Documents/demo/database/Archive/orders.csv' INTO TABLE orders
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '/Users/wangmodan/Documents/demo/database/Archive/order_products.csv' INTO TABLE order_product
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;


select*from product;
select * from  order_product;
