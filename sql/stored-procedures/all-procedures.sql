-- ============================================
-- ETL Stored Procedures - All Procedures
-- ============================================

USE [RetailMedallion];
GO

-- =============================================
-- 1. Populate Date Dimension
-- =============================================
IF OBJECT_ID('ETL.uspPopulateDimDate', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspPopulateDimDate;
GO

CREATE PROCEDURE ETL.uspPopulateDimDate
    @StartDate DATE = '2020-01-01',
    @EndDate DATE = '2030-12-31'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentDate DATE = @StartDate;
    WHILE @CurrentDate <= @EndDate
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Silver.DimDate WHERE FullDate = @CurrentDate)
        BEGIN
            INSERT INTO Silver.DimDate (DateKey, FullDate, DayOfWeek, DayName, DayOfMonth, DayOfYear, WeekOfYear, MonthNumber, MonthName, Quarter, QuarterName, Year, YearMonth, YearQuarter, IsWeekend, FiscalYear, FiscalQuarter, FiscalMonth)
            SELECT
                CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')),
                @CurrentDate,
                DATEPART(WEEKDAY, @CurrentDate),
                DATENAME(WEEKDAY, @CurrentDate),
                DAY(@CurrentDate),
                DATEPART(DAYOFYEAR, @CurrentDate),
                DATEPART(WEEK, @CurrentDate),
                MONTH(@CurrentDate),
                DATENAME(MONTH, @CurrentDate),
                DATEPART(QUARTER, @CurrentDate),
                'Q' + CAST(DATEPART(QUARTER, @CurrentDate) AS VARCHAR),
                YEAR(@CurrentDate),
                FORMAT(@CurrentDate, 'yyyy-MM'),
                CAST(YEAR(@CurrentDate) AS VARCHAR) + '-Q' + CAST(DATEPART(QUARTER, @CurrentDate) AS VARCHAR),
                CASE WHEN DATEPART(WEEKDAY, @CurrentDate) IN (1, 7) THEN 1 ELSE 0 END,
                CASE WHEN MONTH(@CurrentDate) >= 7 THEN YEAR(@CurrentDate) + 1 ELSE YEAR(@CurrentDate) END,
                CASE WHEN MONTH(@CurrentDate) IN (7,8,9) THEN 1 WHEN MONTH(@CurrentDate) IN (10,11,12) THEN 2 WHEN MONTH(@CurrentDate) IN (1,2,3) THEN 3 ELSE 4 END,
                CASE WHEN MONTH(@CurrentDate) >= 7 THEN MONTH(@CurrentDate) - 6 ELSE MONTH(@CurrentDate) + 6 END;
        END
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END;
GO

