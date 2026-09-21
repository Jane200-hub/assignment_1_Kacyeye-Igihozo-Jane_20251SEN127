PLSQL Assignment One – Sunrise Supermarket
Student Information
Item	Details
Student Name	Kacyeye Igihozo Jane
Student ID	20251SEN127
DBMS Used	PostgreSQL
Repository Name	`assignment_1_KacyeyeIgihozoJane-20251SEN127`
---
1. Assignment Summary
This assignment implements a relational database for Sunrise Supermarket using PostgreSQL.
The database stores information about customers, products, orders, and order items. SQL JOINs, a Common Table Expression (CTE), and window functions are used to analyze customer purchases, customer spending, order frequency, and revenue trends.
The database was populated with:
6 customers
8 products
5 product categories
15 orders
30 order items
Orders recorded across multiple dates in September 2026
The original assignment table definitions use Oracle-style data types such as `NUMBER` and `VARCHAR2`. Since PostgreSQL was selected for this assignment, the equivalent PostgreSQL data types were used.
---
2. Business Scenario
Sunrise Supermarket sells products to customers who place orders containing one or more items.
Management wants to understand:
Who their customers are.
Which customers place orders.
What products customers purchase.
How much each customer spends.
Which customers spend above the average.
How customers rank according to total spending.
How frequently customers place orders.
How revenue accumulates over time.
How many days pass between repeat customer orders.
The SQL queries in this assignment provide information that can support these business activities.
---
3. Database Structure
The database contains four related tables:
Customers
The `customers` table stores customer information such as customer ID, name, email, and city.
Products
The `products` table stores product information including product ID, product name, category, and price.
Orders
The `orders` table records orders placed by customers and the date each order was placed.
Order Items
The `order_items` table records the individual products included in each order and their quantities.
Relationships
`orders.customer_id` references `customers.customer_id`.
`order_items.order_id` references `orders.order_id`.
`order_items.product_id` references `products.product_id`.
These relationships allow information from the four tables to be combined for analysis.
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
This query uses an INNER JOIN to connect each order in the `orders` table with the customer who placed it.
The tables are joined using:
`orders.customer_id = customers.customer_id`
The query returns:
Order ID
Customer name
Customer city
Order date
Because an INNER JOIN only returns matching records, every displayed order has a corresponding customer.
Result / Screenshot
INSERT SCREENSHOT 1 HERE – Query 1 Result
Suggested filename: `query1_order_customer.png`
Business Interpretation
This information allows management to identify which customers placed specific orders, where they are located, and when the orders were placed.
---
Query 2 – Order Items with Product Details
Requirement
List every order item with the product name, category, price, and quantity using a JOIN between `order_items` and `products`.
SQL Query
```sql
SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity FROM order_items oi INNER JOIN products p ON oi.product_id = p.product_id ORDER BY oi.order_id;
```
Explanation
This query uses an INNER JOIN between `order_items` and `products`.
The tables are joined using:
`order_items.product_id = products.product_id`
The query shows the product associated with each order item together with:
Order item ID
Order ID
Product name
Product category
Product price
Quantity purchased
Result / Screenshot
INSERT SCREENSHOT 2 HERE – Query 2 Result
Suggested filename: `query2_order_items.png`
Business Interpretation
Management can use this information to see which products are being purchased, the categories they belong to, their prices, and the quantities sold.
---
Query 3 – All Customers and Their Orders
Requirement
List all customers and their orders where they exist, including customers with no orders, using a LEFT JOIN between `customers` and `orders`.
SQL Query
```sql
SELECT c.customer_id, c.customer_name, c.city, o.order_id, o.order_date FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id ORDER BY c.customer_id, o.order_date;
```
Explanation
This query uses a LEFT JOIN with `customers` as the left table.
The tables are joined using:
`customers.customer_id = orders.customer_id`
A LEFT JOIN ensures that all customers are included. If a customer has no order, the order columns will contain `NULL` values.
Result / Screenshot
INSERT SCREENSHOT 3 HERE – Query 3 Result
Suggested filename: `query3_customers_orders.png`
Business Interpretation
This query helps management identify both active customers and customers who have not yet placed an order. This can support customer follow-up and marketing activities.
---
5. CTE Query
Query 4 – Customers Above Average Spending
Requirement
Calculate each customer's total spend using `quantity × price` and return customers whose spending is above the average. A CTE must be used to calculate customer totals first.
SQL Query
```sql
WITH customer_totals AS (SELECT c.customer_id, c.customer_name, COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id LEFT JOIN order_items oi ON o.order_id = oi.order_id LEFT JOIN products p ON oi.product_id = p.product_id GROUP BY c.customer_id, c.customer_name) SELECT customer_id, customer_name, total_spend FROM customer_totals WHERE total_spend > (SELECT AVG(total_spend) FROM customer_totals) ORDER BY total_spend DESC;
```
Explanation
This query uses a Common Table Expression (CTE) called `customer_totals`.
The CTE first:
Connects customers to their orders.
Connects orders to their order items.
Connects order items to products.
Calculates each customer's total spending using `quantity × price`.
Groups the results by customer.
The main query then calculates the average customer spending and returns only customers whose total spending is greater than that average.
`COALESCE` is used so that a customer without purchases can have a total spending value of zero instead of `NULL`.
Result / Screenshot
INSERT SCREENSHOT 4 HERE – Query 4 Result
Suggested filename: `query4_cte_above_average.png`
Business Interpretation
This query identifies customers whose purchases contribute more than the average customer spending. Management can use this information to understand high-value customers and customer purchasing behavior.
---
6. Window-Function Queries
Query 5 – Rank Customers by Total Amount Spent
Requirement
Rank customers by total amount spent, with the highest spending customer first.
SQL Query
```sql
WITH customer_totals AS (SELECT c.customer_id, c.customer_name, COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id LEFT JOIN order_items oi ON o.order_id = oi.order_id LEFT JOIN products p ON oi.product_id = p.product_id GROUP BY c.customer_id, c.customer_name) SELECT customer_id, customer_name, total_spend, RANK() OVER (ORDER BY total_spend DESC) AS spending_rank FROM customer_totals ORDER BY spending_rank;
```
Explanation
This query first calculates each customer's total spending using a CTE.
The `RANK()` window function then ranks customers according to `total_spend` in descending order.
The highest spending customer receives rank 1.
If two customers have the same spending amount, they receive the same rank.
Result / Screenshot
INSERT SCREENSHOT 5 HERE – Query 5 Result
Suggested filename: `query5_customer_ranking.png`
Business Interpretation
The ranking helps management compare customer spending levels and understand the distribution of sales across customers.
---
Query 6 – Number Each Customer's Orders
Requirement
Number each customer's orders according to the order in which they were placed.
SQL Query
```sql
SELECT order_id, customer_id, order_date, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS customer_order_number FROM orders ORDER BY customer_id, order_date;
```
Explanation
This query uses the `ROW_NUMBER()` window function.
`PARTITION BY customer_id` separates the orders for each customer.
`ORDER BY order_date` places each customer's orders in chronological order.
The query therefore assigns:
1 to the customer's first order
2 to the customer's second order
3 to the customer's third order
and so on
Result / Screenshot
INSERT SCREENSHOT 6 HERE – Query 6 Result
Suggested filename: `query6_order_numbering.png`
Business Interpretation
Management can use this information to understand the order sequence and repeat purchasing behavior of individual customers.
---
Query 7 – Running Total of Revenue Over Time
Requirement
Show a running total of revenue over time, ordered by order date.
SQL Query
```sql
WITH daily_revenue AS (SELECT o.order_date, SUM(oi.quantity * p.price) AS daily_revenue FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id GROUP BY o.order_date) SELECT order_date, daily_revenue, SUM(daily_revenue) OVER (ORDER BY order_date) AS running_total_revenue FROM daily_revenue ORDER BY order_date;
```
Explanation
The `daily_revenue` CTE first calculates total revenue for each order date.
Revenue is calculated using:
`quantity × price`
The window function:
`SUM(daily_revenue) OVER (ORDER BY order_date)`
then adds each day's revenue to the revenue accumulated on previous dates.
This produces a running total of revenue in chronological order.
Result / Screenshot
INSERT SCREENSHOT 7 HERE – Query 7 Result
Suggested filename: `query7_running_revenue.png`
Business Interpretation
The running revenue total helps management monitor how sales accumulate over time and observe the overall revenue trend during the period covered by the database.
---
Query 8 – Days Between Current and Previous Orders
Requirement
For each customer with more than one order, show the number of days between the current order and the previous order.
SQL Query
```sql
WITH customer_orders AS (SELECT order_id, customer_id, order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date, COUNT(*) OVER (PARTITION BY customer_id) AS order_count FROM orders) SELECT order_id, customer_id, order_date, previous_order_date, order_date - previous_order_date AS days_between_orders FROM customer_orders WHERE order_count > 1 AND previous_order_date IS NOT NULL ORDER BY customer_id, order_date;
```
Explanation
This query uses the `LAG()` window function to retrieve the previous order date for each customer.
`PARTITION BY customer_id` makes the comparison happen separately for each customer.
`ORDER BY order_date` places each customer's orders chronologically.
The query then subtracts the previous order date from the current order date to calculate the number of days between orders.
The `COUNT(*) OVER (PARTITION BY customer_id)` condition ensures that only customers with more than one order are considered.
Result / Screenshot
INSERT SCREENSHOT 8 HERE – Query 8 Result
Suggested filename: `query8_days_between_orders.png`
Business Interpretation
This information helps management understand how frequently repeat customers place orders. It can support customer retention analysis and planning of customer engagement activities.
---
7. Overall Business Interpretation
The queries provide several useful views of Sunrise Supermarket's business data.
Customer and Order Analysis
The JOIN queries connect customers with their orders and show the products contained in those orders. This gives management a clearer view of customer purchasing activity.
Customer Spending Analysis
The CTE calculates total spending for each customer and identifies customers spending above the average. This provides information about customer spending behavior.
Customer Ranking
The ranking window function orders customers according to their total spending, allowing management to compare spending levels.
Order Frequency
The order-numbering and days-between-orders queries show the sequence and timing of customer purchases. This can help management understand repeat purchasing behavior.
Revenue Trend
The running-total query shows how revenue accumulates over the order dates. This can help management monitor sales performance over time.
---
8. Challenges and Resolutions
Challenge 1 – Using PostgreSQL Instead of Oracle
The assignment's example table definitions use Oracle data types such as `NUMBER` and `VARCHAR2`.
Resolution
PostgreSQL-compatible data types were used instead, including:
`INTEGER`
`VARCHAR`
`NUMERIC(10,2)`
`DATE`
The database relationships and required SQL analysis were preserved.
---
Challenge 2 – Combining Data from Related Tables
Several requirements needed information from multiple tables.
Resolution
INNER JOIN and LEFT JOIN were used with the appropriate primary-key and foreign-key relationships.
---
Challenge 3 – Calculating Customer Spending
Customer spending depends on both the product price and the quantity purchased.
Resolution
The calculation:
`quantity × price`
was used with `SUM()` to calculate the total spending for each customer.
---
Challenge 4 – Using CTEs and Window Functions
The CTE and window-function requirements required calculations across groups of records while still displaying individual records.
Resolution
A CTE was used to create intermediate customer and daily revenue calculations. Window functions including `RANK()`, `ROW_NUMBER()`, `LAG()`, and windowed `SUM()` were then used for the required analysis.
---
9. How to Run the Project
Step 1 – Install PostgreSQL
Install PostgreSQL and make sure the PostgreSQL server is running.
Step 2 – Create or Open the Database
The database used for this assignment is:
```text
sunrise_supermarket
```
Step 3 – Connect to the Database
Using PSQL, connect with:
```text
psql -U postgres -d sunrise_supermarket
```
Step 4 – Run the SQL File
The repository contains:
```text
assignment_1.sql
```
The file contains the database table definitions, sample data, and required SQL queries.
From Command Prompt, the SQL file can be executed using:
```text
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d sunrise_supermarket -f "assignment_1.sql"
```
If PostgreSQL is already configured in the system PATH, the shorter command can be used:
```text
psql -U postgres -d sunrise_supermarket -f assignment_1.sql
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
The screenshot filenames above are suggestions. They can be renamed, but the README screenshot references should be updated if the names are changed.
---
11. Screenshot Submission Checklist
Before submitting the repository, confirm that the following screenshots have been added:
[ ] Screenshot 1: Query 1 – Every order with customer details
[ ] Screenshot 2: Query 2 – Order items with product details
[ ] Screenshot 3: Query 3 – All customers and their orders
[ ] Screenshot 4: Query 4 – Customers above average spending
[ ] Screenshot 5: Query 5 – Customer spending ranking
[ ] Screenshot 6: Query 6 – Customer order numbering
[ ] Screenshot 7: Query 7 – Running total revenue
[ ] Screenshot 8: Query 8 – Days between customer orders
---
12. Final Submission Checklist
Before the deadline, verify that:
[ ] The repository name follows `assignment_1_your_name-your_id`.
[ ] `README.md` is included.
[ ] `assignment_1.sql` is included.
[ ] The README states that PostgreSQL was used.
[ ] The business scenario is explained.
[ ] All 3 JOIN queries are included with explanations.
[ ] The CTE query is included with an explanation.
[ ] All 4 window-function queries are included with explanations.
[ ] Results/screenshots are included for all 8 required queries.
[ ] Business interpretation is included.
[ ] Challenges and resolutions are included.
[ ] The repository has been pushed to GitHub before the deadline.
[ ] The GitHub repository URL is submitted to the instructor.
---
13. Conclusion
This assignment demonstrates the use of PostgreSQL to create and analyze a relational database for Sunrise Supermarket.
The required SQL techniques—INNER JOIN, LEFT JOIN, Common Table Expressions (CTEs), and window functions—were applied to answer business questions about customers, products, orders, spending, order frequency, and revenue trends.
The resulting database provides management with structured information that can be used to understand customer purchasing behavior and monitor sales over time.
