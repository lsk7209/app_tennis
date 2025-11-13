# Tennis Friends App Setup and Run Script

Write-Host "=== Tennis Friends App Setup ===" -ForegroundColor Cyan

# 1. Check Flutter
Write-Host "`n[1/5] Checking Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "Flutter found: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "Flutter is not installed." -ForegroundColor Red
    Write-Host "Please run install_flutter.ps1 or install manually." -ForegroundColor Yellow
    Write-Host "Download: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# 2. Install dependencies
Write-Host "`n[2/5] Installing dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "Dependencies installed" -ForegroundColor Green

# 3. Generate code
Write-Host "`n[3/5] Generating code (Freezed, JSON Serialization)..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray
flutter pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Code generation failed" -ForegroundColor Red
    Write-Host "Please check errors and try again." -ForegroundColor Yellow
    exit 1
}
Write-Host "Code generation completed" -ForegroundColor Green

# 4. Check Firebase config
Write-Host "`n[4/5] Checking Firebase configuration..." -ForegroundColor Yellow
if (Test-Path "lib\firebase_options.dart") {
    Write-Host "firebase_options.dart file found" -ForegroundColor Green
} else {
    Write-Host "firebase_options.dart file not found." -ForegroundColor Yellow
    Write-Host "Generate it with:" -ForegroundColor Yellow
    Write-Host "  dart pub global activate flutterfire_cli" -ForegroundColor Cyan
    Write-Host "  flutterfire configure" -ForegroundColor Cyan
    Write-Host "`nContinue without Firebase? (Some features won't work)" -ForegroundColor Yellow
    $continue = Read-Host "Continue (y/n)"
    if ($continue -ne "y") {
        exit 0
    }
}

# 5. Check devices
Write-Host "`n[5/5] Checking devices..." -ForegroundColor Yellow
flutter devices
$devices = flutter devices 2>&1
$deviceCount = ($devices | Select-String -Pattern "device" | Measure-Object).Count
if ($deviceCount -eq 0) {
    Write-Host "No devices available." -ForegroundColor Yellow
    Write-Host "Please start an emulator or connect a device via USB." -ForegroundColor Yellow
    Write-Host "`nAvailable emulators:" -ForegroundColor Cyan
    flutter emulators
} else {
    Write-Host "Devices found: $deviceCount" -ForegroundColor Green
}

# Run options
Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "`nRun commands:" -ForegroundColor Cyan
Write-Host "  flutter run              - Run app" -ForegroundColor White
Write-Host "  flutter run -d device   - Run on specific device" -ForegroundColor White
Write-Host "  flutter run --debug     - Debug mode" -ForegroundColor White

$run = Read-Host "`nRun now? (y/n)"
if ($run -eq "y") {
    Write-Host "`nRunning app..." -ForegroundColor Green
    flutter run
}
