-- ============================================
-- Gold Layer: Daily Sales Summary
-- ============================================

IF OBJECT_ID('Gold.DailySalesSummary', 'U') IS NOT NULL
    DROP TABLE Gold.DailySalesSummary;
GO

CREATE TABLE Gold.DailySalesSummary (
    DailySalesKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    SalesDate DATE NOT NULL,
    TotalTransactions INT,
    TotalQuantitySold INT,
    GrossSalesAmount DECIMAL(18,2),
    TotalDiscounts DECIMAL(18,2),
    NetSalesAmount DECIMAL(18,2),
    TotalCost DECIMAL(18,2),
    GrossProfit DECIMAL(18,2),
    GrossProfitMargin DECIMAL(5,2),
    TotalTax DECIMAL(18,2),
    AverageTransactionValue DECIMAL(18,2),
    AverageBasketSize DECIMAL(10,2),
    UniqueCustomers INT,
    NewCustomers INT,
    ETLLoadDate DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_DailySalesSummary_DateKey ON Gold.DailySalesSummary(DateKey);
CREATE INDEX IX_DailySalesSummary_SalesDate ON Gold.DailySalesSummary(SalesDate);
GO
