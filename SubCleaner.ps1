try
{
    write-verbose "Retrieving Identity"
    # Ensures you do not inherit an AzContext in your runbook
    Disable-AzContextAutosave -Scope Process

    write-verbose "Connecting to managed identity and getting context"
    # Connect to Azure with system-assigned managed identity
    $AzureContext = (Connect-AzAccount -Identity).context

    write-verbose "Setting and storing context"
    # set and store context
    #$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
}
catch {
    write-verbose "Error Retrieving identity"
    write-verbose -Message $_.Exception
    throw $_.Exception
}

#write-host "Querying resources for expiresOn tag"
#$expResources= Search-AzGraph -Query 'where todatetime(tags.expiresOn) < now() | project id'

#foreach ($r in $expResources) {
#    write-host "Deleting Resource with ID: $r.id"
#    Remove-AzResource -ResourceId $r.id -Force
#}

write-verbose "Obtaining resource groups with expiresOn tags"

# Get the resource groups with an expiresOn Tag
$rgs =  (Get-AzResourceGroup | ForEach-Object { if ($_.Tags.Keys -contains "expiresOn") { $_.ResourceGroupName  } })
$now = [dateTime]::UtcNow
 
foreach($resourceGroup in $rgs){
    write-verbose "Checking resource group $resourceGroup"
    $rg = Get-AzResourceGroup -name $resourceGroup
    $tagValue = $rg.Tags["expiresOn"]
    write-verbose "On resource group $resourceGroup, found tag 'expiresOn' with value of $tagValue"
    $expires = [Datetime]::ParseExact($tagValue, 'yyyy-MM-dd',$null)
    if($expires -le $now) {
        write-verbose "... Deleting Resource Group: $resourceGroup"
        Remove-AzResourceGroup -Name $resourceGroup -Force
    }
}
