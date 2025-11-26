select top(10) * from zepto
--COUNT OF ROWS
select count(*) from zepto
--Here i add a colum sku_id which is the PRIMARY KEY of my table 
alter table zepto
add sku_id int identity(1,1) primary key;
--Null values
select * from zepto 
where name is null
or 
category is null
or
mrp is null
or
discountPercent is null 
or
discountedSellingPrice is null
or
availableQuantity is null
or
outOfStock is null
or
quantity is null;
--count of coluns syntax
select count(*) as columns_count
from INFORMATION_SCHEMA.columns
where TABLE_NAME='zepto';
/*
INFROMATION_SCHEMA.columns
is a system view in SQL surver 
it stores all information about every column in a table
*/


--Different products categories
select  distinct category from zepto
order by category;
--Distinct keyword for getting unique values such as not repeated


--Products in stock vs out of stock
select outOfStock, count(sku_id) as product_count
from zepto
group by outOfStock; 
  

--product names prasent multiple times
select name, count(sku_id) as [Number of SKU]
from zepto
group by name
having count(sku_id) >1 
order by count(sku_id) desc; 

--Data cleaning
--Products with price=0
/*In the table does any of have with a 0 MRP or 0 DSP 
We will drop those */
select * from zepto
where mrp =0 or discountedSellingPrice=0;

delete from zepto 
where mrp=0;

/*In the Dataset MRP is haveing large 
so actually those r not that much 
so here we divede them with some values */
update zepto 
set mrp=mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;


select mrp,discountedSellingPrice from zepto