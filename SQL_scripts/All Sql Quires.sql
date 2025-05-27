

-- ? 2. List the top 5 best-selling products by quantity sold
SELECT TOP 5 
    p.name AS Product_Name,
    SUM(od.quantity) AS Total_Units_Sold
FROM order_details AS od
JOIN products AS p ON od.product_id = p.id
GROUP BY p.name
ORDER BY Total_Units_Sold DESC;

-- ? 3. Identify customers with the highest number of orders
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS Customer_Name,
    COUNT(o.id) AS Order_Count
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.id
GROUP BY c.first_name, c.last_name
ORDER BY Order_Count DESC;

-- ? 4. Generate an alert for products with stock quantities below 20 units
SELECT 
    name AS Product_Name, 
    stock_quantity
FROM products
WHERE stock_quantity < 20
ORDER BY stock_quantity desc

-- ? 5. Determine the percentage of orders that used a discount
SELECT 
    CAST(COUNT(DISTINCT o.id) * 100.0 / 
         (SELECT COUNT(*) FROM orders) AS DECIMAL(5,2)) AS Discount_Usage_Percentage
FROM orders o
JOIN order_details od ON o.id = od.order_id
JOIN discounts d ON  od.product_id = d.product_id
WHERE o.order_date BETWEEN d.start_date AND d.end_date;

-- ? 6. Calculate the average rating for each product
SELECT 
    p.name AS Product_Name,
    ROUND(AVG(r.rating), 2) AS Avg_Rating
FROM reviews AS r
JOIN products AS p ON r.product_id = p.id
GROUP BY p.name
ORDER BY Avg_Rating DESC;


--Compute the 30-day customer retention rate after their first purchase
WITH customerfirstP AS (
    SELECT customer_id, MIN(order_date) AS Firstorder
    FROM orders
    GROUP BY customer_id
),
Next30Days AS (
    SELECT o.customer_id
    FROM orders o
    JOIN customerfirstP cfp ON  cfp.customer_id  = o.customer_id
    WHERE o.order_date > cfp.Firstorder
      AND o.order_date <= DATEADD(DAY, 30, cfp.Firstorder)
)
SELECT 
    CAST(COUNT(DISTINCT Next30Days.customer_id) * 100.0 / 
         (SELECT COUNT(*) FROM customerfirstP) AS DECIMAL(5,2)) AS RetentionRate
FROM Next30Days;










--Advanced Query 2
--● Recommend products frequently bought together with items in customer wishlists.
SELECT 
    w.customer_id,
    w.product_id AS wishlist_product,
    od.product_id AS bought_together_product,
    COUNT(*) AS frequency
FROM wishlists w
JOIN orders o ON w.customer_id = o.customer_id
JOIN order_details od ON o.id = od.order_id
WHERE od.product_id <> w.product_id
GROUP BY w.customer_id, w.product_id, od.product_id
ORDER BY frequency DESC;


--adv3 

-- ✅ 3. Track inventory turnover trends using a 30-day moving average
-- Step: Calculate turnover rate based on total units sold in 30-day windows
SELECT 
    CAST(order_date AS DATE) AS Sale_Date,
    AVG(SUM(od.quantity)) OVER (ORDER BY CAST(order_date AS DATE) ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS Moving_Avg_Units_Sold
FROM orders AS o
JOIN order_details AS od ON o.id = od.order_id
GROUP BY CAST(order_date AS DATE)
ORDER BY Sale_Date;



--Advanced Query 4
--● Identify customers who have purchased every product in a specific category.
DECLARE @category_id INT = 13;

SELECT 
    c.id AS customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_details od ON o.id = od.order_id
JOIN products p ON od.product_id = p.id
WHERE p.category_id = @category_id
GROUP BY c.id, c.first_name, c.last_name
HAVING COUNT(DISTINCT p.id) = (
    SELECT COUNT(*) FROM products WHERE category_id = @category_id
);

--adv5 
--Advanced5.
SELECT 
    p1.name AS First_Product,
    p2.name AS Second_Product,
    COUNT(*) AS Products_Together
FROM 
    order_details AS od1
JOIN 
    order_details AS od2 
    ON od1.order_id = od2.order_id 
    AND od1.product_id < od2.product_id
JOIN 
    products AS p1 ON od1.product_id = p1.id
JOIN 
    products AS p2 ON od2.product_id = p2.id
GROUP BY 
    p1.name, p2.name
ORDER BY
 Products_Together DESC;









--ADV 6 Calculate the time taken to deliver order in days--
SELECT 
O.customer_id as Order_ID,
  O.order_date, 
  sh.shipping_date, 
  DATEDIFF(DAY, O.order_date, sh.shipping_date) AS Delivers
FROM 
  orders O
inner JOIN 
  shipping sh ON O.id = sh.order_id
WHERE 
  O.status = 'delivered';



select * from orders



-----------------------------------------------------------------


SELECT 
    customer_id,
    DATEDIFF(MINUTE, session_start, session_end) AS session_duration_minutes,
    session_start,session_end,
    CASE 
        WHEN DATEDIFF(MINUTE, session_start, session_end) <= 15 THEN 'Short'
        WHEN DATEDIFF(MINUTE, session_start, session_end) >= 60 THEN 'long'
        ELSE 'Medium'
    END AS session_segment

FROM customer_sessions



SELECT 
    cs.customer_id,
    cs.session_start,
    cs.session_end,
    DATEDIFF(MINUTE, cs.session_start, cs.session_end) AS session_duration_minutes,

    CASE 
        WHEN DATEDIFF(MINUTE, cs.session_start, cs.session_end) <= 15 THEN 'Short'
        WHEN DATEDIFF(MINUTE, cs.session_start, cs.session_end) >= 60 THEN 'Long'
        ELSE 'Medium'
    END AS session_segment,

    o.id AS order_id,
    FORMAT(o.order_date, 'M/d/yyyy') AS order_date

FROM customer_sessions cs
LEFT JOIN orders o 
    ON cs.customer_id = o.customer_id
   AND o.order_date BETWEEN cs.session_start AND cs.session_end;


SELECT 
    c.id AS customer_id,
    c.first_name,
    c.last_name,
    cs.session_start,
    cs.session_end,
    DATEDIFF(MINUTE, cs.session_start, cs.session_end) AS session_duration_minutes,

    CASE 
        WHEN DATEDIFF(MINUTE, cs.session_start, cs.session_end) <= 15 THEN 'Short'
        WHEN DATEDIFF(MINUTE, cs.session_start, cs.session_end) >= 60 THEN 'Long'
        ELSE 'Medium'
    END AS session_segment,

    p.amount AS payment_amount,
	p.order_id,
    CONVERT(VARCHAR(10), p.payment_date, 101) AS payment_date  -- format: MM/DD/YYYY

FROM customers c
LEFT JOIN customer_sessions cs
    ON c.id = cs.customer_id
LEFT JOIN payments p
    ON c.id = p.customer_id;





