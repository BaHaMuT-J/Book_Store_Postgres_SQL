-- Function related to Customer's account

-- Register new customer
CREATE OR REPLACE FUNCTION register(
    p_firstname VARCHAR(50),          -- Customer's first name
    p_lastname VARCHAR(50),           -- Customer's last name
    p_birthday DATE,                  -- Customer's birthdate
    p_phone_number VARCHAR(15),       -- Customer's phone number
    p_email VARCHAR(100),             -- Customer's email
    p_password VARCHAR(100)           -- Customer's password
)
RETURNS BOOLEAN AS
$$
DECLARE
    email_exists BOOLEAN;
BEGIN
    -- Check if the email already exists in the Customer table
    SELECT EXISTS (
        SELECT 1
        FROM Customer
        WHERE email = p_email
    ) INTO email_exists;

    -- If the email already exists, raise an exception
    IF email_exists THEN
        RAISE EXCEPTION 'Email % is already registered', p_email;
    END IF;

    -- Password validation: must be at least 8 characters and contain at least one uppercase, one lowercase, and one digit
    IF length(p_password) < 8 OR p_password !~ '[A-Z]' OR p_password !~ '[a-z]' OR p_password !~ '\d' THEN
        RAISE EXCEPTION 'Password must contain at least 8 characters with at least 1 of uppercase letter, lowercase letter, and digit';
    END IF;

    -- Insert a new customer into the Customer table
    INSERT INTO Customer (firstname, lastname, birthday, phone_number, email, password, point)
    VALUES (p_firstname, p_lastname, p_birthday,
            p_phone_number, p_email, p_password, 0);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- SELECT register('Siranut', 'Jongdee',
--                 '2004-01-30', '0861234567',
--                 'siranut.jon@student.mahidol.edu',
--                 'Mahidol648');

-- ****************************************************************************************************************** --

-- Log in
CREATE OR REPLACE FUNCTION login(
    p_email VARCHAR(100),              -- Customer's email
    p_password VARCHAR(100)            -- Customer's password
)
RETURNS BOOLEAN AS
$$
DECLARE
    customer_exists BOOLEAN;
BEGIN
    -- Check if a customer with the provided email and password exists
    SELECT EXISTS (
        SELECT 1
        FROM customer AS c
        WHERE c.email = p_email AND c.password = p_password
    ) INTO customer_exists;

    -- Return whether the customer exists or not
    RETURN customer_exists;
END;
$$ LANGUAGE plpgsql;

-- SELECT login('siranut.jon@student.mahidol.edu',
--              'Mahidol648');

-- ****************************************************************************************************************** --

-- Edit personal information of customer
CREATE OR REPLACE FUNCTION edit_info(
    customer_id INT,                           -- Customer ID to identify the user
    new_firstname VARCHAR(50) DEFAULT NULL,    -- New first name
    new_lastname VARCHAR(50) DEFAULT NULL,     -- New last name
    new_phone_number VARCHAR(15) DEFAULT NULL, -- New phone number
    new_email VARCHAR(100) DEFAULT NULL        -- New email
)
RETURNS VOID AS
$$
DECLARE
    email_exists BOOLEAN;
BEGIN
    -- Check if the new email already exists in the Customer table (except for the current customer)
    IF new_email IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1
            FROM Customer
            WHERE email = new_email AND customerID != customer_id
        ) INTO email_exists;

        -- If the email already exists, raise an exception
        IF email_exists THEN
            RAISE EXCEPTION 'Email % is already registered', new_email;
        END IF;
    END IF;

    -- Update the customer's information
    UPDATE Customer
    SET
        firstname = COALESCE(new_firstname, firstname),          -- Update first name if provided
        lastname = COALESCE(new_lastname, lastname),             -- Update last name if provided
        phone_number = COALESCE(new_phone_number, phone_number), -- Update phone number if provided
        email = COALESCE(new_email, email)                       -- Update email if provided
    WHERE customerID = customer_id;
END;
$$ LANGUAGE plpgsql;

-- SELECT edit_info(1, 'Hello',
--                  'World',
--                  '0123456789',
--                  'helloWorld@gmail.com');

-- ****************************************************************************************************************** --

-- View customer's order history
CREATE OR REPLACE FUNCTION view_order_history(customer_id INT)
RETURNS TABLE(
    order_id INT,
    date_purchase DATE,
    total_price DECIMAL(10, 2),
    status VARCHAR(50)
) AS
$$
BEGIN
    RETURN QUERY
    SELECT
        o.orderID,
        o.date_purchase,
        o.total_price,
        o.status
    FROM Online_order o
    WHERE o.customerID = customer_id
    ORDER BY o.date_purchase DESC; -- Most recent orders first
