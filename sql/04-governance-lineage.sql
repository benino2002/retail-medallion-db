-- ============================================
-- Governance & Data Lineage Schema
-- ============================================

USE [RetailMedallion];
GO

-- Create Governance Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Governance')
    EXEC('CREATE SCHEMA Governance');
GO

-- =============================================
-- GOVERNANCE TABLES
-- =============================================

-- Data Catalog: Metadata for all tables
IF OBJECT_ID('Governance.DataCatalog', 'U') IS NOT NULL DROP TABLE Governance.DataCatalog;
GO

CREATE TABLE Governance.DataCatalog (
    CatalogID INT IDENTITY(1,1) PRIMARY KEY,
    SchemaName NVARCHAR(128) NOT NULL,
    ObjectName NVARCHAR(128) NOT NULL,
    ObjectType NVARCHAR(50) NOT NULL,
    Layer NVARCHAR(20) NOT NULL,
    Description NVARCHAR(MAX),
    BusinessOwner NVARCHAR(200),
    TechnicalOwner NVARCHAR(200),
    DataSteward NVARCHAR(200),
    DataClassification NVARCHAR(50),
    PIIFlag BIT DEFAULT 0,
    PHIFlag BIT DEFAULT 0,
    PCIFlag BIT DEFAULT 0,
    RetentionPolicy NVARCHAR(100),
    RefreshFrequency NVARCHAR(50),
    SourceSystem NVARCHAR(100),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2,
    IsActive BIT DEFAULT 1
);
GO

-- Data Lineage: Track data flow
IF OBJECT_ID('Governance.DataLineage', 'U') IS NOT NULL DROP TABLE Governance.DataLineage;
GO

