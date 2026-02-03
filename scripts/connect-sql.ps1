$serverName = "DESKTOP-I71T2NV\SQLEXPRESS"
$connectionString = "Server=$serverName;Integrated Security=True;"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = $connectionString
    $conn.Open()

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT @@VERSION"
    $result = $cmd.ExecuteScalar()

    Write-Host "Connected successfully!"
    Write-Host "SQL Server Version:"
    Write-Host $result

    $conn.Close()
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
