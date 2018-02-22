#requires library from https://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki
#correct version for processor architecture and .net version must be installed.

#create eventlog
New-EventLog -Source "Datto" -LogName "Application"

#Load Library
Add-Type -Path "C:\Program Files\System.Data.SQLite\2015\bin\System.Data.SQLite.dll"

#get number of succeses in last 24 hours
$con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
$con.ConnectionString = "Data Source=C:\Windows\System32\config\systemprofile\AppData\Local\Datto\Datto Windows Agent\dba.sqlite"
$con.Open()
$sql = $con.CreateCommand()
$sql.CommandText = "select count(result) from history where history.result = 'success' AND history.datetm  >= date('now', '-1 days')"
$adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
$data = New-Object System.Data.DataSet
[void]$adapter.Fill($data)
$success = $data.tables.rows
$sql.Dispose()
$con.Close()

#get number of filures in last 24 hours
$con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
$con.ConnectionString = "Data Source=C:\Windows\System32\config\systemprofile\AppData\Local\Datto\Datto Windows Agent\dba.sqlite"
$con.Open()
$sql = $con.CreateCommand()
$sql.CommandText = "select count(result) from history where history.result = 'failure' AND history.datetm  >= date('now', '-1 days')"
$adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
$data = New-Object System.Data.DataSet
[void]$adapter.Fill($data)
$failure = $data.tables.rows
$sql.Dispose()
$con.Close()

#analyze results
if ($failure."count(result)" -gt 1) {Write-EventLog -LogName Application -Source "Datto" -EntryType Information -EventID 991 -Message "Backups Failed"}
if ($success."count(result)" -gt 1) {Write-EventLog -LogName Application -Source "Datto" -EntryType Information -EventID 992 -Message "Backups Successful"}

#other non monitored conditions
#if ($success."count(result)" -lt 1) {Write-Host Nobackupscompleted}
#if ($failure."count(result)" -lt 1) {Write-Host Nofailures}


