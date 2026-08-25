create database novamart;
use novamart;
show tables;
SELECT COUNT(*) AS Customer_Count
FROM customers;
SELECT *
FROM customers
LIMIT 5;
DESCRIBE customers;
SELECT 'customers' AS Table_Name, COUNT(*) AS Row_Count
FROM customers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items;

describe customers;
describe sellers;
describe orders;
describe order_items;
describe products;

SELECT
    Order_Date
FROM orders
LIMIT 10;

SELECT
    Signup_Date
FROM customers
LIMIT 10;

ALTER TABLE customers
MODIFY Customer_ID VARCHAR(10) NOT NULL,
MODIFY Customer_Name VARCHAR(100) NOT NULL,
MODIFY Gender VARCHAR(20) NOT NULL,
MODIFY Age INT NOT NULL,
MODIFY Customer_Segment VARCHAR(50) NOT NULL,
MODIFY City VARCHAR(100) NOT NULL,
MODIFY State VARCHAR(100) NOT NULL,
MODIFY Region VARCHAR(30) NOT NULL,
MODIFY Signup_Date DATE NOT NULL;

ALTER TABLE customers
ADD PRIMARY KEY (Customer_ID);

describe customers;

ALTER TABLE products
MODIFY Product_ID VARCHAR(10) NOT NULL,
MODIFY Product_Name VARCHAR(100) NOT NULL,
MODIFY Category VARCHAR(100) NOT NULL,
MODIFY Subcategory VARCHAR(100) NOT NULL,
MODIFY Brand VARCHAR(100) NOT NULL,
MODIFY Unit_Cost DECIMAL(12,2) NOT NULL,
MODIFY Unit_Price DECIMAL(12,2) NOT NULL;

alter table products add primary key (Product_ID);

describe products;

ALTER TABLE sellers
MODIFY Seller_ID VARCHAR(10) NOT NULL,
MODIFY Seller_Name VARCHAR(100) NOT NULL,
MODIFY Seller_Type VARCHAR(50) NOT NULL,
MODIFY Seller_Region VARCHAR(50) NOT NULL;

alter table sellers add primary key (Seller_ID);

describe sellers;

ALTER TABLE orders
MODIFY Order_ID VARCHAR(10) NOT NULL,
MODIFY Order_Date DATE NOT NULL,
MODIFY Customer_ID VARCHAR(10) NOT NULL,
MODIFY Seller_ID VARCHAR(10) NOT NULL,
MODIFY Order_Status VARCHAR(20) NOT NULL,
MODIFY Payment_Method VARCHAR(30) NOT NULL,
MODIFY Shipping_Mode VARCHAR(30) NOT NULL,
MODIFY `Year_Month` CHAR(7) NOT NULL;

alter table orders add primary key (Order_ID);

describe orders;

ALTER TABLE order_items
MODIFY Order_ID VARCHAR(10) NOT NULL,
MODIFY Product_ID VARCHAR(10) NOT NULL,
MODIFY Seller_ID VARCHAR(10) NOT NULL,
MODIFY Quantity INT NOT NULL,
MODIFY Discount DECIMAL(6,4) NOT NULL,
MODIFY Sales DECIMAL(14,2) NOT NULL,
MODIFY Cost DECIMAL(14,2) NOT NULL,
MODIFY Profit DECIMAL(14,2) NOT NULL,
MODIFY Order_Status VARCHAR(20) NOT NULL;

describe order_items;

DESCRIBE customers;
DESCRIBE products;
DESCRIBE sellers;
DESCRIBE orders;
DESCRIBE order_items;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Order_ID) AS Unique_Orders,
    COUNT(DISTINCT Product_ID) AS Unique_Products,
    COUNT(DISTINCT Seller_ID) AS Unique_Sellers
FROM order_items;

SELECT
    Order_ID,
    Product_ID,
    Seller_ID,
    COUNT(*) AS Row_Count
FROM order_items
GROUP BY
    Order_ID,
    Product_ID,
    Seller_ID
HAVING COUNT(*) > 1;

ALTER TABLE order_items
ADD PRIMARY KEY (Order_ID, Product_ID, Seller_ID);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (Customer_ID)
REFERENCES customers(Customer_ID);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_seller
FOREIGN KEY (Seller_ID)
REFERENCES sellers(Seller_ID);

ALTER TABLE order_items
ADD CONSTRAINT fk_items_order
FOREIGN KEY (Order_ID)
REFERENCES orders(Order_ID);

ALTER TABLE order_items
ADD CONSTRAINT fk_items_product
FOREIGN KEY (Product_ID)
REFERENCES products(Product_ID);

ALTER TABLE order_items
ADD CONSTRAINT fk_items_seller
FOREIGN KEY (Seller_ID)
REFERENCES sellers(Seller_ID);

SHOW CREATE TABLE customers;
show create table orders;
show create table order_items;

SELECT
    Region,
    COUNT(*) AS Customer_Count
FROM customers
GROUP BY Region
ORDER BY Customer_Count DESC;

SELECT
    Region,
    COUNT(*) AS Customer_Count,
    ROUND(AVG(Age), 2) AS Average_Age
FROM customers
GROUP BY Region
ORDER BY Average_Age DESC;

SELECT
    c.Region,
    ROUND(SUM(oi.Sales), 2) AS Total_Sales,
    ROUND(SUM(oi.Profit), 2) AS Total_Profit,
    SUM(oi.Quantity) AS Total_Quantity
