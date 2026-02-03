# Data Dictionary

## Overview

This document provides detailed descriptions of all tables, columns, and relationships in the Retail Medallion Database.

---

## Bronze Layer (Raw Data)

### Bronze.RawCustomers

Raw customer data as received from source CRM systems.

| Column | Type | Description |
|--------|------|-------------|
| RawCustomerID | INT | Auto-generated surrogate key |
| SourceCustomerID | NVARCHAR(50) | Original customer ID from source system |
| FirstName | NVARCHAR(100) | Customer first name |
| LastName | NVARCHAR(100) | Customer last name |
| Email | NVARCHAR(255) | Customer email address |
| Phone | NVARCHAR(50) | Customer phone number |
| Address | NVARCHAR(500) | Street address |
| City | NVARCHAR(100) | City |
| State | NVARCHAR(50) | State/Province |
| ZipCode | NVARCHAR(20) | Postal/ZIP code |
| Country | NVARCHAR(100) | Country |
| DateOfBirth | NVARCHAR(50) | Date of birth (raw format) |
| Gender | NVARCHAR(20) | Gender |
| SourceSystem | NVARCHAR(50) | Source system identifier |
| LoadDateTime | DATETIME2 | When record was loaded |
| RawPayload | NVARCHAR(MAX) | Original JSON/XML payload |

### Bronze.RawProducts

Raw product catalog data from ERP systems.

| Column | Type | Description |
|--------|------|-------------|
| RawProductID | INT | Auto-generated surrogate key |
| SourceProductID | NVARCHAR(50) | Original product ID from source |
| ProductName | NVARCHAR(255) | Product name |
| ProductDescription | NVARCHAR(MAX) | Product description |
| Category | NVARCHAR(100) | Product category |
| SubCategory | NVARCHAR(100) | Product subcategory |
| Brand | NVARCHAR(100) | Brand name |
| SKU | NVARCHAR(50) | Stock keeping unit |
| UPC | NVARCHAR(50) | Universal product code |
| UnitPrice | NVARCHAR(50) | Retail price (raw) |
| CostPrice | NVARCHAR(50) | Cost price (raw) |
| Weight | NVARCHAR(50) | Product weight (raw) |
| Dimensions | NVARCHAR(100) | Product dimensions |
| SourceSystem | NVARCHAR(50) | Source system identifier |
| LoadDateTime | DATETIME2 | When record was loaded |
| RawPayload | NVARCHAR(MAX) | Original JSON/XML payload |

### Bronze.RawStores

Raw store location data from POS systems.

| Column | Type | Description |
|--------|------|-------------|
| RawStoreID | INT | Auto-generated surrogate key |
| SourceStoreID | NVARCHAR(50) | Original store ID from source |
| StoreName | NVARCHAR(255) | Store name |
| StoreType | NVARCHAR(50) | Type (Flagship, Mall, Express, etc.) |
| Address | NVARCHAR(500) | Street address |
| City | NVARCHAR(100) | City |
| State | NVARCHAR(50) | State/Province |
| ZipCode | NVARCHAR(20) | Postal/ZIP code |
| Country | NVARCHAR(100) | Country |
| Phone | NVARCHAR(50) | Store phone number |
| ManagerName | NVARCHAR(200) | Store manager name |
| OpenDate | NVARCHAR(50) | Store opening date (raw) |
| SquareFootage | NVARCHAR(50) | Store size in sq ft (raw) |
| SourceSystem | NVARCHAR(50) | Source system identifier |
| LoadDateTime | DATETIME2 | When record was loaded |
| RawPayload | NVARCHAR(MAX) | Original JSON/XML payload |

### Bronze.RawTransactions

Raw transaction header data from POS systems.

