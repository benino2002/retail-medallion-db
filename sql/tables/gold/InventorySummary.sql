-- ============================================
-- Gold Layer: Inventory Summary
-- ============================================

IF OBJECT_ID('Gold.InventorySummary', 'U') IS NOT NULL
    DROP TABLE Gold.InventorySummary;
GO

CREATE TABLE Gold.InventorySummary (
    InventorySummaryKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    StoreKey INT,
    TotalSKUs INT,
    TotalUnitsOnHand INT,
    TotalInventoryValue DECIMAL(18,2),
    LowStockSKUs INT,
    OutOfStockSKUs INT,
    OverstockSKUs INT,
    InventoryTurnover DECIMAL(10,2),
    DaysOfSupply DECIMAL(10,2),
    StockoutRate DECIMAL(5,2),
    ETLLoadDate DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_InventorySummary_DateKey ON Gold.InventorySummary(DateKey);
CREATE INDEX IX_InventorySummary_StoreKey ON Gold.InventorySummary(StoreKey);
GO
