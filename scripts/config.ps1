# ============================================
# Retail Medallion Database - Configuration
# ============================================

# Database connection settings
$serverName = "DESKTOP-I71T2NV\SQLEXPRESS"
$databaseName = "RetailMedallion"

# Connection strings
$masterConnStr = "Server=$serverName;Database=master;Integrated Security=True;"
$dbConnStr = "Server=$serverName;Database=$databaseName;Integrated Security=True;"

# Export for use in other scripts
$global:ServerName = $serverName
$global:DatabaseName = $databaseName
$global:MasterConnectionString = $masterConnStr
$global:DatabaseConnectionString = $dbConnStr

Write-Host "Configuration loaded:" -ForegroundColor Cyan
Write-Host "  Server: $serverName" -ForegroundColor White
Write-Host "  Database: $databaseName" -ForegroundColor White
