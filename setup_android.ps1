# Android Studio 설치 후 설정 스크립트

Write-Host "=== Android Studio 설정 ===" -ForegroundColor Cyan

# 1. Android SDK 경로 확인
Write-Host "`n[1/4] Android SDK 경로 확인 중..." -ForegroundColor Yellow
$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"

if (Test-Path $sdkPath) {
    Write-Host "SDK 경로 발견: $sdkPath" -ForegroundColor Green
} else {
    Write-Host "SDK 경로를 찾을 수 없습니다." -ForegroundColor Red
    Write-Host "Android Studio를 설치하고 초기 설정을 완료해주세요." -ForegroundColor Yellow
    Write-Host "SDK 경로: $sdkPath" -ForegroundColor Gray
    exit 1
}

# 2. Flutter에 SDK 경로 설정
Write-Host "`n[2/4] Flutter에 SDK 경로 설정 중..." -ForegroundColor Yellow
flutter config --android-sdk $sdkPath
if ($LASTEXITCODE -eq 0) {
    Write-Host "SDK 경로 설정 완료" -ForegroundColor Green
} else {
    Write-Host "SDK 경로 설정 실패" -ForegroundColor Red
}

# 3. 환경 변수 설정
Write-Host "`n[3/4] 환경 변수 설정 중..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
$env:ANDROID_HOME = $sdkPath
Write-Host "ANDROID_HOME 설정 완료" -ForegroundColor Green

# PATH에 추가
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$platformTools = "$sdkPath\platform-tools"
$tools = "$sdkPath\tools"

if ($currentPath -notlike "*$platformTools*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$platformTools;$tools", "User")
    $env:Path += ";$platformTools;$tools"
    Write-Host "PATH에 Android 도구 추가됨" -ForegroundColor Green
} else {
    Write-Host "PATH에 이미 Android 도구가 있습니다" -ForegroundColor Green
}

# 4. 라이선스 동의
Write-Host "`n[4/4] Android 라이선스 동의 중..." -ForegroundColor Yellow
Write-Host "모든 라이선스에 'y' 입력 필요" -ForegroundColor Gray
flutter doctor --android-licenses

Write-Host "`n=== 설정 완료 ===" -ForegroundColor Green
Write-Host "`n다음 단계:" -ForegroundColor Cyan
Write-Host "1. Android Studio에서 에뮬레이터 생성" -ForegroundColor White
Write-Host "   Tools > Device Manager > Create Device" -ForegroundColor Gray
Write-Host "2. 에뮬레이터 실행" -ForegroundColor White
Write-Host "3. flutter run 실행" -ForegroundColor White

