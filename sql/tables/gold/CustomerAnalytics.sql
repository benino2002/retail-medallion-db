-- ============================================
-- Gold Layer: Customer Analytics
-- ============================================

IF OBJECT_ID('Gold.CustomerAnalytics', 'U') IS NOT NULL
    DROP TABLE Gold.CustomerAnalytics;
GO

CREATE TABLE Gold.CustomerAnalytics (
    CustomerAnalyticsKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerKey INT NOT NULL,
    FirstPurchaseDate DATE,
    LastPurchaseDate DATE,
    DaysSinceLastPurchase INT,
    TotalOrders INT,
    TotalQuantityPurchased INT,
    TotalSpend DECIMAL(18,2),
    AverageOrderValue DECIMAL(18,2),
    AverageBasketSize DECIMAL(10,2),
    PreferredStore INT,
    PreferredCategory NVARCHAR(100),
    PreferredPaymentMethod NVARCHAR(50),
    CustomerLifetimeValue DECIMAL(18,2),
    RFMScore NVARCHAR(10),
    RecencyScore INT,
    FrequencyScore INT,
    MonetaryScore INT,
    CustomerSegment NVARCHAR(50),
    ChurnRisk NVARCHAR(20),
    ETLLoadDate DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_CustomerAnalytics_CustomerKey ON Gold.CustomerAnalytics(CustomerKey);
GO
