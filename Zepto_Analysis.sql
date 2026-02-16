drop table if exists zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
)

----Data Exploration Checking all the data is xeported correctly or not------
---no. of rows
select * from zepto;
---no. of rows in data
select COUNT(*) from zepto;
---Checking is there any null values or not
select * from zepto 
WHERE name IS NULL 
OR
category IS NULL 
OR
discountPercent IS NULL 
OR
mrp IS NULL 
OR
weightInGms IS NULL 
OR
discountedSellingPrice IS NULL 
OR
availableQuantity IS NULL 
OR
Quantity IS NULL 
OR
outOfStock IS NULL 
;

--Checking how many category are there
select category from zepto
ORDER BY category;

--checking how many of them are out of stock or in stock
select outOfStock, COUNT(sku_id)
from zepto
GROUP BY outOfStock;

--product name present in multiple times
select name, COUNT(sku_id) as "number of sku_id's"
from zepto
GROUP BY name 
HAVING COUNT(sku_id) >1
ORDER BY COUNT(sku_id) desc;

------------Data Cleaning------
--checking any product price will be zero

select * from zepto
where mrp = 0 OR discountedSellingPrice = 0;
---Deleting zero price --

DELETE from zepto
WHERE mrp = 0;

--conert price to rupees
update zepto
set mrp=mrp/100.0,
discountedSellingPrice=discountedSellingPrice/100.0;

select mrp,discountedSellingPrice from zepto;

--Q1) Find the top 10 products with highest mrp but outof stock?
select DISTINCT name, mrp,discountPercent from zepto
ORDER BY discountPercent
limit 10;

--Q2) What are theproducts are outof stock
select name from zepto
WHERE outOfStock= TRUE;
--Q3) What are the products with highest price and are outof stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE
AND mrp = (SELECT MAX(mrp) FROM zepto WHERE outOfStock = TRUE)
limit 5;

--Q4) Calculate eastmated revenue for each category
select category, 
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
from zepto
GROUP BY category
ORDER BY total_revenue;

--Q4) Find all products where mrp >500 and discounted price is 10%
select DISTINCT name, mrp, discountPercent
from zepto
WHERE mrp >500
AND discountPercent <10
ORDER BY mrp desc, discountPercent desc;

--Q5) Identify top 5 category with bets avg discount
select category,
ROUND(AVG(discountPercent),2) AS avg_discountPrice
from zepto
GROUP BY category
ORDER BY avg_discountPrice desc
limit 5;

--Q6) Find the price per gram for products above 100grms sort by best value
select DISTINCT(name), weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
from zepto
WHERE weightInGms >=100
ORDER BY price_per_gram;

--Q7) Group the product into categories like low,medium, bulk?
select DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'LOW'
     WHEN weightInGms < 5000 THEN 'MEDIUM'
	 ELSE 'BULK'
	 END AS weight_category
from zepto;


--Q8) What is the Total inventory weight per category?
select category, 
SUM(weightInGms * availableQuantity) AS total_weight
from zepto
GROUP BY category
ORDER BY total_weight;
