-- Function to process an order, including customer details, payment method,
-- update inventory and order quantities, and create a new purchase order entry
CREATE OR REPLACE FUNCTION process_order(
    p_books INT[],                -- Array of book IDs
    p_quantities INT[],           -- Array of quantities for each book
    p_customerID INT,             -- Customer ID (NULL if guest)
    p_branchID INT,               -- Branch ID where the order is processed
    p_payment_method VARCHAR(50)  -- Payment method (e.g., 'credit card', 'cash')
) RETURNS VOID AS $$
DECLARE
    v_total_price DECIMAL(10, 2) := 0;          -- Variable to store total price of the order
    v_book_price DECIMAL(10, 2);                -- Price of each book
    v_orderID INT;                              -- Order ID to be generated
    i INT;
BEGIN
    -- Insert a new purchase order entry into the Purchase_order table
    INSERT INTO Purchase_order (customerID, branchID, date_purchase, total_price, payment_method)
    VALUES (p_customerID, p_branchID, CURRENT_DATE, 0, p_payment_method)
    RETURNING orderID INTO v_orderID; -- Capture the newly generated order ID

    -- Loop through the array of book IDs and quantities
    FOR i IN 1..array_length(p_books, 1) LOOP
        -- Get the price of each book
        SELECT price INTO v_book_price
        FROM Book
        WHERE bookID = p_books[i];

        -- Calculate the total price of the order
        v_total_price := v_total_price + (v_book_price * p_quantities[i]);

        -- Insert each book and quantity into the Order_quantity table
        INSERT INTO Order_quantity (orderID, bookID, branchID, quantity)
        VALUES (v_orderID, p_books[i], p_branchID, p_quantities[i]);

        -- Update the inventory by reducing the quantity for the branch
        UPDATE Inventory
        SET quantity = quantity - p_quantities[i]
        WHERE bookID = p_books[i]
        AND branchID = p_branchID;
    END LOOP;

    -- Update the total price of the order in the Purchase_order table
    UPDATE Purchase_order
    SET total_price = v_total_price
    WHERE orderID = v_orderID;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION apply_discount() RETURNS TRIGGER AS $$
DECLARE
    discount_percentage DECIMAL(10, 2) := 5;     -- Variable to store discount percentage (ex 5%)
BEGIN
    -- Update the NEW.total_price with the discounted total price
    NEW.total_price := NEW.total_price * (100 - discount_percentage) / 100;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the Trigger
DROP TRIGGER IF EXISTS trg_apply_discount_insert ON Purchase_order;
DROP TRIGGER IF EXISTS trg_apply_discount_update ON Purchase_order;

CREATE TRIGGER trg_apply_discount_insert
    BEFORE INSERT
    ON Purchase_order
    FOR EACH ROW
    EXECUTE FUNCTION apply_discount();

CREATE TRIGGER trg_apply_discount_update
    BEFORE UPDATE
    ON Purchase_order
    FOR EACH ROW
    EXECUTE FUNCTION apply_discount();

-- ****************************************************************************************************************** --

-- Function to automatically record attendance of employees. When employee scan their id card,
-- their record will be tracked and automatically recorded after they leave
CREATE OR REPLACE FUNCTION record_attendance(
    p_employeeID INT,           -- Employee ID
    p_start_time TIME,          -- Start time (when employee arrives)
    p_end_time TIME             -- End time (when employee leaves)
) RETURNS VOID AS $$
BEGIN
    INSERT INTO attendance(employeeid, attendance_date, start_time, end_time)
    VALUES (p_employeeID, CURRENT_DATE, p_start_time, p_end_time);
END;
$$ LANGUAGE plpgsql;

-- ****************************************************************************************************************** --

-- Function to notify store when a book quantity is lower than threshold and need to be restocked
CREATE OR REPLACE FUNCTION notify_restock() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO restock (bookID, branchID, quantity, notification_date)
    VALUES (NEW.bookID, NEW.branchID, NEW.quantity, CURRENT_DATE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger for the Inventory table
CREATE TRIGGER trg_inventory_threshold
    AFTER UPDATE ON Inventory
    FOR EACH ROW
    WHEN (OLD.quantity > 10 AND NEW.quantity <= 10)   -- Only trigger when quantity drops below 10
    EXECUTE FUNCTION notify_restock();

-- Function to update Restock table when the corresponding entry is updated in Inventory table
CREATE OR REPLACE FUNCTION update_restock() RETURNS TRIGGER AS $$
BEGIN
    IF New.quantity <= 10 THEN
        -- If new quantity drop, update quantity in Restock table
        UPDATE restock
        SET quantity = New.quantity
        WHERE (branchID, bookID) = (New.branchID, New.bookID);
    ELSE
        -- Delete from Restock table once a book is restocked
        DELETE FROM restock
        WHERE (branchID, bookID) = (New.branchID, New.bookID);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger for the Inventory table
CREATE TRIGGER trg_update_inventory
    AFTER UPDATE ON Inventory
    FOR EACH ROW
    WHEN (OLD.quantity <= 10)   -- Only trigger when quantity is already below 10
    EXECUTE FUNCTION notify_restock();
