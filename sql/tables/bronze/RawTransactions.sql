-- ============================================
-- Bronze Layer: Raw Transactions
-- ============================================

IF OBJECT_ID('Bronze.RawTransactions', 'U') IS NOT NULL
    DROP TABLE Bronze.RawTransactions;
GO

CREATE TABLE Bronze.RawTransactions (
    RawTransactionID INT IDENTITY(1,1) PRIMARY KEY,
    SourceTransactionID NVARCHAR(50),
    TransactionDate NVARCHAR(50),
    TransactionTime NVARCHAR(50),
    StoreID NVARCHAR(50),
    CustomerID NVARCHAR(50),
    EmployeeID NVARCHAR(50),
    TotalAmount NVARCHAR(50),
    TaxAmount NVARCHAR(50),
    DiscountAmount NVARCHAR(50),
    PaymentMethod NVARCHAR(50),
    PaymentStatus NVARCHAR(50),
    SourceSystem NVARCHAR(50),
    LoadDateTime DATETIME2 DEFAULT GETDATE(),
    RawPayload NVARCHAR(MAX)
);
GO
