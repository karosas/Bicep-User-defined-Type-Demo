import { GeneralSharedConfig, PrivateEndpointCreationConfig, SubnetInfo } from '../types.bicep'

param general GeneralSharedConfig
param privateEndpoint PrivateEndpointCreationConfig
param appDelegatedSubnet SubnetInfo

// -------------------------------------------------------------------------------------------- //
// Imports

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: '${appDelegatedSubnet.vnet}/${appDelegatedSubnet.subnet}'
}

// -------------------------------------------------------------------------------------------- //
// Service Plan

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: toUpper('plan-${general.environment}-${general.solution}-WE' )
  tags: general.tags
  location: general.location
  properties: {
    reserved: true
  }
  sku: {
    name: (general.environment == 'PRD' ? 'P1V3' : 'S1')
  }
  kind: 'linux'
}

// -------------------------------------------------------------------------------------------- //
// App Service

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: toUpper('webapp-${general.environment}-${general.solution}-WE' )
  tags: general.tags
  location: general.location
  identity:{
    type:'SystemAssigned'
  }
  kind: 'app,linux'
  properties: {
    publicNetworkAccess: 'Disabled'
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: appSubnet.id
    siteConfig: {
      vnetRouteAllEnabled: true
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      autoHealEnabled: true
      ftpsState: 'Disabled'
      healthCheckPath: '/health'
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: (general.environment == 'DEV' ? 'DEVELOPMENT' : 'PRODUCTION')
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
    clientCertEnabled: false
    httpsOnly: true
  }
}

// -------------------------------------------------------------------------------------------- //
// Private Endpoint

module caseHandlingApiEndpoint 'privateEndpoint.bicep' = {
  name:'${deployment().name}-${general.solution}-webapppe'
  params: {
    resource: {
      name: appService.name
      id: appService.id
      subResource: 'sites'
    }
    general: general
    networking: privateEndpoint
  }
}

// -------------------------------------------------------------------------------------------- //
// Outputs

output principalId string = appService.identity.principalId
output webAppName string = appService.name
output webAppResourceId string = appService.id
