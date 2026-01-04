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
if exist dist rd /s /q dist

echo [3/4] Building Frontend (Vue)...
:: Use npx vite build directly to avoid missing script errors
call npx vite build
if %errorlevel% neq 0 (
    echo Failed to build Vue frontend.
    pause
    exit /b %errorlevel%
)

echo [4/4] Building Backend (Main) and Packaging...
:: Compile the main process TypeScript
:: We use node directly here to avoid yarn/npm script lookup issues
call node -r ts-node/register script/build-main --env=production
if %errorlevel% neq 0 (
    echo Failed to build main process.
    pause
    exit /b %errorlevel%
)

:: Run electron-builder for all targets
:: We use npx to execute the binary from node_modules
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
