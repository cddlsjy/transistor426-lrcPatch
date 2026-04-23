# ========== CONFIGURATION ==========
$ProjectDir = "F:\dev2026\2026-04\transistorv4.2.6-OK-main"
$GiteeApkRepo = "D:\gitee_apk_repo"
$DefaultPatchFile = "patch01.txt"
$GiteeToken = "你的私人令牌"
$GiteeApkRemote = "https://gitee.com/你的用户名/apk-repo.git"
# ===================================

Set-Location $ProjectDir -ErrorAction Stop

Write-Host "=========================================="
Write-Host "1. Pull latest code"
git pull
if ($LASTEXITCODE -ne 0) { throw "git pull failed" }

Write-Host "=========================================="
Write-Host "2. Please ensure code is modified according to patch file."
Write-Host "   Patch file location: $ProjectDir\$DefaultPatchFile"
Read-Host "Press Enter to continue after manual modification"

Write-Host "=========================================="
Write-Host "3. Clean and build APK"
.\gradlew.bat clean
.\gradlew.bat assembleDebug
if ($LASTEXITCODE -ne 0) { throw "Build failed" }

Write-Host "=========================================="
Write-Host "4. Locate APK"
$ApkFile = Get-ChildItem -Path $ProjectDir -Recurse -Filter "*.apk" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $ApkFile) {
    Write-Host "ERROR: No APK found. Listing outputs..."
    Get-ChildItem -Path (Join-Path $ProjectDir "app\build\outputs") -Recurse | Select-Object FullName
    throw "APK not found"
}
$ApkPath = $ApkFile.FullName
Write-Host "Found APK: $ApkPath"

Write-Host "=========================================="
Write-Host "5. Upload to Gitee"
if (-not (Test-Path $GiteeApkRepo)) {
    git clone $GiteeApkRemote $GiteeApkRepo
}
Set-Location $GiteeApkRepo
Copy-Item $ApkPath -Destination ".\app-debug.apk" -Force
git add app-debug.apk
git commit -m "Auto update $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
if ($GiteeToken -ne "你的私人令牌") {
    $RemoteUrl = "https://oauth2:$GiteeToken@gitee.com/你的用户名/apk-repo.git"
    git push $RemoteUrl main
} else {
    git push origin main
}

Write-Host "=========================================="
Write-Host "6. Install to ADB"
adb install -r $ApkPath
if ($LASTEXITCODE -ne 0) { Write-Host "ADB install failed" }

Write-Host "=========================================="
Write-Host "All done!"
Read-Host "Press Enter to exit"
