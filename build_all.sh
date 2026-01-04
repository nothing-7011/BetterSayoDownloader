#!/bin/bash
set -e

echo "=========================================="
echo "SayoDownloader Multi-Platform Build Script"
echo "=========================================="

echo "[1/4] Installing dependencies..."
yarn install

echo "[2/4] Cleaning previous builds..."
rm -rf dist

echo "[3/4] Building Frontend (Vue)..."
# Use npx vite build directly to avoid missing script errors
npx vite build

echo "[4/4] Building Backend (Main) and Packaging..."
# Compile the main process TypeScript
# We use node directly to ensure robust execution
node -r ts-node/register script/build-main --env=production

# Run electron-builder for all targets
# We use npx to ensure we use the project's installed version
npx electron-builder --win --mac --linux

echo "=========================================="
echo "Build Complete! Check the 'release' folder."
echo "=========================================="
