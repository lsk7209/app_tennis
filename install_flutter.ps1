# Flutter Installation Script for Windows
# May require administrator privileges

Write-Host "Starting Flutter installation..." -ForegroundColor Green

# Flutter installation path
$flutterPath = "C:\src\flutter"

# Check Git
Write-Host "`n1. Checking Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "Git installed: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "Git is not installed." -ForegroundColor Red
    Write-Host "Download Git: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Create Flutter directory
if (-not (Test-Path "C:\src")) {
    New-Item -ItemType Directory -Path "C:\src" -Force | Out-Null
}

# Clone Flutter (skip if already exists)
if (-not (Test-Path $flutterPath)) {
    Write-Host "`n2. Downloading Flutter SDK..." -ForegroundColor Yellow
    Set-Location "C:\src"
    git clone https://github.com/flutter/flutter.git -b stable
} else {
    Write-Host "`n2. Flutter SDK already exists. Updating..." -ForegroundColor Yellow
    Set-Location $flutterPath
    git pull
}

# Add Flutter to PATH
Write-Host "`n3. Setting PATH environment variable..." -ForegroundColor Yellow
$flutterBin = "$flutterPath\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$flutterBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterBin", "User")
    Write-Host "Flutter added to PATH" -ForegroundColor Green
    Write-Host "Please open a new PowerShell window." -ForegroundColor Yellow
} else {
    Write-Host "Flutter already in PATH." -ForegroundColor Green
}

# Run Flutter doctor
Write-Host "`n4. Checking Flutter status..." -ForegroundColor Yellow
& "$flutterBin\flutter.bat" doctor

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "Open a new PowerShell window and run:" -ForegroundColor Yellow
Write-Host "  flutter pub get" -ForegroundColor Cyan
Write-Host "  flutter pub run build_runner build --delete-conflicting-outputs" -ForegroundColor Cyan
