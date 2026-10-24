$repo = $PSScriptRoot
$dotnet = "C:\Users\vishe\AppData\Local\Microsoft\dotnet\dotnet.exe"
$env:DOTNET_ROOT = "C:\Users\vishe\AppData\Local\Microsoft\dotnet"
$env:PATH = "$env:DOTNET_ROOT;$env:PATH"

Write-Host "Using dotnet: $dotnet"
Write-Host "Building NitroSSD solution..."
& $dotnet build (Join-Path $repo "CloudPlayX.slnx") -c Release
