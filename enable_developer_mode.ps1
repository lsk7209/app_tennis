# Windows Developer Mode 활성화 스크립트
# 관리자 권한으로 실행 필요

Write-Host "=== Windows Developer Mode 활성화 ===" -ForegroundColor Cyan

# Developer Mode 레지스트리 설정
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$regName = "AllowDevelopmentWithoutDevLicense"

try {
    # 레지스트리 키가 없으면 생성
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Write-Host "레지스트리 키 생성됨" -ForegroundColor Green
    }

    # Developer Mode 활성화
    Set-ItemProperty -Path $regPath -Name $regName -Value 1 -Type DWord
    Write-Host "Developer Mode 활성화 완료!" -ForegroundColor Green
    Write-Host "`n재부팅이 필요할 수 있습니다." -ForegroundColor Yellow
    Write-Host "재부팅 후 다시 시도하세요: flutter run -d windows" -ForegroundColor Cyan
} catch {
    Write-Host "오류 발생: $_" -ForegroundColor Red
    Write-Host "관리자 권한으로 실행해주세요." -ForegroundColor Yellow
}

