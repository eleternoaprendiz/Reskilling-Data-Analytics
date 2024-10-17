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