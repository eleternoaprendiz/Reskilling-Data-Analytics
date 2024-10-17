-- Especialización Data Analytics
-- Álex Vidal

-- Tarea S4.01

-- Nivel 1
-- Ejercicio 1: Realiza una subconsulta que muestre todos los usuarios
-- con más de 30 transacciones usando cuanto menos 2 tablas.

SELECT u.name, u.surname, u.phone, u.email
FROM user u
WHERE u.id IN
		(SELECT user_id FROM
			(SELECT t2.user_id, COUNT(t2.id) numtrans
			FROM transaction t2
			GROUP BY t2.user_id
			HAVING numtrans > 30) AS TablNumTrans)
ORDER BY surname;

-- Ejercicio 2: Muestra la media de amount por IBAN de las tarjetas de credito
-- de la empresa Donec Ltd. Usa al menos 2 tablas.

SELECT cc.iban IBAN, ROUND(AVG(t.amount),2) Media
FROM transaction t
JOIN credit_card cc
	ON cc.id = t.credit_card_id
JOIN company c
	ON c.id = t.company_id
WHERE c.company_name = 'Donec Ltd'
-- and t.declined = 0
GROUP BY t.credit_card_id;

-- Nivel 2
-- Ejercicio 1: ¿Cuántas tarjetas están activas?

CREATE TABLE IF NOT EXISTS credit_card_status (
	id VARCHAR(255) PRIMARY KEY,
    credit_card_id VARCHAR(15),
    declined tinyint,
    timestamp timestamp)
AS WITH credit_card_three AS (
							SELECT id, credit_card_id, declined, timestamp,
                            ROW_NUMBER() OVER(PARTITION BY credit_card_id ORDER BY timestamp DESC) AS numorden
							from transaction
                            )
SELECT id, credit_card_id, declined, timestamp, numorden
FROM credit_card_three
WHERE numorden IN (1,2,3);

-- Comprobamos los datos de la tabla credit_card_status
SELECT * FROM credit_card_status
ORDER BY credit_card_id, timestamp DESC;

-- ¿Cuántas tarjetas están activas?
SELECT COUNT(credit_card_id) 'Núm. tarjetas activas'
FROM (
		SELECT credit_card_id, SUM(declined)
		FROM credit_card_status
		GROUP BY credit_card_id
		HAVING SUM(declined) < 3) AS credit_card_active;

-- Creo una tarjeta de crédito nueva y guardo tres transacciones fallidas
-- con esta tarjeta para comprobar el resultado

INSERT INTO credit_card
VALUES ('CcU-9999', '275', 'CE01234 5678 9012 3456', '0123 4567 8901 2345', 9999, 000, '%tarari', '%tarara','12/28/28');

INSERT INTO transaction
VALUES ('02C6201E-D90A-1859-B4EE-88D2986D3B03', 'CcU-9999', 'b-2422', '2024-10-12 00:00:00', 500.00, 1, '70', 275, 80, 80);
INSERT INTO transaction
VALUES ('02C6201E-D90A-1859-B4EE-88D2986D3B04', 'CcU-9999', 'b-2422', '2024-10-12 00:00:00', 400.00, 1, '69', 275, 80, 80);
INSERT INTO transaction
VALUES ('02C6201E-D90A-1859-B4EE-88D2986D3B05', 'CcU-9999', 'b-2422', '2024-10-12 00:00:00', 300.00, 1, '6', 275, 80, 80);

-- Recreamos la tabla credit_card_status
DROP TABLE credit_card_status;

CREATE TABLE IF NOT EXISTS credit_card_status (
	id VARCHAR(255) PRIMARY KEY,
    credit_card_id VARCHAR(15),
    declined tinyint,
    timestamp timestamp)
AS WITH credit_card_three AS (
							SELECT id, credit_card_id, declined, timestamp,
                            ROW_NUMBER() OVER(PARTITION BY credit_card_id ORDER BY timestamp DESC) AS numorden
							from transaction
                            )
SELECT id, credit_card_id, declined, timestamp, numorden
FROM credit_card_three
WHERE numorden IN (1,2,3);

-- Volvemos a preguntar cuántas tarjetas están activas
-- y comprobamos también cuántas están inactivas
SELECT COUNT(credit_card_id) 'Núm. tarjetas activas'
FROM (
		SELECT credit_card_id, SUM(declined)
		FROM credit_card_status
		GROUP BY credit_card_id
		HAVING SUM(declined) < 3) AS credit_card_active;
        
SELECT COUNT(credit_card_id) 'Núm. tarjetas inactivas'
FROM (
		SELECT credit_card_id, SUM(declined)
		FROM credit_card_status
		GROUP BY credit_card_id
		HAVING SUM(declined) >= 3) AS credit_card_inactive;        
        
-- Nivel 3
-- Ejercicio 1: ¿Cuántas tarjetas están activas?

-- Creamos la tabla product

CREATE TABLE IF NOT EXISTS product (
	id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price VARCHAR(10),
    colour VARCHAR(10),
    wheight DECIMAL(5,1),
    warehouse_id VARCHAR(10)
    );
    
    -- Importamos el fichero products.csv a la tabla product
    -- Creamos la tabla intermedia transaction_product
    
    CREATE TABLE IF NOT EXISTS transaction_products (
	transaction_id VARCHAR(255),
    product_id INT REFERENCES product(id),
    FOREIGN KEY (transaction_id) REFERENCES transaction(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
    );

-- Contamos el número de productos que hay en cada transacción
-- Será el número de comas +1 (en el caso de que solo haya un producto)

CREATE TABLE transaction_numproducts (
	id VARCHAR(255),
    product_ids VARCHAR(45),
    NumProds INT
    )
SELECT
	id,
    product_ids,
    LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 AS NumProds
FROM transaction;

SELECT * FROM transaction_numproducts;

-- Número máximo de productos por transacción:
SELECT MAX(NumProds) AS 'Máx. prods. por transacción'
FROM transaction_numproducts;

-- Número total de productos vendidos:
SELECT SUM(NumProds) AS 'Total productos'
FROM transaction_numproducts;

-- Extraemos los productos de cada transacción y cargamos la tabla transaction_products
-- con tantas líneas por transacción como productos hay en esa transacción
INSERT INTO transaction_products
SELECT id, SUBSTRING_INDEX(product_ids, ',', 1) 
FROM transaction_numproducts;

INSERT INTO transaction_products
SELECT id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1) 
FROM transaction_numproducts
WHERE NumProds <> 1;

INSERT INTO transaction_products
SELECT id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1) 
FROM transaction_numproducts
WHERE NumProds NOT IN (1, 2);

INSERT INTO transaction_products
SELECT id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1) 
FROM transaction_numproducts
WHERE NumProds = 4;

-- Comprobamos que el número de registro coincide con la cantidad de productos
SELECT * FROM transaction_products;

-- Calculamos cuántas veces se ha vendido cada producto

SELECT product_name Producto, COUNT(transaction_id) NumVentas
FROM transaction_products tp
JOIN product p
	ON p.id = tp.product_id
JOIN transaction t
	ON t.id = tp.transaction_id
WHERE t.declined = 0
GROUP BY product_id
ORDER BY NumVentas DESC;
