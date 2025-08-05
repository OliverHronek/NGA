@echo off
echo.
echo 🚀 Starting NGA Development Environment...
echo =======================================
echo.

echo 📡 Starting Backend Server (port 3000)...
start "NGA Backend" cmd /k "cd /d %~dp0 && start-backend-dev.bat"

echo Waiting for backend to start...
timeout /t 3 /nobreak >nul

echo.
echo 🌐 Starting Flutter Web App (port 8080)...
echo 💡 Your login page will be available at: http://localhost:8080
echo 💡 Backend API available at: http://localhost:3000
echo.
echo Press Ctrl+C to stop the frontend. Close the backend window separately.
echo.

flutter run -d web-server --web-port 8080
