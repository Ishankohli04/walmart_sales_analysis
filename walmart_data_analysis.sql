use new_walmart_db;
select count(*) from new_walmart;
select * from new_walmart limit 10;
select payment_method , count(*) from new_walmart group by payment_method;
select count(distinct branch) from new_walmart;
select max(quantity) from new_walmart;
-- Business Problems ;
-- Q.1 find different payment method and number of transaction , number of qty sold
select payment_method , count(*) as no_payments , 
sum(quantity) as no_qty_sold from new_walmart group by payment_method;
-- Q.2 identify the highest rating category in each branch , displaying the branch category avg rating;

select * from (select branch , category , avg(rating) as avg_rating , rank() over(partition by branch order by avg(rating) desc) as ranks
from new_walmart group by branch , category) as ranks_table where ranks = 1;

-- Q.3 Identify the busiest day for each  branch based on the number of transactions;

select * from (
 select branch , date_format(str_to_date(date , '%d/%m/%y'), '%W') as day_name ,count(*) as no_transactions,
 rank() over(partition by branch order by count(*) desc) as ranks
 from new_walmart group by branch , day_name) as trans_table
 where ranks = 1;
 
 -- Q.4 calculate the total quantity of items sold per payment method. list payment_method and total_quantity;
 
 select payment_method ,  
sum(quantity) as no_qty_sold from new_walmart group by payment_method;

-- Q.5 Determine the average ,minimum , and maximum rating of category for each city. list the city ,average_rating ,min_rating
-- and max_rating;
select city, category , min(rating) as min_rating , max(rating) as max_rating , avg(rating) as avg_rating from new_walmart 
group by city , category;

-- Q.6 calculate the total profit for each category by considering total_profit as 
-- (unit_price * quantity * profit_margin). List category and total_profit , ordered from highest to lowest profit;

select category ,sum(total) as total_revenue ,sum(total * profit_margin) as profit from new_walmart group by category;

-- Q.7 Determine the most common method for each branch. Display branch and the preferred_payment_method.

with ftp as
(select branch , payment_method ,count(*) as total_trans, rank() over(partition by branch order by count(*) desc) as ranks from new_walmart
group by branch , payment_method) select * from ftp where ranks = 1;

-- Q.8 Categorize sales into 3 groups morning , afternoon , evening. Find out the each of the shifts and no. of invoices

select branch , case when extract(hour from Time )< 12 then 'Morning'
		   when extract(hour from Time ) between 12 and 17  then 'Afternoon'
           else 'Evening' end as day_time, count(*)
from new_walmart group by day_time, branch order by branch , day_time;

-- Q.9 Identify 5 branch with the highest decrease ratio in revenue compare to last year (current year 2023 and last year 2022);
-- revenue_decreased_ratio = last_rev-cr_rev/ls_rev*100

SELECT * ,YEAR(STR_TO_DATE(date, '%d/%m/%y')) AS formatted_date FROM new_walmart;

-- 2022 sales;
with revenue_2022 as 
(select branch , sum(total) as revenue from new_walmart 
where YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
group by branch),

revenue_2023 as
( select branch , sum(total) as revenue from new_walmart 
where YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023 
group by branch)

select  ls.branch , ls.revenue as last_year_revenue , cs.revenue as current_year_revenue , 
round((cast((ls.revenue - cs.revenue) as decimal) / cast(ls.revenue as decimal )) * 100 , 2)as revenue_decreased_ratio
from revenue_2022 as ls join  revenue_2023 as cs on ls.branch = cs.branch 
where  ls.revenue > cs.revenue 
order by round((cast((ls.revenue - cs.revenue) as decimal) / cast(ls.revenue as decimal )) * 100 , 2) desc
limit 5;






