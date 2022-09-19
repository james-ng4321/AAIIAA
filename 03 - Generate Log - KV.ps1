# Make sure you are authenticated with 
# Connect-AzAccount
# LA workspace ID
[string]$WorkspaceID = '471db0a3-ca04-4673-9174-3530edf7fd7f'
New-Item -ItemType Directory -Path ".\Generate Log Raw-$((Get-Date).ToString('yyyy-MM-dd'))"
# CSV file
$inputCsvFile = "input_kv.csv"
# CSV path
$inputPath = "."
$inputCsv = Import-CSV -Path $inputPath\$inputCsvFile
$SAlist = $inputCsv | 
select AccountName, ResourceGroup | 
Sort-Object * -Unique

$SAoutput = @() # for output csv
# Loop SAlist - List of SA which is unique
 foreach ( $Row in $SAlist )
{
[string]$Query = "
AzureDiagnostics
| where TimeGenerated > ago(31d)
| summarize  Count=count() by CallerIPAddress, Resource, ResourceGroup, ResourceId, ResourceType, ResultType
| sort by Resource
"

$Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $Query
$SAoutput += $Results.Results
}
$SAoutput | Export-Csv -Path "03 – Generate Log By Count.CSV"
echo "03 – Generate Log By Count1.CSV is generated"


 foreach ( $Row in $SAlist )
{
[string]$Query1 = "
AzureDiagnostics
| where Resource contains"+" '"+$Row.AccountName+"'"+"
| where TimeGenerated > ago(31d)
| extend HKTimestamp = TimeGenerated + 8h
| project TimeGenerated, HKTimestamp, Resource, ResourceType, CallerIPAddress,clientInfo_s , ResourceId, Category, ResourceGroup, httpStatusCode_d, requestUri_s, ResultType
| sort by HKTimestamp,Resource
"

$Results1 = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $Query1
$SAoutput1 = $Results1.Results
$path1= ".\Generate Log Raw-$((Get-Date).ToString('yyyy-MM-dd'))\03 – Generate Log Raw -"+$Row.AccountName+".CSV"
$SAoutput1 | Export-Csv -Path $path1
echo "Raw data is generated to $path1"
}