| Column | Type | Description |
|--------|------|-------------|
| RawTransactionID | INT | Auto-generated surrogate key |
| SourceTransactionID | NVARCHAR(50) | Original transaction ID |
| TransactionDate | NVARCHAR(50) | Transaction date (raw) |
| TransactionTime | NVARCHAR(50) | Transaction time (raw) |
| StoreID | NVARCHAR(50) | Store ID reference |
| CustomerID | NVARCHAR(50) | Customer ID reference |
| EmployeeID | NVARCHAR(50) | Employee ID reference |
| TotalAmount | NVARCHAR(50) | Total amount (raw) |
| TaxAmount | NVARCHAR(50) | Tax amount (raw) |
| DiscountAmount | NVARCHAR(50) | Discount amount (raw) |
| PaymentMethod | NVARCHAR(50) | Payment method used |
| PaymentStatus | NVARCHAR(50) | Payment status |
| SourceSystem | NVARCHAR(50) | Source system identifier |
| LoadDateTime | DATETIME2 | When record was loaded |
| RawPayload | NVARCHAR(MAX) | Original JSON/XML payload |

### Bronze.RawTransactionItems

Raw transaction line items from POS systems.

| Column | Type | Description |
|--------|------|-------------|
| RawTransactionItemID | INT | Auto-generated surrogate key |
| SourceTransactionID | NVARCHAR(50) | Transaction ID reference |
| SourceProductID | NVARCHAR(50) | Product ID reference |
| Quantity | NVARCHAR(50) | Quantity purchased (raw) |
| UnitPrice | NVARCHAR(50) | Unit price at sale (raw) |
| Discount | NVARCHAR(50) | Line discount (raw) |
| LineTotal | NVARCHAR(50) | Line total (raw) |
| SourceSystem | NVARCHAR(50) | Source system identifier |
| LoadDateTime | DATETIME2 | When record was loaded |
| RawPayload | NVARCHAR(MAX) | Original JSON/XML payload |

---

## Silver Layer (Cleaned/Validated)

### Silver.DimCustomer

Cleaned customer dimension with SCD Type 2 support.

| Column | Type | Description |
|--------|------|-------------|
| CustomerKey | INT | Surrogate key (primary key) |
| CustomerID | NVARCHAR(50) | Business key |
| FirstName | NVARCHAR(100) | Customer first name |
| LastName | NVARCHAR(100) | Customer last name |
| FullName | COMPUTED | FirstName + LastName |
| Email | NVARCHAR(255) | Email (lowercased, trimmed) |
| Phone | NVARCHAR(50) | Phone number |
| Address | NVARCHAR(500) | Street address |
| City | NVARCHAR(100) | City |
| State | NVARCHAR(50) | State/Province |
| ZipCode | NVARCHAR(20) | Postal/ZIP code |
| Country | NVARCHAR(100) | Country (defaulted to USA) |
| DateOfBirth | DATE | Date of birth (validated) |
| Gender | NVARCHAR(20) | Gender |
| CustomerSegment | NVARCHAR(50) | Customer segment |
| IsActive | BIT | Active flag |
| ValidFrom | DATETIME2 | SCD2 valid from date |
| ValidTo | DATETIME2 | SCD2 valid to date |
| IsCurrent | BIT | Current record flag |
| SourceSystem | NVARCHAR(50) | Source system |
| ETLLoadDate | DATETIME2 | ETL load timestamp |
| ETLUpdateDate | DATETIME2 | ETL update timestamp |

### Silver.DimProduct

Cleaned product dimension with SCD Type 2 support.

| Column | Type | Description |
|--------|------|-------------|
| ProductKey | INT | Surrogate key (primary key) |
| ProductID | NVARCHAR(50) | Business key |
| ProductName | NVARCHAR(255) | Product name (trimmed) |
| ProductDescription | NVARCHAR(MAX) | Description |
| Category | NVARCHAR(100) | Product category |
| SubCategory | NVARCHAR(100) | Product subcategory |
| Brand | NVARCHAR(100) | Brand name |
| SKU | NVARCHAR(50) | Stock keeping unit |
| UPC | NVARCHAR(50) | Universal product code |
| UnitPrice | DECIMAL(18,2) | Retail price |
| CostPrice | DECIMAL(18,2) | Cost price |
| ProfitMargin | COMPUTED | UnitPrice - CostPrice |
| Weight | DECIMAL(10,2) | Product weight |
| IsActive | BIT | Active flag |
| ValidFrom | DATETIME2 | SCD2 valid from date |
| ValidTo | DATETIME2 | SCD2 valid to date |
| IsCurrent | BIT | Current record flag |
| SourceSystem | NVARCHAR(50) | Source system |
| ETLLoadDate | DATETIME2 | ETL load timestamp |
| ETLUpdateDate | DATETIME2 | ETL update timestamp |

