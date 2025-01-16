// becip 
//change log 
// 1.0.0 - Initial version 1/16/25
// 1.0.1 - Updated for Azure Government use will need to verify the exact API versions supported in your Azure Government subscription.

@description('Location for the private endpoint')
param location string = resourceGroup().location

@description('Name of the private endpoint')
param privateEndpointName string

@description('Resource ID of the Azure resource for which private endpoint needs to be created')
param targetResourceId string

@description('Subresource name of the Azure resource (e.g., "blob" for storage account)')
param groupId string

@description('Virtual network name where private endpoint will be created')
param vnetName string

@description('Subnet name where private endpoint will be created')
param subnetName string

@description('Private DNS Zone Resource ID')
param privateDnsZoneId string

// Reference existing virtual network and subnet
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-01-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-01-01' existing = {
  name: subnetName
  parent: virtualNetwork
}

// Create Private Endpoint
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: [
            groupId
          ]
        }
      }
    ]
  }
  tags: {
    Environment: 'Production'
  }
}

// Create Private DNS Zone Group
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
