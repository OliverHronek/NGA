@echo off
echo.
echo 🚀 Starting NGA Production Environment...
echo ========================================
echo.

echo 📡 Starting Backend Server (port 3000)...
start "NGA Backend" cmd /k "cd /d %~dp0 && start-backend.bat"

echo Waiting for backend to start...
timeout /t 3 /nobreak >nul

echo.
echo 🌐 Building and serving Flutter Web App (port 8080)...
echo 💡 Your login page will be available at: http://localhost:8080
echo 💡 Backend API available at: http://localhost:3000
echo.
echo Building Flutter web app...

flutter build web
if %errorlevel% == 0 (
    echo ✅ Build successful! Starting web server...
    cd /d build\web
    python -m http.server 8080
) else (
    echo ❌ Build failed! Check the output above.
    pause
)
