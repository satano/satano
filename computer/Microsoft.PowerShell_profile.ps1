Import-Module posh-git
Import-Module oh-my-posh
$poshTheme = [System.IO.Path]::Join($env:HOMEPATH, "gabo-posh-theme.omp.json")
Set-PoshPrompt -Theme $poshTheme

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

Register-ArgumentCompleter -Native -CommandName nuke -ScriptBlock {
	param($commandName, $wordToComplete, $cursorPosition)

	nuke :complete "$wordToComplete" | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}

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

function az-sponsor {
	az account set --subscription {sponsor-subscription-id}
	$account = az account show | ConvertFrom-Json
	$account
}

function GetAzureObjectById([string] $objectId) {
	az rest --method POST --url 'https://graph.microsoft.com/v1.0/directoryObjects/getByIds' --headers 'Content-Type=application/json'  --body ('{ \"ids\": [\"' + $objectId + '\" ] }')
}

function clean-build {
	Write-Host "Deleting 'bin' folders..."
	Get-ChildItem -Path . -Recurse -Filter "bin" -Directory | Remove-Item -Recurse
	Write-Host "Deleting 'obj' folders..."
	Get-ChildItem -Path . -Recurse -Filter "obj" -Directory | Remove-Item -Recurse
}

# kubectl auto complete
if (Get-Command kubectl -ErrorAction SilentlyContinue) { 
	kubectl completion powershell | Out-String | Invoke-Expression
}
