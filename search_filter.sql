-- Search and Filter Function
CREATE OR REPLACE FUNCTION search(
    keyword VARCHAR DEFAULT NULL,               -- Search keyword for book title (or part of title)
    author_filter VARCHAR DEFAULT NULL,         -- Filter for author
    publisher_filter VARCHAR DEFAULT NULL,      -- Filter for publisher
    category_filter VARCHAR DEFAULT NULL,       -- Filter for category
    genre_filter VARCHAR DEFAULT NULL,          -- Filter for genre
    release_date_from DATE DEFAULT NULL,        -- Filter for release date range from
    release_date_to DATE DEFAULT NULL,          -- Filter for release date range to
    price_min DECIMAL(10, 2) DEFAULT NULL,      -- Filter for minimum price
    price_max DECIMAL(10, 2) DEFAULT NULL,      -- Filter for maximum price
    sort_by VARCHAR DEFAULT 'date_release',     -- Sort by field (default is date_release)
    sort_order VARCHAR DEFAULT 'DESC'           -- Sort order (ASC/DESC, default is DESC)
)
RETURNS SETOF book AS
$$
DECLARE
    query_text TEXT;
BEGIN
    -- Build the dynamic query
    query_text := 'SELECT b.* FROM book b WHERE
        (b.book_title ILIKE ''%'' || COALESCE($1, '''') || ''%'' OR $1 IS NULL)
        AND (b.author ILIKE ''%'' || COALESCE($2, '''') || ''%'' OR $2 IS NULL)
        AND (b.publisher ILIKE ''%'' || COALESCE($3, '''') || ''%'' OR $3 IS NULL)
        AND (b.category ILIKE ''%'' || COALESCE($4, '''') || ''%'' OR $4 IS NULL)
        AND (b.genre ILIKE ''%'' || COALESCE($5, '''') || ''%'' OR $5 IS NULL)
        AND (b.date_release >= COALESCE($6, b.date_release) OR $6 IS NULL)
        AND (b.date_release <= COALESCE($7, b.date_release) OR $7 IS NULL)
        AND (b.price >= COALESCE($8, b.price) OR $8 IS NULL)
        AND (b.price <= COALESCE($9, b.price) OR $9 IS NULL)';

    -- Add sorting logic dynamically based on the sort_by and sort_order parameters
    query_text := query_text ||
        ' ORDER BY ' ||
        CASE
            WHEN sort_by = 'book_title' THEN 'b.book_title'
            WHEN sort_by = 'price' THEN 'b.price'
            ELSE 'b.date_release'  -- Default sorting by date_release
        END ||
        ' ' ||
        CASE
            WHEN sort_order = 'ASC' THEN 'ASC'
            ELSE 'DESC'  -- Default sorting order is DESC
        END;

    -- Execute the dynamic query with the provided arguments
    RETURN QUERY EXECUTE query_text USING keyword, author_filter, publisher_filter, category_filter, genre_filter, release_date_from, release_date_to, price_min, price_max;
END;
$$ LANGUAGE plpgsql;

-- Search for books containing 'database' with case-insensitive in the title
-- SELECT (search('database')).*;

-- Search for books containing 'database' in the title, with a price greater or equal to 100, sorted by price in descending order.
-- SELECT (search('database',NULL,NULL,
--                NULL,NULL,NULL,
--                NULL,100,NULL,'price',
--                NULL)).*;
