[CmdletBinding()]
param(
    [string] [Parameter(Mandatory = $false)] $ResourceGroup = 'all-things-rg',
    [string] [Parameter(Mandatory = $false)] $Location = 'eastus2',
    [string] [Parameter(Mandatory = $false)] $RestAppName = 'restallthings',
    [string] [Parameter(Mandatory = $false)] $AppNamespace = 'allthings'
)
Function Write-Color {
    Param ([String[]]$Text, [ConsoleColor[]]$Color, [Switch]$NoNewline = $false)
    $initColor = @()
    $initColor += $Color
    while ($Color.Length -lt $Text.Length) { $Color += $initColor }
    For ([int]$i = 0; $i -lt $Text.Length; $i++) { 
        Write-Host $Text[$i] -Foreground $Color[$i] -NoNewLine 
    }
    if ($NoNewline -eq $false) { Write-Host '' }
}
Function Set-Header {
    Write-Color ' █████', '╗', ' ██', '╗', '     ██', '╗', '         ████████', '╗', '██', '╗', '  ██', '╗', '███████', '╗', '    ████████', '╗', '██', '╗', '  ██', '╗', '██', '╗', '███', '╗', '   ██', '╗', ' ██████', '╗', ' ███████', '╗' -Color Magenta, White
    Write-Color '██', '╔══', '██', '╗', '██', '║     ', '██', '║         ╚══', '██', '╔══╝', '██', '║', '  ██', '║', '██', '╔════╝    ╚══', '██', '╔══╝', '██', '║', '  ██', '║', '██', '║', '████', '╗  ', '██', '║', '██', '╔════╝ ', '██', '╔════╝' -Color Magenta, White
    Write-Color '███████', '║', '██', '║', '     ██', '║', '            ██', '║', '   ███████', '║', '█████', '╗', '         ██', '║', '   ███████', '║', '██', '║', '██', '╔', '██', '╗', ' ██', '║', '██', '║ ', ' ███', '╗', '███████', '╗' -Color Magenta, White
    Write-Color '██', '╔══', '██', '║', '██', '║', '     ██', '║            ', '██', '║', '   ██', '╔══', '██', '║', '██', '╔══╝         ', '██', '║   ', '██', '╔══', '██', '║', '██', '║', '██', '║╚', '██', '╗', '██', '║', '██', '║   ', '██', '║╚════', '██', '║' -Color Magenta, White
    Write-Color '██', '║  ', '██', '║', '███████', '╗', '███████', '╗       ', '██', '║   ', '██', '║  ', '██', '║', '███████', '╗       ', '██', '║   ', '██', '║  ', '██', '║', '██', '║', '██', '║ ╚', '████', '║╚', '██████', '╔╝', '███████', '║' -Color Magenta, White
    Write-Color '╚═╝  ╚═╝╚══════╝╚══════╝       ╚═╝   ╚═╝  ╚═╝╚══════╝       ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝' -Color White
}

Clear-Host
Set-Header
Write-Color -NoNewline '-> getting subscription info...' -Color White
$subscription = az account show | ConvertFrom-Json
if (!$?) {
    throw '-> FATAL: not logged into Azure. Cannot continue. Run az login.'
}
Write-Color  'OK', '!' -Color Green, White

$subscriptionId = $Subscription.id
Write-Color -Text '-> using subscription [', "$($subscription.name) ($subscriptionId)", ']' -Color White, Cyan, White

Write-Color -NoNewline -Text '-> creating resource group [', "$ResourceGroup", ']...' -Color White, Cyan, White
$rg = az group create --name $ResourceGroup --location $Location --tags type=demo env=dev
if (!$?) {
    throw "-> FATAL: Could not create resource group [$ResourceGroup]. Cannot continue."
}
Write-Color  'OK', '!' -Color Green, White

Write-Color -NoNewline -Text '-> setting default resource group to [', "$ResourceGroup", ']...' -Color White, Cyan, White
az configure --defaults group=$ResourceGroup
if (!$?) {
    throw "-> FATAL: Could not set default resource group [$ResourceGroup]. Cannot continue."
}
Write-Color  'OK', '!' -Color Green, White

Write-Color -Text '-> provisioning Azure Kubernetes Service (AKS) - standby, this takes a bit...' -Color White
$aksResult = az deployment group create -f ./deploy/biceps/aks.bicep 
if (!$?) {
    throw '-> FATAL: Could not create AKS. Cannot continue.'
}
Write-Color  'OK', '!' -Color Green, White

$aksName = ($aksResult | ConvertFrom-Json).properties.outputs.resourceName.value
Write-Color -Text '-> created Azure Kubernetes Service (AKS) [', "$aksName", ']' -Color White, Cyan, White

Write-Color -NoNewline -Text '-> getting AKS credentials...' -Color White
az aks get-credentials -n $aksName --overwrite-existing
if (!$?) {
    throw '-> FATAL: Could not get AKS credentials. Cannot continue.'
}
Write-Color  'OK', '!' -Color Green, White

Write-Color -NoNewline -Text '-> deploying REST api via helm chart(s)...' -Color White
$result = helm upgrade -i --create-namespace -n $AppNamespace $RestAppName ./deploy/charts/rest-all-things/
if (!$?) {
    throw '-> FATAL: Could not helm upgrade. Cannot continue.'
}
Write-Color  'OK', '!' -Color Green, White

Write-Color -NoNewline -Text '-> waiting for REST api external IP...' -Color White

$svcIp = kubectl get --namespace $AppNamespace svc "$RestAppName-rest-all-things" -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'
if (!$?) {
    throw '-> FATAL: Could not get svc IP. Cannot continue.'
}

$i = 0
while ($null -eq $svcIp -and $i -le 6) {
    $i++;
    Start-Sleep -s 10
    Write-Color -NoNewline '.' -Color White
    $svcIp = kubectl get --namespace $AppNamespace svc "$RestAppName-rest-all-things" -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'
} 
if ($null -eq $svcIp) {
    throw '-> FATAL: Could not get svc IP. Cannot continue.'
}

Write-Color  'OK', '!' -Color Green, White

Write-Color -Text '-> svc running @ public IP [', "$svcIp", ']' -Color White, Cyan, White

Write-Color -NoNewline -Text '-> validating REST api...' -Color White

$payload = Invoke-RestMethod -Uri "http://$svcIp/Default"

Write-Color  'OK', '!' -Color Green, White

Write-Color "-> received payload:`r`n" -Color White
Write-Host $payload
Write-Host "`r`n"
Write-Color '********************************************************************************' -Color White
Write-Color '* visit ', "http://$svcIp/swagger/index.html", ' for Swagger documentation.     *' -Color White, Blue, White
Write-Color '********************************************************************************' -Color White

Write-Color -Text '-> All done, ', 'neat', '!' -Color White, Blue, White
Write-Host "`r`n"

