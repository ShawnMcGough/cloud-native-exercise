[CmdletBinding()]
param(
    [string] [Parameter(Mandatory = $false)] $ResourceGroup = 'all-things-rg'
)

Function Write-Color {
    Param ([String[]]$Text, [ConsoleColor[]]$Color, [Switch]$NoNewline = $false)
    For ([int]$i = 0; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -Foreground $Color[$i] -NoNewLine }
    If ($NoNewline -eq $false) { Write-Host '' }
}

Clear-Host
Write-Color -NoNewline '-> getting subscription info...' -Color White
$subscription = az account show | ConvertFrom-Json
if (!$?) {
    throw '-> FATAL: not logged into Azure. Cannot continue. Run az login.'
}
Write-Color  'OK', '!' -Color Green, White

$subscriptionId = $Subscription.id
Write-Color -Text '-> using subscription [', "$($subscription.name) ($subscriptionId)", ']' -Color White, Cyan, White

Write-Color -Text '-> deleting resource group [', "$ResourceGroup", ']...' -Color White, Cyan, White
az group delete --name $ResourceGroup 
if (!$?) {
    Write-Color  'Did ', 'not', ' delete!' -Color White, Red, White
    return
}
Write-Color  'OK', '!' -Color Green, White
Write-Host "`r`n"
Write-Color -Text '-> All done!' -Color White
Write-Host "`r`n"