### Silver.DimDate

Pre-populated calendar dimension.

| Column | Type | Description |
|--------|------|-------------|
| DateKey | INT | Date key (YYYYMMDD format) |
| FullDate | DATE | Full date value |
| DayOfWeek | INT | Day of week (1-7) |
| DayName | NVARCHAR(20) | Day name (Monday, etc.) |
| DayOfMonth | INT | Day of month (1-31) |
| DayOfYear | INT | Day of year (1-366) |
| WeekOfYear | INT | Week number |
| MonthNumber | INT | Month number (1-12) |
| MonthName | NVARCHAR(20) | Month name |
| Quarter | INT | Quarter (1-4) |
| QuarterName | NVARCHAR(10) | Quarter name (Q1, Q2, etc.) |
| Year | INT | Calendar year |
| YearMonth | NVARCHAR(7) | Year-Month (YYYY-MM) |
| YearQuarter | NVARCHAR(7) | Year-Quarter |
| IsWeekend | BIT | Weekend flag |
| IsHoliday | BIT | Holiday flag |
| HolidayName | NVARCHAR(100) | Holiday name if applicable |
| FiscalYear | INT | Fiscal year |
| FiscalQuarter | INT | Fiscal quarter |
| FiscalMonth | INT | Fiscal month |

### Silver.FactSales

Transaction-level sales fact table.

| Column | Type | Description |
|--------|------|-------------|
| SalesKey | BIGINT | Surrogate key |
| TransactionID | NVARCHAR(50) | Transaction identifier |
| DateKey | INT | FK to DimDate |
| TimeKey | INT | Time key (HHMMSS) |
| CustomerKey | INT | FK to DimCustomer |
| ProductKey | INT | FK to DimProduct |
| StoreKey | INT | FK to DimStore |
| Quantity | INT | Quantity sold |
| UnitPrice | DECIMAL(18,2) | Unit selling price |
| UnitCost | DECIMAL(18,2) | Unit cost |
| DiscountAmount | DECIMAL(18,2) | Discount applied |
| SalesAmount | DECIMAL(18,2) | Net sales amount |
| CostAmount | DECIMAL(18,2) | Total cost |
| ProfitAmount | COMPUTED | SalesAmount - CostAmount |
| TaxAmount | DECIMAL(18,2) | Tax amount |
| PaymentMethod | NVARCHAR(50) | Payment method |
| SourceSystem | NVARCHAR(50) | Source system |
| ETLLoadDate | DATETIME2 | ETL load timestamp |

---

## Gold Layer (Business Aggregates)

### Gold.DailySalesSummary

Daily aggregated sales metrics.

| Column | Type | Description |
|--------|------|-------------|
| DailySalesKey | INT | Surrogate key |
| DateKey | INT | Date key |
| SalesDate | DATE | Sales date |
| TotalTransactions | INT | Number of transactions |
| TotalQuantitySold | INT | Units sold |
| GrossSalesAmount | DECIMAL(18,2) | Gross sales |
| TotalDiscounts | DECIMAL(18,2) | Total discounts |
| NetSalesAmount | DECIMAL(18,2) | Net sales |
| TotalCost | DECIMAL(18,2) | Total cost |
| GrossProfit | DECIMAL(18,2) | Gross profit |
| GrossProfitMargin | DECIMAL(5,2) | Profit margin % |
| TotalTax | DECIMAL(18,2) | Total tax |
| AverageTransactionValue | DECIMAL(18,2) | Avg transaction value |
| AverageBasketSize | DECIMAL(10,2) | Avg items per transaction |
| UniqueCustomers | INT | Unique customers |
| NewCustomers | INT | New customers |
| ETLLoadDate | DATETIME2 | ETL load timestamp |

