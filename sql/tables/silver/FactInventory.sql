-- ============================================
-- Silver Layer: Fact Inventory (Snapshot)
-- ============================================

IF OBJECT_ID('Silver.FactInventory', 'U') IS NOT NULL
    DROP TABLE Silver.FactInventory;
GO

CREATE TABLE Silver.FactInventory (
    InventoryKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    StoreKey INT NOT NULL,
    QuantityOnHand INT,
    QuantityReserved INT,
    QuantityAvailable AS (QuantityOnHand - QuantityReserved),
    ReorderPoint INT,
    ReorderQuantity INT,
    DaysOfSupply INT,
    IsLowStock AS CASE WHEN QuantityOnHand <= ReorderPoint THEN 1 ELSE 0 END,
    InventoryValue DECIMAL(18,2),
    SourceSystem NVARCHAR(50),
    ETLLoadDate DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_FactInventory_DateKey ON Silver.FactInventory(DateKey);
CREATE INDEX IX_FactInventory_ProductKey ON Silver.FactInventory(ProductKey);
CREATE INDEX IX_FactInventory_StoreKey ON Silver.FactInventory(StoreKey);
GO
