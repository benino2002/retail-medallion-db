-- ============================================
-- Bronze Layer: Raw Stores
-- ============================================

IF OBJECT_ID('Bronze.RawStores', 'U') IS NOT NULL
    DROP TABLE Bronze.RawStores;
GO

CREATE TABLE Bronze.RawStores (
    RawStoreID INT IDENTITY(1,1) PRIMARY KEY,
    SourceStoreID NVARCHAR(50),
    StoreName NVARCHAR(255),
    StoreType NVARCHAR(50),
    Address NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(50),
    ZipCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    ManagerName NVARCHAR(200),
    OpenDate NVARCHAR(50),
    SquareFootage NVARCHAR(50),
    SourceSystem NVARCHAR(50),
    LoadDateTime DATETIME2 DEFAULT GETDATE(),
    RawPayload NVARCHAR(MAX)
);
GO
