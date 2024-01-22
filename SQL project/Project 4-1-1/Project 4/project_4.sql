create database test_cricket;

select * from batting_figures;

#1.	Import the csv file to a table in the database.

#2.	Remove the column 'Player Profile' from the table.
ALTER TABLE batting_figures DROP COLUMN player_profile ;

#3.	Extract the country name and player names from the given data and store it in separate columns for further usage.
-- Assuming 'Player' is in the format "PlayerName (Country)"

ALTER TABLE batting_figures
ADD COLUMN Country VARCHAR(255),
ADD COLUMN PlayerName VARCHAR(255);

UPDATE batting_figures
SET PlayerName = SUBSTRING_INDEX(Player, '(', 1),
Country = TRIM(TRAILING ')' FROM SUBSTRING_INDEX(Player, '(', -1));



#4.	From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.
ALTER TABLE batting_figures
ADD COLUMN StartYear int,
ADD COLUMN EndYear int;
-- Assuming 'Span' is in the format "start_year - end_year"

UPDATE batting_figures
SET StartYear = SUBSTRING_INDEX(Span, '-', 1) ,
EndYear = SUBSTRING_INDEX(Span, '-', -1);

#5.	The column 'HS' has the highest score scored by the player so far in any given match.
 #The column also has details if the player had completed the match in a NOT OUT status. 
 #Extract the data and store the highest runs and the NOT OUT status in different columns.
ALTER TABLE batting_figures
ADD COLUMN HighestRuns INT,
ADD COLUMN NotOutStatus INT;

-- Assuming 'HS' is in the format "highest_runs* (NOT OUT)"
UPDATE batting_figures
SET HighestRuns = SUBSTRING_INDEX(HS, '*', 1) ,
NotOutStatus = SUBSTRING_INDEX(NO, '*', 1);


#6.	Using the data given, considering the players who were active in the year of 2019,
 #create a set of batting order of best 6 players using the selection criteria of those 
 #who have a good average score across all matches for India.

CREATE VIEW Batting_Order AS
SELECT PlayerName, Country, AVG(runs) AS AvgScore
FROM batting_figures
WHERE Country = 'India' AND EndYear >= 2019
GROUP BY PlayerName, Country
ORDER BY AvgScore DESC LIMIT 6;


#7.	Using the data given, considering the players who were active in the year of 2019,
 #create a set of batting order of best 6 players using the selection criteria of 
 #those who have the highest number of 100s across all matches for India.

SELECT PlayerName,max(century) centuries,avg
FROM batting_figures
WHERE Country = 'India' AND StartYear <= 2019 AND EndYear >= 2019
group by PlayerName,avg
order by centuries desc ;

#using 2 selection criteria of your own for India
#8.	Using the data given, considering the players who were active in the year of 2019, 
#create a set of batting order of best 6 players using 2 selection criteria of your own for India
#Player with the highest Avg in 2019.
#Player with the third-most centuries (100s) in 2019.

WITH ActivePlayers AS 
(SELECT Playername,Avg,century,
ROW_NUMBER() OVER (ORDER BY Avg DESC) AS AvgRank,
ROW_NUMBER() OVER (ORDER BY century DESC) AS CenturiesRank
FROM batting_figures
WHERE StartYear <= 2019 AND EndYear >= 2019
AND Country = 'India')
SELECT Playername,Avg,Century
FROM ActivePlayers
WHERE avgrank = 1    -- Player with the highest Avg in 2019
OR centuriesrank = 3 -- Player with the third-most centuries (100s) in 2019
ORDER BY avgrank,centuriesrank
limit 6;

#9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, 
#considering the players who were active in the year of 2019,
 #create a set of batting order of best 6 players using the selection criteria 
 #of those who have a good average score across all matches for South Africa.

CREATE VIEW Batting_Order_GoodAvgScorers_SA AS
SELECT PlayerName, Avg AS AverageScore
FROM batting_figures
WHERE Country = 'South Africa' AND StartYear <= 2019 AND EndYear >= 2019
ORDER BY AverageScore DESC LIMIT 6;

#10.Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given,
 #considering the players who were active in the year of 2019, create a set of 
 #batting order of best 6 players using the selection criteria of those who have highest 
 #number of 100s across all matches for South Africa.

