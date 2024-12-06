-- Truncate table before add dummy data
TRUNCATE TABLE restock RESTART IDENTITY CASCADE;
TRUNCATE TABLE inventory RESTART IDENTITY CASCADE;
TRUNCATE TABLE order_quantity_online RESTART IDENTITY CASCADE;
TRUNCATE TABLE wishlist RESTART IDENTITY CASCADE;
TRUNCATE TABLE cart RESTART IDENTITY CASCADE;
TRUNCATE TABLE book RESTART IDENTITY CASCADE;
TRUNCATE TABLE online_order RESTART IDENTITY CASCADE;
TRUNCATE TABLE address RESTART IDENTITY CASCADE;
TRUNCATE TABLE customer RESTART IDENTITY CASCADE;
TRUNCATE TABLE attendance RESTART IDENTITY CASCADE;
TRUNCATE TABLE schedule RESTART IDENTITY CASCADE;
TRUNCATE TABLE employee RESTART IDENTITY CASCADE;

-- Insert dummy data into Employee
INSERT INTO Employee (firstname, lastname, birthday, role, work_hour, salary, branchID)
VALUES
('Somchai', 'Prasert', '1990-02-15', 'Manager', 40, 30000.00, 1),
('Suda', 'Chaiyawat', '1995-05-12', 'Cashier', 30, 18000.00, 1),
('Manop', 'Wichai', '1988-07-20', 'Stock Keeper', 35, 20000.00, 2);

-- Insert dummy data into Schedule
INSERT INTO Schedule (employeeID, day, start_hour, end_hour)
VALUES
(1, 'Monday', '09:00:00', '17:00:00'),
(2, 'Tuesday', '12:00:00', '20:00:00'),
(3, 'Wednesday', '10:00:00', '18:00:00');

-- Insert dummy data into Attendance
INSERT INTO Attendance (employeeID, attendance_date, start_time, end_time)
VALUES
(1, '2024-12-01', '09:00:00', '17:00:00'),
(2, '2024-12-01', '12:00:00', '20:00:00'),
(3, '2024-12-01', '10:00:00', '18:00:00');

-- Insert dummy data into Customer
INSERT INTO Customer (firstname, lastname, birthday, phone_number, email, password, point)
VALUES
('Nithya', 'Tharinee', '2000-01-01', '0891234567', 'nithya@gmail.com', 'securepass1', 20),
('Pranee', 'Wirachai', '1998-12-12', '0869876543', 'pranee@gmail.com', 'securepass2', 50);

-- Insert dummy data into Address
INSERT INTO Address (customerID, plot, village, road, subdistrict, district, city, postal_code)
VALUES
(1, '1/23', 'Ladprao', 'Ratchadaphisek', 'Chatuchak', 'Chatuchak', 'Bangkok', '10900'),
(2, '52', null, 'Ban Pong', 'Sathorn', 'Sathorn', 'Bangkok', '10120');

-- Insert dummy data into Book
INSERT INTO Book (book_title, author, publisher, category, genre, date_release, price)
VALUES
('Dog Man: The Graphic Novel', 'Dav Pilkey', 'Graphix', 'Hardcover', 'Children''s Fiction', '2024-12-06', 10.49),
('Onyx Storm (Deluxe Limited Edition)', 'Tricia Levenseller', 'Entangled: Teen', 'Hardcover', 'Fantasy', '2024-12-05', 19.78),
('The Wind of Truth: Book 4 of The Stormlight Archive', 'Brandon Sanderson', 'Tor Books', 'Hardcover', 'Fantasy', '2024-12-03', 26.47),
('Cher: A Memoir (Part One)', 'Cher', 'HarperOne', 'Hardcover', 'Biography', '2024-11-19', 20.98),
('There''s Treasure Inside', 'Jon Collins', 'Black Gold', 'Paperback', 'Motivational', '2024-11-19', 47.44),
('We Who Wrestle with God', 'Richard Rohr', 'Random House', 'Hardcover', 'Religion', '2024-11-12', 23.76),
('What Is a Database?', 'John Coder', 'TechPress', 'Paperback', 'Education', '2024-11-03', 27.99),
('Python Numpy Structures Made Database Easy', 'A. Data', 'CodeWorld', 'Paperback', 'Education', '2024-11-02', 4.99),
('Vector Databases for AI', 'M. AI Guru', 'AI Publishing', 'Hardcover', 'Education', '2024-11-01', 24.00),
('Modern Database Management', 'Jeffrey Hoffer', 'Pearson', 'Hardcover', 'Education', '2002-01-15', 2867.13),
('A Practical Guide to Relational Database Design', 'Mike Hernandez', 'Database Design Publishing', 'Paperback', 'Education', '2004-02-28', 410.51),
('Database Management Systems', 'Raghu Ramakrishnan', 'McGraw-Hill', 'Hardcover', 'Education', '2002-08-12', 188.99),
('From Crook to Cook: Platinum Recipes from Tha Boss Dogg''s Kitchen', 'Snoop Dogg', 'Chronicle Books', 'Hardcover', 'Food', '2018-10-23', 13.57),
('How To Draw Everything: 300 Drawings of Cute Stuff, Animals, Food, Gifts, and other Amazing Things | Book For Kids', 'Emma Greene', 'Independently published', 'Paperback', 'Art', '2018-11-18', 10.58);


-- Insert dummy data into Inventory
INSERT INTO Inventory (bookID, quantity)
VALUES
(1,  50),     -- Dog Man: The Graphic Novel
(2,  30),     -- Onyx Storm (Deluxe Limited Edition)
(3,  20),     -- The Wind of Truth: Book 4 of The Stormlight Archive
(4,  100),    -- Cher: A Memoir
(5, 60),      -- There's Treasure Inside
(6,  40),     -- We Who Wrestle with God
(7,  35),     -- What Is a Database?
(8,  25),     -- Python Numpy Structures Made Easy
(9,  15),     -- Vector Databases for AI
(10, 3),      -- Modern Database Management
(11,  11),    -- A Practical Guide to Relational Database Design
(12,  8),     -- Database Management Systems
(13, 20),     -- From Crook to Cook: Platinum Recipes from Tha Boss Dogg
(14, 30);     -- How To Draw Everything: 300 Drawings of Cute Stuff

-- Insert dummy data into Restock
INSERT INTO Restock (bookID, quantity, notification_date)
VALUES
(10, 3, '2023-12-01'),
(12, 8, '2023-12-02');

-- Insert dummy data into Cart
INSERT INTO Cart (customerID, bookID, quantity)
VALUES
(1, 11, 2);  -- Customer 1 adds 2 copies of "The Great Adventure"

-- Insert dummy data into Wishlist
INSERT INTO Wishlist (customerID, bookID)
VALUES
(1, 2);  -- Customer 1 adds "Mastering SQL" to wishlist

-- Insert dummy data into Purchase_order
INSERT INTO Online_order (customerID, date_purchase, total_price, payment_method, status)
VALUES
(1,  '2024-11-01', 25.98, 'Credit card', 'Complete'), -- For multiple books
(1,  '2024-11-02', 18.57, 'PayPal', 'Complete'),
(1,  '2024-11-03', 15.58, 'QR code', 'Complete');

-- Insert dummy data into Order_quantity
INSERT INTO order_quantity_online (orderID, bookID, quantity)
VALUES
(1, 1, 2),   -- Order 1: 2 copies of "The Great Adventure" from Branch 1
(2, 13, 1),  -- Order 2: 1 copy of "From Crook to Cook" from Branch 2
(3, 14, 1);  -- Order 3: 1 copy of "How To Draw Everything" from Branch 2
