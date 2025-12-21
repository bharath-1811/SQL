# CLINICAL TRIAL ENROLLMENT TRACKER

CREATE TABLE dbo.study_sites (
    site_id     INT IDENTITY(1,1) PRIMARY KEY,
    site_name   VARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE dbo.patients (
    patient_id  VARCHAR(20)  NOT NULL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    age         INT          NOT NULL CHECK (age BETWEEN 18 AND 65),
    gender      CHAR(1)      NOT NULL CHECK (gender IN ('M','F')),
    site_id     INT          NULL FOREIGN KEY REFERENCES dbo.study_sites(site_id),
    created_at  DATETIME2    NOT NULL DEFAULT SYSUTCDATETIME()
);
GO


INSERT INTO dbo.study_sites (site_name) VALUES
('Chennai'),
('Bangalore'),
('Hyderabad'),
('Mumbai');
GO


CREATE FUNCTION dbo.validate_age (@age INT)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT;
    IF @age BETWEEN 18 AND 65
        SET @result = 1;
    ELSE
        SET @result = 0;
    RETURN @result;
END;
GO

CREATE PROCEDURE dbo.add_patient
    @pid     VARCHAR(20),
    @pname   VARCHAR(100),
    @page    INT,
    @pgender CHAR(1),
    @psite   VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sid INT;

    IF dbo.validate_age(@page) = 0
    BEGIN
        RAISERROR('Invalid age %d (must be between 18 and 65).', 16, 1, @page);
        RETURN;
    END;

    -- Ensure site exists or create it
    SELECT @sid = site_id
    FROM dbo.study_sites
    WHERE site_name = @psite;

    IF @sid IS NULL
    BEGIN
        INSERT INTO dbo.study_sites (site_name)
        VALUES (@psite);

        SET @sid = SCOPE_IDENTITY();
    END;

    INSERT INTO dbo.patients (patient_id, name, age, gender, site_id)
    VALUES (@pid, @pname, @page, @pgender, @sid);
END;
GO


CREATE PROCEDURE dbo.delete_patient
    @pid VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.patients
    WHERE patient_id = @pid;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No patient found with ID %s.', 10, 1, @pid);
        RETURN;
    END;
END;
GO


CREATE VIEW dbo.vw_patient_list
AS
SELECT
    p.patient_id,
    p.name,
    p.age,
    p.gender,
    s.site_name AS site,
    p.created_at
FROM dbo.patients AS p
LEFT JOIN dbo.study_sites AS s
    ON p.site_id = s.site_id;
GO


CREATE TRIGGER dbo.trg_age_check
ON dbo.patients
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE age NOT BETWEEN 18 AND 65
    )
    BEGIN
        RAISERROR('Age must be between 18 and 65 for all patients.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO



EXEC dbo.add_patient @pid = 'P001', @pname = 'Rahul', @page = 34, @pgender = 'M', @psite = 'Chennai';
EXEC dbo.add_patient @pid = 'P002', @pname = 'Priya', @page = 29, @pgender = 'F', @psite = 'Bangalore';
EXEC dbo.add_patient @pid = 'P003', @pname = 'Vikas', @page = 40, @pgender = 'M', @psite = 'Hyderabad';
GO


SELECT *
FROM dbo.vw_patient_list
ORDER BY created_at;



SELECT *
FROM stats;
