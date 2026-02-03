-- ============================================
-- Silver Layer: Dim Customer (SCD Type 2)
-- ============================================

IF OBJECT_ID('Silver.DimCustomer', 'U') IS NOT NULL
    DROP TABLE Silver.DimCustomer;
GO

CREATE TABLE Silver.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    FullName AS (FirstName + ' ' + LastName),
    Email NVARCHAR(255),
    Phone NVARCHAR(50),
    Address NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(50),
    ZipCode NVARCHAR(20),
    Country NVARCHAR(100),
    DateOfBirth DATE,
    Gender NVARCHAR(20),
    CustomerSegment NVARCHAR(50),
    IsActive BIT DEFAULT 1,
    ValidFrom DATETIME2 DEFAULT GETDATE(),
    ValidTo DATETIME2,
    IsCurrent BIT DEFAULT 1,
    SourceSystem NVARCHAR(50),
    ETLLoadDate DATETIME2 DEFAULT GETDATE(),
    ETLUpdateDate DATETIME2
);
GO

CREATE INDEX IX_DimCustomer_CustomerID ON Silver.DimCustomer(CustomerID);
CREATE INDEX IX_DimCustomer_IsCurrent ON Silver.DimCustomer(IsCurrent);
GO
