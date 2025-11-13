# Android cmdline-tools 설치 가이드 스크립트

Write-Host "=== Android cmdline-tools 설치 ===" -ForegroundColor Cyan

$sdkPath = "C:\Users\dlatj\AppData\Local\Android\Sdk"

if (-not (Test-Path $sdkPath)) {
    Write-Host "SDK 경로를 찾을 수 없습니다: $sdkPath" -ForegroundColor Red
    exit 1
}

Write-Host "`nSDK 경로: $sdkPath" -ForegroundColor Green

# cmdline-tools 확인
$cmdlinePath = "$sdkPath\cmdline-tools"
$latestTools = Get-ChildItem $cmdlinePath -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "latest" -or $_.Name -match "^\d" } | Sort-Object Name -Descending | Select-Object -First 1

if ($latestTools) {
    Write-Host "`ncmdline-tools 발견: $($latestTools.FullName)" -ForegroundColor Green
    $sdkmanagerPath = "$($latestTools.FullName)\bin\sdkmanager.bat"
    
    if (Test-Path $sdkmanagerPath) {
        Write-Host "sdkmanager 발견: $sdkmanagerPath" -ForegroundColor Green
        Write-Host "`n라이선스 동의 시도 중..." -ForegroundColor Yellow
        & $sdkmanagerPath --licenses
    } else {
        Write-Host "sdkmanager를 찾을 수 없습니다." -ForegroundColor Red
    }
} else {
    Write-Host "`ncmdline-tools가 설치되지 않았습니다." -ForegroundColor Red
    Write-Host "`n해결 방법:" -ForegroundColor Yellow
    Write-Host "1. Android Studio 실행" -ForegroundColor White
    Write-Host "2. Tools > SDK Manager 클릭" -ForegroundColor White
    Write-Host "3. SDK Tools 탭 선택" -ForegroundColor White
    Write-Host "4. 'Android SDK Command-line Tools (latest)' 체크" -ForegroundColor White
    Write-Host "5. Apply > OK 클릭하여 설치`n" -ForegroundColor White
    
    Write-Host "또는 수동 다운로드:" -ForegroundColor Yellow
    Write-Host "https://developer.android.com/studio#command-tools" -ForegroundColor Cyan
    Write-Host "다운로드 후 $cmdlinePath\latest 에 압축 해제" -ForegroundColor Gray
}

