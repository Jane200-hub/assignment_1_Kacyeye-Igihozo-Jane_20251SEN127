PLSQL Assignment One – Sunrise Supermarket
Student Information
Item	Details
Student Name	Kacyeye Igihozo Jane
Student ID	20251SEN127
DBMS Used	PostgreSQL
Repository Name	`assignment_1_KacyeyeIgihozoJane-20251SEN127`
---
1. Assignment Summary
This assignment implements and analyzes a relational database for Sunrise Supermarket using PostgreSQL.
The database contains customers, products, orders, and order items. SQL JOINs, a Common Table Expression (CTE), and window functions are used to answer business questions about customers, products, spending, order frequency, and revenue trends.
The database satisfies the required minimum data:
6 customers
8 products
5 product categories
15 orders
30 order items
Orders recorded across multiple dates
The PostgreSQL data types used are the PostgreSQL equivalents of the Oracle-style types shown in the assignment.
---
2. Business Scenario
Sunrise Supermarket sells products to customers who place orders containing one or more items.
Management wants to understand:
Who their customers are.
What products customers buy.
How much customers spend.
Which customers spend above the average.
How customers rank according to total spending.
How many orders each customer has placed.
How revenue changes over time.
How many days pass between repeat customer orders.
The database queries below provide this information using the SQL techniques required by the assignment.
---
3. Database Tables and Relationships
The database contains four tables.
`customers`
Stores customer information:
`customer_id`
`customer_name`
`email`
`city`
`products`
Stores product information:
`product_id`
`product_name`
`category`
`price`
`orders`
Stores customer orders:
`order_id`
`customer_id`
`order_date`
`order_items`
Stores the products and quantities included in orders:
`order_item_id`
`order_id`
`product_id`
`quantity`
Relationships
`orders.customer_id` references `customers.customer_id`.
`order_items.order_id` references `orders.order_id`.
`order_items.product_id` references `products.product_id`.
These relationships allow information from the different tables to be combined for analysis.
---
4. JOIN Queries
Query 1 – Every Order with Customer Details
Requirement
List every order with the customer's name, city, and order date using an INNER JOIN between `orders` and `customers`.
SQL Query
```sql
SELECT o.order_id, c.customer_name, c.city, o.order_date FROM orders o INNER JOIN customers c ON o.customer_id = c.customer_id ORDER BY o.order_date;
```
Explanation
The `INNER JOIN` connects each order to the customer who placed it.
The tables are matched using:
`o.customer_id = c.customer_id`
The query displays:
Order ID
Customer name
Customer city
Order date
Only records with matching customer and order information are returned.
Result / Screenshot
![Query 1 Result](screenshots/query1_order_customer.png)
Screenshot file: `query1_order_customer.png`
Business Interpretation
Management can use this information to identify which customers placed particular orders, where the customers are located, and when the orders were placed.
---
Query 2 – Order Items with Product Details
Requirement
List every order item with product name, category, price, and quantity using a JOIN between `order_items` and `products`.
SQL Query
```sql
SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity FROM order_items oi INNER JOIN products p ON oi.product_id = p.product_id ORDER BY oi.order_id;
```
Explanation
The `INNER JOIN` connects each order item to its corresponding product.
The tables are matched using:
`oi.product_id = p.product_id`
The query displays the product name, category, price, and quantity purchased for each order item.
Result / Screenshot
![Query 2 Result](screenshots/query2_order_items.png)
Screenshot file: `query2_order_items.png`
Business Interpretation
Management can use this information to see what products are being purchased, the categories they belong to, their prices, and the quantities ordered.
---
Query 3 – All Customers and Their Orders
Requirement
List all customers and their orders where they exist, including customers with no orders, using a LEFT JOIN between `customers` and `orders`.
SQL Query
```sql
SELECT c.customer_id, c.customer_name, c.city, o.order_id, o.order_date FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id ORDER BY c.customer_id, o.order_date;
```
Explanation
The `LEFT JOIN` keeps every customer from the `customers` table.
The tables are matched using:
`c.customer_id = o.customer_id`
If a customer has no matching order, the order columns would appear as `NULL`. This is the purpose of using a LEFT JOIN instead of an INNER JOIN.
Result / Screenshot
![Query 3 Result](screenshots/query3_customers_orders.png)
Screenshot file: `query3_customers_orders.png`
Business Interpretation
This query helps management identify customer order activity and can also identify customers who have not yet placed an order when such customers exist in the database.
---
5. CTE Query
Query 4 – Customers Above Average Spending
Requirement
Calculate each customer's total spend using `quantity × price` and return customers whose spending is above the average. A CTE is used to calculate customer totals first.
SQL Query
```sql
WITH customer_totals AS (SELECT c.customer_id, c.customer_name, COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id LEFT JOIN order_items oi ON o.order_id = oi.order_id LEFT JOIN products p ON oi.product_id = p.product_id GROUP BY c.customer_id, c.customer_name) SELECT customer_id, customer_name, total_spend FROM customer_totals WHERE total_spend > (SELECT AVG(total_spend) FROM customer_totals) ORDER BY total_spend DESC;
```
Explanation
The `customer_totals` CTE first calculates the total amount spent by each customer.
The calculation is:
`quantity × price`
`SUM()` adds the values for all products purchased by each customer.
The main query then calculates the average of all customer totals and returns only customers whose total spending is greater than the average.
`COALESCE` changes a possible `NULL` total into zero.
Result / Screenshot
![Query 4 Result](screenshots/query4_cte_above_average.png)
Screenshot file: `query4_cte_above_average.png`
Business Interpretation
The result identifies customers whose spending is above the average. Management can use this information to understand higher-spending customer groups.
---
6. Window-Function Queries
Query 5 – Rank Customers by Total Amount Spent
Requirement
Rank customers by total amount spent, with the highest amount first.
SQL Query
```sql
WITH customer_totals AS (SELECT c.customer_id, c.customer_name, COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id LEFT JOIN order_items oi ON o.order_id = oi.order_id LEFT JOIN products p ON oi.product_id = p.product_id GROUP BY c.customer_id, c.customer_name) SELECT customer_id, customer_name, total_spend, RANK() OVER (ORDER BY total_spend DESC) AS spending_rank FROM customer_totals ORDER BY spending_rank;
```
Explanation
The CTE calculates the total spending for each customer.
The `RANK()` window function then ranks customers according to total spending in descending order.
The highest total spending receives rank 1. If customers have equal spending amounts, they receive the same rank.
Result / Screenshot
![Query 5 Result](screenshots/query5_customer_ranking.png)
Screenshot file: `query5_customer_ranking.png`
Business Interpretation
The ranking allows management to compare customer spending levels and understand how sales are distributed among customers.
---
Query 6 – Number Each Customer's Orders
Requirement
Number each customer's orders according to the order in which they were placed.
SQL Query
```sql
SELECT order_id, customer_id, order_date, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS customer_order_number FROM orders ORDER BY customer_id, order_date;
```
Explanation
The `ROW_NUMBER()` window function assigns a sequential number to each customer's orders.
`PARTITION BY customer_id` separates orders by customer.
`ORDER BY order_date` places each customer's orders chronologically.
Therefore, a customer's first order receives number 1, the second receives number 2, and so on.
Result / Screenshot
![Query 6 Result](screenshots/query6_order_numbering.png)
Screenshot file: `query6_order_numbering.png`
Business Interpretation
This helps management understand the sequence of customer purchases and identify repeat ordering behavior.
---
Query 7 – Running Total of Revenue Over Time
Requirement
Show a running total of revenue over time, ordered by order date.
SQL Query
```sql
WITH daily_revenue AS (SELECT o.order_date, SUM(oi.quantity * p.price) AS daily_revenue FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id GROUP BY o.order_date) SELECT order_date, daily_revenue, SUM(daily_revenue) OVER (ORDER BY order_date) AS running_total_revenue FROM daily_revenue ORDER BY order_date;
```
Explanation
The `daily_revenue` CTE calculates the total revenue for each order date.
Revenue is calculated using:
`quantity × price`
The windowed `SUM()` then adds each day's revenue to the revenue from previous dates.
This produces a running total in chronological order.
Result / Screenshot
![Query 7 Result](screenshots/query7_running_revenue.png)
Screenshot file: `query7_running_revenue.png`
Business Interpretation
The running total allows management to monitor how revenue accumulates over time and understand the sales trend during the period represented in the database.
---
Query 8 – Days Between Customer Orders
Requirement
For each customer with more than one order, show the number of days between the current order and the previous order.
SQL Query
```sql
WITH customer_orders AS (SELECT order_id, customer_id, order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date, COUNT(*) OVER (PARTITION BY customer_id) AS order_count FROM orders) SELECT order_id, customer_id, order_date, previous_order_date, order_date - previous_order_date AS days_between_orders FROM customer_orders WHERE order_count > 1 AND previous_order_date IS NOT NULL ORDER BY customer_id, order_date;
```
Explanation
The `LAG()` window function retrieves the previous order date for each customer.
`PARTITION BY customer_id` makes the comparison occur separately for each customer.
`ORDER BY order_date` puts the orders in chronological order.
The expression:
`order_date - previous_order_date`
calculates the number of days between the two orders.
The query only returns customers who have more than one order and records where a previous order exists.
Result / Screenshot
![Query 8 Result](screenshots/query8_days_between_orders.png)
Screenshot file: `query8_days_between_orders.png`
Business Interpretation
Management can use this information to understand repeat purchasing frequency and the time between customer orders.
---
7. Overall Business Interpretation
The eight queries provide different views of Sunrise Supermarket's operations.
Customer and Order Analysis
The JOIN queries connect customers, orders, products, and order items. This allows management to understand customer activity and the products included in orders.
Customer Spending
The CTE calculates total spending per customer and identifies customers above the average spending level.
Customer Ranking
The `RANK()` window function provides a spending order based on total customer purchases.
Order Frequency
`ROW_NUMBER()` shows the sequence of orders for each customer, while `LAG()` calculates the number of days between repeat orders.
Revenue Trend
The running-total query shows how revenue accumulates across the order dates.
Together, these results provide structured information that can support customer and sales analysis at Sunrise Supermarket.
---
8. Challenges and Resolutions
Challenge 1 – Using PostgreSQL
The assignment example uses Oracle-style types such as `NUMBER` and `VARCHAR2`, while this project uses PostgreSQL.
Resolution
Equivalent PostgreSQL types were used, including:
`INTEGER`
`VARCHAR`
`NUMERIC(10,2)`
`DATE`
---
Challenge 2 – Combining Related Tables
Some requirements needed information from more than one table.
Resolution
INNER JOIN and LEFT JOIN were used with the primary-key and foreign-key relationships between the tables.
---
Challenge 3 – Calculating Customer Spending
Customer spending depends on both product price and quantity.
Resolution
The calculation `quantity × price` was combined with `SUM()` and grouped by customer.
---
Challenge 4 – CTEs and Window Functions
The CTE and window-function requirements involve calculations across multiple records.
Resolution
CTEs were used to create intermediate customer and revenue calculations. `RANK()`, `ROW_NUMBER()`, `LAG()`, and windowed `SUM()` were used to perform the required analysis.
---
9. How to Run the Project
Step 1 – Install PostgreSQL
Install PostgreSQL and make sure the PostgreSQL server is running.
Step 2 – Open the Database
The database used for this assignment is:
```text
sunrise_supermarket
```
Step 3 – Connect Using PSQL
```text
psql -U postgres -d sunrise_supermarket
```
Step 4 – Run the SQL File
The repository contains:
```text
assignment_1.sql
```
The file contains the table definitions, data, and required queries.
If PostgreSQL is installed in the default Windows location, the SQL file can be run with:
```text
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d sunrise_supermarket -f "assignment_1.sql"
```
---
10. Repository Structure
The GitHub repository should contain:
```text
assignment_1_KacyeyeIgihozoJane-20251SEN127/
│
├── README.md
├── assignment_1.sql
└── screenshots/
    ├── query1_order_customer.png
    ├── query2_order_items.png
    ├── query3_customers_orders.png
    ├── query4_cte_above_average.png
    ├── query5_customer_ranking.png
    ├── query6_order_numbering.png
    ├── query7_running_revenue.png
    └── query8_days_between_orders.png
```
---
11. Screenshot Checklist
Before submitting, confirm that all eight result screenshots are uploaded to the `screenshots` folder:
[ ] Query 1 – `query1_order_customer.png`
[ ] Query 2 – `query2_order_items.png`
[ ] Query 3 – `query3_customers_orders.png`
[ ] Query 4 – `query4_cte_above_average.png`
[ ] Query 5 – `query5_customer_ranking.png`
[ ] Query 6 – `query6_order_numbering.png`
[ ] Query 7 – `query7_running_revenue.png`
[ ] Query 8 – `query8_days_between_orders.png`
Each screenshot is linked directly in the relevant section of this README using a GitHub-relative path such as:
`![Query Result](screenshots/query1_order_customer.png)`
---
12. Final Submission Checklist
[ ] Student name is included.
[ ] Student ID is included.
[ ] PostgreSQL is identified as the DBMS.
[ ] Repository name follows `assignment_1_your_name-your_id`.
[ ] Business scenario is explained.
[ ] Required minimum data is populated.
[ ] All three JOIN queries are included and explained.
[ ] The CTE query is included and explained.
[ ] All four window-function queries are included and explained.
[ ] Results/screenshots are provided for all eight queries.
[ ] Business interpretation is included.
[ ] Challenges and resolutions are included.
[ ] `README.md` is uploaded.
[ ] `assignment_1.sql` is uploaded.
[ ] `screenshots` folder is uploaded with the eight screenshots.
[ ] Repository is pushed before the deadline.
[ ] Repository URL is submitted to the instructor.
---
13. Conclusion
This assignment demonstrates the use of PostgreSQL to manage and analyze Sunrise Supermarket data.
INNER JOIN, LEFT JOIN, a Common Table Expression, and window functions were used to analyze customer information, product orders, customer spending, order sequences, repeat-order timing, and revenue trends.
The results provide useful structured information for understanding customer purchasing behavior and monitoring sales over time.
