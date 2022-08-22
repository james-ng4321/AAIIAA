#Function 
# Simple try, if error , directly return false
Function checkSA_diag($SAid,$workspaceid,$errorlogpath){
    #Echo $SAid
    #Echo $workspaceid
    try {
        $output = Get-AzDiagnosticSetting -ResourceId $SAid -ErrorAction Stop
    }
    catch {
        echo "catch"
        $_.Exception.Message
        "Input> $SAID.  Failed at $(Get-Date). Error: $($_.Exception.Message)" | Add-Content $errorlogpath
        Return $false
     }

    if ($output.WorkspaceId -eq $workspaceid) 
    { Return $true }
Return $false
}

#PARAMETER
$workspaceid = "/subscriptions/809647d3-201b-4c39-86db-bb00cb3e5581/resourcegroups/rg-aia-uat01-hk/providers/microsoft.operationalinsights/workspaces/ala-test1"
#$SAid = "/subscriptions/30fd6d8e-bebb-4118-b139-7868d97f9313/resourceGroups/rg-aia-p1oc/providers/Microsoft.Storage/storageAccounts/stoaiapocsto03/blobServices/default"
$errorlogpath = "/home/james/"

## TEST FUNCTION
##checkBlob_diag $SAid $workspaceid "$errorlogpathsaerror.txt"

#INITIAL
#Set-AzContext -SubscriptionId "xxxx-xxxx-xxxx-xxxx"

#0 export the full list of SA
$outputcsv = "/home/james/kv.csv"
$checkedcsv = "/home/james/kv_diag.csv"
$allSA = Get-AzKeyVault  |export-csv -Encoding UTF8 -Path $outputcsv -NoTypeInformation #-Delimiter ";"

#1 Add blob, file , queue, table id into csv
$csv = Import-Csv $outputcsv
#adddiag column

#2 check and update table with dianostoc config
$csv = Import-Csv $outputcsv

$csv | 
Select-Object *,@{Name='diag_kv';Expression={(checkSA_diag $_.'Resource id' $workspaceid "$errorlogpathsaerror.txt")}} |
Export-Csv $checkedcsv  -NoTypeInformation





