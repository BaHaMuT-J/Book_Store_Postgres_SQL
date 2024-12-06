-- Function related to cart

-- Add books to Cart
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

    -- Remove the book from the wishlist if it exists
    DELETE FROM wishlist
    WHERE customerID = p_customerID
    AND bookID = p_bookID;
END;
$$ LANGUAGE plpgsql;

-- Remove books from Cart
CREATE OR REPLACE FUNCTION remove_from_cart(
    p_customerID INT,  -- Customer ID
    p_bookID INT       -- Book ID
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

-- Update number of books in cart to update number on cart icon in the site
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

-- Trigger to update number of books in Cart
CREATE OR REPLACE FUNCTION update_cart_count()
RETURNS TRIGGER AS
$$
BEGIN
    -- Update the total quantity of books in the cart for the customer after insert or update
    PERFORM count_cart(NEW.customerID);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger after insert or update in Cart
DROP TRIGGER IF EXISTS trg_update_count_cart ON cart;
CREATE TRIGGER trg_update_count_cart
    AFTER INSERT OR UPDATE
    ON cart
    FOR EACH ROW
    EXECUTE FUNCTION update_cart_count();

-- View customer's own Cart
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

-- SELECT add_to_cart(3, 10, 1);
-- SELECT add_to_cart(3, 11, 3);

-- SELECT remove_from_cart(3, 11);

-- SELECT count_cart(3);

-- SELECT (view_cart(3)).*;