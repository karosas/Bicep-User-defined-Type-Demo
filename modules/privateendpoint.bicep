import { PrivateEndpointCreationConfig, GeneralSharedConfig, PrivateEndpointResourceConfig } from '../types.bicep'

param general GeneralSharedConfig
param networking PrivateEndpointCreationConfig
param resource PrivateEndpointResourceConfig

// -------------------------------------------------------------------------------------------- //
// Variables

var networkInterfaceName = '${resource.name}-nic'

// -------------------------------------------------------------------------------------------- //
// Imports

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  name: '${networking.subnetInfo.vnet}/${networking.subnetInfo.subnet}'
}

// -------------------------------------------------------------------------------------------- //
// Private Endpoint

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: resource.name
  location: general.location
  tags: general.tags

  properties: {
    ipConfigurations: [
      {
        name: resource.subResource
        properties: {
          groupId: resource.subResource
          memberName: resource.subResource
          privateIPAddress: networking.ip
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
    customNetworkInterfaceName: networkInterfaceName
    privateLinkServiceConnections: [
      {
        name: resource.name
        properties: {
// Disabling warning because we're referencing full resource id of generic resource, 
// so we can't import it, instead we trust the input and pass it fully
#disable-next-line use-resource-id-functions
          privateLinkServiceId: resource.id
          groupIds: [
            resource.subResource
          ]
        }
      }
    ]
  }
}


