Import-Module posh-git
Import-Module oh-my-posh
$poshTheme = [System.IO.Path]::Join($env:HOMEPATH, "gabo-posh-theme.omp.json")
Set-PoshPrompt -Theme $poshTheme

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

function az-prod {
    az account set --subscription {prod-subscription-id}
    $account = az account show | ConvertFrom-Json
    $account
}
function az-dev {
    az account set --subscription {dev-subscription-id}
    $account = az account show | ConvertFrom-Json
    $account
}
function az-gabo {
    az account set --subscription {gabo-subscription-id}
    $account = az account show | ConvertFrom-Json
    $account
}

function clean-build {
    Write-Host "Deleting 'bin' folders..."
    Get-ChildItem -Path . -Recurse -Filter "bin" -Directory | Remove-Item -Recurse
    Write-Host "Deleting 'obj' folders..."
    Get-ChildItem -Path . -Recurse -Filter "obj" -Directory | Remove-Item -Recurse
}
