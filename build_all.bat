@echo off
setlocal

echo ==========================================
echo SayoDownloader Multi-Platform Build Script
echo ==========================================

echo [1/4] Installing dependencies...
call yarn install
if %errorlevel% neq 0 (
    echo Failed to install dependencies.
    pause
    exit /b %errorlevel%
)

echo [2/4] Cleaning previous builds...
call npx rimraf dist

echo [3/4] Building Frontend (Vue)...
call npm run build:vue
if %errorlevel% neq 0 (
    echo Failed to build Vue frontend.
    pause
    exit /b %errorlevel%
)

echo [4/4] Building Backend (Main) and Packaging...
:: Compile the main process TypeScript
call node -r ts-node/register script/build-main --env=production
if %errorlevel% neq 0 (
    echo Failed to build main process.
    pause
    exit /b %errorlevel%
)

:: Run electron-builder for all targets
:: This will build for Windows (exe), macOS (zip), and Linux (AppImage)
call npx electron-builder --win --mac --linux
if %errorlevel% neq 0 (
    echo Failed to package application.
    pause
    exit /b %errorlevel%
)

echo ==========================================
echo Build Complete! Check the 'release' folder.
echo ==========================================
pause
