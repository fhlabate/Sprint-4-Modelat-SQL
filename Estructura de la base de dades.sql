#Creación tabla "transaction"
CREATE TABLE transaction (
	id VARCHAR(255),
    card_id VARCHAR(255),
    business_id VARCHAR(255),
    timestamp VARCHAR(255),
    amount VARCHAR(255),
    declined VARCHAR(255),
    products_id VARCHAR(255),
    user_id VARCHAR(255),
    lat VARCHAR(255),
    longitude VARCHAR(255)
);
#inserción de datos tabla "transaction"
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transaction 
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
IGNORE 1 ROWS;

#Creación tabla "credit_card"
CREATE TABLE credit_card (
	id VARCHAR(255),
    user_id VARCHAR(255),
    iban VARCHAR(255),
    pan VARCHAR(255),
    pin VARCHAR(255),
    cvv VARCHAR(255),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(255)
);
#inserción de datos tabla "credit_card"
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_card 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

#Creación tabla "products"
CREATE TABLE products (
	id VARCHAR(255),
    product_name VARCHAR(255),
    price VARCHAR(255),
    colour VARCHAR(255),
    weight VARCHAR(255),
    warehouse_id VARCHAR(255)
);

#inserción de datos tabla "products"
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

#Creación tabla "companies"
CREATE TABLE companies (
	id VARCHAR(255),
    company_name VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    country VARCHAR(255),
    website VARCHAR(255)
);

#inserción de datos tabla "companies"
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

#Creación tabla "users_ca"
CREATE TABLE users_ca (
	id VARCHAR(255),
    name VARCHAR(255),
    surname VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    birth_date VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(255),
    address VARCHAR(255)
);

#inserción de datos tabla "users_ca"
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'
INTO TABLE users_ca
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

#Creación tabla users_uk
CREATE TABLE users_uk (
	id VARCHAR(255),
    name VARCHAR(255),
    surname VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    birth_date VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(255),
    address VARCHAR(255)
);

#inserción de datos tabla "users_uk"
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
INTO TABLE users_uk
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

#Creación tabla "users_usa"
CREATE TABLE users_usa (
	id VARCHAR(255),
    name VARCHAR(255),
    surname VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    birth_date VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(255),
    address VARCHAR(255)
);

#inserción de datos tabla "users_usa"
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
INTO TABLE users_usa
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

#Ya creadas las tablas e insertadas los datos, resuelvo el campo transaction.product_id

####### Inicio de transformación transaction.product_id #######

#[X]transaction.product_id (convertir en orders) 
CREATE TABLE orders SELECT products_id FROM transaction;

#[X]Le creo un id a orders
ALTER TABLE orders ADD id INT; #Creación del campo orders.id

#[X]Le asigno un número de id
SET @row_number = 0;
UPDATE orders SET id = (@row_number := @row_number + 1);

#[X] Creo una tabla temporal "temp_orders" donde coloco el valor luego de cada ","
CREATE TABLE temp_orders (
	id INT,
	product_id1 INT,
	product_id2 INT,
	product_id3 INT,
   	product_id4 INT
    );
#[X] Separo los números delimitados por "," en campos.
#¿Cómo funciona? -> Esta diseñado para un máximo de 4 products_id separado por ",":
#Voy a insentar en las columnas product_id1 | _id2 | _id3 | _id4,  los valores que cumplan la siguiente condición:
## 1 valor:
#Si el largo de products_id menos el largo el largo de products_id (reemplazando la "," por un caracter vacío) es igual a 0, 
#significa que no hay una "," por lo tanto solo debo castear toda la cadena a INT y colocarla en el campo product_id1
## 2 valores:
#Si el largo de products_id menos el largo el largo de products_id (reemplazando la "," por un caracter vacío) es igual a 1, 
#significa que hay una "," por lo tanto casteo el valor que esté a la izquierda de la "," al siguiente campo (product_id2)
## 3 valores:
#Si el largo de products_id menos el largo el largo de products_id (reemplazando la "," por un caracter vacío) es igual a 2, 
#significa que hay dos "," por lo tanto casteo el valor que esté a la izquierda de la última "," al siguiente campo (product_id3)
#(Los anteriores ya se habrán decantado en product_id1, product_id2)
## 4 valores:
#Si el largo de products_id menos el largo el largo de products_id (reemplazando la "," por un caracter vacío) es igual a 3, 
#significa que hay tres "," por lo tanto casteo el valor que esté a la izquierda de la última "," al siguiente campo (product_id4)
#(Los anteriores ya se habrán decantado en product_id1, product_id2 y product_id3)
## ¿Qué pasa cuando no se cumplen los 4 valores? Se complentan los campos vacios con un NULL.
INSERT INTO temp_orders (id, product_id1, product_id2, product_id3, product_id4)
SELECT id,
    CASE WHEN LENGTH(products_id) - LENGTH(REPLACE(products_id, ',','')) + 1 >= 1 THEN CAST(SUBSTRING_INDEX(products_id, ',', 1) AS UNSIGNED) ELSE NULL END,
    CASE WHEN LENGTH(products_id) - LENGTH(REPLACE(products_id, ',','')) + 1 >= 2 THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(products_id, ',', 2), ',', -1) AS UNSIGNED) ELSE NULL END,
    CASE WHEN LENGTH(products_id) - LENGTH(REPLACE(products_id, ',','')) + 1 >= 3 THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(products_id, ',', 3), ',', -1) AS UNSIGNED) ELSE NULL END,
    CASE WHEN LENGTH(products_id) - LENGTH(REPLACE(products_id, ',','')) + 1 >= 4 THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(products_id, ',', 4), ',', -1) AS UNSIGNED) ELSE NULL END
