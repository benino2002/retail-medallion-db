# Data Governance & Lineage Guide

## Overview

This document describes the data governance framework implemented in the Retail Medallion Database, including data cataloging, lineage tracking, quality rules, and audit logging.

## Governance Schema

The `Governance` schema contains all metadata management objects:

```sql
-- Tables
Governance.DataCatalog         -- Metadata for all tables
Governance.DataLineage         -- Column-level lineage
Governance.DataQualityRules    -- DQ rule definitions
Governance.DataQualityResults  -- DQ execution results
Governance.ETLAuditLog         -- ETL audit trail

-- Views
Governance.vwDataCatalogSummary  -- Table summary with counts
Governance.vwColumnLineage       -- Column metadata
Governance.vwTableDependencies   -- Object dependencies
Governance.vwETLPipelineStatus   -- ETL procedure status
Governance.vwDataLineageMap      -- Data flow visualization
```

## Data Catalog

### Viewing the Data Catalog

```sql
-- View all cataloged objects
SELECT * FROM Governance.DataCatalog;

-- View summary with row counts
SELECT * FROM Governance.vwDataCatalogSummary;

-- Find tables with PII
SELECT SchemaName, ObjectName, Description
FROM Governance.DataCatalog
WHERE PIIFlag = 1;

-- Find confidential data
SELECT SchemaName, ObjectName, Description
FROM Governance.DataCatalog
WHERE DataClassification = 'Confidential';
```

### Adding New Tables to Catalog

```sql
INSERT INTO Governance.DataCatalog (
    SchemaName, ObjectName, ObjectType, Layer,
    Description, DataClassification, PIIFlag,
    RefreshFrequency, SourceSystem
)
VALUES (
    'Silver', 'NewTable', 'Table', 'Silver',
    'Description of the table', 'Internal', 0,
    'Daily', 'Bronze.SourceTable'
);
```

## Data Lineage

### Viewing Data Lineage

```sql
-- View complete lineage map
SELECT * FROM Governance.vwDataLineageMap;

-- View column-level metadata
SELECT * FROM Governance.vwColumnLineage
WHERE SchemaName = 'Silver';

-- View object dependencies
SELECT * FROM Governance.vwTableDependencies;
```

### Lineage Map

```
BRONZE LAYER                    SILVER LAYER                    GOLD LAYER
─────────────                   ─────────────                   ───────────
RawCustomers ───────────────► DimCustomer ──────────────────► CustomerAnalytics
RawProducts  ───────────────► DimProduct  ──────────────────► ProductPerformance
                                           └─────────────────► CategoryPerformance
RawStores    ───────────────► DimStore    ──────────────────► StorePerformance
RawSuppliers ───────────────► DimSupplier
RawTransactions ─┐
RawTransactionItems ─────────► FactSales  ──────────────────► DailySalesSummary
                                           └─────────────────► ExecutiveKPIs
RawInventory ───────────────► FactInventory ────────────────► InventorySummary
```

## Data Quality Rules

### Rule Types

| Type | Description | Example |
|------|-------------|---------|
| Completeness | Checks for null/missing values | Email IS NOT NULL |
| Validity | Checks data format/range | UnitPrice > 0 |
| Consistency | Checks logical relationships | CostPrice < UnitPrice |
| Referential | Checks foreign key integrity | ProductKey exists in DimProduct |

### Viewing Rules

```sql
-- View all rules
SELECT * FROM Governance.DataQualityRules;

-- View rules by severity
SELECT * FROM Governance.DataQualityRules
WHERE Severity = 'Critical';

-- View rules for a specific table
SELECT * FROM Governance.DataQualityRules
WHERE SchemaName = 'Silver' AND ObjectName = 'FactSales';
```

### Adding New Rules

```sql
INSERT INTO Governance.DataQualityRules (
    RuleName, SchemaName, ObjectName, ColumnName,
    RuleType, RuleExpression, Threshold, Severity
)
VALUES (
    'Customer Phone Not Null',
    'Silver', 'DimCustomer', 'Phone',
    'Completeness', 'Phone IS NOT NULL',
    90.00, 'Medium'
);
```

### Running Data Quality Checks

```sql
-- Example: Check email completeness
DECLARE @RuleID INT = 1;
DECLARE @Total INT, @Passed INT;

SELECT @Total = COUNT(*) FROM Silver.DimCustomer WHERE IsCurrent = 1;
SELECT @Passed = COUNT(*) FROM Silver.DimCustomer WHERE IsCurrent = 1 AND Email IS NOT NULL;

INSERT INTO Governance.DataQualityResults (
    RuleID, TotalRecords, PassedRecords, FailedRecords, PassRate, Status
)
VALUES (
    @RuleID, @Total, @Passed, @Total - @Passed,
    CAST(@Passed AS DECIMAL) / @Total * 100,
    CASE WHEN CAST(@Passed AS DECIMAL) / @Total * 100 >= 95 THEN 'PASSED' ELSE 'FAILED' END
);
```

## ETL Audit Logging

### Logging ETL Execution

```sql
-- Start of ETL
DECLARE @AuditID INT;
INSERT INTO Governance.ETLAuditLog (ProcedureName, SourceTable, TargetTable, StartTime, Status)
VALUES ('ETL.uspLoadSilverCustomers', 'Bronze.RawCustomers', 'Silver.DimCustomer', GETDATE(), 'Running');
SET @AuditID = SCOPE_IDENTITY();

-- ... ETL logic ...

-- End of ETL
UPDATE Governance.ETLAuditLog
SET EndTime = GETDATE(),
    RowsRead = @RowsRead,
    RowsInserted = @RowsInserted,
    Status = 'Success'
WHERE AuditID = @AuditID;
```

### Viewing Audit History

```sql
-- View recent ETL runs
SELECT TOP 20
    ProcedureName,
    StartTime,
    EndTime,
    DATEDIFF(SECOND, StartTime, EndTime) AS DurationSeconds,
    RowsInserted,
    Status
FROM Governance.ETLAuditLog
ORDER BY StartTime DESC;

-- View failed ETL runs
SELECT *
FROM Governance.ETLAuditLog
WHERE Status = 'Failed';
```

## Data Classification

### Classification Levels

| Level | Description | Access | Examples |
|-------|-------------|--------|----------|
| **Public** | No restrictions | All users | DimDate, Reference data |
| **Internal** | Business use only | Internal staff | Products, Stores |
| **Confidential** | Sensitive data | Authorized only | Customers, Sales |
| **Restricted** | Highly sensitive | Executives only | KPIs, Financial |

### Viewing Classifications

```sql
-- View by classification
SELECT SchemaName, ObjectName, DataClassification, PIIFlag
FROM Governance.DataCatalog
ORDER BY
    CASE DataClassification
        WHEN 'Restricted' THEN 1
        WHEN 'Confidential' THEN 2
        WHEN 'Internal' THEN 3
        WHEN 'Public' THEN 4
    END;
```

## Best Practices

1. **Update catalog** when adding new tables
2. **Define DQ rules** for critical columns
3. **Log all ETL executions** for troubleshooting
4. **Review lineage** before making schema changes
5. **Mark PII columns** for compliance
6. **Set appropriate classifications** for access control
