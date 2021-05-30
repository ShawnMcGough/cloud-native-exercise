# Cloud Native Exercise

 This is a simple project to demonstrate some cloud native stuff.

## Prerequisites (Windows or Linux)

* An Azure subscription. If you don't have an Azure subscription, you can create a free account.
* PowerShell Core
* Azure CLI 2.20+
  - `apt install azure-cli`
  - `az upgrade`
* Azure CLI Bicep Extension
  - `az bicep install`
* Azure CLI AKS Extension
  - `az aks install-cli`
* Helm v3 [installed][Helm Install].
* kubectl

## How to Deploy/Run

After cloning this repository, you can type the following command to deploy the app:

### Windows Powershell
`.\deploy.ps1`

### Linux Powershell
`pwsh ./deploy.ps1`

The deploy script will test the REST API with a GET request. 
The url is also displayed so you can view the swagger docs.

## What is Happening

The `deploy` script will:
1. provision an AKS cluster via .bicep 
1. deploy a dotnet core 5.0 web api application via helm chart
1. get the public IP address via kubectl
1. validate a simple rest request works via powershell `Invoke-RestMethod`

## Cleanup

To teardown, run the following command:

### Windows Powershell
`.\teardown.ps1`

### Linux Powershell
`pwsh ./teardown.ps1`



[Helm Install]:  https://helm.sh/docs/intro/install/#from-apt-debianubuntu