FROM orders;

#[X] Una vez resuelta la separación de los valores, se deben transponer todo a una mismo campo respetando sus ids. 
##[X] Tabla auxiliar "transp_order" para transponer los valores:
CREATE TABLE transp_order (
	id INT NOT NULL,
    product_id INT
    );
##[X] Insertar los valores transpuestos desde "temp_orders" (product_id1 | _id2 | _id3 | _id4) a la tabla "transp_order", exceptuando los datos NULL.
INSERT INTO transp_order (id, product_id)
SELECT id, product_id1 
FROM temp_orders
WHERE product_id1 IS NOT NULL 
UNION ALL
SELECT id, product_id2 
FROM temp_orders 
WHERE product_id2 IS NOT NULL
UNION ALL
SELECT id, product_id3 
FROM temp_orders
WHERE product_id3 IS NOT NULL
UNION ALL
SELECT id, product_id4 
FROM temp_orders
WHERE product_id4 IS NOT NULL;

#[X] borrar la tabla original "orders" la cual será reemplazada con "transp_order"
DROP table orders;
#[X] Renombrar la tabla "transp_order" a su valor final "orders".
ALTER TABLE transp_order RENAME orders;
#[X] Borrar tabla temporal "temp_orders"
DROP TABLE temp_orders;

#[X] En la tabla "transaction" ahora esa columna de comas se borra (products_id).
ALTER TABLE transaction DROP products_id;

#[X] Y se crea un order_id (INT). Esto lo hago para una facilidad visual humana. Realmente podría relacionar el id de transaction con el id de orders
ALTER TABLE transaction ADD order_id INT;

#[X] Le asigno un id a transaction.order_id
SET @row_number = 0;
UPDATE transaction SET order_id = (@row_number := @row_number + 1);

####### Fin de transformación transaction.product_id #######

#[X]Elimino el campo credit_card.user_id
ALTER TABLE credit_card
DROP COLUMN user_id;

#[X]Hacer UNION de las 3 tablas "user"
CREATE TABLE users (
	id VARCHAR(255),
    name VARCHAR(255),
    surname VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    birth_date VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(255),
    address VARCHAR(255)
);
#Unifico las 3 tablas users_ca | _uk | _usa en "users"
INSERT INTO users (id, name, surname, phone, email, birth_date, country, city, postal_code, address)
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address 
FROM users_ca
UNION ALL
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address 
FROM users_uk
UNION ALL
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address 
FROM users_usa;
#Elimino users_ca | _uk | _usa
DROP TABLE users_ca;
DROP TABLE users_uk;
DROP TABLE users_usa;

####### Redefino estructura de las tablas para hacer un uso eficiente del espacio #######
#[X] companies -> "company". 
ALTER TABLE companies RENAME company;
ALTER TABLE company MODIFY id VARCHAR (6) PRIMARY KEY NOT NULL;
ALTER TABLE company MODIFY company_name VARCHAR(35) NOT NULL;
ALTER TABLE company MODIFY phone VARCHAR(14) NOT NULL;   
ALTER TABLE company MODIFY email VARCHAR(40) NOT NULL;   
ALTER TABLE company MODIFY country VARCHAR(15) NOT NULL;   
ALTER TABLE company MODIFY website VARCHAR(32) NOT NULL; 

