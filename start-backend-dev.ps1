# Start NGA Backend Server in Development Mode
Write-Host "Starting NGA Backend Server in Development Mode..." -ForegroundColor Green
Set-Location -Path "$PSScriptRoot\backend"
npm run dev
