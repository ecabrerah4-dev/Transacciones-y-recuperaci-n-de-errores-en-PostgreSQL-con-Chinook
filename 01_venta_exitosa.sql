\set ON_ERROR_STOP on

SELECT pg_backend_pid() AS pid_sesion_A,
       current_setting('transaction_isolation') AS aislamiento;
\echo Autocommit de psql: :AUTOCOMMIT

SELECT customer_id AS cust
FROM customer
ORDER BY customer_id
LIMIT 1 \gset

BEGIN ISOLATION LEVEL READ COMMITTED;

INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city,
                     billing_state, billing_country, billing_postal_code, total)
SELECT customer_id, now(), 'PRACTICA_TX01', city, state, country, postal_code, 0
FROM customer
WHERE customer_id = :cust
RETURNING invoice_id \gset
    \echo Factura creada: :invoice_id

INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
SELECT :invoice_id, track_id, unit_price, row_number() OVER (ORDER BY track_id)
FROM track
ORDER BY track_id
LIMIT 3;

UPDATE invoice
SET total = (SELECT SUM(unit_price * quantity)
FROM invoice_line
WHERE invoice_id = :invoice_id)
WHERE invoice_id = :invoice_id;

SELECT i.invoice_id, count(l.*) AS detalles, i.total,
       sum(l.unit_price * l.quantity) AS suma_detalles,
       i.total = sum(l.unit_price * l.quantity) AS coincide
FROM invoice i
JOIN invoice_line l USING (invoice_id)
WHERE i.invoice_id = :invoice_id
GROUP BY i.invoice_id, i.total;

\echo >>> EN LA SESIÓN B ejecute: psql -v invoice_id=:invoice_id -f 04_validaciones.sql
\echo >>> Esperado en B: 0 filas de cabecera y 0 detalles (A no ha confirmado).
\prompt 'Presione Enter cuando haya revisado B ' _pausa

COMMIT;

\echo >>> Repita 04_validaciones.sql en B. Esperado: 1 cabecera y 3 detalles.
\echo invoice_id de esta venta: :invoice_id