@allowed([
  'nonprod'
  'prod'
])
param enviromentType string

param dataFactoryName string = 'dataFactoryGranges${uniqueString(resourceGroup().id)}'

/* Data factory specific variables*/
var dataFactoryLocation = 'northeurope' // swedencentral does not exist for datafactory

/** Data Factory*/
resource dataFactoryResource 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: dataFactoryLocation
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource dataFactoryNetwork 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  parent: dataFactoryResource
  name: 'default'
  properties: {}
}

resource dataFactoryIntRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
parent: dataFactoryResource
name: 'AutoResolveIntegrationRuntime'
properties: {
  type: 'Managed'
  managedVirtualNetwork: {
    referenceName: 'default'
    type: 'ManagedVirtualNetworkReference'
  }
  typeProperties: {
    computeProperties: {
      location: 'AutoResolve'
    }
  }
}
dependsOn: [
  dataFactoryNetwork
]
}
