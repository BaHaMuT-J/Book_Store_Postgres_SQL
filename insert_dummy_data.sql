-- Truncate table before add dummy data
TRUNCATE TABLE shipping RESTART IDENTITY CASCADE;
TRUNCATE TABLE restock RESTART IDENTITY CASCADE;
TRUNCATE TABLE inventory RESTART IDENTITY CASCADE;
TRUNCATE TABLE order_quantity_online RESTART IDENTITY CASCADE;
TRUNCATE TABLE wishlist RESTART IDENTITY CASCADE;
TRUNCATE TABLE cart RESTART IDENTITY CASCADE;
TRUNCATE TABLE book RESTART IDENTITY CASCADE;
TRUNCATE TABLE online_order RESTART IDENTITY CASCADE;
TRUNCATE TABLE address RESTART IDENTITY CASCADE;
TRUNCATE TABLE customer RESTART IDENTITY CASCADE;

-- Insert dummy data

INSERT INTO Customer (firstname, lastname, birthday, phone_number, email, password, point)
VALUES
('Nithya', 'Tharinee', '2000-01-01', '0891234567', 'nithya@gmail.com', 'securepass1', 20),
('Pranee', 'Wirachai', '1998-12-12', '0869876543', 'pranee@gmail.com', 'securepass2', 50);

INSERT INTO Address (customerID, plot, village, road, subdistrict, district, city, postal_code)
VALUES
(1, '1/23', 'Ladprao', 'Ratchadaphisek', 'Chatuchak', 'Chatuchak', 'Bangkok', '10900'),
(2, '52', null, 'Ban Pong', 'Sathorn', 'Sathorn', 'Bangkok', '10120');

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

INSERT INTO Restock (bookID, quantity, notification_date)
VALUES
(10, 3, '2024-12-01'),
(12, 8, '2024-12-02');

INSERT INTO Cart (customerID, bookID, quantity)
VALUES
(1, 11, 2);

INSERT INTO Wishlist (customerID, bookID)
VALUES
(1, 2);

INSERT INTO Online_order (customerID, date_purchase, total_price, payment_method, addressid, status)
VALUES
(1,  '2024-11-01', 25.98, 'Credit card', 1, 'Complete'),
(1,  '2024-11-02', 18.57, 'PayPal', 1,'Complete'),
(1,  '2024-11-03', 15.58, 'QR code', 1,'Complete');

INSERT INTO Order_quantity_online (orderID, bookID, quantity)
VALUES
(1, 1, 2),
(2, 13, 1),
(3, 14, 1);
