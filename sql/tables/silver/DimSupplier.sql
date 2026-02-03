-- ============================================
-- Silver Layer: Dim Supplier
-- ============================================

IF OBJECT_ID('Silver.DimSupplier', 'U') IS NOT NULL
    DROP TABLE Silver.DimSupplier;
GO

CREATE TABLE Silver.DimSupplier (
    SupplierKey INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID NVARCHAR(50) NOT NULL,
    SupplierName NVARCHAR(255) NOT NULL,
    ContactName NVARCHAR(200),
    Email NVARCHAR(255),
    Phone NVARCHAR(50),
    Address NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(50),
    Country NVARCHAR(100),
    PaymentTerms NVARCHAR(100),
    IsActive BIT DEFAULT 1,
    SourceSystem NVARCHAR(50),
    ETLLoadDate DATETIME2 DEFAULT GETDATE(),
    ETLUpdateDate DATETIME2
);
GO

CREATE INDEX IX_DimSupplier_SupplierID ON Silver.DimSupplier(SupplierID);
GO
