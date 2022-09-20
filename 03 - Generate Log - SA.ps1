# Make sure you are authenticated with 
# Connect-AzAccount
# LA workspace ID
[string]$WorkspaceID = '471db0a3-ca04-4673-9174-3530edf7fd7f'
New-Item -ItemType Directory -Path ".\Generate Log SA-$((Get-Date).ToString('yyyy-MM-dd'))" -erroraction 'silentlycontinue'
# CSV file
$inputCsvFile = "HK-SA.csv"
# CSV path
$inputPath = "."
$inputCsv = Import-CSV -Path $inputPath\$inputCsvFile -Delimiter ","
$SAlist = $inputCsv |
select AccountName |
Sort-Object * -Unique

$SAoutput = @() # for output csv
# Loop SAlist - List of SA which is unique
 foreach ( $Row in $SAlist )
{
[string]$Query = "
StorageBlobLogs 
| union StorageFileLogs, StorageQueueLogs, StorageTableLogs
| where AccountName contains"+" '"+$Row.AccountName+"'"+"
| extend HKTimestamp = TimeGenerated + 8h 
| where TimeGenerated > ago(31d) and Uri !contains 'sk=system-1'
| summarize Count=count() by CallerIpAddress, AccountName, ServiceType, AuthenticationType,StatusText, UserAgentHeader, _ResourceId
| sort by AccountName 
"

$Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $Query
$SAoutput += $Results.Results
}
$path2= ".\Generate Log SA-$((Get-Date).ToString('yyyy-MM-dd'))\03 – Generate Log By Count.CSV"
$SAoutput | Export-Csv -Path $path2
echo "03 – Generate Log By Count.CSV is generated"


 foreach ( $Row in $SAlist )
{
[string]$Query1 = "
StorageBlobLogs 
| union StorageFileLogs, StorageQueueLogs, StorageTableLogs
| where AccountName contains"+" '"+$Row.AccountName+"'"+"
| extend HKTimestamp = TimeGenerated + 8h 
| where TimeGenerated > ago(31d) and Uri !contains 'sk=system-1'
| project TimeGenerated, HKTimestamp, AccountName, ServiceType, AuthenticationType, AuthenticationHash, RequesterUpn, StatusCode, StatusText, Uri, CallerIpAddress, UserAgentHeader,ClientRequestId, Category,Type 
| sort by HKTimestamp, AccountName 
"

$Results1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $Query1
$SAoutput1 = $Results1.Results
$path1= ".\Generate Log SA-$((Get-Date).ToString('yyyy-MM-dd'))\03 – Generate Log Raw -"+$Row.AccountName+".CSV"
$SAoutput1 | Export-Csv -Path $path1
echo "Raw data is generated to $path1"
}
