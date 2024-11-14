-- Especialización Data Analytics
-- Álex Vidal

-- Tarea S4.01

-- Nivel 1
-- Ejercicio 1: Realiza una subconsulta que muestre todos los usuarios
-- con más de 30 transacciones usando cuanto menos 2 tablas.

-- CORRECCIÓN: simplificar la subquery eliminando la subquery anidada
SELECT u.name, u.surname, u.phone, u.email
FROM user u
WHERE u.id IN
		(SELECT t.user_id
			FROM transaction t
			GROUP BY t.user_id
			HAVING COUNT(t.id) > 30)
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

-- Creamos una tabla temporal donde ordenamos cronológicamente,
-- de reciente a antigua, las transacciones de cada tarjeta
-- usada para hacer transacciones:
CREATE TEMPORARY TABLE IF NOT EXISTS credit_card_ordered AS (
	SELECT
		id,
		credit_card_id,
		declined,
		timestamp,
		ROW_NUMBER() OVER(PARTITION BY credit_card_id ORDER BY timestamp DESC) AS numorden
	FROM transaction
    );

-- Comprobamos los datos de esta tabla temporal
SELECT * FROM credit_card_ordered;    

-- Creamos la tabla que asignará el estado de las tarjetas de crédito
CREATE TABLE IF NOT EXISTS credit_card_status AS (
	SELECT
		cco.credit_card_id AS 'Id. tarjeta',
		cc.iban,
		u.name,
		u.surname,
		CASE
			WHEN SUM(declined) = 3 THEN 'Inactiva'
			ELSE 'Activa'
		END AS Estado
	FROM credit_card_ordered cco
	JOIN credit_card cc ON cco.credit_card_id = cc.id
	JOIN user u ON cc.user_id = u.id
	WHERE numorden in (1,2,3)
	GROUP BY credit_card_id
);

-- Comprobamos los datos de la tabla credit_card_status
SELECT * FROM credit_card_status;

-- ¿Cuántas tarjetas están activas?
SELECT estado, COUNT(estado) 'Núm. tarjetas por estado'
FROM credit_card_status
GROUP BY estado;

-- Creo una tarjeta de crédito nueva y guardo tres transacciones fallidas
-- con esta tarjeta para comprobar que el procedimiento es correcto

INSERT INTO credit_card
VALUES ('CcU-9999', '275', 'CE01234 5678 9012 3456', '0123 4567 8901 2345', 9999, 000, '%tarari', '%tarara','12/28/28');

INSERT INTO transaction
VALUES ('02C6201E-D90A-1859-B4EE-88D2986D3B03', 'CcU-9999', 'b-2422', '2024-10-12 00:00:00', 500.00, 1, '70', 275, 80, 80);
INSERT INTO transaction
VALUES ('02C6201E-D90A-1859-B4EE-88D2986D3B04', 'CcU-9999', 'b-2422', '2024-10-12 00:00:00', 400.00, 1, '69', 275, 80, 80);
INSERT INTO transaction
VALUES ('02C6201E-D90A-1859-B4EE-88D2986D3B05', 'CcU-9999', 'b-2422', '2024-10-12 00:00:00', 300.00, 1, '6', 275, 80, 80);

-- Recreamos la tabla credit_card_status y el procedimiento
DROP TABLE credit_card_ordered;
DROP TABLE credit_card_status;

CREATE TEMPORARY TABLE IF NOT EXISTS credit_card_ordered AS (
	SELECT
		id,
		credit_card_id,
		declined,
		timestamp,
		ROW_NUMBER() OVER(PARTITION BY credit_card_id ORDER BY timestamp DESC) AS numorden
	FROM transaction
    );

-- Comprobamos los datos de esta tabla temporal
SELECT * FROM credit_card_ordered;    

-- Creamos la tabla que asignará el estado de las tarjetas de crédito
CREATE TABLE IF NOT EXISTS credit_card_status AS (
	SELECT
		cco.credit_card_id AS 'Id. tarjeta',
		cc.iban,
		u.name,
		u.surname,
		CASE
			WHEN SUM(declined) = 3 THEN 'Inactiva'
			ELSE 'Activa'
		END AS Estado
	FROM credit_card_ordered cco
	JOIN credit_card cc ON cco.credit_card_id = cc.id
	JOIN user u ON cc.user_id = u.id
	WHERE numorden in (1,2,3)
	GROUP BY credit_card_id
);

-- Comprobamos de nuevo los datos de la tabla credit_card_status
SELECT * FROM credit_card_status;

-- ¿Cuántas tarjetas están activas?
SELECT estado, COUNT(estado) 'Núm. tarjetas por estado'
FROM credit_card_status
GROUP BY estado;

-- Eliminamos los registros "inventados" antes de seguir
delete from transaction
where credit_card_id = 'CcU-9999';   

delete from credit_card
where id = 'CcU-9999';     
        
-- Nivel 3
-- Ejercicio 1: Crear una tabla product para añadir la información
-- del fichero products.csv y crear una consulta para obtener
-- el número de veces que se ha vendido cada producto

-- Creamos la tabla product

CREATE TABLE IF NOT EXISTS product (
	id VARCHAR(15) PRIMARY KEY,
    product_name VARCHAR(255),
    price VARCHAR(10),
    colour VARCHAR(10),
    wheight DECIMAL(5,1),
    warehouse_id VARCHAR(10)
    );
    
-- Importamos el fichero products.csv a la tabla product

LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE transactions_alex.product
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Comprobamos que se han importado correctamente los datos
SELECT * FROM product;

-- Creamos la tabla intermedia transaction_product
    
CREATE TABLE IF NOT EXISTS transaction_products (
	transaction_id VARCHAR(255),
    product_id VARCHAR(15),
    FOREIGN KEY (transaction_id) REFERENCES transaction(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
    );

-- Contamos el número de productos que hay en cada transacción
-- Será el número de comas +1 (en el caso de que solo haya un producto)

CREATE TEMPORARY TABLE IF NOT EXISTS transaction_numproducts (
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

-- Creamos otra tabla temporal en la que almacenaremos las distintas cantidades
-- de productos por transaccions; irá desde el mínimo al máximo de productos por línea.
-- Será nuestro contador para la siguiente operación.

CREATE TEMPORARY TABLE IF NOT EXISTS numcontrol
SELECT DISTINCT(NumProds) num
FROM transaction_numproducts
ORDER BY num ASC;

-- Mostramos los datos de esta nueva tabla de control
SELECT * FROM numcontrol;

-- Número máximo de productos por transacción:
SELECT MAX(NumProds) AS 'Máx. prods. por transacción'
FROM transaction_numproducts;

-- Número total de productos vendidos:
SELECT SUM(NumProds) AS 'Total productos'
FROM transaction_numproducts;

-- Extraemos los productos de cada transacción y cargamos la tabla transaction_products
-- con tantas líneas por transacción como productos hay en esa transacción.

INSERT INTO transaction_products
SELECT id,
		TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', num), ',', -1))
FROM transaction_numproducts
JOIN numcontrol
ON NumProds >= num;

-- Comprobamos que el número de registro coincide con la cantidad de productos
SELECT * FROM transaction_products;

-- Calculamos cuántas veces se ha vendido cada producto

SELECT tp.product_id Id, p.product_name Producto, p.colour Color, p.price Precio, COUNT(tp.transaction_id) NumVentas
FROM transaction_products tp
JOIN product p
	ON p.id = tp.product_id
JOIN transaction t
	ON t.id = tp.transaction_id
WHERE t.declined = 0
GROUP BY Id
ORDER BY NumVentas DESC;