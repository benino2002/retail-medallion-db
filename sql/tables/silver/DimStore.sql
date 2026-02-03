-- ============================================
-- Silver Layer: Dim Store (SCD Type 2)
-- ============================================

IF OBJECT_ID('Silver.DimStore', 'U') IS NOT NULL
    DROP TABLE Silver.DimStore;
GO

CREATE TABLE Silver.DimStore (
    StoreKey INT IDENTITY(1,1) PRIMARY KEY,
    StoreID NVARCHAR(50) NOT NULL,
    StoreName NVARCHAR(255) NOT NULL,
    StoreType NVARCHAR(50),
    Address NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(50),
    ZipCode NVARCHAR(20),
    Country NVARCHAR(100),
    Region NVARCHAR(100),
    Phone NVARCHAR(50),
    ManagerName NVARCHAR(200),
    OpenDate DATE,
    SquareFootage INT,
    IsActive BIT DEFAULT 1,
    ValidFrom DATETIME2 DEFAULT GETDATE(),
    ValidTo DATETIME2,
    IsCurrent BIT DEFAULT 1,
    SourceSystem NVARCHAR(50),
    ETLLoadDate DATETIME2 DEFAULT GETDATE(),
    ETLUpdateDate DATETIME2
);
GO

CREATE INDEX IX_DimStore_StoreID ON Silver.DimStore(StoreID);
CREATE INDEX IX_DimStore_IsCurrent ON Silver.DimStore(IsCurrent);
GO
