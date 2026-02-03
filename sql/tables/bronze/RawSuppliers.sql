-- ============================================
-- Bronze Layer: Raw Suppliers
-- ============================================

IF OBJECT_ID('Bronze.RawSuppliers', 'U') IS NOT NULL
    DROP TABLE Bronze.RawSuppliers;
GO

CREATE TABLE Bronze.RawSuppliers (
    RawSupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SourceSupplierID NVARCHAR(50),
    SupplierName NVARCHAR(255),
    ContactName NVARCHAR(200),
    Email NVARCHAR(255),
    Phone NVARCHAR(50),
    Address NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(50),
    Country NVARCHAR(100),
    PaymentTerms NVARCHAR(100),
    SourceSystem NVARCHAR(50),
    LoadDateTime DATETIME2 DEFAULT GETDATE(),
    RawPayload NVARCHAR(MAX)
);
GO
