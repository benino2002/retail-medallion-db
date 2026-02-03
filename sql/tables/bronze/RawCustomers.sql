-- ============================================
-- Bronze Layer: Raw Customers
-- ============================================

IF OBJECT_ID('Bronze.RawCustomers', 'U') IS NOT NULL
    DROP TABLE Bronze.RawCustomers;
GO

CREATE TABLE Bronze.RawCustomers (
    RawCustomerID INT IDENTITY(1,1) PRIMARY KEY,
    SourceCustomerID NVARCHAR(50),
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(255),
    Phone NVARCHAR(50),
    Address NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(50),
    ZipCode NVARCHAR(20),
    Country NVARCHAR(100),
    DateOfBirth NVARCHAR(50),
    Gender NVARCHAR(20),
    SourceSystem NVARCHAR(50),
    LoadDateTime DATETIME2 DEFAULT GETDATE(),
    RawPayload NVARCHAR(MAX)
);
GO
