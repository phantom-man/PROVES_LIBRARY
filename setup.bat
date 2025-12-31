@echo off
REM PROVES Library Quick Setup Script for Windows
REM This is a simple wrapper that calls the Python setup script

echo ============================================================
echo   PROVES Library Setup (Windows)
echo ============================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found in PATH
    echo Please install Python 3.11+ from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

REM Run the Python setup script
python setup.py

REM Check if setup was successful
if errorlevel 1 (
    echo.
    echo [FAILED] Setup encountered errors
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Setup complete!
echo.
pause
