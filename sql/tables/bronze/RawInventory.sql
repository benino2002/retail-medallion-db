-- ============================================
-- Bronze Layer: Raw Inventory
-- ============================================

IF OBJECT_ID('Bronze.RawInventory', 'U') IS NOT NULL
    DROP TABLE Bronze.RawInventory;
GO

CREATE TABLE Bronze.RawInventory (
    RawInventoryID INT IDENTITY(1,1) PRIMARY KEY,
    SourceStoreID NVARCHAR(50),
    SourceProductID NVARCHAR(50),
    QuantityOnHand NVARCHAR(50),
    QuantityReserved NVARCHAR(50),
    ReorderPoint NVARCHAR(50),
    ReorderQuantity NVARCHAR(50),
    LastRestockDate NVARCHAR(50),
    SourceSystem NVARCHAR(50),
    LoadDateTime DATETIME2 DEFAULT GETDATE(),
    RawPayload NVARCHAR(MAX)
);
GO
