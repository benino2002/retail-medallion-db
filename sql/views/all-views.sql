-- ============================================
-- Views - All Views
-- ============================================

USE [RetailMedallion];
GO

-- =============================================
-- Silver Layer Views
-- =============================================

-- View: Current Products
IF OBJECT_ID('Silver.vwCurrentProducts', 'V') IS NOT NULL
    DROP VIEW Silver.vwCurrentProducts;
GO

CREATE VIEW Silver.vwCurrentProducts AS
SELECT
    ProductKey,
    ProductID,
    ProductName,
    Category,
    SubCategory,
    Brand,
    SKU,
    UnitPrice,
    CostPrice,
    ProfitMargin,
    CASE WHEN UnitPrice > 0 THEN (ProfitMargin / UnitPrice) * 100 ELSE 0 END AS ProfitMarginPercent
FROM Silver.DimProduct
WHERE IsCurrent = 1 AND IsActive = 1;
GO

-- View: Current Customers
IF OBJECT_ID('Silver.vwCurrentCustomers', 'V') IS NOT NULL
    DROP VIEW Silver.vwCurrentCustomers;
GO

CREATE VIEW Silver.vwCurrentCustomers AS
SELECT
    CustomerKey,
    CustomerID,
    FullName,
    Email,
    City,
    State,
    Country,
    CustomerSegment
FROM Silver.DimCustomer
WHERE IsCurrent = 1 AND IsActive = 1;
GO

-- View: Sales Detail (Denormalized)
IF OBJECT_ID('Silver.vwSalesDetail', 'V') IS NOT NULL
    DROP VIEW Silver.vwSalesDetail;
GO

CREATE VIEW Silver.vwSalesDetail AS
SELECT
    fs.SalesKey,
    fs.TransactionID,
    dd.FullDate AS SalesDate,
    dd.DayName,
    dd.MonthName,
    dd.Year,
    dd.Quarter,
    dc.FullName AS CustomerName,
    dc.City AS CustomerCity,
    dc.State AS CustomerState,
    dp.ProductName,
    dp.Category,
    dp.SubCategory,
    dp.Brand,
    ds.StoreName,
    ds.City AS StoreCity,
    ds.State AS StoreState,
    fs.Quantity,
    fs.UnitPrice,
    fs.DiscountAmount,
    fs.SalesAmount,
    fs.CostAmount,
    fs.ProfitAmount,
    fs.PaymentMethod
FROM Silver.FactSales fs
INNER JOIN Silver.DimDate dd ON fs.DateKey = dd.DateKey
LEFT JOIN Silver.DimCustomer dc ON fs.CustomerKey = dc.CustomerKey
INNER JOIN Silver.DimProduct dp ON fs.ProductKey = dp.ProductKey
INNER JOIN Silver.DimStore ds ON fs.StoreKey = ds.StoreKey;
GO

-- =============================================
-- Gold Layer Views
-- =============================================

-- View: Top Selling Products
IF OBJECT_ID('Gold.vwTopSellingProducts', 'V') IS NOT NULL
    DROP VIEW Gold.vwTopSellingProducts;
GO

CREATE VIEW Gold.vwTopSellingProducts AS
SELECT TOP 100
    dp.ProductKey,
    dp.ProductName,
    dp.Category,
    dp.SubCategory,
    dp.Brand,
    SUM(fs.Quantity) AS TotalQuantitySold,
    SUM(fs.SalesAmount) AS TotalRevenue,
    SUM(fs.ProfitAmount) AS TotalProfit,
    COUNT(DISTINCT fs.TransactionID) AS NumberOfTransactions
FROM Silver.FactSales fs
INNER JOIN Silver.DimProduct dp ON fs.ProductKey = dp.ProductKey
GROUP BY dp.ProductKey, dp.ProductName, dp.Category, dp.SubCategory, dp.Brand
ORDER BY TotalRevenue DESC;
GO

-- View: Store Sales Summary
IF OBJECT_ID('Gold.vwStoreSalesSummary', 'V') IS NOT NULL
    DROP VIEW Gold.vwStoreSalesSummary;
GO

CREATE VIEW Gold.vwStoreSalesSummary AS
SELECT
    ds.StoreKey,
    ds.StoreName,
    ds.City,
    ds.State,
    ds.StoreType,
    ds.SquareFootage,
    COUNT(DISTINCT fs.TransactionID) AS TotalTransactions,
    SUM(fs.Quantity) AS TotalUnitsSold,
    SUM(fs.SalesAmount) AS TotalRevenue,
    SUM(fs.ProfitAmount) AS TotalProfit,
    COUNT(DISTINCT fs.CustomerKey) AS UniqueCustomers,
    CASE WHEN ds.SquareFootage > 0 THEN SUM(fs.SalesAmount) / ds.SquareFootage ELSE 0 END AS RevenuePerSqFt
FROM Silver.DimStore ds
LEFT JOIN Silver.FactSales fs ON ds.StoreKey = fs.StoreKey
WHERE ds.IsCurrent = 1
GROUP BY ds.StoreKey, ds.StoreName, ds.City, ds.State, ds.StoreType, ds.SquareFootage;
GO

-- View: Monthly Sales Trend
IF OBJECT_ID('Gold.vwMonthlySalesTrend', 'V') IS NOT NULL
    DROP VIEW Gold.vwMonthlySalesTrend;
GO

CREATE VIEW Gold.vwMonthlySalesTrend AS
SELECT
    dd.Year,
    dd.MonthNumber,
    dd.MonthName,
    dd.YearMonth,
    COUNT(DISTINCT fs.TransactionID) AS TotalTransactions,
    SUM(fs.Quantity) AS TotalUnitsSold,
    SUM(fs.SalesAmount) AS TotalRevenue,
    SUM(fs.ProfitAmount) AS TotalProfit,
    SUM(fs.SalesAmount) / NULLIF(COUNT(DISTINCT fs.TransactionID), 0) AS AvgTransactionValue
FROM Silver.FactSales fs
INNER JOIN Silver.DimDate dd ON fs.DateKey = dd.DateKey
GROUP BY dd.Year, dd.MonthNumber, dd.MonthName, dd.YearMonth;
GO

-- View: Customer Purchase Summary
IF OBJECT_ID('Gold.vwCustomerPurchaseSummary', 'V') IS NOT NULL
    DROP VIEW Gold.vwCustomerPurchaseSummary;
GO

CREATE VIEW Gold.vwCustomerPurchaseSummary AS
SELECT
    dc.CustomerKey,
    dc.CustomerID,
    dc.FullName,
    dc.Email,
    dc.City,
    dc.State,
    MIN(dd.FullDate) AS FirstPurchase,
    MAX(dd.FullDate) AS LastPurchase,
    DATEDIFF(DAY, MAX(dd.FullDate), GETDATE()) AS DaysSinceLastPurchase,
    COUNT(DISTINCT fs.TransactionID) AS TotalOrders,
    SUM(fs.Quantity) AS TotalItemsPurchased,
    SUM(fs.SalesAmount) AS TotalSpend,
    SUM(fs.SalesAmount) / NULLIF(COUNT(DISTINCT fs.TransactionID), 0) AS AvgOrderValue
FROM Silver.DimCustomer dc
INNER JOIN Silver.FactSales fs ON dc.CustomerKey = fs.CustomerKey
INNER JOIN Silver.DimDate dd ON fs.DateKey = dd.DateKey
WHERE dc.IsCurrent = 1
GROUP BY dc.CustomerKey, dc.CustomerID, dc.FullName, dc.Email, dc.City, dc.State;
GO

PRINT 'All views created successfully';
