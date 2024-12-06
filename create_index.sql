CREATE INDEX idx_customer_email ON customer (email);

CREATE INDEX idx_book_date_release ON book (date_release DESC);
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_book_title ON book USING gin (book_title gin_trgm_ops);

CREATE INDEX idx_cart_customerID ON cart (customerID);
CREATE INDEX idx_cart_bookID ON cart (bookID);

CREATE INDEX idx_wishlist_customerID ON wishlist (customerID);
CREATE INDEX idx_wishlist_bookID ON wishlist (bookID);

CREATE INDEX idx_address_customerID ON address (customerID);

CREATE INDEX idx_online_order_customerID ON online_order (customerID);
CREATE INDEX idx_online_order_date_purchase ON online_order (date_purchase DESC);

CREATE INDEX idx_order_quantity_orderID ON order_quantity_online (orderID);
CREATE INDEX idx_order_quantity_bookID ON order_quantity_online (bookID);

CREATE INDEX idx_inventory_bookID ON inventory (bookID);
CREATE INDEX idx_inventory_quantity ON inventory (quantity);

CREATE INDEX idx_shipping_orderID ON shipping (orderID);

CREATE INDEX idx_restock_bookID ON restock (bookID);
