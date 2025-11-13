# Quick App Runner Script
# Automatically refreshes PATH and runs the app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "=== Tennis Friends App Runner ===" -ForegroundColor Cyan

# Check Flutter
try {
    $null = flutter --version 2>&1
    Write-Host "Flutter found" -ForegroundColor Green
} catch {
    Write-Host "Flutter not found. Please install Flutter first." -ForegroundColor Red
    Write-Host "Run: .\install_flutter.ps1" -ForegroundColor Yellow
    exit 1
}

# Show available devices
Write-Host "`nAvailable devices:" -ForegroundColor Yellow
flutter devices

# Ask for device
Write-Host "`nSelect device:" -ForegroundColor Cyan
Write-Host "  1. Windows (desktop)" -ForegroundColor White
Write-Host "  2. Chrome (web)" -ForegroundColor White
Write-Host "  3. Edge (web)" -ForegroundColor White
Write-Host "  4. Auto-select" -ForegroundColor White

$choice = Read-Host "Enter choice (1-4, default: 4)"

$device = switch ($choice) {
    "1" { "windows" }
    "2" { "chrome" }
    "3" { "edge" }
    default { "" }
}

if ($device) {
    Write-Host "`nRunning on $device..." -ForegroundColor Green
    flutter run -d $device
} else {
    Write-Host "`nRunning (auto-select device)..." -ForegroundColor Green
    flutter run
}

