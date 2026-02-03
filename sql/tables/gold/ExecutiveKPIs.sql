-- ============================================
-- Gold Layer: Executive KPIs
-- ============================================

IF OBJECT_ID('Gold.ExecutiveKPIs', 'U') IS NOT NULL
    DROP TABLE Gold.ExecutiveKPIs;
GO

CREATE TABLE Gold.ExecutiveKPIs (
    KPIKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    PeriodType NVARCHAR(20),
    TotalRevenue DECIMAL(18,2),
    TotalCost DECIMAL(18,2),
    GrossProfit DECIMAL(18,2),
    GrossMargin DECIMAL(5,2),
    TotalTransactions INT,
    TotalUnitsSold INT,
    AverageOrderValue DECIMAL(18,2),
    TotalCustomers INT,
    NewCustomers INT,
    RepeatCustomers INT,
    CustomerRetentionRate DECIMAL(5,2),
    TotalStores INT,
    RevenuePerStore DECIMAL(18,2),
    RevenuePerEmployee DECIMAL(18,2),
    InventoryTurnover DECIMAL(10,2),
    YoYRevenueGrowth DECIMAL(10,2),
    YoYProfitGrowth DECIMAL(10,2),
    ETLLoadDate DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_ExecutiveKPIs_DateKey ON Gold.ExecutiveKPIs(DateKey);
GO
