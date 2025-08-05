# Start NGA Production Environment
# This script starts both the Flutter frontend (port 8080) and Node.js backend (port 3000)

Write-Host "🚀 Starting NGA Production Environment..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Start Backend in background
Write-Host "📡 Starting Backend Server (port 3000)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot'; .\start-backend.ps1"

# Wait a moment for backend to start
Start-Sleep -Seconds 3

# Build and serve Flutter web app
Write-Host "🌐 Building and serving Flutter Web App (port 8080)..." -ForegroundColor Yellow
Write-Host "💡 Your login page will be available at: http://localhost:8080" -ForegroundColor Green
Write-Host "💡 Backend API available at: http://localhost:3000" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "Building Flutter web app..." -ForegroundColor Cyan

flutter build web
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful! Starting web server..." -ForegroundColor Green
    Set-Location -Path "build\web"
    python -m http.server 8080
} else {
    Write-Host "❌ Build failed! Check the output above." -ForegroundColor Red
}
