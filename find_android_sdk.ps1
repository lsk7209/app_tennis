# Android SDK 경로 찾기 스크립트

Write-Host "=== Android SDK 경로 찾기 ===" -ForegroundColor Cyan

$possiblePaths = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:USERPROFILE\AppData\Local\Android\Sdk",
    "$env:ProgramFiles\Android\Sdk",
    "$env:ProgramFiles(x86)\Android\Sdk",
    "C:\Android\Sdk"
)

Write-Host "`n검색 중..." -ForegroundColor Yellow
$found = $false

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        Write-Host "SDK 발견: $path" -ForegroundColor Green
        $found = $true
        
        # Flutter에 설정
        Write-Host "`nFlutter에 SDK 경로 설정 중..." -ForegroundColor Yellow
        flutter config --android-sdk $path
        
        # 환경 변수 설정
        [Environment]::SetEnvironmentVariable("ANDROID_HOME", $path, "User")
        $env:ANDROID_HOME = $path
        Write-Host "ANDROID_HOME 설정 완료" -ForegroundColor Green
        
        break
    }
}

if (-not $found) {
    Write-Host "`nAndroid SDK를 찾을 수 없습니다." -ForegroundColor Red
    Write-Host "`n다음 단계를 확인해주세요:" -ForegroundColor Yellow
    Write-Host "1. Android Studio를 실행했는지 확인" -ForegroundColor White
    Write-Host "2. Setup Wizard를 완료했는지 확인" -ForegroundColor White
    Write-Host "3. SDK Manager에서 SDK가 설치되었는지 확인" -ForegroundColor White
    Write-Host "   (Android Studio > Tools > SDK Manager)" -ForegroundColor Gray
    Write-Host "`n또는 수동으로 SDK 경로를 설정:" -ForegroundColor Yellow
    Write-Host "  flutter config --android-sdk <SDK경로>" -ForegroundColor Cyan
}