CREATE TABLE Governance.DataLineage (
    LineageID INT IDENTITY(1,1) PRIMARY KEY,
    SourceSchema NVARCHAR(128) NOT NULL,
    SourceObject NVARCHAR(128) NOT NULL,
    SourceColumn NVARCHAR(128),
    TargetSchema NVARCHAR(128) NOT NULL,
    TargetObject NVARCHAR(128) NOT NULL,
    TargetColumn NVARCHAR(128),
    TransformationType NVARCHAR(100),
    TransformationLogic NVARCHAR(MAX),
    ETLProcedure NVARCHAR(200),
    LoadType NVARCHAR(50),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
GO

-- Data Quality Rules
IF OBJECT_ID('Governance.DataQualityRules', 'U') IS NOT NULL DROP TABLE Governance.DataQualityRules;
GO

CREATE TABLE Governance.DataQualityRules (
    RuleID INT IDENTITY(1,1) PRIMARY KEY,
    RuleName NVARCHAR(200) NOT NULL,
    SchemaName NVARCHAR(128) NOT NULL,
    ObjectName NVARCHAR(128) NOT NULL,
    ColumnName NVARCHAR(128),
    RuleType NVARCHAR(50) NOT NULL,
    RuleExpression NVARCHAR(MAX),
    Threshold DECIMAL(5,2),
    Severity NVARCHAR(20),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
GO

-- Data Quality Results
IF OBJECT_ID('Governance.DataQualityResults', 'U') IS NOT NULL DROP TABLE Governance.DataQualityResults;
GO

CREATE TABLE Governance.DataQualityResults (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    RuleID INT NOT NULL,
    ExecutionDate DATETIME2 DEFAULT GETDATE(),
    TotalRecords INT,
    PassedRecords INT,
    FailedRecords INT,
    PassRate DECIMAL(5,2),
    Status NVARCHAR(20),
    ErrorDetails NVARCHAR(MAX)
);
GO

-- ETL Audit Log
IF OBJECT_ID('Governance.ETLAuditLog', 'U') IS NOT NULL DROP TABLE Governance.ETLAuditLog;
GO

CREATE TABLE Governance.ETLAuditLog (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ProcedureName NVARCHAR(200) NOT NULL,
    SourceTable NVARCHAR(200),
    TargetTable NVARCHAR(200),
    StartTime DATETIME2 NOT NULL,
    EndTime DATETIME2,
    RowsRead INT,
    RowsInserted INT,
    RowsUpdated INT,
    RowsDeleted INT,
    RowsRejected INT,
    Status NVARCHAR(20),
    ErrorMessage NVARCHAR(MAX),
    ExecutedBy NVARCHAR(128) DEFAULT SYSTEM_USER
);
GO

-- =============================================
-- GOVERNANCE VIEWS
-- =============================================

-- View: Data Catalog Summary
IF OBJECT_ID('Governance.vwDataCatalogSummary', 'V') IS NOT NULL DROP VIEW Governance.vwDataCatalogSummary;
GO

CREATE VIEW Governance.vwDataCatalogSummary AS
SELECT
    t.TABLE_SCHEMA AS SchemaName,
    t.TABLE_NAME AS TableName,
    'TABLE' AS ObjectType,
    CASE
        WHEN t.TABLE_SCHEMA = 'Bronze' THEN 'Bronze (Raw)'
        WHEN t.TABLE_SCHEMA = 'Silver' THEN 'Silver (Cleansed)'
        WHEN t.TABLE_SCHEMA = 'Gold' THEN 'Gold (Aggregated)'
        ELSE 'Other'
    END AS Layer,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS c WHERE c.TABLE_SCHEMA = t.TABLE_SCHEMA AND c.TABLE_NAME = t.TABLE_NAME) AS ColumnCount,
    (SELECT SUM(p.rows) FROM sys.partitions p INNER JOIN sys.tables tb ON p.object_id = tb.object_id WHERE SCHEMA_NAME(tb.schema_id) = t.TABLE_SCHEMA AND tb.name = t.TABLE_NAME AND p.index_id IN (0,1)) AS RecordCount
FROM INFORMATION_SCHEMA.TABLES t
WHERE t.TABLE_TYPE = 'BASE TABLE'
AND t.TABLE_SCHEMA IN ('Bronze', 'Silver', 'Gold');
GO

-- View: Column-Level Lineage
IF OBJECT_ID('Governance.vwColumnLineage', 'V') IS NOT NULL DROP VIEW Governance.vwColumnLineage;
GO

CREATE VIEW Governance.vwColumnLineage AS
SELECT
    c.TABLE_SCHEMA AS SchemaName,
    c.TABLE_NAME AS TableName,
    c.COLUMN_NAME AS ColumnName,
    c.DATA_TYPE AS DataType,
    c.CHARACTER_MAXIMUM_LENGTH AS MaxLength,
    c.IS_NULLABLE AS IsNullable,
    c.COLUMN_DEFAULT AS DefaultValue,
    CASE
        WHEN c.TABLE_SCHEMA = 'Bronze' THEN 'Source System'
        WHEN c.TABLE_SCHEMA = 'Silver' THEN 'Bronze Layer'
        WHEN c.TABLE_SCHEMA = 'Gold' THEN 'Silver Layer'
        ELSE 'Unknown'
    END AS DataSource,
    CASE
        WHEN c.TABLE_SCHEMA = 'Bronze' THEN 'Raw/Untransformed'
        WHEN c.TABLE_SCHEMA = 'Silver' THEN 'Cleaned/Validated'
        WHEN c.TABLE_SCHEMA = 'Gold' THEN 'Aggregated/Calculated'
        ELSE 'Unknown'
    END AS TransformationStatus
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA IN ('Bronze', 'Silver', 'Gold');
GO

-- View: Table Dependencies
IF OBJECT_ID('Governance.vwTableDependencies', 'V') IS NOT NULL DROP VIEW Governance.vwTableDependencies;
GO

CREATE VIEW Governance.vwTableDependencies AS
SELECT DISTINCT
    OBJECT_SCHEMA_NAME(d.referencing_id) AS ReferencingSchema,
    OBJECT_NAME(d.referencing_id) AS ReferencingObject,
    o1.type_desc AS ReferencingType,
    COALESCE(d.referenced_schema_name, OBJECT_SCHEMA_NAME(d.referenced_id)) AS ReferencedSchema,
    d.referenced_entity_name AS ReferencedObject,
    o2.type_desc AS ReferencedType
FROM sys.sql_expression_dependencies d
LEFT JOIN sys.objects o1 ON d.referencing_id = o1.object_id
LEFT JOIN sys.objects o2 ON d.referenced_id = o2.object_id
WHERE OBJECT_SCHEMA_NAME(d.referencing_id) IN ('Bronze', 'Silver', 'Gold', 'ETL', 'Governance')
   OR COALESCE(d.referenced_schema_name, OBJECT_SCHEMA_NAME(d.referenced_id)) IN ('Bronze', 'Silver', 'Gold');
GO

-- View: ETL Pipeline Status
IF OBJECT_ID('Governance.vwETLPipelineStatus', 'V') IS NOT NULL DROP VIEW Governance.vwETLPipelineStatus;
GO

CREATE VIEW Governance.vwETLPipelineStatus AS
SELECT
    p.name AS ProcedureName,
    SCHEMA_NAME(p.schema_id) AS SchemaName,
    p.create_date AS CreatedDate,
    p.modify_date AS LastModifiedDate,
    CASE
        WHEN p.name LIKE '%Silver%' OR p.name LIKE '%Dim%' OR p.name LIKE '%Fact%' THEN 'Bronze to Silver'
        WHEN p.name LIKE '%Gold%' OR p.name LIKE '%Refresh%' THEN 'Silver to Gold'
        WHEN p.name LIKE '%Populate%' THEN 'Reference Data'
        WHEN p.name LIKE '%Pipeline%' THEN 'Full Pipeline'
        ELSE 'Other'
    END AS PipelineStage
FROM sys.procedures p
WHERE SCHEMA_NAME(p.schema_id) = 'ETL';
GO

-- View: Data Lineage Map
IF OBJECT_ID('Governance.vwDataLineageMap', 'V') IS NOT NULL DROP VIEW Governance.vwDataLineageMap;
GO

CREATE VIEW Governance.vwDataLineageMap AS
SELECT 'Bronze' AS SourceLayer, 'RawCustomers' AS SourceTable, 'Silver' AS TargetLayer, 'DimCustomer' AS TargetTable, 'ETL.uspLoadSilverCustomers' AS ETLProcedure, 'Incremental' AS LoadType, 'Clean, Validate, Type Cast' AS Transformation
UNION ALL SELECT 'Bronze', 'RawProducts', 'Silver', 'DimProduct', 'ETL.uspLoadSilverProducts', 'Incremental', 'Clean, Validate, Type Cast'
UNION ALL SELECT 'Bronze', 'RawStores', 'Silver', 'DimStore', 'ETL.uspLoadSilverStores', 'Incremental', 'Clean, Validate, Type Cast'
UNION ALL SELECT 'Bronze', 'RawSuppliers', 'Silver', 'DimSupplier', 'ETL.uspLoadSilverSuppliers', 'Incremental', 'Clean, Validate, Type Cast'
UNION ALL SELECT 'Bronze', 'RawTransactions + RawTransactionItems', 'Silver', 'FactSales', 'ETL.uspLoadFactSales', 'Incremental', 'Join, Lookup Keys, Calculate Amounts'
UNION ALL SELECT 'Bronze', 'RawInventory', 'Silver', 'FactInventory', 'ETL.uspLoadFactInventory', 'Full Refresh', 'Lookup Keys, Calculate Values'
UNION ALL SELECT 'Silver', 'FactSales + DimDate', 'Gold', 'DailySalesSummary', 'ETL.uspRefreshGoldDailySales', 'Full Refresh', 'Aggregate by Date'
UNION ALL SELECT 'Silver', 'FactSales + DimCustomer + DimDate', 'Gold', 'CustomerAnalytics', 'ETL.uspRefreshGoldCustomerAnalytics', 'Full Refresh', 'Aggregate by Customer, Calculate Metrics'
UNION ALL SELECT 'Silver', 'FactSales + DimStore', 'Gold', 'StorePerformance', 'ETL.uspRefreshGoldStorePerformance', 'Full Refresh', 'Aggregate by Store, Rank'
UNION ALL SELECT 'Silver', 'FactSales + DimProduct', 'Gold', 'ProductPerformance', 'ETL.uspRefreshGoldProductPerformance', 'Full Refresh', 'Aggregate by Product, Rank'
UNION ALL SELECT 'Silver', 'FactSales + DimProduct', 'Gold', 'CategoryPerformance', 'ETL.uspRefreshGoldCategoryPerformance', 'Full Refresh', 'Aggregate by Category'
UNION ALL SELECT 'Silver', 'FactInventory', 'Gold', 'InventorySummary', 'ETL.uspRefreshGoldInventorySummary', 'Full Refresh', 'Aggregate by Store'
UNION ALL SELECT 'Silver', 'FactSales', 'Gold', 'ExecutiveKPIs', 'ETL.uspRefreshGoldExecutiveKPIs', 'Full Refresh', 'Calculate KPIs';
GO

-- =============================================
-- SAMPLE GOVERNANCE DATA
-- =============================================

-- Populate Data Catalog
INSERT INTO Governance.DataCatalog (SchemaName, ObjectName, ObjectType, Layer, Description, DataClassification, PIIFlag, RefreshFrequency, SourceSystem)
VALUES
('Bronze', 'RawCustomers', 'Table', 'Bronze', 'Raw customer data from CRM system', 'Confidential', 1, 'Daily', 'CRM'),
('Bronze', 'RawProducts', 'Table', 'Bronze', 'Raw product catalog from ERP system', 'Internal', 0, 'Daily', 'ERP'),
('Bronze', 'RawStores', 'Table', 'Bronze', 'Raw store location data from POS', 'Internal', 0, 'Weekly', 'POS'),
('Bronze', 'RawSuppliers', 'Table', 'Bronze', 'Raw supplier data from ERP', 'Confidential', 0, 'Weekly', 'ERP'),
('Bronze', 'RawTransactions', 'Table', 'Bronze', 'Raw transaction headers from POS', 'Confidential', 0, 'Real-time', 'POS'),
('Bronze', 'RawTransactionItems', 'Table', 'Bronze', 'Raw transaction line items from POS', 'Internal', 0, 'Real-time', 'POS'),
('Bronze', 'RawInventory', 'Table', 'Bronze', 'Raw inventory levels from WMS', 'Internal', 0, 'Daily', 'WMS'),
('Silver', 'DimCustomer', 'Table', 'Silver', 'Cleaned customer dimension with SCD2', 'Confidential', 1, 'Daily', 'Bronze.RawCustomers'),
('Silver', 'DimProduct', 'Table', 'Silver', 'Cleaned product dimension with SCD2', 'Internal', 0, 'Daily', 'Bronze.RawProducts'),
('Silver', 'DimStore', 'Table', 'Silver', 'Cleaned store dimension with SCD2', 'Internal', 0, 'Weekly', 'Bronze.RawStores'),
('Silver', 'DimSupplier', 'Table', 'Silver', 'Cleaned supplier dimension', 'Confidential', 0, 'Weekly', 'Bronze.RawSuppliers'),
('Silver', 'DimDate', 'Table', 'Silver', 'Date dimension (pre-populated)', 'Public', 0, 'Static', 'Generated'),
('Silver', 'FactSales', 'Table', 'Silver', 'Sales fact table at transaction level', 'Confidential', 0, 'Daily', 'Bronze.RawTransactions'),
('Silver', 'FactInventory', 'Table', 'Silver', 'Inventory snapshot fact table', 'Internal', 0, 'Daily', 'Bronze.RawInventory'),
('Gold', 'DailySalesSummary', 'Table', 'Gold', 'Daily aggregated sales metrics', 'Internal', 0, 'Daily', 'Silver.FactSales'),
('Gold', 'StorePerformance', 'Table', 'Gold', 'Store-level performance metrics', 'Internal', 0, 'Daily', 'Silver.FactSales'),
('Gold', 'ProductPerformance', 'Table', 'Gold', 'Product-level performance metrics', 'Internal', 0, 'Daily', 'Silver.FactSales'),
('Gold', 'CustomerAnalytics', 'Table', 'Gold', 'Customer behavior and value metrics', 'Confidential', 0, 'Daily', 'Silver.FactSales'),
('Gold', 'CategoryPerformance', 'Table', 'Gold', 'Category-level sales analysis', 'Internal', 0, 'Daily', 'Silver.FactSales'),
('Gold', 'InventorySummary', 'Table', 'Gold', 'Inventory health metrics by store', 'Internal', 0, 'Daily', 'Silver.FactInventory'),
('Gold', 'ExecutiveKPIs', 'Table', 'Gold', 'Executive dashboard KPIs', 'Restricted', 0, 'Daily', 'Silver.FactSales');
GO

-- Populate Data Quality Rules
INSERT INTO Governance.DataQualityRules (RuleName, SchemaName, ObjectName, ColumnName, RuleType, RuleExpression, Threshold, Severity)
VALUES
('Customer Email Not Null', 'Silver', 'DimCustomer', 'Email', 'Completeness', 'Email IS NOT NULL', 95.00, 'High'),
('Customer Email Valid Format', 'Silver', 'DimCustomer', 'Email', 'Validity', 'Email LIKE ''%@%.%''', 98.00, 'Medium'),
('Product Price Positive', 'Silver', 'DimProduct', 'UnitPrice', 'Validity', 'UnitPrice > 0', 100.00, 'Critical'),
('Product Cost Less Than Price', 'Silver', 'DimProduct', 'CostPrice', 'Consistency', 'CostPrice < UnitPrice', 100.00, 'High'),
('Sales Amount Positive', 'Silver', 'FactSales', 'SalesAmount', 'Validity', 'SalesAmount >= 0', 100.00, 'Critical'),
('Sales Has Valid Date', 'Silver', 'FactSales', 'DateKey', 'Referential', 'DateKey IN (SELECT DateKey FROM Silver.DimDate)', 100.00, 'Critical'),
('Store Has Valid Location', 'Silver', 'DimStore', 'City', 'Completeness', 'City IS NOT NULL AND State IS NOT NULL', 100.00, 'High'),
('Transaction Has Products', 'Silver', 'FactSales', 'ProductKey', 'Referential', 'ProductKey IN (SELECT ProductKey FROM Silver.DimProduct)', 100.00, 'Critical');
GO

PRINT 'Governance schema, tables, views, and sample data created successfully';
