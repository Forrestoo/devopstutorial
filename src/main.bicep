@allowed([
  'nonprod'
  'prod'
])
param enviromentType string
param location string = resourceGroup().location
param dataLakeName string =  'dlgranges${uniqueString(resourceGroup().id)}' // must be lowercase and max 24 char
param dataFactoryName string = 'dataFactoryGranges${uniqueString(resourceGroup().id)}'
param workspaceName string = 'granges'

module databricksModule './databricksModule.bicep' = {
  name: workspaceName
  params: {
    enviromentType: enviromentType
    workspaceName: workspaceName
  }
}


module dataFactoryModule './datafactoryModule.bicep' = {
  name: dataFactoryName
  params: {
    dataFactoryName: dataFactoryName
    enviromentType: enviromentType
  }
}

module dataLakeModule './datalakeModule.bicep' = {
  name: dataLakeName
  params: {
    enviromentType: enviromentType
    dataLakeName: dataLakeName
    location: location
  }
}