-- =============================================
-- 2. Load Silver Customers
-- =============================================
IF OBJECT_ID('ETL.uspLoadSilverCustomers', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspLoadSilverCustomers;
GO

CREATE PROCEDURE ETL.uspLoadSilverCustomers AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Silver.DimCustomer (CustomerID, FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country, DateOfBirth, Gender, SourceSystem)
    SELECT SourceCustomerID, LTRIM(RTRIM(FirstName)), LTRIM(RTRIM(LastName)), LOWER(LTRIM(RTRIM(Email))), Phone, Address, City, State, ZipCode, ISNULL(Country, 'USA'), TRY_CAST(DateOfBirth AS DATE), Gender, SourceSystem
    FROM Bronze.RawCustomers rc
    WHERE NOT EXISTS (SELECT 1 FROM Silver.DimCustomer dc WHERE dc.CustomerID = rc.SourceCustomerID AND dc.IsCurrent = 1);
END;
GO

-- =============================================
-- 3. Load Silver Products
-- =============================================
IF OBJECT_ID('ETL.uspLoadSilverProducts', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspLoadSilverProducts;
GO

CREATE PROCEDURE ETL.uspLoadSilverProducts AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Silver.DimProduct (ProductID, ProductName, ProductDescription, Category, SubCategory, Brand, SKU, UPC, UnitPrice, CostPrice, Weight, SourceSystem)
    SELECT SourceProductID, LTRIM(RTRIM(ProductName)), ProductDescription, Category, SubCategory, Brand, SKU, UPC, TRY_CAST(UnitPrice AS DECIMAL(18,2)), TRY_CAST(CostPrice AS DECIMAL(18,2)), TRY_CAST(Weight AS DECIMAL(10,2)), SourceSystem
    FROM Bronze.RawProducts rp
    WHERE NOT EXISTS (SELECT 1 FROM Silver.DimProduct dp WHERE dp.ProductID = rp.SourceProductID AND dp.IsCurrent = 1);
END;
GO

-- =============================================
-- 4. Load Silver Stores
-- =============================================
IF OBJECT_ID('ETL.uspLoadSilverStores', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspLoadSilverStores;
GO

CREATE PROCEDURE ETL.uspLoadSilverStores AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Silver.DimStore (StoreID, StoreName, StoreType, Address, City, State, ZipCode, Country, Phone, ManagerName, OpenDate, SquareFootage, SourceSystem)
    SELECT SourceStoreID, LTRIM(RTRIM(StoreName)), StoreType, Address, City, State, ZipCode, ISNULL(Country, 'USA'), Phone, ManagerName, TRY_CAST(OpenDate AS DATE), TRY_CAST(SquareFootage AS INT), SourceSystem
    FROM Bronze.RawStores rs
    WHERE NOT EXISTS (SELECT 1 FROM Silver.DimStore ds WHERE ds.StoreID = rs.SourceStoreID AND ds.IsCurrent = 1);
END;
GO

-- =============================================
-- 5. Load Silver Suppliers
-- =============================================
IF OBJECT_ID('ETL.uspLoadSilverSuppliers', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspLoadSilverSuppliers;
GO

CREATE PROCEDURE ETL.uspLoadSilverSuppliers AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Silver.DimSupplier (SupplierID, SupplierName, ContactName, Email, Phone, Address, City, State, Country, PaymentTerms, SourceSystem)
    SELECT SourceSupplierID, LTRIM(RTRIM(SupplierName)), ContactName, LOWER(LTRIM(RTRIM(Email))), Phone, Address, City, State, ISNULL(Country, 'USA'), PaymentTerms, SourceSystem
    FROM Bronze.RawSuppliers rs
    WHERE NOT EXISTS (SELECT 1 FROM Silver.DimSupplier ds WHERE ds.SupplierID = rs.SourceSupplierID);
END;
GO

-- =============================================
-- 6. Load Fact Sales
-- =============================================
IF OBJECT_ID('ETL.uspLoadFactSales', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspLoadFactSales;
GO

CREATE PROCEDURE ETL.uspLoadFactSales AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Silver.FactSales (TransactionID, DateKey, CustomerKey, ProductKey, StoreKey, Quantity, UnitPrice, UnitCost, DiscountAmount, SalesAmount, CostAmount, TaxAmount, PaymentMethod, SourceSystem)
    SELECT rt.SourceTransactionID, CONVERT(INT, FORMAT(TRY_CAST(rt.TransactionDate AS DATE), 'yyyyMMdd')), dc.CustomerKey, dp.ProductKey, ds.StoreKey, TRY_CAST(ri.Quantity AS INT), TRY_CAST(ri.UnitPrice AS DECIMAL(18,2)), dp.CostPrice, ISNULL(TRY_CAST(ri.Discount AS DECIMAL(18,2)), 0), TRY_CAST(ri.LineTotal AS DECIMAL(18,2)), dp.CostPrice * TRY_CAST(ri.Quantity AS INT), TRY_CAST(rt.TaxAmount AS DECIMAL(18,2)), rt.PaymentMethod, rt.SourceSystem
    FROM Bronze.RawTransactions rt
    INNER JOIN Bronze.RawTransactionItems ri ON rt.SourceTransactionID = ri.SourceTransactionID
    LEFT JOIN Silver.DimCustomer dc ON rt.CustomerID = dc.CustomerID AND dc.IsCurrent = 1
    INNER JOIN Silver.DimProduct dp ON ri.SourceProductID = dp.ProductID AND dp.IsCurrent = 1
    INNER JOIN Silver.DimStore ds ON rt.StoreID = ds.StoreID AND ds.IsCurrent = 1
    WHERE NOT EXISTS (SELECT 1 FROM Silver.FactSales fs WHERE fs.TransactionID = rt.SourceTransactionID AND fs.ProductKey = dp.ProductKey);
END;
GO

-- =============================================
-- 7. Load Fact Inventory
-- =============================================
IF OBJECT_ID('ETL.uspLoadFactInventory', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspLoadFactInventory;
GO

CREATE PROCEDURE ETL.uspLoadFactInventory AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE Silver.FactInventory;
    INSERT INTO Silver.FactInventory (DateKey, ProductKey, StoreKey, QuantityOnHand, QuantityReserved, ReorderPoint, ReorderQuantity, DaysOfSupply, InventoryValue, SourceSystem)
    SELECT CONVERT(INT, FORMAT(GETDATE(), 'yyyyMMdd')), dp.ProductKey, ds.StoreKey, TRY_CAST(ri.QuantityOnHand AS INT), TRY_CAST(ri.QuantityReserved AS INT), TRY_CAST(ri.ReorderPoint AS INT), TRY_CAST(ri.ReorderQuantity AS INT), 30, TRY_CAST(ri.QuantityOnHand AS INT) * dp.CostPrice, ri.SourceSystem
    FROM Bronze.RawInventory ri
    INNER JOIN Silver.DimProduct dp ON ri.SourceProductID = dp.ProductID AND dp.IsCurrent = 1
    INNER JOIN Silver.DimStore ds ON ri.SourceStoreID = ds.StoreID AND ds.IsCurrent = 1;
END;
GO

-- =============================================
-- 8. Refresh Gold Daily Sales
-- =============================================
IF OBJECT_ID('ETL.uspRefreshGoldDailySales', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspRefreshGoldDailySales;
GO

CREATE PROCEDURE ETL.uspRefreshGoldDailySales AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE Gold.DailySalesSummary;
    INSERT INTO Gold.DailySalesSummary (DateKey, SalesDate, TotalTransactions, TotalQuantitySold, GrossSalesAmount, TotalDiscounts, NetSalesAmount, TotalCost, GrossProfit, GrossProfitMargin, TotalTax, AverageTransactionValue, AverageBasketSize, UniqueCustomers)
    SELECT fs.DateKey, dd.FullDate, COUNT(DISTINCT fs.TransactionID), SUM(fs.Quantity), SUM(fs.SalesAmount + fs.DiscountAmount), SUM(fs.DiscountAmount), SUM(fs.SalesAmount), SUM(fs.CostAmount), SUM(fs.SalesAmount) - SUM(fs.CostAmount), CASE WHEN SUM(fs.SalesAmount) > 0 THEN ((SUM(fs.SalesAmount) - SUM(fs.CostAmount)) / SUM(fs.SalesAmount)) * 100 ELSE 0 END, SUM(fs.TaxAmount), SUM(fs.SalesAmount) / NULLIF(COUNT(DISTINCT fs.TransactionID), 0), SUM(fs.Quantity) / NULLIF(COUNT(DISTINCT fs.TransactionID), 0), COUNT(DISTINCT fs.CustomerKey)
    FROM Silver.FactSales fs
    INNER JOIN Silver.DimDate dd ON fs.DateKey = dd.DateKey
    GROUP BY fs.DateKey, dd.FullDate;
END;
GO

-- =============================================
-- 9. Refresh Gold Customer Analytics
-- =============================================
IF OBJECT_ID('ETL.uspRefreshGoldCustomerAnalytics', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspRefreshGoldCustomerAnalytics;
GO

CREATE PROCEDURE ETL.uspRefreshGoldCustomerAnalytics AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE Gold.CustomerAnalytics;
    INSERT INTO Gold.CustomerAnalytics (CustomerKey, FirstPurchaseDate, LastPurchaseDate, DaysSinceLastPurchase, TotalOrders, TotalQuantityPurchased, TotalSpend, AverageOrderValue, AverageBasketSize, CustomerLifetimeValue)
    SELECT dc.CustomerKey, MIN(dd.FullDate), MAX(dd.FullDate), DATEDIFF(DAY, MAX(dd.FullDate), GETDATE()), COUNT(DISTINCT fs.TransactionID), SUM(fs.Quantity), SUM(fs.SalesAmount), SUM(fs.SalesAmount) / NULLIF(COUNT(DISTINCT fs.TransactionID), 0), SUM(fs.Quantity) / NULLIF(COUNT(DISTINCT fs.TransactionID), 0), SUM(fs.SalesAmount)
    FROM Silver.DimCustomer dc
    INNER JOIN Silver.FactSales fs ON dc.CustomerKey = fs.CustomerKey
    INNER JOIN Silver.DimDate dd ON fs.DateKey = dd.DateKey
    WHERE dc.IsCurrent = 1
    GROUP BY dc.CustomerKey;
END;
GO

-- =============================================
-- 10. Refresh Gold Store Performance
-- =============================================
IF OBJECT_ID('ETL.uspRefreshGoldStorePerformance', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspRefreshGoldStorePerformance;
GO

CREATE PROCEDURE ETL.uspRefreshGoldStorePerformance AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE Gold.StorePerformance;
    INSERT INTO Gold.StorePerformance (StoreKey, DateKey, PeriodType, TotalSales, TotalTransactions, TotalQuantitySold, UniqueCustomers, AverageTransactionValue, SalesPerSquareFoot, StoreRank)
    SELECT fs.StoreKey, MAX(fs.DateKey), 'Monthly', SUM(fs.SalesAmount), COUNT(DISTINCT fs.TransactionID), SUM(fs.Quantity), COUNT(DISTINCT fs.CustomerKey), SUM(fs.SalesAmount) / NULLIF(COUNT(DISTINCT fs.TransactionID), 0), SUM(fs.SalesAmount) / NULLIF(ds.SquareFootage, 0), ROW_NUMBER() OVER (ORDER BY SUM(fs.SalesAmount) DESC)
    FROM Silver.FactSales fs
    INNER JOIN Silver.DimStore ds ON fs.StoreKey = ds.StoreKey
    GROUP BY fs.StoreKey, ds.SquareFootage;
END;
GO

-- =============================================
-- 11. Refresh Gold Product Performance
-- =============================================
IF OBJECT_ID('ETL.uspRefreshGoldProductPerformance', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspRefreshGoldProductPerformance;
GO

CREATE PROCEDURE ETL.uspRefreshGoldProductPerformance AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE Gold.ProductPerformance;
    INSERT INTO Gold.ProductPerformance (ProductKey, DateKey, PeriodType, TotalQuantitySold, TotalSalesAmount, TotalCostAmount, GrossProfit, ProfitMargin, UniqueCustomers, AverageSellingPrice, ProductRank)
    SELECT fs.ProductKey, MAX(fs.DateKey), 'Monthly', SUM(fs.Quantity), SUM(fs.SalesAmount), SUM(fs.CostAmount), SUM(fs.SalesAmount) - SUM(fs.CostAmount), CASE WHEN SUM(fs.SalesAmount) > 0 THEN ((SUM(fs.SalesAmount) - SUM(fs.CostAmount)) / SUM(fs.SalesAmount)) * 100 ELSE 0 END, COUNT(DISTINCT fs.CustomerKey), SUM(fs.SalesAmount) / NULLIF(SUM(fs.Quantity), 0), ROW_NUMBER() OVER (ORDER BY SUM(fs.SalesAmount) DESC)
    FROM Silver.FactSales fs
    GROUP BY fs.ProductKey;
END;
GO

-- =============================================
-- 12. Refresh Gold Category Performance
-- =============================================
IF OBJECT_ID('ETL.uspRefreshGoldCategoryPerformance', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspRefreshGoldCategoryPerformance;
GO

CREATE PROCEDURE ETL.uspRefreshGoldCategoryPerformance AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE Gold.CategoryPerformance;
    DECLARE @TotalSales DECIMAL(18,2) = (SELECT SUM(SalesAmount) FROM Silver.FactSales);
    INSERT INTO Gold.CategoryPerformance (Category, SubCategory, DateKey, PeriodType, TotalProducts, TotalQuantitySold, TotalSalesAmount, TotalCostAmount, GrossProfit, ProfitMargin, PercentOfTotalSales, CategoryRank)
    SELECT dp.Category, dp.SubCategory, MAX(fs.DateKey), 'Monthly', COUNT(DISTINCT dp.ProductKey), SUM(fs.Quantity), SUM(fs.SalesAmount), SUM(fs.CostAmount), SUM(fs.SalesAmount) - SUM(fs.CostAmount), CASE WHEN SUM(fs.SalesAmount) > 0 THEN ((SUM(fs.SalesAmount) - SUM(fs.CostAmount)) / SUM(fs.SalesAmount)) * 100 ELSE 0 END, CASE WHEN @TotalSales > 0 THEN (SUM(fs.SalesAmount) / @TotalSales) * 100 ELSE 0 END, ROW_NUMBER() OVER (ORDER BY SUM(fs.SalesAmount) DESC)
    FROM Silver.FactSales fs
    INNER JOIN Silver.DimProduct dp ON fs.ProductKey = dp.ProductKey
    GROUP BY dp.Category, dp.SubCategory;
END;
GO

-- =============================================
-- 13. Refresh Gold Inventory Summary
-- =============================================
IF OBJECT_ID('ETL.uspRefreshGoldInventorySummary', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspRefreshGoldInventorySummary;
GO

CREATE PROCEDURE ETL.uspRefreshGoldInventorySummary AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE Gold.InventorySummary;
    INSERT INTO Gold.InventorySummary (DateKey, StoreKey, TotalSKUs, TotalUnitsOnHand, TotalInventoryValue, LowStockSKUs, OutOfStockSKUs, OverstockSKUs, DaysOfSupply)
    SELECT fi.DateKey, fi.StoreKey, COUNT(DISTINCT fi.ProductKey), SUM(fi.QuantityOnHand), SUM(fi.InventoryValue), SUM(CASE WHEN fi.QuantityOnHand <= fi.ReorderPoint AND fi.QuantityOnHand > 0 THEN 1 ELSE 0 END), SUM(CASE WHEN fi.QuantityOnHand = 0 THEN 1 ELSE 0 END), SUM(CASE WHEN fi.QuantityOnHand > fi.ReorderPoint * 3 THEN 1 ELSE 0 END), AVG(fi.DaysOfSupply)
    FROM Silver.FactInventory fi
    GROUP BY fi.DateKey, fi.StoreKey;
END;
GO

-- =============================================
-- 14. Refresh Gold Executive KPIs
-- =============================================
IF OBJECT_ID('ETL.uspRefreshGoldExecutiveKPIs', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspRefreshGoldExecutiveKPIs;
GO

CREATE PROCEDURE ETL.uspRefreshGoldExecutiveKPIs AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE Gold.ExecutiveKPIs;
    INSERT INTO Gold.ExecutiveKPIs (DateKey, PeriodType, TotalRevenue, TotalCost, GrossProfit, GrossMargin, TotalTransactions, TotalUnitsSold, AverageOrderValue, TotalCustomers, TotalStores, RevenuePerStore)
    SELECT MAX(fs.DateKey), 'All Time', SUM(fs.SalesAmount), SUM(fs.CostAmount), SUM(fs.SalesAmount) - SUM(fs.CostAmount), CASE WHEN SUM(fs.SalesAmount) > 0 THEN ((SUM(fs.SalesAmount) - SUM(fs.CostAmount)) / SUM(fs.SalesAmount)) * 100 ELSE 0 END, COUNT(DISTINCT fs.TransactionID), SUM(fs.Quantity), SUM(fs.SalesAmount) / NULLIF(COUNT(DISTINCT fs.TransactionID), 0), COUNT(DISTINCT fs.CustomerKey), COUNT(DISTINCT fs.StoreKey), SUM(fs.SalesAmount) / NULLIF(COUNT(DISTINCT fs.StoreKey), 0)
    FROM Silver.FactSales fs;
END;
GO

-- =============================================
-- 15. Run Full Pipeline
-- =============================================
IF OBJECT_ID('ETL.uspRunFullPipeline', 'P') IS NOT NULL
    DROP PROCEDURE ETL.uspRunFullPipeline;
GO

CREATE PROCEDURE ETL.uspRunFullPipeline AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Starting ETL Pipeline...'

    EXEC ETL.uspLoadSilverCustomers;
    EXEC ETL.uspLoadSilverProducts;
    EXEC ETL.uspLoadSilverStores;
    EXEC ETL.uspLoadSilverSuppliers;
    EXEC ETL.uspLoadFactSales;
    EXEC ETL.uspLoadFactInventory;
    EXEC ETL.uspRefreshGoldDailySales;
    EXEC ETL.uspRefreshGoldCustomerAnalytics;
    EXEC ETL.uspRefreshGoldStorePerformance;
    EXEC ETL.uspRefreshGoldProductPerformance;
    EXEC ETL.uspRefreshGoldCategoryPerformance;
    EXEC ETL.uspRefreshGoldInventorySummary;
    EXEC ETL.uspRefreshGoldExecutiveKPIs;

    PRINT 'ETL Pipeline completed successfully!'
END;
GO

PRINT 'All stored procedures created successfully';
