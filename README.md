# Retail Medallion Database

A complete **Medallion Architecture** implementation for a retail company using SQL Server. This project demonstrates a modern data lakehouse pattern with Bronze, Silver, and Gold layers for data transformation and analytics.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MEDALLION ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────┐      ┌─────────────┐      ┌─────────────┐                │
│   │   BRONZE    │ ───► │   SILVER    │ ───► │    GOLD     │                │
│   │  (Raw Data) │      │  (Cleaned)  │      │ (Analytics) │                │
│   └─────────────┘      └─────────────┘      └─────────────┘                │
│                                                                             │
│   • Raw data as-is     • Validated data    • Business metrics              │
│   • All data types     • Proper types      • Aggregated KPIs               │
│   • Source metadata    • Dimensional model • Ready for BI                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Database Structure

### Schemas

| Schema | Purpose |
|--------|---------|
| `Bronze` | Raw data layer - data as received from source systems |
| `Silver` | Cleaned/validated layer - conformed dimensions and facts |
| `Gold` | Business aggregates - ready for BI/reporting |
| `ETL` | Stored procedures for data movement between layers |

### Tables

#### Bronze Layer (7 tables)
Raw data tables with all fields stored as `NVARCHAR` to capture any source data:

- `Bronze.RawCustomers` - Customer data from CRM
- `Bronze.RawProducts` - Product catalog from ERP
- `Bronze.RawStores` - Store locations from POS
- `Bronze.RawSuppliers` - Supplier information
- `Bronze.RawTransactions` - Transaction headers
- `Bronze.RawTransactionItems` - Transaction line items
- `Bronze.RawInventory` - Inventory levels from WMS

#### Silver Layer (7 tables)
Cleaned, validated data with proper data types and relationships:

- `Silver.DimCustomer` - Customer dimension (SCD Type 2)
- `Silver.DimProduct` - Product dimension (SCD Type 2)
- `Silver.DimStore` - Store dimension (SCD Type 2)
- `Silver.DimSupplier` - Supplier dimension
- `Silver.DimDate` - Date dimension (pre-populated calendar)
- `Silver.FactSales` - Sales fact table
- `Silver.FactInventory` - Inventory snapshot fact table

#### Gold Layer (7 tables)
Business-level aggregates and KPIs:

- `Gold.DailySalesSummary` - Daily sales metrics
- `Gold.StorePerformance` - Store-level performance
- `Gold.ProductPerformance` - Product-level performance
- `Gold.CustomerAnalytics` - Customer behavior metrics
- `Gold.CategoryPerformance` - Category-level analysis
- `Gold.InventorySummary` - Inventory health metrics
- `Gold.ExecutiveKPIs` - Executive dashboard metrics

### Views (7 views)

| View | Description |
|------|-------------|
| `Silver.vwCurrentProducts` | Active products with profit margins |
| `Silver.vwCurrentCustomers` | Active customer list |
| `Silver.vwSalesDetail` | Denormalized sales with all dimensions |
| `Gold.vwTopSellingProducts` | Top 100 products by revenue |
| `Gold.vwStoreSalesSummary` | Store performance summary |
| `Gold.vwMonthlySalesTrend` | Monthly sales trends |
| `Gold.vwCustomerPurchaseSummary` | Customer purchase history |

### Stored Procedures (15 procedures)

#### Silver Layer ETL
| Procedure | Description |
|-----------|-------------|
| `ETL.uspPopulateDimDate` | Populate date dimension |
| `ETL.uspLoadSilverCustomers` | Load customers Bronze → Silver |
| `ETL.uspLoadSilverProducts` | Load products Bronze → Silver |
| `ETL.uspLoadSilverStores` | Load stores Bronze → Silver |
| `ETL.uspLoadSilverSuppliers` | Load suppliers Bronze → Silver |
| `ETL.uspLoadFactSales` | Load sales facts Bronze → Silver |
| `ETL.uspLoadFactInventory` | Load inventory facts Bronze → Silver |

#### Gold Layer ETL
| Procedure | Description |
|-----------|-------------|
| `ETL.uspRefreshGoldDailySales` | Refresh daily sales summary |
| `ETL.uspRefreshGoldCustomerAnalytics` | Refresh customer analytics |
| `ETL.uspRefreshGoldStorePerformance` | Refresh store performance |
| `ETL.uspRefreshGoldProductPerformance` | Refresh product performance |
| `ETL.uspRefreshGoldCategoryPerformance` | Refresh category performance |
| `ETL.uspRefreshGoldInventorySummary` | Refresh inventory summary |
| `ETL.uspRefreshGoldExecutiveKPIs` | Refresh executive KPIs |

#### Pipeline
| Procedure | Description |
|-----------|-------------|
| `ETL.uspRunFullPipeline` | Execute complete ETL pipeline |

## Quick Start

### Prerequisites
- SQL Server 2019+ or SQL Server Express
- PowerShell 5.1+
- Windows Authentication enabled

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/retail-medallion-db.git
   cd retail-medallion-db
   ```

2. **Update connection settings**

   Edit `scripts/config.ps1` and update the server name:
   ```powershell
   $serverName = "YOUR_SERVER\SQLEXPRESS"
   ```

3. **Run the installation script**
   ```powershell
   .\scripts\install.ps1
   ```

4. **Verify installation**
   ```powershell
   .\scripts\run-etl-verify.ps1
   ```

### Manual Installation

Run the SQL scripts in this order:
1. `sql/01-create-database.sql`
2. `sql/02-create-schemas.sql`
3. `sql/tables/*.sql`
4. `sql/stored-procedures/*.sql`
5. `sql/views/*.sql`
6. `sql/03-sample-data.sql`

## Usage

### Run the ETL Pipeline

```sql
-- Run complete ETL pipeline
EXEC ETL.uspRunFullPipeline;

-- Or run individual procedures
EXEC ETL.uspLoadSilverCustomers;
EXEC ETL.uspRefreshGoldDailySales;
```

### Query Examples

```sql
-- Top selling products
SELECT * FROM Gold.vwTopSellingProducts;

-- Daily sales summary
SELECT * FROM Gold.DailySalesSummary
ORDER BY SalesDate DESC;

-- Customer analytics
SELECT * FROM Gold.vwCustomerPurchaseSummary
ORDER BY TotalSpend DESC;

-- Store performance
SELECT * FROM Gold.vwStoreSalesSummary
ORDER BY TotalRevenue DESC;
```

## Sample Data

The database includes sample data for testing:
- 25 products across 5 categories (Electronics, Fashion, Home, Sports, Food)
- 8 stores across the US
- 20 customers
- 5 suppliers
- ~90 days of transaction history (~2,500+ transactions)

## Project Structure

```
retail-medallion-db/
├── README.md
├── docs/
│   └── data-dictionary.md
├── scripts/
│   ├── config.ps1
│   ├── install.ps1
│   ├── run-etl-verify.ps1
│   └── connect-sql.ps1
└── sql/
    ├── 01-create-database.sql
    ├── 02-create-schemas.sql
    ├── 03-sample-data.sql
    ├── tables/
    │   ├── bronze/
    │   ├── silver/
    │   └── gold/
    ├── stored-procedures/
    └── views/
```

## Connection Details

```
Server: DESKTOP-I71T2NV\SQLEXPRESS
Database: RetailMedallion
Authentication: Windows Authentication
```

## License

MIT License - Feel free to use this for learning and development.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
