[CmdletBinding()]
param(
    [string]$InstallDirectory = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs\Tipoff'),
    [string]$ShortcutDirectory = [Environment]::GetFolderPath('Programs'),
    [switch]$NoLaunch,
    [switch]$NoShortcut
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path "$PSScriptRoot\..").Path
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $dotnet) {
    throw 'The .NET 9 SDK is required. Install it with: winget install Microsoft.DotNet.SDK.9'
}

$sdks = @(& dotnet --list-sdks)
if ($LASTEXITCODE -ne 0 -or -not ($sdks | Where-Object { $_ -match '^9\.' })) {
    throw 'The .NET 9 SDK is required. Install it with: winget install Microsoft.DotNet.SDK.9'
}

$install = [System.IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($InstallDirectory))
$root = [System.IO.Path]::GetPathRoot($install)
if ([string]::IsNullOrWhiteSpace($install) -or $install -eq $root) {
    throw "Refusing unsafe install directory: $install"
}

$executable = Join-Path $install 'Tipoff.exe'
Get-Process Tipoff -ErrorAction SilentlyContinue | Where-Object {
    try { $_.Path -eq $executable } catch { $false }
} | Stop-Process

& "$PSScriptRoot\package-windows.ps1" -OutputDirectory $install
if (-not (Test-Path -LiteralPath $executable)) {
    throw "Installation failed: $executable was not created."
}

if (-not $NoShortcut) {
    $shortcutFolder = [System.IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($ShortcutDirectory))
    New-Item -ItemType Directory -Path $shortcutFolder -Force | Out-Null
    $shortcutPath = Join-Path $shortcutFolder 'Tipoff.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $executable
    $shortcut.WorkingDirectory = $install
    $shortcut.IconLocation = "$executable,0"
    $shortcut.Description = 'NBA, NFL, WNBA, NHL, and MLB viewing guide'
    $shortcut.Save()
    Write-Output "Start Menu shortcut: $shortcutPath"
}

if (-not $NoLaunch) {
    Start-Process -FilePath $executable
    Write-Output 'Tipoff launched. Its tray menu controls Start with Windows.'
}

Write-Output "Installed Tipoff: $executable"
