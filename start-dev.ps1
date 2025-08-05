# Start NGA Development Environment
# This script starts both the Flutter frontend (port 8080) and Node.js backend (port 3000)

Write-Host "Starting NGA Development Environment..." -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Cyan

# Start Backend in background
Write-Host "Starting Backend Server (port 3000)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot'; .\start-backend-dev.ps1"

# Wait a moment for backend to start
Start-Sleep -Seconds 3

# Start Frontend
Write-Host "Starting Flutter Web App (port 8080)..." -ForegroundColor Yellow
Write-Host "Your login page will be available at: http://localhost:8080" -ForegroundColor Green
Write-Host "Backend API available at: http://localhost:3000" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop the frontend. Close the backend window separately." -ForegroundColor Cyan
Write-Host ""

flutter run -d web-server --web-port 8080
