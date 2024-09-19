DROP VIEW IF EXISTS rental_info_sumarize;
DROP temporary TABLE IF EXISTS total_paid_by_customer;

-- 1. Create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW rental_info_sumarize AS
	SELECT c.customer_id, c.first_name, c.email, count(r.rental_id) AS 'rental_count'
    FROM customer c
    INNER JOIN rental r
    ON c.customer_id = r.customer_id
    GROUP BY c.customer_id, c.first_name, c.email ;

-- 2. create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE total_paid_by_customer AS
    SELECT r.customer_id, r.first_name, r.email, r.rental_count, sum(p.amount) AS 'total_paid'
    FROM rental_info_sumarize r
    INNER JOIN payment p 
    ON r.customer_id = p.customer_id
	GROUP BY r.customer_id, r.first_name, r.email ;

    -- Haciendo asi debemos agrupar dos veces, primero con la VIEW y luego con esto ¿Esta bien?

-- Si hago esto de abajo me queda una burrada de filas (más de 9 millones)
-- CREATE TEMPORARY TABLE total_paid_by_customer AS
--    SELECT r.customer_id, r.first_name, r.email, r.rental_count, p.amount
--    FROM rental_info_sumarize r
--    INNER JOIN payment p
--    ON rental_id = p.rental_id


-- 3. Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH join_view_and_temporaryTable AS (
	SELECT *
    FROM total_paid_by_customer tp
)

SELECT *, (total_paid/rental_count) AS average_payment_per_rental
FROM join_view_and_temporaryTable