### Gold.CustomerAnalytics

Customer behavior and value metrics.

| Column | Type | Description |
|--------|------|-------------|
| CustomerAnalyticsKey | INT | Surrogate key |
| CustomerKey | INT | FK to DimCustomer |
| FirstPurchaseDate | DATE | First purchase date |
| LastPurchaseDate | DATE | Most recent purchase |
| DaysSinceLastPurchase | INT | Recency in days |
| TotalOrders | INT | Total order count |
| TotalQuantityPurchased | INT | Total items purchased |
| TotalSpend | DECIMAL(18,2) | Lifetime spend |
| AverageOrderValue | DECIMAL(18,2) | Average order value |
| AverageBasketSize | DECIMAL(10,2) | Avg basket size |
| PreferredStore | INT | Most visited store |
| PreferredCategory | NVARCHAR(100) | Most purchased category |
| PreferredPaymentMethod | NVARCHAR(50) | Preferred payment |
| CustomerLifetimeValue | DECIMAL(18,2) | CLV |
| RFMScore | NVARCHAR(10) | RFM score |
| RecencyScore | INT | Recency score (1-5) |
| FrequencyScore | INT | Frequency score (1-5) |
| MonetaryScore | INT | Monetary score (1-5) |
| CustomerSegment | NVARCHAR(50) | Customer segment |
| ChurnRisk | NVARCHAR(20) | Churn risk level |
| ETLLoadDate | DATETIME2 | ETL load timestamp |

### Gold.ExecutiveKPIs

Executive-level KPI summary.

| Column | Type | Description |
|--------|------|-------------|
| KPIKey | INT | Surrogate key |
| DateKey | INT | Date key |
| PeriodType | NVARCHAR(20) | Period type |
| TotalRevenue | DECIMAL(18,2) | Total revenue |
| TotalCost | DECIMAL(18,2) | Total cost |
| GrossProfit | DECIMAL(18,2) | Gross profit |
| GrossMargin | DECIMAL(5,2) | Gross margin % |
| TotalTransactions | INT | Transaction count |
| TotalUnitsSold | INT | Units sold |
| AverageOrderValue | DECIMAL(18,2) | AOV |
| TotalCustomers | INT | Customer count |
| NewCustomers | INT | New customers |
| RepeatCustomers | INT | Repeat customers |
| CustomerRetentionRate | DECIMAL(5,2) | Retention rate % |
| TotalStores | INT | Store count |
| RevenuePerStore | DECIMAL(18,2) | Revenue per store |
| RevenuePerEmployee | DECIMAL(18,2) | Revenue per employee |
| InventoryTurnover | DECIMAL(10,2) | Inventory turnover |
| YoYRevenueGrowth | DECIMAL(10,2) | YoY revenue growth % |
| YoYProfitGrowth | DECIMAL(10,2) | YoY profit growth % |
| ETLLoadDate | DATETIME2 | ETL load timestamp |

---

## Relationships

```
Bronze.RawCustomers ──ETL──► Silver.DimCustomer ──► Gold.CustomerAnalytics
Bronze.RawProducts  ──ETL──► Silver.DimProduct  ──► Gold.ProductPerformance
Bronze.RawStores    ──ETL──► Silver.DimStore    ──► Gold.StorePerformance
Bronze.RawTransactions ─┐
Bronze.RawTransactionItems ─┴─ETL──► Silver.FactSales ──► Gold.DailySalesSummary
```

---

## Governance Schema

### Governance.DataCatalog

Metadata catalog for all tables in the Medallion architecture.

