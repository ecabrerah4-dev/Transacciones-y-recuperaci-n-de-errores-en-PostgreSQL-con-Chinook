\set ON_ERROR_STOP off

SELECT customer_id AS cust
FROM customer
ORDER BY customer_id
OFFSET 2
LIMIT 1 \gset
SELECT 999999999 AS bad_track,
NOT EXISTS (SELECT 1 FROM track WHERE track_id = 999999999) AS no_existe \gset
\echo ¿La canción inválida NO existe? -> :no_existe

BEGIN ISOLATION LEVEL READ COMMITTED;

INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city,
                     billing_state, billing_country, billing_postal_code, total)
SELECT customer_id, now(), 'PRACTICA_TX03', city, state, country, postal_code, 0
FROM customer
WHERE customer_id = :cust
RETURNING invoice_id \gset
    \echo Factura de la venta 3: :invoice_id

INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
SELECT :invoice_id, track_id, unit_price, 1
FROM track
ORDER BY track_id
OFFSET 20
LIMIT 2;

SAVEPOINT antes_riesgo;

INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
VALUES (:invoice_id, :bad_track, 0.99, 1);

ROLLBACK TO SAVEPOINT antes_riesgo;

SELECT count(*) AS detalles,
       count(*) FILTER (WHERE track_id = :bad_track) AS invalidos
FROM invoice_line WHERE invoice_id = :invoice_id;

INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
SELECT :invoice_id, track_id, unit_price, 2
FROM track
ORDER BY track_id
OFFSET 50
LIMIT 1;


UPDATE invoice
SET total = (SELECT SUM(unit_price * quantity)
             FROM invoice_line
             WHERE invoice_id = :invoice_id)
WHERE invoice_id = :invoice_id;


SELECT i.invoice_id, count(l.*) AS detalles, i.total,
       i.total = sum(l.unit_price * l.quantity) AS coincide
FROM invoice i
JOIN invoice_line l USING (invoice_id)
WHERE i.invoice_id = :invoice_id
GROUP BY i.invoice_id, i.total;

COMMIT;

SELECT count(*) AS detalles,
       count(*) FILTER (WHERE track_id = :bad_track) AS invalidos
FROM invoice_line
WHERE invoice_id = :invoice_id;