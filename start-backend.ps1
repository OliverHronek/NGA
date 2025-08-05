# Start NGA Backend Server
Write-Host "Starting NGA Backend Server..." -ForegroundColor Green
Set-Location -Path "$PSScriptRoot\backend"
npm start