| Column | Type | Description |
|--------|------|-------------|
| CatalogID | INT | Surrogate key |
| SchemaName | NVARCHAR(128) | Schema name |
| ObjectName | NVARCHAR(128) | Table/View name |
| ObjectType | NVARCHAR(50) | Object type (Table, View) |
| Layer | NVARCHAR(20) | Medallion layer (Bronze/Silver/Gold) |
| Description | NVARCHAR(MAX) | Business description |
| BusinessOwner | NVARCHAR(200) | Business owner name |
| TechnicalOwner | NVARCHAR(200) | Technical owner name |
| DataSteward | NVARCHAR(200) | Data steward name |
| DataClassification | NVARCHAR(50) | Classification (Public/Internal/Confidential/Restricted) |
| PIIFlag | BIT | Contains PII data |
| PHIFlag | BIT | Contains PHI data |
| PCIFlag | BIT | Contains PCI data |
| RetentionPolicy | NVARCHAR(100) | Data retention policy |
| RefreshFrequency | NVARCHAR(50) | How often data is refreshed |
| SourceSystem | NVARCHAR(100) | Source system/table |

### Governance.DataQualityRules

Data quality rule definitions.

| Column | Type | Description |
|--------|------|-------------|
| RuleID | INT | Surrogate key |
| RuleName | NVARCHAR(200) | Rule name |
| SchemaName | NVARCHAR(128) | Target schema |
| ObjectName | NVARCHAR(128) | Target table |
| ColumnName | NVARCHAR(128) | Target column |
| RuleType | NVARCHAR(50) | Type (Completeness/Validity/Consistency/Referential) |
| RuleExpression | NVARCHAR(MAX) | SQL expression |
| Threshold | DECIMAL(5,2) | Pass threshold % |
| Severity | NVARCHAR(20) | Severity (Critical/High/Medium/Low) |

### Governance.ETLAuditLog

ETL execution audit trail.

| Column | Type | Description |
|--------|------|-------------|
| AuditID | INT | Surrogate key |
| ProcedureName | NVARCHAR(200) | ETL procedure name |
| SourceTable | NVARCHAR(200) | Source table |
| TargetTable | NVARCHAR(200) | Target table |
| StartTime | DATETIME2 | Execution start |
| EndTime | DATETIME2 | Execution end |
| RowsRead | INT | Rows read from source |
| RowsInserted | INT | Rows inserted |
| RowsUpdated | INT | Rows updated |
| RowsDeleted | INT | Rows deleted |
| RowsRejected | INT | Rows rejected |
| Status | NVARCHAR(20) | Status (Success/Failed) |
| ErrorMessage | NVARCHAR(MAX) | Error details |
| ExecutedBy | NVARCHAR(128) | User who executed |

---

## Data Classification

| Classification | Description | Examples |
|----------------|-------------|----------|
| **Public** | No restrictions, can be shared externally | DimDate |
| **Internal** | Internal use only, not for external sharing | Products, Stores, Inventory |
| **Confidential** | Sensitive business data, limited access | Customers, Suppliers, Sales |
| **Restricted** | Executive-level, highly restricted | Executive KPIs |

---

## Data Lineage Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA LINEAGE FLOW                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SOURCE SYSTEMS          BRONZE              SILVER              GOLD       │
│  ─────────────          ──────              ──────              ────       │
│                                                                             │
│  CRM ──────────► RawCustomers ────► DimCustomer ────► CustomerAnalytics    │
│                                                                             │
│  ERP ──────────► RawProducts  ────► DimProduct  ────► ProductPerformance   │
│               └► RawSuppliers ────► DimSupplier      │ CategoryPerformance │
│                                                       │                     │
│  POS ──────────► RawStores ───────► DimStore ───────► StorePerformance     │
│               └► RawTransactions ─┐                   │                     │
│               └► RawTransactionItems ─► FactSales ───► DailySalesSummary   │
│                                                       └► ExecutiveKPIs      │
│  WMS ──────────► RawInventory ────► FactInventory ──► InventorySummary     │
│                                                                             │
│  Generated ──────────────────────► DimDate                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```
