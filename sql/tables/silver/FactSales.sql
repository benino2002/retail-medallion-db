-- ============================================
-- Silver Layer: Fact Sales
-- ============================================

IF OBJECT_ID('Silver.FactSales', 'U') IS NOT NULL
    DROP TABLE Silver.FactSales;
GO

CREATE TABLE Silver.FactSales (
    SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    TransactionID NVARCHAR(50) NOT NULL,
    DateKey INT NOT NULL,
    TimeKey INT,
    CustomerKey INT,
    ProductKey INT NOT NULL,
    StoreKey INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2),
    UnitCost DECIMAL(18,2),
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    SalesAmount DECIMAL(18,2),
    CostAmount DECIMAL(18,2),
    ProfitAmount AS (SalesAmount - CostAmount),
    TaxAmount DECIMAL(18,2) DEFAULT 0,
    PaymentMethod NVARCHAR(50),
    SourceSystem NVARCHAR(50),
    ETLLoadDate DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_FactSales_DateKey ON Silver.FactSales(DateKey);
CREATE INDEX IX_FactSales_CustomerKey ON Silver.FactSales(CustomerKey);
CREATE INDEX IX_FactSales_ProductKey ON Silver.FactSales(ProductKey);
CREATE INDEX IX_FactSales_StoreKey ON Silver.FactSales(StoreKey);
CREATE INDEX IX_FactSales_TransactionID ON Silver.FactSales(TransactionID);
GO
