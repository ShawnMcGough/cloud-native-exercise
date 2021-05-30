# Cloud Native Exercise

 This is a simple project to demonstrate some cloud native stuff.

## Prerequisites (Windows or Linux)

* An Azure subscription
* [PowerShell 7+][powershell install]
* [Azure CLI 2.20+][az install] (check with `az -v`)
  > ⚠ Linux Warning: Ubuntu 20.04 (Focal Fossa) and 20.10 (Groovy Gorilla) include an azure-cli package with version 2.0.81 provided by the `universe` repository. This package is outdated and not recommended. If this package is installed, remove the package before continuing by running the command `sudo apt remove azure-cli -y && sudo apt autoremove -y`.
* The following `az cli` extensions:
  - aks [`az aks install-cli`]
  - bicep [`az bicep install`] 
* [Helm 3+][Helm Install]

## How to Deploy/Run

> Note: Works on Windows or Linux 

After cloning this repository, you can type the following command from PowerShell to deploy the app:

`.\deploy.ps1`

The deploy script will test the REST API with a GET request. 
The url is also displayed so you can view the swagger docs.

## What is Happening

The `deploy.ps1` script will:
1. provision an AKS cluster via .bicep 
1. deploy a dotnet core 5.0 web api application via helm chart
1. get the public IP address via kubectl
1. validate a simple rest request works via powershell `Invoke-RestMethod`

## Cleanup

To teardown, run the following command:

`.\teardown.ps1`



[powershell install]: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1#powershell
[az install]: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli#install
[Helm Install]:  https://helm.sh/docs/intro/install/#through-package-managers

