CREATE DATABASE Practice
GO

USE [Practice]
GO

CREATE TABLE Department_Table
(
D_ID int,
D_Name Varchar(10) PRIMARY KEY,
Block_Name Varchar (15)
)

CREATE TABLE Student_Table
(
S_ID Int PRIMARY KEY,
S_Name Varchar (20) Unique,
DOB DATE NOT NULL,
S_Dept Varchar (10) FOREIGN KEY References Department_Table (D_Name)
)


INSERT INTO [dbo].[Department_Table] (D_ID, D_Name, Block_Name) values (01, 'Pharma', 'A-Block')
INSERT INTO [dbo].[Department_Table] values (02, 'Maths', 'B-Block'), (03, 'CS', 'C-Block'), (04, 'IT', 'D-Block')
INSERT INTO [dbo].[Department_Table] values (05, 'Chemistry', 'F-Block'), (06, 'Physics', 'G-Block')

SELECT * FROM [dbo].[Department_Table]

INSERT INTO [dbo].[Student_Table] (S_ID, S_Name, DOB, S_Dept) values (001, 'BHARATH', '2001-11-18', 'Pharma'), (002, 'AMMU', '2002-05-21', 'Maths')
INSERT INTO [dbo].[Student_Table] Values (003, 'KESAVA', '2000-11-05', 'CS'), (004, 'KICHI', '1999-11-25', 'IT')

SELECT * FROM [dbo].[Student_Table]

INSERT INTO [dbo].[Student_Table] (S_ID, S_Name, DOB, S_Dept) values (005, 'BHARATHI', '2000-10-04', 'Pharma'), (006, 'KANCHANA', '1967-04-08', 'Physics')


SELECT * FROM [dbo].[Department_Table]
SELECT * FROM [dbo].[Student_Table]
SELECT * from Student_Table S Inner JOIN Department_Table D on S.S_Dept= D.D_Name


SELECT * from Department_Table cross join Student_Table  

SELECT * from Department_Table D FULL OUTER JOIN Student_Table S on D.D_ID = S.S_ID


SELECT S_Name, D_Name, Block_Name from Student_Table S inner join Department_Table D on S.S_Dept = D. D_Name

