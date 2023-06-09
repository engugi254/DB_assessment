--1. Write a query to retrieve the list of orders along with the customer name and staff name for each order

SELECT c.customer_id, c.first_name, c.last_name,order_status,order_date,item_id,product_id,s.staff_id, s.first_name, s.last_name
FROM sales.customers c
INNER JOIN sales.orders o
ON c.customer_id=o.customer_id
INNER JOIN sales.order_items i
ON i.order_id=o.order_id
INNER JOIN sales.staffs s
ON s.staff_id = o.staff_id 

--2. Create a view that returns the total quantity and sales amount for each product.
	--First thing is to create a VIEW with name sales.total_sales_quantity

CREATE VIEW sales.total_sales_quantity
AS
	/*Here i calculate the sum of quantity grouped by product_id
	I also calculate sum of sales amount by removing the discounted price for each product also grouped by product_id */

	SELECT product_id,SUM(quantity) AS quantity_sum,SUM(list_price*(1-discount)) AS sales_amount
	FROM sales.order_items
	GROUP BY product_id

--3. Write a stored procedure that accepts a customer ID and returns the total number of orders placed by that customer.
	/*First step is to create a procedure with name sales.total_orders with variable _customer_id which takes the
	customer's id and produces their total orders */

CREATE PROCEDURE sales.total_orders(
	@_customer_id INT
)
AS
BEGIN
	SELECT customer_id,SUM(quantity) AS total_orders
	FROM sales.orders o
	INNER JOIN sales.order_items i
	ON o.order_id=i.order_id
	WHERE customer_id=@_customer_id
	GROUP BY customer_id

END
--here we execute the total number of orders by customer with id 259 which is 8 orders
EXEC sales.total_orders 259

--4. Write a query to find the top 5 customers who have placed the most orders.

	/*First step is to join sales.order_items which contains the quantity of orders 
	with sales.orders table which contains customer_id. I will also need to join with sales.customers
	to get their names and then find the total of orders grouped by customers
	then pick the top 5 */

	SELECT TOP 5 c.customer_id,first_name,last_name, SUM(quantity) AS total_quantity
	FROM sales.order_items i
	INNER JOIN sales.orders o
	ON i.order_id=o.order_id
	INNER JOIN sales.customers c
	ON o.customer_id=c.customer_id
	GROUP BY c.customer_id,first_name,last_name
	ORDER BY SUM(quantity) DESC
	
	
--.5 Create a view that shows the product details along with the total sales quantity and revenue for each product.
CREATE VIEW sales.total_product_sales_quantity
AS
	SELECT p.product_id, product_name,category_id,SUM(quantity) AS quantity_sum,SUM(i.list_price*(1-discount)) AS sales_amount
	FROM production.products p
	INNER JOIN sales.order_items i
	ON p.product_id=i.product_id
	INNER JOIN sales.orders o
	ON i.order_id=o.order_id
	GROUP BY p.product_id,product_name,category_id
	
	
	
	