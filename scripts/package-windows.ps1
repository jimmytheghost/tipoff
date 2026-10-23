param([string]$OutputDirectory = "$PSScriptRoot\..\dist\windows")
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path "$PSScriptRoot\..").Path
$output = [System.IO.Path]::GetFullPath($OutputDirectory)
& "$PSScriptRoot\generate-windows-icon.ps1" -OutputPath "$projectRoot\Windows\Tipoff.App\Tipoff.ico"
dotnet publish "$projectRoot\Windows\Tipoff.App\Tipoff.App.csproj" -c Release -r win-x64 --self-contained false -o $output --configfile "$projectRoot\Windows\NuGet.Config"
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed with exit code $LASTEXITCODE" }
Copy-Item "$projectRoot\LICENSE", "$projectRoot\NOTICE" -Destination $output -Force
Write-Host "Packaged $output\Tipoff.exe"
