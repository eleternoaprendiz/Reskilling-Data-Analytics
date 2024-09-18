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

-- Calculamos qué empresa es la que más consume y buscamos su nombre

SELECT 
    company.company_name AS 'Compañía líder',
    SUM(transaction.amount) AS Importe
FROM
    company
        JOIN
    transaction ON transaction.company_id = company.id
GROUP BY transaction.company_id
ORDER BY Importe DESC
LIMIT 1;