\set ON_ERROR_STOP off

SELECT pg_backend_pid() AS pid_sesion_A;
SELECT customer_id AS cust
FROM customer
ORDER BY customer_id
OFFSET 1
LIMIT 1 \gset

SELECT 999999999 AS bad_track,
       NOT EXISTS (SELECT 1 FROM track WHERE track_id = 999999999) AS no_existe \gset
\echo ¿La canción :bad_track NO existe? -> :no_existe

BEGIN ISOLATION LEVEL READ COMMITTED;

INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city,
                     billing_state, billing_country, billing_postal_code, total)
SELECT customer_id, now(), 'PRACTICA_TX02', city, state, country, postal_code, 0
FROM customer
WHERE customer_id = :cust
RETURNING invoice_id \gset
    \echo Factura de la venta 2: :invoice_id

INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
SELECT :invoice_id, track_id, unit_price, 1
FROM track
ORDER BY track_id
OFFSET 10
LIMIT 1;

INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
VALUES (:invoice_id, :bad_track, 0.99, 1);

SELECT 1;

ROLLBACK;

SELECT (SELECT count(*)
FROM invoice
WHERE invoice_id = :invoice_id) AS cabeceras,
(SELECT count(*)
FROM invoice_line
WHERE invoice_id = :invoice_id) AS detalles;

SELECT last_value
FROM invoice_invoice_id_seq;