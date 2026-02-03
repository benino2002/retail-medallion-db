-- ============================================
-- Bronze Layer: Raw Transaction Items
-- ============================================

IF OBJECT_ID('Bronze.RawTransactionItems', 'U') IS NOT NULL
    DROP TABLE Bronze.RawTransactionItems;
GO

CREATE TABLE Bronze.RawTransactionItems (
    RawTransactionItemID INT IDENTITY(1,1) PRIMARY KEY,
    SourceTransactionID NVARCHAR(50),
    SourceProductID NVARCHAR(50),
    Quantity NVARCHAR(50),
    UnitPrice NVARCHAR(50),
    Discount NVARCHAR(50),
    LineTotal NVARCHAR(50),
    SourceSystem NVARCHAR(50),
    LoadDateTime DATETIME2 DEFAULT GETDATE(),
    RawPayload NVARCHAR(MAX)
);
GO
