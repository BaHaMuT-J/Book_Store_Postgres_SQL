-- Drop tables in reverse order of dependencies to avoid foreign key conflicts
DROP TABLE IF EXISTS Restock CASCADE;
DROP TABLE IF EXISTS Inventory CASCADE;
DROP TABLE IF EXISTS Order_quantity_online CASCADE;
DROP TABLE IF EXISTS Wishlist CASCADE;
DROP TABLE IF EXISTS Cart CASCADE;
DROP TABLE IF EXISTS Book CASCADE;
DROP TABLE IF EXISTS Online_order CASCADE;
DROP TABLE IF EXISTS Address CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Attendance CASCADE;
DROP TABLE IF EXISTS Schedule CASCADE;
DROP TABLE IF EXISTS Employee CASCADE;

CREATE TABLE IF NOT EXISTS Employee (
    employeeID SERIAL PRIMARY KEY,                 -- Auto-incremented employee ID
    firstname VARCHAR(50) NOT NULL,                -- Employee's first name
    lastname VARCHAR(50) NOT NULL,                 -- Employee's last name
    birthday DATE NOT NULL,                        -- Employee's birthdate
    role VARCHAR(50) NOT NULL,                     -- Role of the employee (e.g., cashier, manager)
    work_hour INT NOT NULL,                        -- Number of work hours per week
    salary DECIMAL(10, 2) NOT NULL                -- Employee's salary (with two decimal points)
);

CREATE TABLE IF NOT EXISTS Schedule (
    employeeID INT NOT NULL,                       -- References the employee assigned to the schedule
    day VARCHAR(9) NOT NULL,                       -- Day of the week (e.g., 'Monday', 'Tuesday', etc.)
    start_hour TIME NOT NULL,                      -- Shift start time
    end_hour TIME NOT NULL,                        -- Shift end time
    PRIMARY KEY (employeeID, day),
    CONSTRAINT fk_employeeID FOREIGN KEY (employeeID)
        REFERENCES Employee(employeeID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Attendance (
    employeeID INT NOT NULL,                       -- References the employee attendance
    attendance_date DATE NOT NULL,                 -- Date of attendance
    start_time TIME NOT NULL,                      -- When employee arrives
    end_time TIME NOT NULL,                        -- When employee leaves
    PRIMARY KEY (employeeID, attendance_date),
    CONSTRAINT fk_employee FOREIGN KEY (employeeID)
        REFERENCES Employee(employeeID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Customer (
    customerID SERIAL PRIMARY KEY,                 -- Auto-incremented customer ID
    firstname VARCHAR(50) NOT NULL,                -- Customer's first name
    lastname VARCHAR(50) NOT NULL,                 -- Customer's last name
    birthday DATE NOT NULL,                        -- Customer's birthdate
    phone_number VARCHAR(15) NOT NULL,             -- Customer's phone number (optional)
    email VARCHAR(100) NOT NULL,                   -- Customer's email address
    password VARCHAR(100) NOT NULL,                -- Customer's password
    point INT NOT NULL                             -- Customer's points
);

CREATE TABLE IF NOT EXISTS Address (
    addressID SERIAL PRIMARY KEY,                   -- Auto-incremented address ID
    customerID INT NOT NULL,                        -- Customer ID of address
    plot VARCHAR(10) NOT NULL,                      -- Plot information (e.g., building number)
    village VARCHAR(50),                            -- Village or locality
    road VARCHAR(50) NOT NULL,                      -- Road or street name
    subdistrict VARCHAR(50) NOT NULL,               -- Subdistrict name
    district VARCHAR(50) NOT NULL,                  -- District name
    city VARCHAR(50) NOT NULL,                      -- City name
    postal_code VARCHAR(10) NOT NULL,               -- Postal code for the branch location
    CONSTRAINT fk_customer FOREIGN KEY (customerID)
        REFERENCES Customer(customerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Online_order (
    orderID SERIAL PRIMARY KEY,                    -- Auto-incremented order ID
    customerID INT NOT NULL,                       -- References the customer placing the order
    date_purchase DATE NOT NULL,                   -- Date when the order was made
    total_price DECIMAL(10, 2) NOT NULL,           -- Total price of the order
    payment_method VARCHAR(50) NOT NULL,           -- Payment method used for the order
    status VARCHAR(50) NOT NULL,                   -- Status of order (In progress, Complete, Error)
    CONSTRAINT fk_customer FOREIGN KEY (customerID)
        REFERENCES Customer(customerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Book (
    bookID SERIAL PRIMARY KEY,                     -- Auto-incremented book ID
    book_title VARCHAR(200) NOT NULL,              -- Title of the book
    author VARCHAR(100) NOT NULL,                  -- Author of the book
    publisher VARCHAR(100) NOT NULL,               -- Publisher of the book
    category VARCHAR(50),                              -- Type of the book (e.g., paperback, hardcover)
    genre VARCHAR(50),                             -- Genre of the book (e.g., fiction, non-fiction)
    date_release DATE NOT NULL,                    -- Release date of the book
    price DECIMAL(10, 2) NOT NULL                  -- Price of the book
);

CREATE TABLE IF NOT EXISTS Cart (
    customerID INT NOT NULL,                          -- ID of the order
    bookID INT NOT NULL,                              -- ID of the book being ordered
    quantity INT NOT NULL,                            -- Quantity of the book in the order
    PRIMARY KEY (customerID, bookID),
    CONSTRAINT fk_customer FOREIGN KEY (customerID)
        REFERENCES Customer(customerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_book FOREIGN KEY (bookID)
        REFERENCES Book(bookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Wishlist (
    customerID INT NOT NULL,                          -- ID of the order
    bookID INT NOT NULL,                              -- ID of the book in the list
    PRIMARY KEY (customerID, bookID),
    CONSTRAINT fk_customer FOREIGN KEY (customerID)
        REFERENCES Customer(customerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_book FOREIGN KEY (bookID)
        REFERENCES Book(bookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Order_quantity_online (
    orderID INT NOT NULL,                          -- ID of the order
    bookID INT NOT NULL,                           -- ID of the book being ordered
    quantity INT NOT NULL,                         -- Quantity of the book in the order
    PRIMARY KEY (orderID, bookID),                 -- Composite primary key (orderID, bookID)
    CONSTRAINT fk_order FOREIGN KEY (orderID)
        REFERENCES Online_order(orderID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_book FOREIGN KEY (bookID)
        REFERENCES Book(bookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Inventory (
    bookID INT NOT NULL PRIMARY KEY,               -- ID of the book in the inventory
    quantity INT NOT NULL,                         -- Quantity of the book available in inventory
    CONSTRAINT fk_inventory_book FOREIGN KEY (bookID)
        REFERENCES Book(bookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Restock (
    bookID INT NOT NULL PRIMARY KEY,                -- ID of the book that need to be restocked
    quantity INT NOT NULL,                          -- Remaining quantity
    notification_date DATE NOT NULL,                -- Date of notification
    CONSTRAINT fk_inventory_book FOREIGN KEY (bookID)
        REFERENCES Book(bookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