END;
$$ LANGUAGE plpgsql;

-- SELECT (view_order_history(3)).*;

-- ****************************************************************************************************************** --

-- Add books to customer's wishlist
CREATE OR REPLACE FUNCTION add_to_wishlist(
    customer_id INT,
    book_id INT)
RETURNS VOID AS
$$
BEGIN
    INSERT INTO Wishlist (customerID, bookID)
    VALUES (customer_id, book_id);
END;
$$ LANGUAGE plpgsql;

-- Remove books from customer's wishlist
CREATE OR REPLACE FUNCTION remove_from_wishlist(customer_id INT, book_id INT)
RETURNS VOID AS
$$
BEGIN
    DELETE FROM Wishlist
    WHERE customerID = customer_id AND bookID = book_id;
END;
$$ LANGUAGE plpgsql;

-- View customer's own wishlist
CREATE OR REPLACE FUNCTION view_wishlist(customer_id INT)
RETURNS TABLE(
    book_id INT,
    book_title VARCHAR(200),
    price DECIMAL(10, 2)
) AS
$$
BEGIN
    RETURN QUERY
    SELECT
        b.bookID,
        b.book_title,
        b.price
    FROM Wishlist w
    JOIN Book b ON w.bookID = b.bookID
    WHERE w.customerID = customer_id;
END;
$$ LANGUAGE plpgsql;

-- SELECT add_to_wishlist(3, 1);
-- SELECT add_to_wishlist(3, 2);

-- SELECT remove_from_wishlist(3, 2);

-- SELECT (view_wishlist(3)).*;

-- ****************************************************************************************************************** --

-- Add address, don't have to necessarily be new (customer can have multiple same address if they want)
CREATE OR REPLACE FUNCTION add_to_address(
    p_customerID INT,                       -- Customer ID
    p_plot VARCHAR(10),                     -- Plot information
    p_village VARCHAR(50),                  -- Village or locality
    p_road VARCHAR(50),                     -- Road or street name
    p_subdistrict VARCHAR(50),              -- Subdistrict name
    p_district VARCHAR(50),                 -- District name
    p_city VARCHAR(50),                     -- City name
    p_postal_code VARCHAR(10)               -- Postal code
)
RETURNS VOID AS
$$
BEGIN
    INSERT INTO Address (
        customerID, plot, village, road, subdistrict, district, city, postal_code
    )
    VALUES (
        p_customerID, p_plot, p_village, p_road,p_subdistrict, p_district, p_city, p_postal_code
    );
END;
$$ LANGUAGE plpgsql;

-- Remove address
CREATE OR REPLACE FUNCTION remove_address(
    p_customerID INT,   -- Customer ID
    p_addressID INT     -- Address ID to remove
)
RETURNS VOID AS
$$
BEGIN
    DELETE FROM Address
    WHERE customerID = p_customerID AND addressID = p_addressID;
END;
$$ LANGUAGE plpgsql;

-- View customer's own address
CREATE OR REPLACE FUNCTION view_address(
    p_customerID INT  -- Customer ID
)
RETURNS TABLE(
    plot VARCHAR(10),
    village VARCHAR(50),
    road VARCHAR(50),
    subdistrict VARCHAR(50),
    district VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(10)
) AS
$$
BEGIN
    RETURN QUERY
    SELECT
        a.plot, a.village, a.road, a.subdistrict, a.district, a.city, a.postal_code
    FROM Address AS a
    WHERE a.customerID = p_customerID;
END;
$$ LANGUAGE plpgsql;

-- SELECT add_to_address(3, '999',
--                       NULL, 'Phuttamonthon 4',
--                       'Phuttamonthon', 'Salaya',
--                       'Nakhon Pathom', '73170');

-- SELECT remove_address(3, 3);

-- SELECT (view_address(3)).*;

-- ****************************************************************************************************************** --

-- Delete customer's own account
CREATE OR REPLACE FUNCTION delete_account(customer_id INT)
RETURNS VOID AS
$$
BEGIN
    -- Cascade delete will handle related data in Online_order, Wishlist, Cart, etc.
    DELETE FROM Customer WHERE customerID = customer_id;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM customer;
-- SELECT delete_account(3);
-- SELECT * FROM customer;
