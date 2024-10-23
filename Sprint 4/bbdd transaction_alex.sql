-- Creamos la base de datos
-- Le asignamos un char set y collate lo más inclusivos posible

CREATE DATABASE IF NOT EXISTS transactions_alex
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- Creamos la tabla company
CREATE TABLE IF NOT EXISTS transactions_alex.company (
  id VARCHAR(15) PRIMARY KEY,
  company_name VARCHAR(255) NULL DEFAULT NULL,
  phone VARCHAR(15) NULL DEFAULT NULL,
  email VARCHAR(100) NULL DEFAULT NULL,
  country VARCHAR(100) NULL DEFAULT NULL,
  website VARCHAR(255) NULL DEFAULT NULL
 );

-- Creamos la tabla credit_card
CREATE TABLE IF NOT EXISTS transactions_alex.credit_card (
  id VARCHAR(15) PRIMARY KEY,
  user_id VARCHAR(15) NULL DEFAULT NULL,
  iban VARCHAR(50) NULL DEFAULT NULL,
  pan VARCHAR(50) NULL DEFAULT NULL,
  pin VARCHAR(4) NULL DEFAULT NULL,
  cvv VARCHAR(4) NULL DEFAULT NULL,
  track1 VARCHAR(100) NULL DEFAULT NULL,
  track2 VARCHAR(100) NULL DEFAULT NULL,
  expiring_date VARCHAR(10) NULL DEFAULT NULL
  );
  
-- Creamos la tabla user
CREATE TABLE IF NOT EXISTS transactions_alex.user (
  id INT NOT NULL PRIMARY KEY,
  name VARCHAR(100) NULL DEFAULT NULL,
  surname VARCHAR(100) NULL DEFAULT NULL,
  phone VARCHAR(150) NULL DEFAULT NULL,
  email VARCHAR(150) NULL DEFAULT NULL,
  birth_date VARCHAR(45) NULL DEFAULT NULL,
  country VARCHAR(150) NULL DEFAULT NULL,
  city VARCHAR(100) NULL DEFAULT NULL,
  postal_code VARCHAR(45) NULL DEFAULT NULL,
  address VARCHAR(255) NULL DEFAULT NULL
  );
  
-- Creamos la tabla transaction y las claves foráneas
CREATE TABLE IF NOT EXISTS transactions_alex.transaction (
  id VARCHAR(255) PRIMARY KEY,
  credit_card_id VARCHAR(15) NOT NULL,
  company_id VARCHAR(15) NOT NULL,
  timestamp TIMESTAMP NULL DEFAULT NULL,
  amount DECIMAL(10,2) NULL DEFAULT NULL,
  declined TINYINT,
  product_ids VARCHAR(45) NULL DEFAULT NULL,
  user_id INT NOT NULL,
  latitude FLOAT NULL DEFAULT NULL,
  longitude FLOAT NULL DEFAULT NULL,
  FOREIGN KEY (company_id) REFERENCES company(id),
  FOREIGN KEY (credit_card_id) REFERENCES credit_card(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
  );
  
-- Buscamos el valor del parámetro secure_file_priv para
-- asegurarnos si existe y cuál es la ruta habilitada
-- para la importación de ficheros a la bbdd
SHOW VARIABLES LIKE 'secure_file_priv';
  
-- Importamos el fichero companies.csv a la tabla company
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE transactions_alex.company
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Importamos el fichero credit_cards.csv a la tabla credit_card
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE transactions_alex.credit_card
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Eliminamos la fk y cambiamos los tipos de datos de id de usuario
-- en las tablas user y transaction
ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_3;

ALTER TABLE transaction
MODIFY user_id VARCHAR(15);

ALTER TABLE user
MODIFY id VARCHAR(15);

-- Importamos los ficheros de usuarios a la tabla user
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
INTO TABLE transactions_alex.user
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
INTO TABLE transactions_alex.user
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'
INTO TABLE transactions_alex.user
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Importamos transactions.csv a la tabla transaction
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions_alex.transaction
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Recuperamos la clave foránea
ALTER TABLE transaction
ADD CONSTRAINT FOREIGN KEY (user_id)
REFERENCES user(id);
