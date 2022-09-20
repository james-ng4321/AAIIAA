# Make sure you are authenticated with 
# Connect-AzAccount
#Connect-AzAccount -TenantId 7f2c1900-9fd4-4b89-91d3-79a649996f0a

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

$Results2 += New-Object PSObject -property @{ 
ResourceName = $Results.VaultName
ResourceGroup = $Results.ResourceGroupName
Location = $Results.Location
ResourceID = $Results.ResourceId
Tags = $Results.TagsTable
#PublicNetworkAccess = $Results.PublicNetworkAccess
WhitelistIP = $Results.NetworkAcls.IpAddressRangesText
AllowPublicAccess = if(($Results.PublicNetworkAccess -eq 'Enabled')-and($Results.NetworkAcls.DefaultAction -eq 'Allow')){'True'}else{''}
RestrictAccess = if(($Results.PublicNetworkAccess -eq 'Enabled') -and ($Results.NetworkAcls.DefaultAction -eq 'Allow')){'True'}else{''}
DisableAccess = if(($Results.PublicNetworkAccess -eq "Disable")-and ($Results.NetworkAcls.DefaultAction -eq "Deny")){'True'}else{''}
}
}
$path= ".\02 - Validate Result-KV.CSV"
$Results2 | select ResourceName,ResourceGroup,ResourceID,Location,Tags,AllowPublicAccess,ResrictAccess,DisableAccess,WhitelistIP | Export-Csv -Path $path -NoTypeInformation
echo "02 - Validate Result-KV.CSV is generated !"

