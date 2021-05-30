@description('The name of the Managed Cluster resource.')
param resourceName string = 'all-things-aks'

@description('The location of AKS resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'all-things-dns'

@description('The version of Kubernetes.')
param kubernetesVersion string = '1.20.5'

@allowed([
  'azure'
  'kubenet'
])
@description('Network plugin used for building Kubernetes network.')
param networkPlugin string = 'kubenet'

@description('Boolean flag to turn on and off of RBAC.')
param enableRBAC bool = true

@description('Boolean flag to turn on and off of virtual machine scale sets')
param vmssNodePool bool = true


resource resourceName_resource 'Microsoft.ContainerService/managedClusters@2021-02-01' = {
  location: location
  name: resourceName
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: enableRBAC
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 0
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        osDiskType: 'Managed'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 30
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: networkPlugin
    }
  }
  tags: {}
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: []
}

output resourceName string = resourceName
output controlPlaneFQDN string = resourceName_resource.properties.fqdn
