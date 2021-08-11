param(
	[string] $Proxy = ""
)

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
	Write-Host "Running as administrator. Environment variables will be set also for machine scope." -ForegroundColor Green
}

$Unset = [string]::IsNullOrWhiteSpace($Proxy)

$proxyNoSchema = $Proxy
if ($Proxy.StartsWith("http://")) {
	$proxyNoSchema = $Proxy.Substring("http://".Length)
}
if ($Proxy.StartsWith("https://")) {
	$proxyNoSchema = $Proxy.Substring("https://".Length)
}

Write-Host "Proxy: $Proxy" -ForegroundColor Yellow
Write-Host "Proxy without schema: $proxyNoSchema" -ForegroundColor Yellow
if ($Unset) {
	Write-Host "  Proxy is empty, so it will be unset." -ForegroundColor Yellow
}
if ($Unset) {
	Write-Host "Turn off system proxy" -ForegroundColor Green
	Invoke-Expression "reg add ""HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyEnable /t REG_DWORD /d 0 /f"

	Write-Host "Remove environment variables HTTP_PROXY and HTTPS_PROXY" -ForegroundColor Green
	$env:HTTP_PROXY = ""
	$env:HTTPS_PROXY = ""
	[System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "", [System.EnvironmentVariableTarget]::User)
	[System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "", [System.EnvironmentVariableTarget]::User)
	if ($isAdmin) {
		[System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "", [System.EnvironmentVariableTarget]::Machine)
		[System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "", [System.EnvironmentVariableTarget]::Machine)
	}

	Write-Host "Rempve Git proxy" -ForegroundColor Green
	Invoke-Expression "git config --global --unset http.proxy"

	Write-Host "Remove NPM proxy" -ForegroundColor Green
	Invoke-Expression "npm config rm proxy"
	Invoke-Expression "npm config rm https-proxy"
	Invoke-Expression "npm config --global rm proxy"
	Invoke-Expression "npm config --global rm https-proxy"
}
else {
	Write-Host "Turn on system  proxy" -ForegroundColor Green
	Invoke-Expression "reg add ""HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyEnable /t REG_DWORD /d 1 /f"

	Write-Host "Set  environment variables HTTP_PROXY and HTTPS_PROXY" -ForegroundColor Green
	$env:HTTP_PROXY = $Proxy
	$env:HTTPS_PROXY = $Proxy
	[System.Environment]::SetEnvironmentVariable("HTTP_PROXY", $Proxy, [System.EnvironmentVariableTarget]::User)
	[System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", $Proxy, [System.EnvironmentVariableTarget]::User)
	if ($isAdmin) {
		[System.Environment]::SetEnvironmentVariable("HTTP_PROXY", $Proxy, [System.EnvironmentVariableTarget]::Machine)
		[System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", $Proxy, [System.EnvironmentVariableTarget]::Machine)
	}

	Write-Host "Set Git proxy" -ForegroundColor Green
	Invoke-Expression "git config --global http.proxy $proxyNoSchema"

	Write-Host "Set NPM proxy" -ForegroundColor Green
	Invoke-Expression "npm config set proxy $Proxy"
	Invoke-Expression "npm config set https-proxy $Proxy"
}

Write-Host "Git proxy" -ForegroundColor Yellow
Invoke-Expression "git config --global --get http.proxy"

Write-Host "NPM proxy" -ForegroundColor Yellow
Invoke-Expression "npm config get proxy"
