
/*-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
-- Showing all the table summary in hr schema.
USE Project;
SHOW TABLES;  

-- Extarcting all columns data.
SELECT * FROM customer_t;
SELECT * FROM order_t;
SELECT * FROM product_t;
SELECT * FROM shipper_t;	

/*-- QUESTIONS RELATED TO CUSTOMERS*/
     
     SELECT 
		  State, 
          COUNT(customer_id) AS Total_Customers
     FROM customer_t
     GROUP BY state
     ORDER BY Total_Customers DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.*/

WITH CUSTOMER_RATINGS AS(
   SELECT 
      Quarter_Number,
	  Customer_Feedback,
	  CASE -- Assigning Numerical values for each type of Customer_feedback.
		  WHEN UPPER(customer_feedback) = 'VERY BAD' THEN 1
		  WHEN UPPER(customer_feedback) = 'BAD' THEN 2
		  WHEN UPPER(customer_feedback) = 'OKAY' THEN 3
		  WHEN UPPER(customer_feedback) = 'GOOD' THEN 4
		  ELSE 5
	  END AS Ratings
	FROM order_t
    )
SELECT 
     quarter_number, 
     AVG(Ratings) AS Avg_Rating
FROM CUSTOMER_RATINGS
GROUP BY quarter_number
ORDER BY quarter_number;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?*/
      
	WITH Cust_Feedback AS(
		SELECT 
			  quarter_number,
			  COUNT(customer_feedback) OVER(PARTITION BY quarter_number) AS Count_by_Quarter,
              customer_feedback,
			  COUNT(customer_feedback) OVER(PARTITION BY quarter_number, customer_feedback) AS Count_by_feedback
			  FROM order_t
		)
	SELECT 
         quarter_number, 
         customer_feedback,
         Count_by_feedback,
         Count_by_Quarter,
         ROUND((Count_by_feedback / Count_by_Quarter) * 100, 2) AS percentage
    FROM Cust_Feedback
    GROUP BY 1,2
    ORDER BY quarter_number;
    
    
-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.*/

SELECT 
     P.vehicle_maker,
     COUNT(O.customer_id) AS Total_Customers
FROM product_t P
LEFT JOIN order_t O 
USING(product_id)
GROUP BY P.vehicle_maker
ORDER BY Total_Customers DESC
LIMIT 5; -- Extarcting Top-5 Vehicle_maker preferred by the customers.


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?*/

SELECT 
      State, 
      Vehicle_Maker,
      Total_Customers
FROM(
     SELECT 
           C.state, 
           P.vehicle_maker,
           COUNT(C.customer_id) as Total_Customers,
		   RANK() OVER(PARTITION BY C.state ORDER BY COUNT(C.customer_id) DESC) AS State_Rank
     FROM customer_t C
     LEFT JOIN order_t O USING(customer_id)
     JOIN product_t P USING(product_id)
     GROUP BY 1,2   -- Grouping by State and Vehicle_Maker.
     ORDER BY Total_Customers DESC
	) AS table_t
WHERE 
    State_Rank = 1
ORDER BY 
     Total_Customers DESC;
     

-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS

-- [Q6] What is the trend of number of orders by quarters?*/

SELECT 
      Quarter_Number, 
      COUNT(order_id) AS Orders_Trend
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? */

WITH QoQ AS(
      SELECT 
            Quarter_Number,
            SUM(vehicle_price * (1 - discount / 100))AS Total_Revenue
	  FROM order_t
      GROUP BY quarter_number
      ORDER BY quarter_number)
SELECT 
     Quarter_Number, 
     ROUND(Total_Revenue, 2) as Total_Revenue,
     ROUND(LAG(Total_Revenue) OVER (ORDER BY quarter_number), 2) AS Previous_quarter_Revenue,
	 ROUND((Total_Revenue-LAG(Total_Revenue) OVER (ORDER BY quarter_number))/LAG(Total_Revenue) OVER (ORDER BY quarter_number), 4)*100 AS Percentage
FROM QoQ;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?*/

SELECT 
      Quarter_Number,
      ROUND(SUM(vehicle_price-(vehicle_price*discount/100)),2) AS Total_Revenue,
      COUNT(order_id) AS Total_Orders
FROM order_t
GROUP BY  quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?*/

SELECT
     C.Credit_Card_Type, 
     ROUND(AVG(O.discount), 2)*100 AS Average_Discount
FROM customer_t C
LEFT JOIN order_t O 
USING(customer_id)
GROUP BY C.credit_card_type
ORDER BY Average_Discount DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?*/
    
    SELECT 
    Quarter_Number,
    CEIL(AVG(DATEDIFF(ship_date, order_date))) AS Average_Time_Taken
    FROM order_t
    GROUP BY quarter_number
    ORDER BY quarter_number;
-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



