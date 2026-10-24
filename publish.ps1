$repo = $PSScriptRoot
$dotnet = "C:\Users\vishe\AppData\Local\Microsoft\dotnet\dotnet.exe"
$env:DOTNET_ROOT = "C:\Users\vishe\AppData\Local\Microsoft\dotnet"
$dist = Join-Path $repo "dist"
$stage = Join-Path $dist "NitroSSD-1.0.0-win-x64"

New-Item -ItemType Directory -Force $stage | Out-Null

$common = @("-c", "Release", "-r", "win-x64", "--self-contained", "true", "-p:PublishReadyToRun=true", "-p:Version=1.0.0", "--nologo", "-v", "m", "-o", $stage)

Write-Host "Publishing NitroSSD.Desktop..."
& $dotnet publish (Join-Path $repo "src\CloudPlayX.Desktop\CloudPlayX.Desktop.csproj") @common

Write-Host "Publishing NitroSSD.Cli..."
& $dotnet publish (Join-Path $repo "src\CloudPlayX.Cli\CloudPlayX.Cli.csproj") @common

# Copy rclone
$toolDir = Join-Path $stage "tools\rclone"
New-Item -ItemType Directory -Force $toolDir | Out-Null
Copy-Item (Join-Path $repo "tools\rclone\*") $toolDir -Recurse -Force

# Copy scripts & docs
foreach ($f in "README.md", "KNOWN_LIMITATIONS.md", "COMPATIBILITY.md", "BENCHMARKS.md", "TEST_REPORT.md", "BUILD_STATUS.md", "ARCHITECTURE.md") {
    if (Test-Path (Join-Path $repo $f)) { Copy-Item (Join-Path $repo $f) $stage -Force }
}
New-Item -ItemType Directory -Force (Join-Path $stage "docs") | Out-Null
Copy-Item (Join-Path $repo "docs\*") (Join-Path $stage "docs") -Recurse -Force
Copy-Item (Join-Path $repo "installer\Install-NitroSSD.ps1") $stage -Force
Copy-Item (Join-Path $repo "installer\Uninstall-NitroSSD.ps1") $stage -Force
Set-Content (Join-Path $stage "Install.cmd") "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0Install-NitroSSD.ps1`" %*`r`npause"

Write-Host "Publish complete at $stage"
