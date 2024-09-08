Import-Module posh-git
$poshTheme = [System.IO.Path]::Join($env:USERPROFILE, "gabo-posh-theme.omp.json")
oh-my-posh init pwsh --config $poshTheme | Invoke-Expression

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

## Tab completion for Nuke
Register-ArgumentCompleter -Native -CommandName nuke -ScriptBlock {
	param($commandName, $wordToComplete, $cursorPosition)

	nuke :complete "$wordToComplete" | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}

## Tab completion for Azure CLI
Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    $completion_file = New-TemporaryFile
    $env:ARGCOMPLETE_USE_TEMPFILES = 1
    $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
    $env:COMP_LINE = $wordToComplete
    $env:COMP_POINT = $cursorPosition
    $env:_ARGCOMPLETE = 1
    $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
    $env:_ARGCOMPLETE_IFS = "`n"
    $env:_ARGCOMPLETE_SHELL = 'powershell'
    az 2>&1 | Out-Null
    Get-Content $completion_file | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
    }
    Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS, Env:\_ARGCOMPLETE_SHELL
}

function az-prod {
	az account set --subscription 611f2c82-f542-4424-9720-1cdb67088c2a
	$account = az account show | ConvertFrom-Json
	$account
}

function az-dev {
	az account set --subscription 0f009b83-9652-4e0f-b891-2e6d816ecb88
	$account = az account show | ConvertFrom-Json
	$account
}

function az-gabo {
	az account set --subscription e321f168-8250-4ebb-b970-5b9f6a8f1847
	$account = az account show | ConvertFrom-Json
	$account
}

function az-mino {
	az account set --subscription 201bbd88-5ccc-47b0-b7e5-b7dd65985971
	$account = az account show | ConvertFrom-Json
	$account
}

function az-sponsor {
	az account set --subscription f26537be-6bf3-423e-8c30-f567aaa76bf5
	$account = az account show | ConvertFrom-Json
	$account
}

function GetAzureObjectById([string] $objectId) {
	az rest --method POST --url 'https://graph.microsoft.com/v1.0/directoryObjects/getByIds' --headers 'Content-Type=application/json' --body ('{ \"ids\": [\"' + $objectId + '\" ] }')
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

function GenerateRandomBytes {
	param(
		[int]$numberOfBytes = 32
	)

	$randomBytes = New-Object byte[] $numberOfBytes
	$randomNumberGenerator = [System.Security.Cryptography.RandomNumberGenerator]::Create()
	$randomNumberGenerator.GetBytes($randomBytes)
	$randomNumberGenerator.Dispose()

	$hexString = -join ($randomBytes | ForEach-Object { $_.ToString("X2") })
	Write-Output $hexString
}
