-- Creating and filling database
CREATE TABLE sqlday1.Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255),
    Email VARCHAR(255),
    JoinDate DATE
);

CREATE TABLE sqlday1.Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255),
    Price DECIMAL(10, 2),
    Category VARCHAR(255)
);

CREATE TABLE sqlday1.Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    Status VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE sqlday1.OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert into Customers
INSERT INTO sqlday1.Customers (Name, Email, JoinDate) VALUES
('John Doe', 'john.doe@example.com', '2022-01-10'),
('Jane Smith', 'jane.smith@example.com', '2022-02-15'),
('Emily Davis', 'emily.davis@example.com', '2022-03-20'),
('Michael Brown', 'michael.brown@example.com', '2022-04-25');

-- Insert into Products
INSERT INTO sqlday1.Products (Name, Price, Category) VALUES
('Laptop', 1200.00, 'Electronics'),
('Smartphone', 800.00, 'Electronics'),
('Desk Chair', 150.00, 'Furniture'),
('Table Lamp', 45.00, 'Home Decor'),
('Notebook', 5.00, 'Stationery'),
('Desk', 250.00, 'Furniture');

-- Insert into Orders
INSERT INTO sqlday1.Orders (CustomerID, OrderDate, Status) VALUES
(1, '2022-06-15', 'Completed'),
(2, '2022-07-20', 'Completed'),
(1, '2022-08-25', 'Completed'),
(3, '2022-09-30', 'Completed'),
(4, '2022-10-05', 'Completed'),
(2, '2022-11-10', 'Completed'),
(1, '2022-12-15', 'Completed'),
(3, '2023-01-19', 'Completed'),
(4, '2023-02-23', 'Completed'),
(2, '2023-03-29', 'Completed');

-- Insert into OrderDetails
INSERT INTO sqlday1.OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 2),
(4, 4, 3),
(5, 5, 10),
(2, 3, 1),
(3, 2, 1),
(4, 1, 1),
(5, 6, 1),
(6, 1, 1),
(7, 2, 2),
(8, 3, 1),
(9, 4, 2),
(10, 5, 5);

-- Task 1: calculate top 10% of order by value
WITH cte AS (
			SELECT o.OrderID, od.ProductID, od.Quantity, p.Name, p.Price
			FROM Orders AS o
			INNER JOIN OrderDetails AS od
			ON o.OrderID = od.OrderID
			INNER JOIN Products AS p
			ON od.ProductID = p.ProductID)
SELECT OrderID, Name, SUM(Quantity * Price) AS Total
FROM cte
GROUP BY OrderID, Name
ORDER BY Total DESC
LIMIT 1;

-- Task 2: Cumulative Revenue for 2022
WITH cte1 AS (
			SELECT o.OrderID, o.OrderDate, od.ProductID, od.Quantity, p.Name, p.Price
			FROM Orders AS o
			INNER JOIN OrderDetails AS od
			ON o.OrderID = od.OrderID
			INNER JOIN Products AS p
			ON od.ProductID = p.ProductID
			WHERE o.OrderDate < '2023-01-01')
SELECT SUM(Price * Quantity) AS Revenue2022
FROM cte1;

-- Task 3&4 :
-- Rank customers based on spending
WITH cte AS (
			SELECT c.Name, SUM(od.Quantity * p.Price) AS order_value
			FROM Customers AS c
			LEFT JOIN Orders AS o
			ON c.CustomerID = o.CustomerID
			LEFT JOIN OrderDetails AS od
			ON od.OrderID = o.OrderID
			LEFT JOIN Products AS p
			ON p.ProductID = od.ProductID
            GROUP BY c.Name)
SELECT *,
	RANK() OVER(w1) AS ranking
FROM cte
WINDOW w1 AS (ORDER BY order_value DESC);

-- Categorize customers into loyalty tiers based on their total spending
-- more than $500 spent - "Gold"
-- b/w $200 and $500 - "Silver," 
-- less than $200 - "Bronze." 
-- Show customer name, total spending, and their respective loyalty tier as a result

WITH cte AS (
			SELECT c.Name, SUM(od.Quantity * p.Price) AS spending
			FROM Customers AS c
			LEFT JOIN Orders AS o
			ON c.CustomerID = o.CustomerID
			LEFT JOIN OrderDetails AS od
			ON od.OrderID = o.OrderID
			LEFT JOIN Products AS p
			ON p.ProductID = od.ProductID
            GROUP BY c.Name)
SELECT Name, spending,
	CASE WHEN spending >= 500 THEN 'Gold'
		WHEN spending BETWEEN 250 AND 500 THEN 'Silver'
        ELSE 'Bronze' END AS loyalty_tier
FROM cte;

-- Task 5: Average number of days between orders for each customer

WITH cte2 AS
	(WITH cte AS(
				SELECT 
					o.OrderId,
					o.CustomerID,
                    c.Name,
					o.OrderDate,
					LEAD(o.OrderDate) OVER (w1) AS next_order
				FROM Orders AS o
                INNER JOIN Customers AS c
                ON o.CustomerID = c.CustomerID
                WINDOW w1 AS (PARTITION BY o.CustomerID))
	SELECT CustomerID, Name,
			DATEDIFF(next_order, OrderDate) AS difference
			FROM cte)
SELECT 
	CustomerID, Name, ROUND(AVG(difference),1) AS avg_order_days
FROM cte2
GROUP BY CustomerID, Name
ORDER BY Name;	