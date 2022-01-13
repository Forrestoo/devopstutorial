@allowed([
  'nonprod'
  'prod'
])
param enviromentType string
param location string = resourceGroup().location
param dataLakeName string =  'dlgranges${uniqueString(resourceGroup().id)}' // must be lowercase and max 24 char

/* Data Lake specific variables*/
var accessTier = (enviromentType == 'prod') ? 'Hot' : 'Cool'
var accountType = 'Standard_RAGRS'
var kind = 'StorageV2'
var minimumTlsVersion = 'TLS1_2'
var supportsHttpsTrafficOnly = true
var allowBlobPublicAccess = false
var allowSharedKeyAccess = false
var allowCrossTenantReplication = false
var defaultOAuth = true
var networkAclsBypass = 'AzureServices'
var networkAclsDefaultAction = 'Deny'
var isHnsEnabled = true
var isSftpEnabled = false
var keySource = 'Microsoft.Storage'
var encryptionEnabled = true
var infrastructureEncryptionEnabled = false
var retentionDays = 7
var isRetentionEnabled = true

/* Data Lake Gen 2*/
resource dataLakeResource 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: dataLakeName
  location: location
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    defaultToOAuthAuthentication: defaultOAuth
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      ipRules: []
  }
  isHnsEnabled: isHnsEnabled
    isSftpEnabled: isSftpEnabled
    encryption: {
      keySource: keySource
      services: {
        blob: {
          enabled: encryptionEnabled
        }
        file: {
          enabled: encryptionEnabled
        }
        table: {
          enabled: encryptionEnabled
        }
        queue: {
          enabled: encryptionEnabled
        }
      }
      requireInfrastructureEncryption: infrastructureEncryptionEnabled
    }
  }
  sku: {
    name: accountType
  }
  kind: kind
}

resource dataLakeBlobService 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  parent: dataLakeResource
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: isRetentionEnabled
      days: retentionDays
    }
    containerDeleteRetentionPolicy: {
      enabled: isRetentionEnabled
      days: retentionDays
    }
  }
}

resource dataLakeFileService 'Microsoft.Storage/storageAccounts/fileservices@2021-08-01' = {
  parent: dataLakeResource
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: isRetentionEnabled
      days: retentionDays
    }
  }
  dependsOn: [
    dataLakeBlobService
  ]
}
