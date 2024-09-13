create database swiggy;

use swiggy;

-- 1. How many customers have not placed any orders?

SELECT NAME FROM USERS WHERE
USER_ID NOT IN (SELECT USER_ID FROM ORDERS);

-- 2. What is the average price for each food?

SELECT F.F_NAME, AVG(PRICE) AS AVG_PRICE FROM MENU M JOIN FOOD F ON M.F_ID=F.F_ID
GROUP BY F.F_NAME;

-- 3.Find the top restaurants in terms of number of orders for the month of June?

SELECT R.R_NAME, COUNT(*) FROM ORDERS O JOIN RESTAURANTS R ON O.R_ID = R.R_ID
WHERE MONTHNAME(DATE) = 'JUNE'
GROUP BY R.R_NAME
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 4. Find the restaurants with monthly revenue greater than 500?

SELECT R.R_NAME, SUM(AMOUNT) AS REVENUE FROM ORDERS O JOIN RESTAURANTS R ON O.R_ID = R.R_ID
WHERE MONTHNAME(DATE) = 'JUNE'
GROUP BY R.R_NAME
HAVING REVENUE > 500;

-- 5.Show all orders with order details for a particular customer in a particular date range (10th June 2022 to 10th July 2022)?

SELECT O.ORDER_ID, R.R_NAME, F.F_NAME FROM ORDERS O
JOIN RESTAURANTS R ON R.R_ID = O.R_ID
JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
JOIN FOOD F ON F.F_ID = OD.F_ID
WHERE USER_ID = (SELECT USER_ID FROM USERS WHERE NAME LIKE 'ANKIT') AND
DATE BETWEEN '2022-06-10' AND '2022-07-10';

-- 6.Find the restaurants with the maximum repeated customers?

SELECT R.R_NAME, COUNT(*) AS LOYAL_CUSTOMERS FROM (
	SELECT R_ID, USER_ID, COUNT(*) AS VISITS
    FROM ORDERS 
    GROUP BY R_ID,USER_ID
    HAVING VISITS > 1 ) T
JOIN RESTAURANTS R ON R.R_ID = T.R_ID
GROUP BY R.R_NAME
ORDER BY LOYAL_CUSTOMERS DESC
LIMIT 1;

-- 7. Find the month over month revenue growth of swiggy?

SELECT MON, ((REVENUE - PREV )/PREV)*100 FROM (

WITH SALES AS(
SELECT MONTH(DATE), MONTHNAME(DATE) AS MON , SUM(AMOUNT) AS REVENUE FROM ORDERS
GROUP BY MONTH(DATE), MONTHNAME(DATE)
ORDER BY MONTH(DATE)
)
SELECT MON, REVENUE, LAG(REVENUE,1) OVER(ORDER BY REVENUE) AS PREV FROM SALES
) T;

-- 8. Fing the favorite food for each customer?

WITH TEMP AS(

SELECT O.USER_ID, OD.F_ID, COUNT(*) AS FREQUENCY FROM ORDERS O
JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY O.USER_ID,OD.F_ID

)

SELECT U.NAME, F.F_NAME FROM TEMP T1 JOIN USERS U ON U.USER_ID = T1.USER_ID 
JOIN FOOD F ON F.F_ID = T1.F_ID
WHERE T1.FREQUENCY = (SELECT MAX(FREQUENCY) FROM TEMP T2 
						WHERE T2.USER_ID = T1.USER_ID);
                        
                        
                        
-- 9. Find the top 3 most ordered dish?

SELECT F_NAME,ORDER_COUNT FROM (
SELECT F_NAME,COUNT(*) as ORDER_COUNT, ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS ROWNUM FROM ORDER_DETAILS OD
INNER JOIN FOOD F
ON F.F_ID = OD.F_ID
GROUP BY F_NAME
ORDER BY ORDER_COUNT DESC
) T
WHERE ROWNUM <= 3;

-- 10. What is the average order value per user?

SELECT NAME, ROUND(AVG(AMOUNT),1) AS AVG_ORDER_VALUE
FROM ORDERS O JOIN USERS U ON O.USER_ID = U.USER_ID
GROUP BY NAME;

-- 11. What is the average delivery time for each restaurant, and how does it affect customer satisfaction?

select r.r_name, round(avg(o.delivery_time),2) as avg_delivery_time, round(avg(o.delivery_rating),2) as avg_delivery_rating
from orders o
join restaurants r on o.r_id = r.r_id
group by r.r_name;

-- 12. What is the average rating for each restaurant and delivery partner?
SELECT R.R_NAME, ROUND(AVG(O.RESTAURANT_RATING),2) AS AVG_RESTAURANT_RATING
FROM ORDERS O 
JOIN RESTAURANTS R ON O.R_ID = R.R_ID
GROUP BY R.R_NAME;

SELECT DP.PARTNER_NAME, ROUND(AVG(O.DELIVERY_RATING),2) AS AVG_DELIVERY_RATING
FROM ORDERS O
JOIN DELIVERY_PARTNER DP ON O.PARTNER_ID = DP.PARTNER_ID
GROUP BY DP.PARTNER_NAME;


-- 13. Which days and times see the highest order volume, and are there any patterns in user behavior?

SELECT DAYNAME(DATE) AS ORDER_DAY, 
       COUNT(ORDER_ID) AS ORDER_COUNT
FROM ORDERS
GROUP BY DAYNAME(DATE)
ORDER BY ORDER_COUNT DESC;

-- 14. How many orders were delivered by each delivery partner and what is their average delivery rating?

SELECT DP.PARTNER_ID, DP.PARTNER_NAME, COUNT(*) AS DELIVERY_COUNT, AVG(O.DELIVERY_RATING) AS AVG_DELIVERY_RATING
FROM ORDERS O
JOIN DELIVERY_PARTNER DP ON O.PARTNER_ID = DP.PARTNER_ID
GROUP BY DP.PARTNER_ID, DP.PARTNER_NAME;
