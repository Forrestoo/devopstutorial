@allowed([
  'nonprod'
  'prod'
])
param enviromentType string
param workspaceName string = 'granges'

/** Databricks specific variables*/
var databricksTier = (enviromentType == 'prod') ? 'premium' : 'standard'
var databricksLocation = 'northeurope' // swedencentral does not exist for databricks
var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'
var managedResourceGroupId = '${subscription().id}/resourceGroups/${managedResourceGroupName}'

/* Databricks workspace*/
resource databricksWorkspaceResource  'Microsoft.Databricks/workspaces@2018-04-01' = {
  location: databricksLocation
  name: workspaceName
  sku: {
    name: databricksTier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
  }
}
