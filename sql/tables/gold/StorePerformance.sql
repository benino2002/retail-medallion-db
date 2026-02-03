-- ============================================
-- Gold Layer: Store Performance
-- ============================================

IF OBJECT_ID('Gold.StorePerformance', 'U') IS NOT NULL
    DROP TABLE Gold.StorePerformance;
GO

CREATE TABLE Gold.StorePerformance (
    StorePerformanceKey INT IDENTITY(1,1) PRIMARY KEY,
    StoreKey INT NOT NULL,
    DateKey INT NOT NULL,
    PeriodType NVARCHAR(20),
    TotalSales DECIMAL(18,2),
    TotalTransactions INT,
    TotalQuantitySold INT,
    UniqueCustomers INT,
    AverageTransactionValue DECIMAL(18,2),
    SalesPerSquareFoot DECIMAL(18,2),
    YoYGrowth DECIMAL(10,2),
    MoMGrowth DECIMAL(10,2),
    StoreRank INT,
    ETLLoadDate DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_StorePerformance_StoreKey ON Gold.StorePerformance(StoreKey);
CREATE INDEX IX_StorePerformance_DateKey ON Gold.StorePerformance(DateKey);
GO
