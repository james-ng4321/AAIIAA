# Make sure you are authenticated with 
# Connect-AzAccount
#Connect-AzAccount -TenantId 7f2c1900-9fd4-4b89-91d3-79a649996f0a
# LA workspace ID
[string]$WorkspaceResourceID = 'aabecabb-3f4e-4d65-8a7c-17434a094cb6'
[string]$WorkspaceResourceID2 = 'f486ca19-3cb9-4345-8639-7ccfe1fe149a'
# CSV file
$inputCsvFile = "HK-kv.csv"

# CSV path
$inputPath = "."
# import csv
$inputCsv = Import-CSV -Path $inputPath\$inputCsvFile -Delimiter ";"
$SAlist = $inputCsv |
select AccountName |
Sort-Object * -Unique
# for output csv
$Results2 = @()
#create folder
#$date=$((Get-Date).ToString('yyyy-MM-dd-hhmm'))
#New-Item -ItemType Directory -Path ".\Generate Log SA-$date" -erroraction 'silentlycontinue'
# Loop SAlist - List of SA which is unique
 foreach ( $Row in $SAlist )
{
$Results = Get-AzKeyVault -name $Row.AccountName
$WorkspaceResourceID3 = Get-AzDiagnosticSetting -ResourceId $Results.ResourceId
$Results2 += New-Object PSObject -property @{ 
ResourceName = $Results.VaultName
ResourceGroup = $Results.ResourceGroupName
Location = $Results.Location
ResourceID = $Results.ResourceId
Tags = $Results.TagsTable
#PublicNetworkAccess = $Results.PublicNetworkAccess
DiagnosticSetting = if(($WorkspaceResourceID -eq $WorkspaceResourceID3 )-or($WorkspaceResourceID2 -eq $WorkspaceResourceID3)){'True'}else{'False'}
WhitelistIP = $Results.NetworkAcls.IpAddressRangesText
AllowPublicAccess = if(($Results.PublicNetworkAccess -eq 'Enabled')-and($Results.NetworkAcls.DefaultAction -eq 'Allow')){'True'}else{''}
RestrictAccess = if(($Results.PublicNetworkAccess -eq 'Enabled') -and ($Results.NetworkAcls.DefaultAction -eq 'Allow')){'True'}else{''}
DisableAccess = if(($Results.PublicNetworkAccess -eq "Disable")-and ($Results.NetworkAcls.DefaultAction -eq "Deny")){'True'}else{''}
}
}
$path= ".\02 - Validate Result-KV.CSV"
$Results2 | select ResourceName,ResourceGroup,ResourceID,Location,DiagnosticSetting,AllowPublicAccess,RestrictAccess,DisableAccess,WhitelistIP,Tags | Export-Csv -Path $path -NoTypeInformation
echo "02 - Validate Result-KV.CSV is generated !"

