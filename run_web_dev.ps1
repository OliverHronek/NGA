# PowerShell script to run Flutter web on port 8081 to match server CORS
Write-Host "Starting Flutter Web on port 8081 to match server CORS settings..." -ForegroundColor Green

# Set location to project directory
Set-Location "C:\Users\olive\source\GitHub\NGA"

# Run Flutter with Chrome on port 8081 (matches server CORS configuration)
flutter run -d chrome `
  --web-port 8081 `
  --web-browser-flag="--disable-web-security" `
  --web-browser-flag="--disable-features=VizDisplayCompositor" `
  --web-browser-flag="--user-data-dir=C:/temp/chrome_dev_session" `
  --web-browser-flag="--allow-running-insecure-content"

Write-Host "Press any key to continue..." -ForegroundColor Yellow
Read-Host
