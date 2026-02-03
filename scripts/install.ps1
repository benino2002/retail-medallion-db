# ============================================
# Retail Medallion Database - Installation Script
# ============================================

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\config.ps1"

function Execute-SQLFile {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw
    $batches = $content -split '\bGO\b'

    $conn = New-Object System.Data.SqlClient.SqlConnection($global:DatabaseConnectionString)
    $conn.Open()

    foreach ($batch in $batches) {
        $batch = $batch.Trim()
        if ($batch -ne '') {
            try {
                $cmd = $conn.CreateCommand()
                $cmd.CommandText = $batch
                $cmd.CommandTimeout = 120
                $cmd.ExecuteNonQuery() | Out-Null
            }
            catch {
                Write-Host "Warning: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    $conn.Close()
}

function Execute-SQL {
    param([string]$Query, [string]$ConnStr = $global:DatabaseConnectionString)

    $conn = New-Object System.Data.SqlClient.SqlConnection($ConnStr)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $Query
    $cmd.CommandTimeout = 120
    try {
        $cmd.ExecuteNonQuery() | Out-Null
        return $true
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally { $conn.Close() }
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  RETAIL MEDALLION DATABASE INSTALLATION" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$sqlPath = Join-Path (Split-Path $scriptPath -Parent) "sql"

# Step 1: Create Database
Write-Host "[1/6] Creating Database..." -ForegroundColor Yellow
$createDbSQL = @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$($global:DatabaseName)')
BEGIN
    CREATE DATABASE [$($global:DatabaseName)]
END
"@
Execute-SQL -Query $createDbSQL -ConnStr $global:MasterConnectionString
Write-Host "      Done!" -ForegroundColor Green

# Step 2: Create Schemas
Write-Host "[2/6] Creating Schemas..." -ForegroundColor Yellow
Execute-SQLFile (Join-Path $sqlPath "02-create-schemas.sql")
Write-Host "      Done!" -ForegroundColor Green

# Step 3: Create Tables
Write-Host "[3/6] Creating Tables..." -ForegroundColor Yellow
Get-ChildItem "$sqlPath\tables" -Recurse -Filter "*.sql" | ForEach-Object {
    Execute-SQLFile $_.FullName
}
Write-Host "      Done!" -ForegroundColor Green

# Step 4: Create Stored Procedures
Write-Host "[4/6] Creating Stored Procedures..." -ForegroundColor Yellow
Execute-SQLFile (Join-Path $sqlPath "stored-procedures\all-procedures.sql")
Write-Host "      Done!" -ForegroundColor Green

# Step 5: Create Views
Write-Host "[5/6] Creating Views..." -ForegroundColor Yellow
Execute-SQLFile (Join-Path $sqlPath "views\all-views.sql")
Write-Host "      Done!" -ForegroundColor Green

# Step 6: Load Sample Data
Write-Host "[6/6] Loading Sample Data..." -ForegroundColor Yellow
Execute-SQLFile (Join-Path $sqlPath "03-sample-data.sql")

# Populate date dimension
Execute-SQL "EXEC ETL.uspPopulateDimDate @StartDate = '2024-01-01', @EndDate = '2026-12-31'"

# Run ETL pipeline
Execute-SQL "EXEC ETL.uspRunFullPipeline"
Write-Host "      Done!" -ForegroundColor Green

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  INSTALLATION COMPLETE!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Database: $($global:DatabaseName)" -ForegroundColor White
Write-Host "Server: $($global:ServerName)" -ForegroundColor White
Write-Host ""
Write-Host "Run .\run-etl-verify.ps1 to verify installation" -ForegroundColor Yellow
