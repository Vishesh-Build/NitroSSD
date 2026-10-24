<#
.SYNOPSIS
  Uninstalls NitroSSD for the current user.
#>
param([switch]$RemoveData, [switch]$RemoveCache, [switch]$Quiet)
$ErrorActionPreference = "Continue"
$installDir = $PSScriptRoot
$dataRoot = Join-Path $env:LOCALAPPDATA "NitroSSD"

if (-not $Quiet -and -not $PSBoundParameters.ContainsKey('RemoveData')) {
    $a = Read-Host "Also delete NitroSSD settings, game library, profiles and saved cloud login? [y/N]"
    $RemoveData = $a -match '^[yY]'
}
if (-not $Quiet -and -not $PSBoundParameters.ContainsKey('RemoveCache')) {
    $a = Read-Host "Also delete cached game data from your SSD (cloud files are not affected)? [y/N]"
    $RemoveCache = $a -match '^[yY]'
}

$ours = { Get-Process NitroSSD -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($installDir, 'OrdinalIgnoreCase') } }
& $ours | ForEach-Object { $_.CloseMainWindow() | Out-Null; $_.WaitForExit(60000) | Out-Null }
& $ours | Stop-Process -Force
$rclones = Get-Process rclone -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($installDir, 'OrdinalIgnoreCase') }
foreach ($r in $rclones) {
    Write-Host "Stopping rclone mount (pid $($r.Id))..."
    $r | Stop-Process -Force
}
Start-Sleep 2

$settingsFile = Join-Path $dataRoot "settings.json"
$cacheRoot = Join-Path $dataRoot "cache"
if (Test-Path $settingsFile) {
    try { $s = Get-Content $settingsFile -Raw | ConvertFrom-Json; if ($s.Cache.CacheRoot) { $cacheRoot = $s.Cache.CacheRoot } } catch { }
}
if ($RemoveCache -and (Test-Path $cacheRoot)) {
    Get-ChildItem $cacheRoot -Directory -Filter "m-*" | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
    }
}

if ($RemoveData -and (Test-Path $dataRoot)) {
    Remove-Item $dataRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Remove-Item (Join-Path ([Environment]::GetFolderPath("Programs")) "NitroSSD.lnk") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path ([Environment]::GetFolderPath("Desktop")) "NitroSSD.lnk") -Force -ErrorAction SilentlyContinue
Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\NitroSSD" -Recurse -Force -ErrorAction SilentlyContinue
$removedFiles = $false
if ((Test-Path (Join-Path $installDir "NitroSSD.exe")) -and $installDir -like "*NitroSSD*") {
    Set-Location $env:TEMP
    Start-Process cmd.exe -ArgumentList "/c timeout /t 2 >nul & rmdir /s /q `"$installDir`"" -WindowStyle Hidden
    $removedFiles = $true
}
Write-Host "NitroSSD uninstalled."