CREATE VIEW Batting_Order_HighestCenturyScorers_SA AS
SELECT PlayerName, 100 AS Centuries
FROM batting_figures
WHERE Country = 'South Africa' AND StartYear <= 2019 AND EndYear >= 2019
ORDER BY Centuries DESC LIMIT 6;

#11.Using the data given, Give the number of player_played for each country.

SELECT Country, COUNT(DISTINCT PlayerName) AS NumberOfPlayers
FROM batting_figures GROUP BY Country;

#12.Using the data given, Give the number of player_played for Asian and Non-Asian continent

SELECT
CASE
WHEN Country IN ('India', 'Pakistan', 'Bangladesh', 'Sri Lanka', 'Afghanistan') THEN 'Asian'
ELSE 'Non-Asian'
END AS Continent,
COUNT(DISTINCT PlayerName) AS NumberOfPlayers
FROM batting_figures
GROUP BY Continent;


----------------------------------------------------------------------------------------------------------------------------
#1.	Company sells the product at different discounted rates. 
#Refer actual product price in product table and selling price in the order item table.
#Write a query to find out total amount saved in each order then display the orders from highest to lowest amount saved. 

SELECT o.Id AS OrderId,c.firstname,SUM((p.UnitPrice - oi.UnitPrice) * oi.Quantity) AS AmountSaved
FROM Orders o
JOIN OrderItem oi ON o.Id = oi.OrderId
JOIN Product p ON oi.ProductId = p.Id
join customer c on c.id=o.id
GROUP BY o.Id ORDER BY AmountSaved desc;


#2.	Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick:  
#a. List few products that he should choose based on demand.
#b. Who will be the competitors for him for the products suggested in above questions.

#3.	Create a combined list to display customers and suppliers details considering the following criteria 
#●	Both customer and supplier belong to the same country
#●	Customer who does not have supplier in their country
#●	Supplier who does not have customer in their country

SELECT C.FirstName AS CustomerFirstName,C.LastName AS CustomerLastName,C.Country AS CustomerCountry,
S.CompanyName AS SupplierCompanyName,S.Country AS SupplierCountry
FROM Customer C
join Supplier S ON C.country=s.country
WHERE C.Country IS NOT NULL OR S.Country IS NOT NULL;

#4.	Every supplier supplies specific products to the customers. 
#Create a view of suppliers and total sales made by their products and write 
#a query on this view to find out top 2 suppliers (using windows function) in each country by total sales done by the products.
CREATE VIEW SupplierSales AS
SELECT S.Id AS SupplierId,S.CompanyName AS SupplierName,s.country as suppliercountry,P.ProductName,
SUM(OI.UnitPrice * OI.Quantity) AS TotalSales
FROM Supplier S
JOIN Product P ON S.Id = P.SupplierId
JOIN OrderItem OI ON P.Id = OI.ProductId
GROUP BY S.Id, S.CompanyName, P.ProductName;


SELECT SupplierId, SupplierName, ProductName,suppliercountry, TotalSales
FROM (SELECT *,ROW_NUMBER() OVER (PARTITION BY SupplierCountry ORDER BY TotalSales DESC) 
AS RowNum FROM SupplierSales) RankedSuppliers
WHERE RowNum <= 2;


#5.	Find out for which products, UK is dependent on other countries for the supply. 
#List the countries which are supplying these products in the same list.

SELECT DISTINCT P.ProductName, S.Country AS SupplierCountry
FROM Product P
JOIN Supplier S ON P.SupplierId = S.Id
WHERE P.ProductName NOT IN
(SELECT DISTINCT P2.ProductName FROM Product P2 JOIN Supplier S2 ON P2.SupplierId = S2.Id
WHERE S2.Country = 'UK') AND S.Country <> 'UK';

#6.	Create two tables as ‘customer’ and ‘customer_backup’ as follow - 
#‘customer’ table attributes -
#Id, FirstName,LastName,Phone
#‘customer_backup’ table attributes - 
#Id, FirstName,LastName,Phone

-- Create the 'customer' table

CREATE TABLE customer (
   Id INT PRIMARY KEY,
   FirstName VARCHAR(50) NOT NULL,
   LastName VARCHAR(50) NOT NULL,
   Phone VARCHAR(20)
);

-- Create the 'customer_backup' table
CREATE TABLE customer_backup (
   Id INT PRIMARY KEY,
   FirstName VARCHAR(50) NOT NULL,
   LastName VARCHAR(50) NOT NULL,
   Phone VARCHAR(20)
);










