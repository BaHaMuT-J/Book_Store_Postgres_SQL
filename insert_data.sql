TRUNCATE TABLE inventory CASCADE;
TRUNCATE TABLE order_quantity CASCADE;
TRUNCATE TABLE book CASCADE;
TRUNCATE TABLE purchase_order CASCADE;
TRUNCATE TABLE customer CASCADE;
TRUNCATE TABLE schedule CASCADE;
TRUNCATE TABLE employee CASCADE;
TRUNCATE TABLE branch CASCADE;

-- Insert data into Branch Table
INSERT INTO Branch (branch_name, phone_number, open_hour, close_hour, plot, village, road, subdistrict, district, city, postal_code)
VALUES
('Downtown Branch', '123-456-7890', '08:00', '18:00', 'A10', 'Central Village', 'Main Road', 'North Subdistrict', 'Central District', 'City1', '10001'),
('Mall Branch', '234-567-8901', '09:00', '19:00', 'B20', 'East Village', 'Park Road', 'South Subdistrict', 'East District', 'City1', '10002');

-- Insert data into Employee Table
INSERT INTO Employee (firstname, lastname, birthday, role, work_hour, salary, branchID)
VALUES
('John', 'Doe', '1985-05-15', 'Sales Associate', 40, 3000.00, 1),
('Jane', 'Smith', '1990-07-22', 'Manager', 40, 4500.00, 2),
('Michael', 'Johnson', '1988-02-20', 'Cashier', 35, 2500.00, 1),
('Emily', 'Davis', '1992-11-10', 'Security', 40, 2800.00, 2);

-- Insert data into Schedule Table
INSERT INTO Schedule (employeeID, day, start_hour, end_hour)
VALUES
(1, 'Monday', '08:00', '16:00'),
(1, 'Tuesday', '08:00', '16:00'),
(2, 'Monday', '09:00', '17:00'),
(2, 'Wednesday', '09:00', '17:00'),
(3, 'Monday', '09:00', '15:00'),
(3, 'Tuesday', '09:00', '15:00'),
(4, 'Wednesday', '08:00', '16:00'),
(4, 'Friday', '08:00', '16:00');

-- Insert data into Customer Table
INSERT INTO Customer (firstname, lastname, email, phone_number)
VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '555-1234'),
('Bob', 'Williams', 'bob.williams@example.com', '555-5678'),
('Charlie', 'Brown', 'charlie.brown@example.com', '555-8765'),
('David', 'Wilson', 'david.wilson@example.com', '555-2345'),
('Eve', 'Martinez', 'eve.martinez@example.com', '555-6789');

-- Insert data into Book Table
INSERT INTO Book (Book_title, author, publisher, type, genre, date_release, price)
VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'Scribner', 'Hardcover', 'Fiction', '1925-04-10', 15.99),
('1984', 'George Orwell', 'Harcourt', 'Paperback', 'Dystopian', '1949-06-08', 12.99),
('To Kill a Mockingbird', 'Harper Lee', 'J.B. Lippincott & Co.', 'Hardcover', 'Fiction', '1960-07-11', 18.99),
('Pride and Prejudice', 'Jane Austen', 'T. Egerton', 'Hardcover', 'Romance', '1813-01-28', 20.00),
('Moby-Dick', 'Herman Melville', 'Harper & Brothers', 'Paperback', 'Adventure', '1851-10-18', 22.50);

-- Insert data into Purchase_order Table
INSERT INTO Purchase_order (customerID, branchID, date_purchase, total_price, payment_method)
VALUES
(1, 1, '2024-12-01', 45.97, 'Credit Card'),
(2, 2, '2024-12-02', 35.98, 'Cash'),
(3, 1, '2024-12-03', 20.00, 'Debit Card'),
(4, 2, '2024-12-04', 25.99, 'Credit Card'),
(5, 1, '2024-12-05', 42.00, 'Cash');

-- Insert data into Order_quantity Table
INSERT INTO Order_quantity (orderID, bookID, branchID, quantity)
VALUES
(1, 1, 1, 2),
(1, 2, 1, 1),
(2, 3, 2, 2),
(2, 4, 2, 1),
(3, 5, 1, 1),
(4, 1, 2, 1),
(4, 3, 2, 2),
(5, 2, 1, 3),
(5, 4, 1, 2);

-- Insert data into Inventory Table
INSERT INTO Inventory (branchID, bookID, quantity)
VALUES
(1, 1, 50),
(1, 2, 40),
(1, 3, 30),
(1, 4, 25),
(1, 5, 60),
(2, 1, 40),
(2, 2, 35),
(2, 3, 20),
(2, 4, 15),
(2, 5, 50);
