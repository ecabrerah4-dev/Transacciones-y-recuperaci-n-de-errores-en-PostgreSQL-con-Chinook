\set ON_ERROR_STOP on

SELECT pg_backend_pid() AS pid_sesion_B,
       current_setting('transaction_isolation') AS aislamiento;
\echo Autocommit de psql: :AUTOCOMMIT

SELECT (SELECT count(*)
FROM invoice
WHERE invoice_id = :invoice_id) AS cabeceras,
(SELECT count(*)
FROM invoice_line
WHERE invoice_id = :invoice_id) AS detalles;

SELECT i.invoice_id, i.billing_address AS marca, count(l.*) AS detalles,
       i.total, i.total = COALESCE(sum(l.unit_price * l.quantity), 0) AS coincide
FROM invoice i
LEFT JOIN invoice_line l USING (invoice_id)
WHERE i.billing_address
LIKE 'PRACTICA_TX%'
GROUP BY i.invoice_id, i.billing_address, i.total
ORDER BY i.invoice_id;

SELECT count(*) AS huerfanos
FROM invoice_line l
LEFT JOIN invoice i USING (invoice_id)
WHERE i.invoice_id IS NULL;