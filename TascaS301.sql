-- Especialización Data Analytics
-- Álex Vidal

-- Tarea S2.01

-- Nivel 1
-- Ejercicio 1: Diseñar y crear una nueva tabla "credit_card"
-- que almacene detalles importantes de tarjetas de crédito.
-- La nueva tabla ha de identificar de manera única cada tarjeta
-- y establecer una relación adecuada con las otras dos tablas
-- Introducir los datos del fichero "dades_introduir_credit".

-- Creamos la tabla credit_card

CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(15) PRIMARY KEY,
        iban VARCHAR(255),
        pan VARCHAR(255),
        pin SMALLINT,
        cvv SMALLINT,
        expiring_date VARCHAR(15)
    );

-- Añadimos la clave foránea credit_card_id de la tabla transaction
-- tras rellenar la tabla credit_card

ALTER TABLE transaction
ADD CONSTRAINT credit_card_fk
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Ejercicio 2: RRHH ha identificado un error en el número de cuenta del usuario con ID CcU-2938.
-- La informació que tiene que enseñarse para este aquest registro es: R323456312213576817699999.  

-- Comprobamos que el IBAN del usuario CcU-2938 no corresponde
-- con el que nos notifica RRHH 
SELECT * FROM credit_card
WHERE id = 'CcU-2938';

-- Ejecutamos el cambio 
UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

-- Comprobamos que el cambio se ha realizado correctamente 
SELECT * FROM credit_card
WHERE id = 'CcU-2938';

-- Ejercicio 3: En la tabla "transaction" añadir un usuario nuevo con la siguiente info:
-- Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
-- credit_card_id	CcU-9999
-- company_id	b-9999
-- user_id	9999
-- lat	829.999
-- longitude	-117.999
-- amount	111.11
-- declined	0

-- Como no existen los registros correspondientes a company_id = 'b-9999'
-- y credit_card_id	= 'CcU-9999', añadimos estos datos en las tablas correspondientes

-- Tabla company
INSERT INTO company
VALUES ('b-9999', 'Eleternoaprendjz Data and DJ Ltd.', '0-1200-CALL-ME', 'eleternoaprendiz@proton.me', 'Spain', 'http://eleternoaprendiz.dj');

-- Tabla credit_card
INSERT INTO credit_card
VALUES ('CcU-9999', 'CE01234 5678 9012 3456', '0123 4567 8901 2345', 9999, 000, '12/28/28');

-- Transacción en transaction
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

-- Comprobamos que el registro se ha insertado correctamente
SELECT * FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- Ejercicio 4: Eliminar la columna "pan" de la tabla credit_card y mostrar el cambio realizado realizado.

ALTER TABLE credit_card
DROP COLUMN pan;

-- Mostramos la información de las columnas de la tabla credit_card
SHOW COLUMNs FROM credit_card;

-- Nivel 2
-- Ejercicio 1: Elimina de la tabla transaction el registro con ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de datos.

DELETE FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02'; 

-- Comprobamos que hemos eliminado el registro
SELECT * FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Ejercicio 2: Crear una vista llamada VistaMarketing que continga la siguiente información:
-- Nombre de la empresa. Teléfono de contacto. País de residencia. Media de compra realizada por cada empresa.
-- Presenta la vista creada, ordenando los datos de mayor a menor media de compra.

CREATE VIEW VistaMarketing AS
SELECT c.company_name Empresa, c.phone Teléfono, c.country País, round(AVG(t.amount),2) Media
FROM company c
JOIN transaction t
ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.id;

-- Mostramos los datos de la vista
SELECT * FROM VistaMarketing
ORDER BY Media DESC;

-- Ejercicio 3: Filtra la vista VistaMarketing para mostrar solo las empresas con residencia en "Germany".

SELECT * FROM VistaMarketing
WHERE País = 'Germany';


-- Nivel 3
-- Ejercicio 2: Preparar los comandos para crear la tabla data_user y modificar la base de datos
-- para dejarla tal como aparece en el diagrama.

-- a) Eliminamos la columna website de la tabla company
ALTER TABLE company
DROP COLUMN website;

-- b) Modificamos los tipos de datos de la tabla credit_card
-- y añadimos la columna fecha_actual
ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20),
MODIFY COLUMN iban VARCHAR(50),
MODIFY COLUMN pin VARCHAR(4),
MODIFY COLUMN cvv INT,
MODIFY COLUMN expiring_date VARCHAR(10),
ADD COLUMN fecha_actual DATE;

-- c) Rellenamos el campo fecha_actual de cada registro
-- con el valor de expiring_date, cambiándolo a formato DATE.
-- Comprobamos primero los datos:
SELECT * FROM credit_card;

-- Rellenamos la fecha en fecha_actual con formato DATE
UPDATE credit_card
SET fecha_actual = STR_TO_DATE(expiring_date, '%m/%d/%y'); 

-- Comprobamos de nuevo los registros en la tabla credit_card
SELECT * FROM credit_card;

-- d) Creamos la tabla user
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
    );
    
-- Aquí tenemos que añadir los datos de los usuarios

-- Comprobamos que no haya algún user_id no presente en la tabla user
SELECT user_id FROM transaction
WHERE user_id NOT IN (SELECT id FROM user);

-- Insertamos el usuario 9999
INSERT INTO user
VALUES (9999, 'Álex', 'Vidal', '666 666 666', 'eleternoaprendiz@proton.me',
'Mar 24, 1972', 'Spain', 'Barcelona', '08005', 'Patio, 117, Mi Casa, Particular');

-- Creamos la clave foránea    
ALTER TABLE transaction
ADD CONSTRAINT user_fk
FOREIGN KEY (user_id) REFERENCES user(id);

-- e) Indexamos el campo user_id de la tabla transaction
CREATE INDEX idx_user_id ON transaction(user_id);

-- f) Un último cambio en la tabla user
ALTER TABLE user
RENAME COLUMN email TO personal_email;

RENAME TABLE user TO data_user;

-- Ejercicio 3: Crear una vista llamada "InformeTecnico" que contenga:
-- ID de la transacción
-- Nombre user
-- Apellido user
-- IBAN de la tarjeta de crédito empleada.
-- Nombre de la empresa que realiza la transacción.
-- Incluir información relevante de ambas tablas i usar alias de columnas si fuera necesario.
-- Mostrar los resultados de la vista, ordenando los resultados de forma descendente
-- en función de la variable ID de transaction.
CREATE VIEW InformeTecnico AS
    SELECT 
        t.id NumTransaccion,
        u.name Nombre,
        u.surname Apellidos,
        u.phone Teléfono,
        u.personal_email 'Correo-e',
        cc.iban IBAN,
        c.company_name Media,
        t.amount,
        CASE
            WHEN t.declined = 0 THEN 'Aceptada'
            WHEN t.declined = 1 THEN 'Rechazada'
            ELSE 'Error'
        END AS 'Transacción'
    FROM
        transaction t
            JOIN
        data_user u ON t.user_id = u.id
            JOIN
        company c ON t.company_id = c.id
            JOIN
        credit_card cc ON t.credit_card_id = cc.id;

SELECT * FROM InformeTecnico
ORDER BY NumTransaccion DESC;