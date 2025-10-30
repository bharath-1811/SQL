CREATE DATABASE SQL_Class


USE [SQL_Class]
GO


CREATE TABLE Tb1
(
TID int PRIMARY KEY,
F_NAME varchar(20) UNIQUE,
SALES float DEFAULT 100,
TAX decimal (10,2) CHECK (TAX>0)
)

CREATE TABLE Tb2
(
TID int,
F_NAME varchar(20),
SALES float,
TABLE_ID int foreign key references Tb1 (TID) 
)

SELECT * From [dbo].[Tb1]

SELECT * FROm [dbo].[Tb2]


INSERT INTO Tb1 (TID, F_NAME, SALES, TAX) values (1,'SQL', 4.56, '5.365' ), (2,'Python', 3.0, '5.365' )
INSERT INTO Tb2 (TID, F_NAME, SALES, TABLE_ID) values (1,'SQL', 4.56, 1)


INSERT INTO Tb1 values (50, 'SAS', 6.29, '8.29')