-- total revenue in 1997
SELECT sum(oi.unit_price*oi.quantity*(1-oi.discount))
FROM order_details oi
        JOIN orders o USING (order_id)
WHERE o.order_date >= '1997-01-01' AND o.order_date <= '1997-12-31';

-- total cost/revenye per customer
SELECT c.company_name, sum(oi.unit_price*oi.quantity*(1-oi.discount)) AS total_payed
FROM customers c
        JOIN orders o USING (customer_id)
        JOIN order_details oi USING (order_id)
GROUP BY c.customer_id, c.company_name;

-- 10 most popular products (in terms of how many times they have been orderd) 
SELECT oi.product_id, p.product_name, count(*) AS no_orders
FROM order_details oi
        JOIN products p ON p.product_id = oi.product_id
GROUP BY oi.product_id, p.product_name
ORDER BY no_orders DESC
northwind-> LIMIT 10;


-- UK based customers having payed more than 1000 dollars
WITH revenue_per_customer AS(
        SELECT o.customer_id, sum(od.unit_price*od.quantity*(1-od.discount)) AS total_revenue
        FROM orders o
        JOIN order_details od USING (order_id)
        GROUP BY o.customer_id
        ORDER BY total_revenue DESC)


SELECT c.customer_id
FROM customers c
        JOIN revenue_per_customer rpc ON rpc.customer_id = c.customer_id
WHERE c.country = 'UK'
        AND rpc.total_revenue > 1000;


-- customers not having ordered anything 1/3

SELECT c.company_name
FROM customers c
LEFT JOIN orders o USING (customer_id)
WHERE o.order_id IS NULL;

(SELECT customer_id FROM customers) EXCEPT (SELECT customer_id FROM orders);


-- customers who have bought products costing less tan 5 dollars
SELECT DISTINCT c.customer_id
FROm customers c
JOIN orders o USING (customer_id)
JOIN order_details od USING (order_id)
WHERE od.unit_price < 5;

-- products that have been sold by all employees
SELECT od.product_id
FROM orders o
    JOIN order_details od USING (order_id)
GROUP BY od.product_id
HAVING count(DISTINCT o.employee_id)=9;

-- the average price of products by category.

SELECT c.category_name, sum(p.unit_price)
FROM products p
JOIN categories c USING (category_id)
GROUP BY c.category_id, c.category_name;

-- most popular product per country
WITH country_products AS (
        SELECT c.country, od.product_id, sum(od.quantity) AS antall
        FROM customers c
                JOIN orders o USING (customer_id)
                JOIN order_details od USING (order_id)
        GROUP BY c.country, od.product_id
        ORDER BY c.country, antall DESC
),
countries AS (
        SELECT DISTINCT country FROM customers
)

SELECT c.country, (SELECT cp.product_id FROM country_products cp WHERE cp.country = c.country LIMIT 1) AS product_id
FROM countries c;