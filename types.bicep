/*
    Custom bicep types to make configuration more structured
*/

// -------------------------------------------------------------------------------------------- //
// Project Parameters

// Bicep doesn't support adding decorators like @minLength inside properties of user-defined object type
// Instead we can create a custom type that has restrictions we want

@export()
type GeneralSharedConfig = {
  @minLength(2)
  @maxLength(10)
  solution: string
  environment: 'DEV' | 'PROD'
  location: string

  @description('Tags to add to resources created where applicable')
  tags: object
}

@export()
type ResourceGroupNetworkingConfig = {
  @description('Name of VNET')
  vnet: string

  @description('Name of a subnet within given vnet that is not delegated and will be used to place private endpoints')
  undelegatedSubnet: string

  @description('Name of subnet that is delegated to serverFarms and used exclusively for webapp\'s service plan')
  webAppSubnet: string
}

@export()
@description('Dictionary of private IP addresses used for private endpoints within resource group')
type SolutionIpAddressDictionary = {
  webapp: string
}

// -------------------------------------------------------------------------------------------- //
// Private Endpoint

@export()
type SubnetInfo = {
  @description('Name of the subnet')
  subnet: string

  @description('Name of the VNET that subnet belongs to')
  vnet: string
}

@export()
@description('Networking related parameters to create a private endpoint')
type PrivateEndpointCreationConfig = {
  @description('Subnet where private endpoint should be placed')
  subnetInfo: SubnetInfo

  @description('Static IP for the private endpoint')
  ip: string
}

@export()
@description('Resource information to provide for private endpoint')
type PrivateEndpointResourceConfig = {
  id: string
  name: string
  @description('subresource name that endpoint targets (e.g. sites/vault) - https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource')
  subResource: string
}

/*

Additionally something like this would be nice as well
However current vscode bicep extension seems to not recognize/support function imports yet and mark them as errors

@export()
@description('Generates resource name to keep naming consistent within Resource Group')
func generateResourceName(resourceShortName string, environment string, solution string, suffix string?) string => 
  toUpper('${resourceShortName}-${environment}-${solution}${suffix == null ? '' : '-${suffix}'}')

*/ 
