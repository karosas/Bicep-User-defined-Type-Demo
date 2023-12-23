targetScope = 'resourceGroup'
import { GeneralSharedConfig, ResourceGroupNetworkingConfig, SolutionIpAddressDictionary } from 'types.bicep'

// Properties of 'GeneralSharedConfig' provided flat, because some of them are not configurable or generated at runtime
// I personally found it nicer to go this way and then construct 'GeneralSharedConfig'
param environment string
param location string = resourceGroup().location
param solution string = 'userapi'

param networking ResourceGroupNetworkingConfig
param ipAddressDict SolutionIpAddressDictionary

// -------------------------------------------------------------------------------------------- //
// Variables

var general = {
  environment: environment
  location: location
  solution: solution
  tags: {
    Environment: environment
    Service: solution
  }
}

// -------------------------------------------------------------------------------------------- //
// Imports
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: networking.vnet
}

resource webAppDelegatedSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-11-01' existing = {
  name: networking.webAppSubnet
  parent: vnet
}

resource undelegatedSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-11-01' existing = {
  name: networking.undelegatedSubnet
  parent: vnet
}


// -------------------------------------------------------------------------------------------- //
// WebApp

module userApiWebApp 'modules/webapp.bicep' = {
  scope: resourceGroup()
  name: '${deployment().name}-app'
  params: {
    appDelegatedSubnet: {
      vnet: vnet.name
      subnet: webAppDelegatedSubnet.name
    }
    general: general
    privateEndpoint: {
      ip: ipAddressDict.webapp
      subnetInfo: {
        vnet: vnet.name
        subnet: undelegatedSubnet.name
      }
    }
  }
}
