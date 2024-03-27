
-- creating database and table for walmart analysis

CREATE DATABASE IF NOT EXISTS walmartSales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);


-----------------------------------------------------------
----------------FEATURE ENGINEERING-------------------

select time,
(case
	when time between "00:00:00" and "12:00:00" then "Morning"
	when time between "12:01:00" and "16:00:00" then "Afternoon" 
	else "Evening"
end) as time_of_day from sales; 

alter table sales add column time_of_day varchar(15);
update sales 
set time_of_day = (case
	when time between "00:00:00" and "12:00:00" then "Morning"
	when time between "12:01:00" and "16:00:00" then "Afternoon" 
	else "Evening"
end);

---------------------------------------------------------
--------------------------------------------

select date, dayname(date) from sales;

alter table sales add column day_name varchar(15);
update sales 
set day_name = dayname(date);

----------------------------------------------------------
-----------------------------------------

select date, monthname(date) from sales;

alter table sales add column month_name varchar(20);
update sales
set month_name = monthname(date);

-----------------------------------------------------------
-------------------GENERIC QUESTION-----------------------

-- How many unique cities does the data have?

select distinct city from sales;

-- In which city is each branch?

select distinct city, branch from sales;

--------------------------------------------------------------
--------------------PRODUCT QUESTION-------------------

-- How many unique product lines does the data have?

select count(distinct product_line) from sales;

-- What is the most common payment method?

select payment, count(payment) as count from sales
group by payment
order by count desc;

-- What is the most selling product line?

select product_line, count(product_line) as count from sales 
group by product_line
order by count desc;

-- What is the total revenue by month?

select month_name as month, sum(total) as total from sales
group by month_name
order by total desc; 

-- What month had the largest COGS?

select month_name,  sum(cogs) as total_cogs from sales
group by month_name
order by sum(cogs) desc;

-- What product line had the largest revenue?

select product_line, sum(total) as revenue from sales
group by product_line
order by sum(total) desc;

-- What is the city with the largest revenue?

select city, sum(total) as revenue from sales
group by city
order by sum(total) desc;

-- What product line had the largest VAT?

select product_line, avg(tax_pct) as avg_tax from sales
group by product_line
order by avg(tax_pct) desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

select product_line,
case when avg(quantity) > 5.50 then 'Good' else 'Bad' end as remark
from sales
group by product_line;

-- Which branch sold more products than average product sold?

select branch, sum(quantity) as qun from sales
group by branch
having qun > avg(quantity) 
order by qun desc limit 1;

-- What is the most common product line by gender?

select product_line, gender, count(gender) as count from sales
group by gender, product_line
order by gender, count desc;

-- What is the average rating of each product line?

select product_line, round(avg(rating),2) as avg_rating from sales
group by product_line
order by avg(rating) desc; 

-------------------------------------------------------------------------
--------------------SALES QUESTION------------------------------

-- Number of sales made in each time of the day per weekday

select time_of_day, count(*) from sales
where day_name = "Monday"
group by time_of_day
order by count(*) desc;

-- Which of the customer types brings the most revenue?

select customer_type, round(sum(total),2) as total from sales
group by customer_type
order by sum(total) desc;

-- Which city has the largest tax percent/ VAT ?

select city, round(sum(tax_pct),2) as VAT from sales
group by city
order by sum(tax_pct) desc limit 1;

-- Which customer type pays the most in VAT?

select customer_type, round(sum(tax_pct),2) as VAT from sales
group by customer_type
order by sum(tax_pct) desc;

------------------------------------------------------------------------
--------------------CUSTOMER QUESTION---------------------------

-- How many unique customer types does the data have?

select count(distinct customer_type) from sales;

-- How many unique payment methods does the data have?

select count(distinct payment) from sales;

-- What is the most common customer type?

select customer_type, count(*) as common_customer from sales
group by customer_type
order by count(*) desc limit 1;

-- Which customer type buys the most?

select customer_type, sum(total) as total from sales
group by customer_type
order by sum(total) desc limit 1;

-- What is the gender of most of the customers?

select gender, count(gender) from sales
group by gender
order by count(gender) desc limit 1;

-- What is the gender distribution per branch?

select branch, gender, count(gender) as gender_distribution from sales
group by branch, gender
order by branch;

-- Which time of the day do customers give most ratings?

select time_of_day, round(avg(rating),2) as avg_rating from sales
group by time_of_day
order by avg(rating) desc limit 1;

-- Which time of the day do customers give most ratings per branch?

select branch, time_of_day, round(avg(rating),2) as avg_rating from sales
group by branch, time_of_day
order by avg_rating desc;

-- Which day of the week has the best avg ratings?

select day_name, avg(rating) from sales
group by day_name
order by avg(rating) desc limit 1;

-- Which day of the week has the best average ratings per branch?

select branch, day_name, avg(rating) from sales
group by day_name, branch
order by avg(rating) desc;	
