-- ============================================
-- Retail Medallion Database - Create Schemas
-- ============================================

USE [RetailMedallion];
GO

-- Bronze Schema: Raw data layer
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Bronze')
    EXEC('CREATE SCHEMA Bronze');
GO

-- Silver Schema: Cleaned/validated data layer
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Silver')
    EXEC('CREATE SCHEMA Silver');
GO

-- Gold Schema: Business aggregates layer
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Gold')
    EXEC('CREATE SCHEMA Gold');
GO

-- ETL Schema: Stored procedures
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ETL')
    EXEC('CREATE SCHEMA ETL');
GO

PRINT 'All schemas created successfully';
