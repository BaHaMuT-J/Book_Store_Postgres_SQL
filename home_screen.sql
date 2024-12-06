-- Function related to home screen

-- Show new release books in the home screen
CREATE OR REPLACE FUNCTION show_new_release()
RETURNS SETOF book AS
    $$
    BEGIN
        RETURN QUERY
            SELECT *
            FROM Book AS b
            WHERE b.date_release >= CURRENT_DATE - INTERVAL '1 month'   -- Show books release not more than 1 month ago
            ORDER BY b.date_release DESC;                               -- Most recently released books first
    END;
    $$ LANGUAGE plpgsql;

-- SELECT (show_new_release()).*;

-- Show bestseller books in the home screen
CREATE OR REPLACE FUNCTION show_best_seller()
RETURNS SETOF book AS
    $$
    BEGIN
        RETURN QUERY
            WITH book_sales AS (
                SELECT o.bookID, SUM(o.quantity) AS total_sold
                FROM order_quantity_online o
                JOIN online_order p ON o.orderID = p.orderID
                WHERE
                    -- Consider only books sold in the last month
                    p.date_purchase >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month' AND
                    p.date_purchase < DATE_TRUNC('month', CURRENT_DATE)
                GROUP BY o.bookID
                ORDER BY total_sold DESC
                LIMIT 10
            )
            SELECT b.*
            FROM book b
            JOIN book_sales bs ON b.bookID = bs.bookID;
    END;
    $$ LANGUAGE plpgsql;

-- SELECT (show_best_seller()).*;
