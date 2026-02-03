-- ============================================
-- Gold Layer: Product Performance
-- ============================================

IF OBJECT_ID('Gold.ProductPerformance', 'U') IS NOT NULL
    DROP TABLE Gold.ProductPerformance;
GO

CREATE TABLE Gold.ProductPerformance (
    ProductPerformanceKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductKey INT NOT NULL,
    DateKey INT NOT NULL,
    PeriodType NVARCHAR(20),
    TotalQuantitySold INT,
    TotalSalesAmount DECIMAL(18,2),
    TotalCostAmount DECIMAL(18,2),
    GrossProfit DECIMAL(18,2),
    ProfitMargin DECIMAL(5,2),
    UniqueCustomers INT,
    AverageSellingPrice DECIMAL(18,2),
    ProductRank INT,
    CategoryRank INT,
    ETLLoadDate DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_ProductPerformance_ProductKey ON Gold.ProductPerformance(ProductKey);
CREATE INDEX IX_ProductPerformance_DateKey ON Gold.ProductPerformance(DateKey);
GO
