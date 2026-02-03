-- ============================================
-- Silver Layer: Dim Product (SCD Type 2)
-- ============================================

IF OBJECT_ID('Silver.DimProduct', 'U') IS NOT NULL
    DROP TABLE Silver.DimProduct;
GO

CREATE TABLE Silver.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID NVARCHAR(50) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    ProductDescription NVARCHAR(MAX),
    Category NVARCHAR(100),
    SubCategory NVARCHAR(100),
    Brand NVARCHAR(100),
    SKU NVARCHAR(50),
    UPC NVARCHAR(50),
    UnitPrice DECIMAL(18,2),
    CostPrice DECIMAL(18,2),
    ProfitMargin AS (UnitPrice - CostPrice),
    Weight DECIMAL(10,2),
    IsActive BIT DEFAULT 1,
    ValidFrom DATETIME2 DEFAULT GETDATE(),
    ValidTo DATETIME2,
    IsCurrent BIT DEFAULT 1,
    SourceSystem NVARCHAR(50),
    ETLLoadDate DATETIME2 DEFAULT GETDATE(),
    ETLUpdateDate DATETIME2
);
GO

CREATE INDEX IX_DimProduct_ProductID ON Silver.DimProduct(ProductID);
CREATE INDEX IX_DimProduct_Category ON Silver.DimProduct(Category);
CREATE INDEX IX_DimProduct_IsCurrent ON Silver.DimProduct(IsCurrent);
GO
