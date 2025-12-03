/* ========================================================================
   CLINICAL TRIAL ENROLLMENT TRACKER (SQL PROJECT) - SQL SERVER VERSION
   
   ======================================================================== */

-- ------------------------------------------------------------------------
-- 1. CREATE TABLES
-- ------------------------------------------------------------------------

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


-- ------------------------------------------------------------------------
-- 2. SEED SAMPLE STUDY SITES
-- ------------------------------------------------------------------------

INSERT INTO dbo.study_sites (site_name) VALUES
('Chennai'),
('Bangalore'),
('Hyderabad'),
('Mumbai');
GO


-- ------------------------------------------------------------------------
-- 3. FUNCTIONS
-- ------------------------------------------------------------------------
-- Validate age function (returns BIT: 1 = valid, 0 = invalid)

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


-- ------------------------------------------------------------------------
-- 4. STORED PROCEDURES
-- ------------------------------------------------------------------------

-- Add new patient (similar to Python add_patient())
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

    -- Validate age using function
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

    -- Insert patient
    INSERT INTO dbo.patients (patient_id, name, age, gender, site_id)
    VALUES (@pid, @pname, @page, @pgender, @sid);
END;
GO


-- Delete patient (similar to Python delete_patient())
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


-- ------------------------------------------------------------------------
-- 5. VIEW: PATIENT LIST 
-- ------------------------------------------------------------------------

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


-- ------------------------------------------------------------------------
-- 6. CTE EXAMPLES
-- ------------------------------------------------------------------------

/*
-- 6.1 Search patient by ID using a CTE
WITH search_cte AS (
    SELECT 
        p.patient_id,
        p.name,
        p.age,
        p.gender,
        s.site_name
    FROM dbo.patients AS p
    JOIN dbo.study_sites AS s
        ON p.site_id = s.site_id
)
SELECT *
FROM search_cte
WHERE patient_id = 'P001';
*/


/*
-- 6.2 Summary report (total, males, females) using CTE
WITH stats AS (
    SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS males,
        SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS females
    FROM dbo.patients
)
SELECT *
FROM stats;
*/


/*
-- 6.3 Site-wise distribution using CTE
WITH site_cte AS (
    SELECT 
        s.site_name,
        COUNT(p.patient_id) AS [count]
    FROM dbo.study_sites AS s
    LEFT JOIN dbo.patients AS p
        ON s.site_id = p.site_id
    GROUP BY s.site_name
)
SELECT *
FROM site_cte
ORDER BY [count] DESC;
*/


-- ------------------------------------------------------------------------
-- 7. RECURSIVE CTE
-- ------------------------------------------------------------------------

/*
WITH site_counts AS (
    SELECT 
        s.site_name,
        COUNT(p.patient_id) AS enrollments
    FROM dbo.study_sites AS s
    LEFT JOIN dbo.patients AS p
        ON s.site_id = p.site_id
    GROUP BY s.site_name
),
ordered AS (
    SELECT
        site_name,
        enrollments,
        ROW_NUMBER() OVER (ORDER BY enrollments DESC) AS [rank]
    FROM site_counts
),
recursive_rank AS (
    -- Anchor
    SELECT 
        site_name,
        enrollments,
        [rank]
    FROM ordered
    WHERE [rank] = 1

    UNION ALL

    -- Recursive part
    SELECT 
        o.site_name,
        o.enrollments,
        o.[rank]
    FROM ordered AS o
    JOIN recursive_rank AS r
        ON o.[rank] = r.[rank] + 1
)
SELECT *
FROM recursive_rank
ORDER BY [rank];
*/


-- ------------------------------------------------------------------------
-- 8. TRIGGER: EXTRA AGE ENFORCEMENT
-- ------------------------------------------------------------------------

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


-- ------------------------------------------------------------------------
-- 9. SAMPLE DATA INSERTS 
-- ------------------------------------------------------------------------

EXEC dbo.add_patient @pid = 'P001', @pname = 'Rahul', @page = 34, @pgender = 'M', @psite = 'Chennai';
EXEC dbo.add_patient @pid = 'P002', @pname = 'Priya', @page = 29, @pgender = 'F', @psite = 'Bangalore';
EXEC dbo.add_patient @pid = 'P003', @pname = 'Vikas', @page = 40, @pgender = 'M', @psite = 'Hyderabad';
GO


-- ------------------------------------------------------------------------
-- 10. SAMPLE QUERIES
-- ------------------------------------------------------------------------

-- 10.1 View all patients
SELECT *
FROM dbo.vw_patient_list
ORDER BY created_at;


-- 10.2 Delete a patient
-- EXEC dbo.delete_patient @pid = 'P001';


-- 10.3 Summary stats example
/*
WITH stats AS (
    SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS males,
        SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS females
    FROM dbo.patients
)
SELECT *
FROM stats;
*/
