-- ============================================
-- Bronze Layer: Raw Products
-- ============================================

IF OBJECT_ID('Bronze.RawProducts', 'U') IS NOT NULL
    DROP TABLE Bronze.RawProducts;
GO

CREATE TABLE Bronze.RawProducts (
    RawProductID INT IDENTITY(1,1) PRIMARY KEY,
    SourceProductID NVARCHAR(50),
    ProductName NVARCHAR(255),
    ProductDescription NVARCHAR(MAX),
    Category NVARCHAR(100),
    SubCategory NVARCHAR(100),
    Brand NVARCHAR(100),
    SKU NVARCHAR(50),
    UPC NVARCHAR(50),
    UnitPrice NVARCHAR(50),
    CostPrice NVARCHAR(50),
    Weight NVARCHAR(50),
    Dimensions NVARCHAR(100),
    SourceSystem NVARCHAR(50),
    LoadDateTime DATETIME2 DEFAULT GETDATE(),
    RawPayload NVARCHAR(MAX)
);
GO
