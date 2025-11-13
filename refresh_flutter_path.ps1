# Flutter PATH Refresh Script
# Run this in any PowerShell session to refresh Flutter PATH

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "Flutter PATH refreshed!" -ForegroundColor Green
Write-Host "You can now use 'flutter' command." -ForegroundColor Cyan

# Verify Flutter is accessible
try {
    $version = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "Flutter version: $version" -ForegroundColor Green
} catch {
    Write-Host "Flutter not found. Please check installation." -ForegroundColor Red
}

