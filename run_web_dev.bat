@echo off
echo Starting Flutter Web on port 8081 to match server CORS settings...
flutter run -d chrome --web-port 8081 --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=VizDisplayCompositor" --web-browser-flag="--user-data-dir=C:/temp/chrome_dev_session"
pause
