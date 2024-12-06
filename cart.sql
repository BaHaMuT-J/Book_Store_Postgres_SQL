CREATE OR REPLACE FUNCTION add_to_cart(
    p_customerID INT,  -- Customer ID
    p_bookID INT,      -- Book ID
    p_quantity INT     -- Quantity to add or update
)
RETURNS VOID AS
$$
BEGIN
    -- Check if the book already exists in the customer's cart
    IF EXISTS (
        SELECT 1
        FROM cart
        WHERE customerID = p_customerID
        AND bookID = p_bookID
    ) THEN
        -- If the book exists, update the quantity
        UPDATE cart
        SET quantity = quantity + p_quantity  -- Increase the existing quantity by the new quantity
        WHERE customerID = p_customerID
        AND bookID = p_bookID;
    ELSE
        -- If the book does not exist, insert a new entry into the cart
        INSERT INTO cart (customerID, bookID, quantity)
        VALUES (p_customerID, p_bookID, p_quantity);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION remove_from_cart(
    p_customerID INT,  -- Customer ID
    p_bookID INT      -- Book ID
)
RETURNS VOID AS
$$
BEGIN
    -- Check if the book already exists in the customer's cart
    IF EXISTS (
        SELECT 1
        FROM cart
        WHERE customerID = p_customerID
        AND bookID = p_bookID
    ) THEN
        -- If the book exists, reduce the quantity of the book by 1
        UPDATE cart
        SET quantity = quantity - 1
        WHERE customerID = p_customerID
          AND bookID = p_bookID;

        -- If the quantity reaches 0, delete the book from the cart
        DELETE FROM cart
        WHERE customerID = p_customerID
          AND bookID = p_bookID
          AND quantity = 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cart(
    p_customer_id INT
)
RETURNS INT AS
$$
DECLARE count INT;
BEGIN
    SELECT sum(quantity) INTO count
    FROM cart
    WHERE customerID = p_customer_id;
    RETURN count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_cart_count()
RETURNS TRIGGER AS
$$
BEGIN
    -- Update the total quantity of books in the cart for the customer after insert or update
    PERFORM count_cart(NEW.customerID);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_count_cart
    AFTER INSERT OR UPDATE
    ON cart
    FOR EACH ROW
    EXECUTE FUNCTION update_cart_count();

CREATE OR REPLACE FUNCTION view_cart(
    p_customer_id INT
)
RETURNS SETOF cart AS
$$
BEGIN
    RETURN QUERY
        SELECT *
        FROM cart
        WHERE customerID = p_customer_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM cart;
SELECT add_to_cart(2, 10, 1);
SELECT add_to_cart(2, 11, 1);
SELECT * FROM cart;

SELECT * FROM cart;
SELECT remove_from_cart(2, 10);
SELECT * FROM cart;

SELECT count_cart(2);

SELECT (view_cart(2)).*;