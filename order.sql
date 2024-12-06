-- Function related to order

-- Process order
CREATE OR REPLACE PROCEDURE process_order(
    p_customerID INT,                   -- Customer's ID
    p_point INT,                        -- Points customer want to use
    p_addressID INT,                    -- Address for this order
    p_payment_method VARCHAR(50)        -- Payment method customer chose
)
LANGUAGE plpgsql
AS $$
DECLARE
    cart_item RECORD;                    -- For iterating through items in the cart
    total_price DECIMAL(10, 2);          -- Total price of the order
    effective_price DECIMAL(10, 2);      -- Price after applying points
    points_gained INT;                   -- Points gained from the order
    shipping_fee DECIMAL(10, 2) := 5.00; -- Flat shipping fee
    available_points INT;                -- Points available for the customer
    points_to_use INT;                   -- Points that will actually be used
    order_id INT;                        -- Generated order ID
BEGIN
    -- Retrieve customer's available points
    SELECT point INTO available_points
    FROM Customer
    WHERE customerID = p_customerID
    FOR UPDATE; -- Lock the customer row to prevent point updates by other transactions

    -- Check if the customer is trying to use more points than they have
    IF p_point > available_points THEN
        RAISE EXCEPTION 'Insufficient points. You have % points available.', available_points;
    END IF;

    -- Initialize total price
    total_price := 0;

    -- Lock inventory and cart rows to prevent other users from modifying them
    FOR cart_item IN
        SELECT c.bookID, c.quantity, b.price, i.quantity AS inventory_quantity
        FROM Cart c
        JOIN Inventory i ON c.bookID = i.bookID
        JOIN Book b ON c.bookID = b.bookID
        WHERE c.customerID = p_customerID
        FOR UPDATE NOWAIT -- Lock rows to prevent concurrent modification
    LOOP
        IF cart_item.quantity > cart_item.inventory_quantity THEN
            RAISE EXCEPTION 'Book ID % has insufficient stock.', cart_item.bookID;
        END IF;

        -- Add to total price
        total_price := total_price + (cart_item.price * cart_item.quantity);
    END LOOP;

    -- Add shipping fee
    total_price := total_price + shipping_fee;

    -- Calculate the points to use (only up to the total price)
    IF p_point * 0.1 > total_price THEN
        points_to_use := FLOOR(total_price / 0.1); -- Max points that can be used
    ELSE
        points_to_use := p_point; -- Use the requested points
    END IF;

    -- Calculate effective price after applying points
    effective_price := total_price - (points_to_use * 0.1);

    -- Calculate points gained (5% of the effective price)
    points_gained := FLOOR(effective_price * 0.05);

    -- Update customer's points: deduct used points and add gained points
    UPDATE Customer
    SET point = point - points_to_use + points_gained
    WHERE customerID = p_customerID;

    -- Insert a new order into Online_order
    INSERT INTO Online_order (customerID, date_purchase, total_price, payment_method, addressID, status)
    VALUES (p_customerID, CURRENT_DATE, effective_price,
            p_payment_method, p_addressID, 'Pending')
    RETURNING orderID INTO order_id;

    -- Insert into Shipping
    INSERT INTO Shipping (orderID, status)
    VALUES (order_id, 'Pending');

    -- Process items in the cart
    FOR cart_item IN
        SELECT c.bookID, c.quantity
        FROM Cart c
        WHERE c.customerID = p_customerID
    LOOP
        -- Insert into Order_quantity_online
        INSERT INTO Order_quantity_online (orderID, bookID, quantity)
        VALUES (order_id, cart_item.bookID, cart_item.quantity);

        -- Reduce inventory
        UPDATE Inventory
        SET quantity = quantity - cart_item.quantity
        WHERE bookID = cart_item.bookID;
    END LOOP;

    -- Clear the customer's cart
    DELETE FROM Cart WHERE customerID = p_customerID;

    -- Assume customer proceed with their payment in the external site
END;
$$;

-- Trigger to notify that the book's quantity drop below threshold and need to be restocked
CREATE OR REPLACE FUNCTION notify_restock() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO restock (bookID, quantity, notification_date)
    VALUES (NEW.bookID, NEW.quantity, CURRENT_DATE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger when update Inventory
DROP TRIGGER IF EXISTS trg_inventory_threshold ON inventory;
CREATE TRIGGER trg_inventory_threshold
    AFTER UPDATE ON Inventory
    FOR EACH ROW
    WHEN (OLD.quantity > 10 AND NEW.quantity <= 10)   -- Only trigger when quantity drops below 10
    EXECUTE FUNCTION notify_restock();

-- Trigger to update Restock when the corresponding entry is updated in Inventory
CREATE OR REPLACE FUNCTION update_restock() RETURNS TRIGGER AS $$
BEGIN
    IF New.quantity <= 10 THEN
        -- If new quantity drop, update quantity in Restock table
        UPDATE restock
        SET quantity = New.quantity
        WHERE bookID = New.bookID;
    ELSE
        -- Delete from Restock table once a book is restocked
        DELETE FROM restock
        WHERE bookID = New.bookID;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger when update Inventory
DROP TRIGGER IF EXISTS trg_update_restock ON inventory;
CREATE TRIGGER trg_update_restock
    AFTER UPDATE ON Inventory
    FOR EACH ROW
    WHEN (OLD.quantity <= 10)   -- Only trigger when quantity is already below 10
    EXECUTE FUNCTION update_restock();

-- Trigger to update order status after the order are shipped
CREATE OR REPLACE FUNCTION update_order_in_progress() RETURNS TRIGGER AS $$
BEGIN
    UPDATE online_order
    SET status = 'In progress'
    WHERE orderID = NEW.orderID;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger when order are shipped
DROP TRIGGER IF EXISTS trg_update_order_in_progress ON shipping;
CREATE TRIGGER trg_update_order_in_progress
    AFTER UPDATE ON shipping
    FOR EACH ROW
    WHEN (NEW.status = 'Shipped')
    EXECUTE FUNCTION update_order_in_progress();

-- Trigger to update order status after the order are delivered
CREATE OR REPLACE FUNCTION update_order_complete() RETURNS TRIGGER AS $$
BEGIN
    UPDATE online_order
    SET status = 'Complete'
    WHERE orderID = NEW.orderID;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger when order are delivered
DROP TRIGGER IF EXISTS trg_update_order_complete ON shipping;
CREATE TRIGGER trg_update_order_complete
    AFTER UPDATE ON shipping
    FOR EACH ROW
    WHEN (NEW.status = 'Delivered')
    EXECUTE FUNCTION update_order_complete();

-- CALL process_order(3, 0, 3, 'Credit card');

-- Update shipping SET status = 'Shipped' WHERE orderid = 4;
-- Update shipping SET status = 'Delivered' WHERE orderid = 4;
