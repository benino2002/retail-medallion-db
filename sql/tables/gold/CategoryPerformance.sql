-- ============================================
-- Gold Layer: Category Performance
-- ============================================

IF OBJECT_ID('Gold.CategoryPerformance', 'U') IS NOT NULL
    DROP TABLE Gold.CategoryPerformance;
GO

CREATE TABLE Gold.CategoryPerformance (
    CategoryPerformanceKey INT IDENTITY(1,1) PRIMARY KEY,
    Category NVARCHAR(100) NOT NULL,
    SubCategory NVARCHAR(100),
    DateKey INT NOT NULL,
    PeriodType NVARCHAR(20),
    TotalProducts INT,
    TotalQuantitySold INT,
    TotalSalesAmount DECIMAL(18,2),
    TotalCostAmount DECIMAL(18,2),
    GrossProfit DECIMAL(18,2),
    ProfitMargin DECIMAL(5,2),
    PercentOfTotalSales DECIMAL(5,2),
    YoYGrowth DECIMAL(10,2),
    CategoryRank INT,
    ETLLoadDate DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_CategoryPerformance_Category ON Gold.CategoryPerformance(Category);
CREATE INDEX IX_CategoryPerformance_DateKey ON Gold.CategoryPerformance(DateKey);
GO
