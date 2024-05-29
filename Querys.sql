-- Tasca S4.01. "Modelat SQL"

-- ####### Nivell 1 #######
-- Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
SELECT u.id AS idUser, CONCAT(u.name," ",u.surname) AS nomCognom , count(t.id) AS QuantitatTransaccions
FROM transaction t
JOIN user u
ON t.user_id = u.id
GROUP BY user_id
HAVING QuantitatTransaccions > 30;

-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
#Tomando en cuenta todas las transacciones: transaction.declined = 1 OR 0.
SELECT cc.iban AS IBAN, ROUND(AVG(amount),2) AS mitjanaVendes
FROM transaction t
JOIN credit_card cc
ON t.credit_card_id = cc.id
JOIN company c
ON t.company_id = c.id
WHERE c.company_name = "Donec Ltd"
GROUP BY cc.iban;
#Tomando en cuenta solo las ventas: transaction.declined = 0
SELECT cc.iban AS IBAN, ROUND(AVG(amount),2) AS mitjanaVendes
FROM transaction t
JOIN credit_card cc
ON t.credit_card_id = cc.id
JOIN company c
ON t.company_id = c.id
WHERE t.declined = 0 AND c.company_name = "Donec Ltd"
GROUP BY cc.iban;

-- ####### Nivell 2 #######
#Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:
-- Exercici 1
-- Quantes targetes estan actives?
#Creación de tabla auxiliar temporal: credit_card_status_declined con transaciones rechazadas: transaction.declined = 1
WITH credit_card_status_declined AS (
    SELECT ROW_NUMBER() OVER (PARTITION BY credit_card_id ORDER BY timestamp DESC) AS TransactionRow, credit_card_id, timestamp, declined
    FROM transaction 
	WHERE declined = 1
							)
#Visualizo cuantas tarjetas tienen las últimas 3 transacciones declinadas
SELECT credit_card_id AS creditCardId, transactionRow, timestamp, declined
FROM credit_card_status_declined
WHERE transactionRow <= 3
ORDER BY transactionRow ASC;

#Creación de tabla auxiliar temporal: credit_card_status_approved con transaciones aceptadas: transaction.declined = 0
WITH credit_card_status_approved AS (
    SELECT ROW_NUMBER() OVER (PARTITION BY credit_card_id ORDER BY timestamp DESC) AS TransactionRow, credit_card_id, timestamp, declined
    FROM transaction 
	WHERE declined = 0
							)
#Visualizo cuantas tarjetas están activas 
SELECT COUNT(DISTINCT credit_card_id) AS targetesActives
FROM credit_card_status_approved;

-- ####### Nivell 3 #######
#Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
-- Exercici 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT p.id AS idProducte, p.product_name AS productName, p.colour AS color, count(o.product_id) AS quantitatVenuda
FROM orders o
JOIN product p
ON o.product_id = p.id
JOIN transaction t
ON o.id = t.orders_id
WHERE t.declined = 0
GROUP BY idProducte
ORDER BY quantitatVenuda DESC;