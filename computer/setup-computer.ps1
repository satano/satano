Write-Host "Set proxy for netsh"
netsh winhttp import proxy source=ie

Write-Host "Install Powershell module 'posh-git'"
Install-Module posh-git -Force

Write-Host "Install Powershell module 'oh-my-posh'"
Install-Module oh-my-posh -Force

if ([String]::IsNullOrEmpty($PROFILE)) {
	Write-Host 'Profile will not be set, because $PROFILE variable is empty.'
} elseif (-not (Test-Path $PROFILE)) {
	Write-Host "Copy profile file to '$PROFILE'"
	$source = [System.IO.Path]::Join($PSScriptRoot, "Microsoft.PowerShell_profile.ps1")
	Copy-Item -Path $source -Destination $PROFILE
} else {
	Write-Host "Profile file '$PROFILE' already exist. I will not modify it."
}
