$ErrorActionPreference = 'Stop'

$sdk = Join-Path $env:LOCALAPPDATA 'Android\sdk'
$zip = Join-Path $env:TEMP 'commandlinetools-win-11076708_latest.zip'
$stage = Join-Path $env:TEMP 'commandlinetools-win-11076708_stage'
$downloadUrl = 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip'

New-Item -ItemType Directory -Path $sdk -Force | Out-Null
if (Test-Path $zip) { Remove-Item $zip -Force }
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }

Write-Host 'Downloading Android command-line tools...'
Invoke-WebRequest -Uri $downloadUrl -OutFile $zip -UseBasicParsing
Write-Host "ZIP_SIZE=$((Get-Item $zip).Length)"

Expand-Archive -Path $zip -DestinationPath $stage -Force
$cmdlineDir = Get-ChildItem $stage -Recurse -Directory -Filter 'cmdline-tools' | Select-Object -First 1
if (-not $cmdlineDir) { throw 'cmdline-tools folder not found in the extracted archive.' }

$targetRoot = Join-Path $sdk 'cmdline-tools'
if (Test-Path $targetRoot) { Remove-Item $targetRoot -Recurse -Force }
New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
$latest = Join-Path $targetRoot 'latest'
Move-Item -Path $cmdlineDir.FullName -Destination $latest -Force

$sdkmanager = Join-Path $latest 'bin\sdkmanager.bat'
$apkanalyzer = Join-Path $latest 'bin\apkanalyzer.bat'
Write-Host "SDKMANAGER_EXISTS=$(Test-Path $sdkmanager)"
Write-Host "APKANALYZER_EXISTS=$(Test-Path $apkanalyzer)"
if (-not (Test-Path $sdkmanager)) { throw 'sdkmanager.bat missing after install.' }
if (-not (Test-Path $apkanalyzer)) { throw 'apkanalyzer.bat missing after install.' }

$env:ANDROID_HOME = $sdk
$env:ANDROID_SDK_ROOT = $sdk
'Y' | & $sdkmanager --sdk_root=$sdk --licenses
Write-Host 'SDK_LICENSES_ACCEPTED'

$platformTools = Join-Path $sdk 'platform-tools'
if (-not (Test-Path $platformTools)) {
    Write-Host 'Installing platform-tools...'
    & $sdkmanager --sdk_root=$sdk 'platform-tools'
}

$flutter = 'C:\src\flutter\bin\flutter.bat'
if (-not (Test-Path $flutter)) { throw "Flutter not found at $flutter" }

Write-Host 'Configuring Flutter Android SDK...'
& $flutter config --android-sdk $sdk
Write-Host 'Running flutter pub get...'
& $flutter pub get
Write-Host 'Running flutter build appbundle --release...'
& $flutter build appbundle --release
Write-Host 'BUILD_COMPLETE'
