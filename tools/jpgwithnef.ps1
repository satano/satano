$folder = Get-Location
$deleteFolder = [System.IO.Path]::Join($folder, "delete_" + [Guid]::NewGuid().ToString())
Write-Host "Create delete folder '$deleteFolder'"
New-Item -Path $deleteFolder -ItemType Directory

$knownExtensions = @(".jpg", ".nef", ".xmp")
$jpgNames = Get-ChildItem -Path $folder -Filter *.jpg | ForEach-Object { $_.BaseName.ToLower() }
$allFiles = Get-ChildItem -Path $folder -File | ForEach-Object { $_.FullName }
foreach ($file in $allFiles) {
	$isKnownExtension = $knownExtensions -contains [System.IO.Path]::GetExtension($file).ToLower()
	$hasJpgFileName = $jpgNames -contains [System.IO.Path]::GetFileNameWithoutExtension($file).ToLower()
	if ($isKnownExtension -and $hasJpgFileName) {
		continue
	}
	Write-Host "Moving $file to delete folder."
	Move-Item -Path $file -Destination $deleteFolder
}
