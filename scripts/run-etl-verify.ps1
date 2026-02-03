$serverName = "DESKTOP-I71T2NV\SQLEXPRESS"
$databaseName = "RetailMedallion"
$connStr = "Server=$serverName;Database=$databaseName;Integrated Security=True;"

function Execute-Query {
    param([string]$Query)
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($Query, $conn)
    $cmd.CommandTimeout = 120
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset) | Out-Null
    $conn.Close()
    return $dataset.Tables[0]
}

function Execute-NonQuery {
    param([string]$Query)
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($Query, $conn)
    $cmd.CommandTimeout = 120
    $cmd.ExecuteNonQuery() | Out-Null
    $conn.Close()
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  RUNNING ETL PIPELINE" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/8] Running ETL.uspPopulateDimDate..." -ForegroundColor Yellow
Execute-NonQuery "EXEC ETL.uspPopulateDimDate @StartDate = '2024-01-01', @EndDate = '2026-12-31'"
Write-Host "      Done!" -ForegroundColor Green

Write-Host "[2/8] Running ETL.uspLoadSilverCustomers..." -ForegroundColor Yellow
Execute-NonQuery "EXEC ETL.uspLoadSilverCustomers"
Write-Host "      Done!" -ForegroundColor Green

Write-Host "[3/8] Running ETL.uspLoadSilverProducts..." -ForegroundColor Yellow
Execute-NonQuery "EXEC ETL.uspLoadSilverProducts"
Write-Host "      Done!" -ForegroundColor Green

Write-Host "[4/8] Running ETL.uspLoadSilverStores..." -ForegroundColor Yellow
Execute-NonQuery "EXEC ETL.uspLoadSilverStores"
Write-Host "      Done!" -ForegroundColor Green

Write-Host "[5/8] Running ETL.uspLoadFactSales..." -ForegroundColor Yellow
Execute-NonQuery "EXEC ETL.uspLoadFactSales"
Write-Host "      Done!" -ForegroundColor Green

Write-Host "[6/8] Running ETL.uspRefreshGoldDailySales..." -ForegroundColor Yellow
Execute-NonQuery "EXEC ETL.uspRefreshGoldDailySales"
Write-Host "      Done!" -ForegroundColor Green

Write-Host "[7/8] Running ETL.uspRefreshGoldCustomerAnalytics..." -ForegroundColor Yellow
Execute-NonQuery "EXEC ETL.uspRefreshGoldCustomerAnalytics"
Write-Host "      Done!" -ForegroundColor Green

Write-Host "[8/8] ETL Pipeline Complete!" -ForegroundColor Green

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  VERIFYING TABLE ROW COUNTS" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Silver Layer Tables
Write-Host "SILVER LAYER TABLES:" -ForegroundColor Yellow
Write-Host "--------------------" -ForegroundColor Yellow

$silverTables = @(
    "Silver.DimCustomer",
    "Silver.DimProduct",
    "Silver.DimStore",
    "Silver.DimSupplier",
    "Silver.DimDate",
    "Silver.FactSales",
    "Silver.FactInventory"
)

$silverResults = @()
foreach ($table in $silverTables) {
    $count = (Execute-Query "SELECT COUNT(*) AS Cnt FROM $table").Cnt
    $status = if ($count -gt 0) { "OK" } else { "EMPTY" }
    $color = if ($count -gt 0) { "Green" } else { "Red" }
    $silverResults += [PSCustomObject]@{
        Table = $table
        RowCount = $count
        Status = $status
    }
    Write-Host "  $table : $count rows " -NoNewline
    Write-Host "[$status]" -ForegroundColor $color
}

Write-Host ""
Write-Host "GOLD LAYER TABLES:" -ForegroundColor Yellow
Write-Host "------------------" -ForegroundColor Yellow

$goldTables = @(
    "Gold.DailySalesSummary",
    "Gold.StorePerformance",
    "Gold.ProductPerformance",
    "Gold.CustomerAnalytics",
    "Gold.CategoryPerformance",
    "Gold.InventorySummary",
    "Gold.ExecutiveKPIs"
)

$goldResults = @()
foreach ($table in $goldTables) {
    $count = (Execute-Query "SELECT COUNT(*) AS Cnt FROM $table").Cnt
    $status = if ($count -gt 0) { "OK" } else { "EMPTY" }
    $color = if ($count -gt 0) { "Green" } else { "Red" }
    $goldResults += [PSCustomObject]@{
        Table = $table
        RowCount = $count
        Status = $status
    }
    Write-Host "  $table : $count rows " -NoNewline
    Write-Host "[$status]" -ForegroundColor $color
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$silverEmpty = ($silverResults | Where-Object { $_.RowCount -eq 0 }).Count
$goldEmpty = ($goldResults | Where-Object { $_.RowCount -eq 0 }).Count

Write-Host ""
Write-Host "Silver Layer: " -NoNewline
if ($silverEmpty -eq 0) {
    Write-Host "All $($silverTables.Count) tables have data" -ForegroundColor Green
} else {
    Write-Host "$silverEmpty of $($silverTables.Count) tables are EMPTY" -ForegroundColor Red
}

Write-Host "Gold Layer:   " -NoNewline
if ($goldEmpty -eq 0) {
    Write-Host "All $($goldTables.Count) tables have data" -ForegroundColor Green
} else {
    Write-Host "$goldEmpty of $($goldTables.Count) tables are EMPTY" -ForegroundColor Red
}

if ($goldEmpty -gt 0) {
    Write-Host ""
    Write-Host "Empty Gold tables need additional ETL procedures to be created." -ForegroundColor Yellow
}

Write-Host ""
