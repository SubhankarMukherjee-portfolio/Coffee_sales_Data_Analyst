create DATABASE Coffee_sales;
USE Coffee_sales;

select * from coffee_sales;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE coffee_sales
ADD COLUMN OrderDate DATE;
ALTER TABLE coffee_sales
ADD COLUMN OrderDateTime DATETIME(3);

UPDATE coffee_sales
SET OrderDate = STR_TO_DATE(TRIM(date), '%Y-%m-%d');

UPDATE coffee_sales
SET OrderDateTime = STR_TO_DATE(TRIM(datetime), '%Y-%m-%d %H:%i:%s.%f');

ALTER TABLE coffee_sales
DROP COLUMN date;
ALTER TABLE coffee_sales
DROP COLUMN datetime;

select * from coffee_sales;

#check number of empty rows
SELECT * FROM coffee_sales
WHERE OrderDate IS NULL 
   OR OrderDateTime IS NULL
   OR cash_type IS NULL
   OR card IS NULL
   OR money IS NULL
   OR coffee_name IS NULL;

#count number of empty rows
SELECT COUNT(*) AS empty_row_count FROM coffee_sales
WHERE OrderDate IS NULL 
   OR OrderDateTime IS NULL
   OR cash_type IS NULL
   OR card IS NULL
   OR money IS NULL
   OR coffee_name IS NULL;


#1.	How many total orders in dataset were placed?
SELECT COUNT(*) AS total_orders_in_dataset from coffee_sales;

#2.	How many distinct customers used cards?
SELECT COUNT(DISTINCT card) AS distinct_customers_used_cards FROM coffee_sales
WHERE card IS NOT NULL;

#3. What are the unique coffee names sold?
SELECT DISTINCT coffee_name AS distinct_coffee_name FROM coffee_sales
WHERE coffee_name IS NOT NULL;
SELECT COUNT(DISTINCT coffee_name) AS distinct_coffee_name_count FROM coffee_sales
WHERE coffee_name IS NOT NULL;

#4. What is the total revenue generated?
select round(sum(money) ,2) as total_revenue from coffee_sales;

#5. How many orders were made using cash vs card?
select cash_type , count(*)  as no_of_orders from coffee_sales
group by cash_type;

#6. What is the total revenue by each coffee type
select cash_type , round(sum(money),2)  as total_revenue from coffee_sales
group by cash_type;

#7. Which coffee had the highest number of sales?
select coffee_name, round(sum(money),2) as total_revenue from coffee_sales
group by coffee_name
order by total_revenue desc;

#8. How much revenue and number of cups were sold each month?
SELECT MONTH(OrderDate) AS month_number, MONTHNAME(OrderDate) AS month_name, ROUND(SUM(money), 2) AS total_revenue, count(*)as number_of_cups_of_coffee
FROM coffee_sales
GROUP BY MONTH(OrderDate), MONTHNAME(OrderDate)
ORDER BY MONTH(OrderDate);

#9. How much revenue and number of cups were sold each day of week?
SELECT DAYNAME(OrderDate) AS day_name, ROUND(SUM(money), 2) AS total_revenue, count(*)as number_of_cups_of_coffee FROM coffee_sales
GROUP BY day_name
ORDER BY 
    CASE day_name
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

#10. Top 10 customer (card) made the most purchases?
select card, count(*) as number_of_purchase, ROUND(SUM(money), 2) AS total_revenue FROM coffee_sales
WHERE cash_type = 'card'
group by card order by number_of_purchase desc limit 10; 

#11. At what time of day are most coffees sold (morning, afternoon, evening)?
SELECT 
  CASE 
    WHEN HOUR(OrderDateTime) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(OrderDateTime) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(OrderDateTime) BETWEEN 18 AND 22 THEN 'Evening'
    ELSE 'Other'
  END AS time_of_day,
  COUNT(*) AS total_sales, ROUND(SUM(money), 2) AS total_revenue FROM coffee_sales
GROUP BY time_of_day
ORDER BY total_sales DESC;

#12. What is the average time between two purchases for each customer?
SELECT ROUND(AVG(TIMESTAMPDIFF(MINUTE, prev_time, OrderDateTime)), 2) AS overall_avg_minutes_between_purchases
FROM (SELECT card,OrderDateTime,LAG(OrderDateTime) OVER (PARTITION BY card, DATE(OrderDateTime) ORDER BY OrderDateTime) AS prev_time FROM coffee_sales
  WHERE card IS NOT NULL) AS t
WHERE prev_time IS NOT NULL;

#13. Which coffee is most commonly purchased with cash?
select coffee_name, round(sum(money),2) as total_revenue, count(*) as number_of_purchase from coffee_sales
where cash_type = 'cash'
group by coffee_name
order by total_revenue desc, number_of_purchase desc ;

#14. What is the average transaction amount by cash type ?
select cash_type, round(avg(money),2) as average_transaction_amount from coffee_sales
group by cash_type;

# 15. Which coffee has the highest average price? is there is difference between cand and cash payment
select cash_type , coffee_name, round(avg(money),2) as  average_price from coffee_sales 
group by cash_type, coffee_name
order by average_price desc;

#16.  Identify customer behavior: Which customers (card IDs) show loyalty over multiple days?
select card, count(OrderDate) as number_of_time_visit  from coffee_sales
where cash_type = 'card'
group by card order by number_of_time_visit desc;

#17. How many customers made more than 3 purchases in total(cash_type is card)?
SELECT COUNT(*) AS customers_with_more_than_3_purchases
FROM (SELECT card FROM coffee_sales
    WHERE cash_type = 'card'
    GROUP BY card
    HAVING COUNT(*) > 3) AS subquery;

#18. What is the proportion of revenue contributed by cash vs card and coffee type?
SELECT cash_type, coffee_name,ROUND(SUM(money), 2) AS total_revenue, 
ROUND(SUM(money) * 100.0 / (SELECT SUM(money) FROM coffee_sales), 2) AS revenue_percentage FROM coffee_sales
GROUP BY cash_type, coffee_name ORDER BY total_revenue DESC;



