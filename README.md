# AzureSubscriptionCleanerRunbook
Simple runbook to remove indicated or expired resource groups

## Important
When using this as a runbook, ensure you give the automation account - managed identity a role of contributor at the subscription level/scope
otherwise you will get errors such as 'this.Subscription.ID' is null and other errors when attempting to remove a resource group.

Reader would be sufficient to obtain the subscription Id however in order to remove resource groups, then contrinutor is required.

