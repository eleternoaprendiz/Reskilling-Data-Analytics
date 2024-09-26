-- Especialización Data Analytics
-- Álex Vidal

-- Tarea S2.01

-- Nivel 1
-- Ejercicio 2: Consultas con JOIN

-- Seleccionamos los países que están realizando compras

SELECT DISTINCT country
FROM company
JOIN transaction ON transaction.company_id = company.id
ORDER BY country;

-- Calculamos el número de países diferentes que están realizando compras

SELECT COUNT(DISTINCT Country) AS 'Número de países'
FROM company
JOIN transaction ON transaction.company_id = company.id
ORDER BY country;

-- Calculamos qué empresa tiene una media mayor de ventas y buscamos su nombre

SELECT 
    company.company_name AS 'Compañía líder',
    ROUND(AVG(transaction.amount),2) AS Importe
FROM
    company
        JOIN
    transaction ON transaction.company_id = company.id
WHERE transaction.declined = 0
GROUP BY transaction.company_id
ORDER BY Importe DESC
LIMIT 1;

-- Ejercicio 3: Consultas con subqueries

-- Mostrar todas las transacciones realizadas por empresas de Alemania
SELECT * FROM transaction
WHERE company_id IN
	(SELECT id FROM company
	 WHERE country = 'Germany');
     
-- Obtener el listado de empresas que han realizado transacciones por una cantidad superior a la media de todas las transacciones

SELECT company_name FROM company
WHERE id IN
	(SELECT company_id FROM transaction
	 WHERE amount >
		(SELECT AVG(amount)
        FROM transaction))
ORDER BY company_name;

-- Obtener el listado de empresas que no han realizado pedidos

SELECT company_name FROM company
WHERE NOT EXISTS
	(SELECT DISTINCT company_id FROM transaction)
ORDER BY company_name ASC;
    
-- Nivel 2
-- Ejercicio 1: Listar los cinco días de mayores ventas y la cantidad total recaudada esos días

SELECT DATE(timestamp) AS Fecha, SUM(amount) AS Total
FROM transaction
WHERE declined = 0
GROUP BY Fecha
ORDER BY Total DESC
LIMIT 5;

-- Ejercicio 2: Obtener la media de ventas por país y ordenarlas de menor a mayor

SELECT 
    c.country País, ROUND(AVG(amount), 2) Total
FROM
    transaction t
        JOIN
    company c ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY País
ORDER BY Total DESC;

-- Ejercicio 2: Mostrar todas las transacciones de las empresas ubicadas en el mismo país que "Non Institute"
-- a) Mediante JOIN y subqueries

SELECT 
    t.id, t.credit_card_id, t.company_id, c.company_name, t.user_id,
    t.lat, t.longitude, t.timestamp, t.amount, t.declined, c.country
FROM
    transaction t
        JOIN
    company c ON c.id = t.company_id
WHERE
    c.country = (SELECT c2.country
        FROM company c2
        WHERE c2.company_name = 'Non Institute')
        AND c.company_name <>  'Non Institute'
ORDER BY company_name;

-- b) Solo subqueries

SELECT * 
FROM transaction
WHERE
    company_id IN (SELECT id
        FROM company
        WHERE country = (SELECT country
						FROM company
						WHERE
                    company_name = 'Non Institute')
		AND company_name <>  'Non Institute'
					);
                    
-- Nivel 3
-- Ejercicio 1: Presentar nombre, teléfono, país, fecha e importe de aquellas empresas
-- que realizaron transacciones de un valor comprendido entre 100 y 200 euros en las siguientes
-- fechas: 29/04/2021, 20/07/2021 y 13/03/2022, presentadas de mayor a menor cantidad.

SELECT 
    c.company_name Empresa,
    c.phone Teléfono,
    c.country País,
    DATE(t.timestamp) Fecha,
    t.amount Importe
FROM
    company c
        JOIN
    transaction t ON c.id = t.company_id
WHERE
    t.amount BETWEEN 100 AND 200
        AND DATE(t.timestamp) IN ('2021-04-29' , '2021-07-20', '2022-03-13')
ORDER BY Importe DESC;

-- Ejercicio 2: Obtener un listado con las empresas que tiene más de cuatro o menos de cuatro transacciones

SELECT 
   c.company_name Empresa,
--   COUNT(t.id) Transacciones,
CASE
	WHEN COUNT(t.id) > 4 THEN 'Más de cuatro transacciones'
    ELSE 'Menos de cuatro transacciones'
END AS NumTrans
FROM
    transaction t
JOIN
    company c ON c.id = t.company_id
GROUP BY Empresa
ORDER BY COUNT(t.id) DESC;