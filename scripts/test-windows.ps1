param()
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path "$PSScriptRoot\..").Path
dotnet build "$projectRoot\Windows\Tipoff.Windows.slnx" -c Release -m:1 /nr:false --configfile "$projectRoot\Windows\NuGet.Config"
if ($LASTEXITCODE -ne 0) { throw "Windows build failed with exit code $LASTEXITCODE" }
foreach ($runner in @('Tipoff.Tests/bin/Release/net9.0/Tipoff.Tests.dll', 'Tipoff.App.Tests/bin/Release/net9.0-windows/Tipoff.App.Tests.dll')) {
    dotnet "$projectRoot\Windows\$runner"
    if ($LASTEXITCODE -ne 0) { throw "$runner failed with exit code $LASTEXITCODE" }
}
