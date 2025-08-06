#!/usr/bin/env pwsh
# Deploy-Skript für NGA Web App

Write-Host "Starting deployment process..." -ForegroundColor Green

# 1. Build Flutter Web App
Write-Host "Building Flutter web app..." -ForegroundColor Yellow
flutter clean
flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Flutter build completed successfully!" -ForegroundColor Green

# 2. Prepare build directory
$buildPath = "build\web"
if (Test-Path $buildPath) {
    Write-Host "Build directory found: $buildPath" -ForegroundColor Yellow
    
    # List files in build directory
    Write-Host "Files in build directory:" -ForegroundColor Cyan
    Get-ChildItem $buildPath -Recurse | Select-Object Name, Length, LastWriteTime | Format-Table
} else {
    Write-Host "Build directory not found!" -ForegroundColor Red
    exit 1
}

# 3. Optional: Upload to server (placeholder for now)
Write-Host "Ready for deployment!" -ForegroundColor Green
Write-Host "Deploy files from: $buildPath" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "   1. Upload contents of '$buildPath' to your web server" -ForegroundColor White
Write-Host "   2. Configure web server to serve index.html for all routes" -ForegroundColor White
Write-Host "   3. Ensure HTTPS is enabled for production" -ForegroundColor White

Write-Host "Deployment preparation complete!" -ForegroundColor Green