FROM customers c
JOIN orders o
    ON c.Customer_ID = o.Customer_ID
JOIN order_items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY c.Region
ORDER BY Total_Sales DESC;

SELECT
    p.Category,
    ROUND(SUM(oi.Sales), 2) AS Total_Sales,
    ROUND(SUM(oi.Profit), 2) AS Total_Profit,
    SUM(oi.Quantity) AS Total_Quantity,
    ROUND(
        SUM(oi.Profit) / SUM(oi.Sales) * 100,
        2
    ) AS Profit_Margin
FROM products p
JOIN order_items oi
    ON p.Product_ID = oi.Product_ID
GROUP BY p.Category
ORDER BY Total_Sales DESC;

SELECT
    s.Seller_ID,
    s.Seller_Name,
    ROUND(SUM(oi.Sales), 2) AS Total_Sales,
    ROUND(SUM(oi.Profit), 2) AS Total_Profit,
    SUM(oi.Quantity) AS Total_Quantity
FROM sellers s
JOIN order_items oi
    ON s.Seller_ID = oi.Seller_ID
GROUP BY
    s.Seller_ID,
    s.Seller_Name
ORDER BY Total_Profit DESC
LIMIT 10;

SELECT
    o.Order_ID,
    ROUND(SUM(oi.Sales), 2) AS Order_Value,
    CASE
        WHEN SUM(oi.Sales) >= 50000 THEN 'High Value'
        WHEN SUM(oi.Sales) >= 25000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Order_Category
FROM orders o
JOIN order_items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY o.Order_ID
ORDER BY Order_Value DESC;

SELECT
    s.Seller_ID,
    s.Seller_Name,
    ROUND(SUM(oi.Sales), 2) AS Total_Sales,
    ROUND(SUM(oi.Profit), 2) AS Total_Profit
FROM sellers s
JOIN order_items oi
    ON s.Seller_ID = oi.Seller_ID
GROUP BY
    s.Seller_ID,
    s.Seller_Name
HAVING SUM(oi.Sales) > 65000000
ORDER BY Total_Sales DESC;

WITH seller_performance AS (
    SELECT
        Seller_ID,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit
    FROM order_items
    GROUP BY Seller_ID
)

SELECT
    Seller_ID,
    ROUND(Total_Sales, 2) AS Total_Sales,
    ROUND(Total_Profit, 2) AS Total_Profit,
    ROUND(Total_Profit / Total_Sales * 100, 2) AS Profit_Margin
FROM seller_performance
ORDER BY Profit_Margin DESC;

WITH seller_profit AS (
    SELECT
        Seller_ID,
        SUM(Profit) AS Total_Profit
    FROM order_items
    GROUP BY Seller_ID
)

SELECT
    Seller_ID,
    ROUND(Total_Profit, 2) AS Total_Profit,
    RANK() OVER (
        ORDER BY Total_Profit DESC
    ) AS Profit_Rank
FROM seller_profit
ORDER BY Profit_Rank;

WITH product_profit AS (
    SELECT
        p.Product_ID,
        p.Product_Name,
        p.Category,
        SUM(oi.Profit) AS Total_Profit
    FROM products p
    JOIN order_items oi
        ON p.Product_ID = oi.Product_ID
    GROUP BY
        p.Product_ID,
        p.Product_Name,
        p.Category
),

ranked_products AS (
    SELECT
        Product_ID,
        Product_Name,
        Category,
        Total_Profit,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY Total_Profit DESC
        ) AS Profit_Rank
    FROM product_profit
)

SELECT
    Product_ID,
    Product_Name,
    Category,
    ROUND(Total_Profit, 2) AS Total_Profit,
    Profit_Rank
FROM ranked_products
WHERE Profit_Rank <= 3
ORDER BY
    Category,
    Profit_Rank;
    
    SELECT
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    ROUND(SUM(oi.Sales), 2) AS Total_Sales,
    ROUND(SUM(oi.Profit), 2) AS Total_Profit,
    ROUND(
        SUM(oi.Profit) / SUM(oi.Sales) * 100,
        2
    ) AS Profit_Margin
FROM customers c
JOIN orders o
    ON c.Customer_ID = o.Customer_ID
JOIN order_items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment
ORDER BY Total_Profit DESC
LIMIT 10;

SELECT
    DATE_FORMAT(o.Order_Date, '%Y-%m') AS 'Year_Month',
    ROUND(SUM(oi.Sales), 2) AS Total_Sales,
    ROUND(SUM(oi.Profit), 2) AS Total_Profit,
    SUM(oi.Quantity) AS Total_Quantity,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    ROUND(
        SUM(oi.Profit) / SUM(oi.Sales) * 100,
        2
    ) AS Profit_Margin
FROM orders o
JOIN order_items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY
    DATE_FORMAT(o.Order_Date, '%Y-%m')
ORDER BY 'Year_Month';

SELECT
    o.Order_Status,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    ROUND(SUM(oi.Sales), 2) AS Total_Sales,
    ROUND(SUM(oi.Profit), 2) AS Total_Profit,
    ROUND(
        SUM(oi.Profit) / SUM(oi.Sales) * 100,
        2
    ) AS Profit_Margin
FROM orders o
JOIN order_items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY o.Order_Status
ORDER BY Total_Sales DESC;

SELECT
    c.Customer_ID,
    c.Customer_Name
FROM customers c
LEFT JOIN orders o
    ON c.Customer_ID = o.Customer_ID
WHERE o.Order_ID IS NULL;