#[X] "credit_card".
ALTER TABLE credit_card MODIFY id VARCHAR(8) PRIMARY KEY NOT NULL;
ALTER TABLE credit_card MODIFY iban VARCHAR(32) NOT NULL;
ALTER TABLE credit_card MODIFY pan VARCHAR(20) NOT NULL;
ALTER TABLE credit_card MODIFY pin INT NOT NULL;
ALTER TABLE credit_card MODIFY cvv INT NOT NULL;
ALTER TABLE credit_card MODIFY track1 VARCHAR(46) NOT NULL;
ALTER TABLE credit_card MODIFY track2 VARCHAR(32) NOT NULL;
ALTER TABLE credit_card MODIFY expiring_date DATE;

#[X] credit_card.expiring_date
ALTER TABLE credit_card ADD COLUMN fecha_temp DATE; 
UPDATE credit_card SET fecha_temp = STR_TO_DATE(expiring_date, '%m/%d/%y');
ALTER TABLE credit_card DROP expiring_date;
ALTER TABLE credit_card RENAME COLUMN fecha_temp TO expiring_date;
ALTER TABLE credit_card MODIFY COLUMN expiring_date DATE NOT NULL;

#[X] "orders".
ALTER TABLE orders MODIFY id INT NOT NULL;
ALTER TABLE orders MODIFY product_id INT NOT NULL;

#[X] products -> "product".
ALTER TABLE products RENAME product;
ALTER TABLE product MODIFY id INT PRIMARY KEY NOT NULL;
ALTER TABLE product MODIFY product_name VARCHAR(30) NOT NULL;
ALTER TABLE product MODIFY colour VARCHAR(7) NOT NULL;
ALTER TABLE product MODIFY weight FLOAT NOT NULL;
ALTER TABLE product MODIFY warehouse_id VARCHAR(7) NOT NULL;

##[X] Sacar el signo "$" al campo price antes de cambiar a FLOAT
UPDATE product
SET price = REPLACE(price, '$', '');
ALTER TABLE product MODIFY price FLOAT NOT NULL;

#[X] "transaction"
ALTER TABLE transaction MODIFY id VARCHAR(255) PRIMARY KEY NOT NULL;
ALTER TABLE transaction CHANGE card_id credit_card_id VARCHAR(8) NOT NULL;
ALTER TABLE transaction CHANGE business_id company_id VARCHAR(6) NOT NULL;
ALTER TABLE transaction MODIFY timestamp DATETIME NOT NULL;
ALTER TABLE transaction MODIFY amount DECIMAL(10,2) NOT NULL;
ALTER TABLE transaction CHANGE order_id orders_id INT PRIMARY KEY NOT NULL;
ALTER TABLE transaction MODIFY user_id INT NOT NULL;
ALTER TABLE transaction MODIFY lat FLOAT NOT NULL;
ALTER TABLE transaction MODIFY longitude FLOAT NOT NULL;

#[X] users -> user
ALTER TABLE users RENAME user;
ALTER TABLE user MODIFY id INT PRIMARY KEY NOT NULL;
ALTER TABLE user MODIFY name VARCHAR(10) NOT NULL;
ALTER TABLE user MODIFY surname VARCHAR(11) NOT NULL;
ALTER TABLE user MODIFY phone VARCHAR(15) NOT NULL;
ALTER TABLE user MODIFY email VARCHAR(40) NOT NULL;
ALTER TABLE user MODIFY country VARCHAR(14) NOT NULL;
ALTER TABLE user MODIFY city VARCHAR(24) NOT NULL;
ALTER TABLE user MODIFY postal_code VARCHAR(24) NOT NULL;
ALTER TABLE user MODIFY address VARCHAR(36) NOT NULL;

##[X] Campo birth_date -> STR_TO_DATE
ALTER TABLE user ADD COLUMN birth_date_temp DATE; 
UPDATE user SET birth_date_temp = STR_TO_DATE(birth_date, '%b %d, %Y');
ALTER TABLE user DROP birth_date;
ALTER TABLE user CHANGE birth_date_temp birth_date DATE NOT NULL;

#[X] Con todo eso resuelto, crear FK:
##[X] Indice de ir en orders para poder vincular con la FK de fk_transaction_orders.
ALTER TABLE orders ALTER INDEX idx_id VISIBLE;
##[X] "transaction"
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card FOREIGN KEY (credit_card_id) REFERENCES credit_card (id),
ADD CONSTRAINT fk_transaction_company FOREIGN KEY (company_id) REFERENCES company (id),
ADD CONSTRAINT fk_transaction_user FOREIGN KEY (user_id) REFERENCES user (id),
ADD CONSTRAINT fk_transaction_orders FOREIGN KEY (orders_id) REFERENCES orders (id); 
#Como orders_id no es una PK (tiene repeteciones) le cree un idx_id

##[X] "orders"
ALTER TABLE orders
ADD CONSTRAINT fk_orders_product FOREIGN KEY (product_id) REFERENCES product (id);