# Flutter Windows Symlink 문제 해결 스크립트
# 관리자 권한으로 실행 필요

Write-Host "=== Flutter Windows Symlink 문제 해결 ===" -ForegroundColor Cyan

# 1. Developer Mode 활성화
Write-Host "`n[1/2] Developer Mode 활성화 중..." -ForegroundColor Yellow
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$regName = "AllowDevelopmentWithoutDevLicense"

try {
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name $regName -Value 1 -Type DWord
    Write-Host "Developer Mode 활성화 완료" -ForegroundColor Green
} catch {
    Write-Host "오류: $_" -ForegroundColor Red
    Write-Host "관리자 권한으로 실행해주세요." -ForegroundColor Yellow
    exit 1
}

# 2. 사용자 레지스트리도 확인
Write-Host "`n[2/2] 사용자 레지스트리 확인 중..." -ForegroundColor Yellow
$userRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
try {
    if (-not (Test-Path $userRegPath)) {
        New-Item -Path $userRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $userRegPath -Name $regName -Value 1 -Type DWord
    Write-Host "사용자 레지스트리 설정 완료" -ForegroundColor Green
} catch {
    Write-Host "사용자 레지스트리 설정 실패 (무시 가능)" -ForegroundColor Yellow
}

Write-Host "`n=== 완료 ===" -ForegroundColor Green
Write-Host "재부팅이 필요할 수 있습니다." -ForegroundColor Yellow
Write-Host "재부팅 후 다음 명령어 실행:" -ForegroundColor Cyan
Write-Host "  flutter run -d windows" -ForegroundColor White

