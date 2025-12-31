#!/bin/bash
# PROVES Library Quick Setup Script for macOS/Linux

echo "============================================================"
echo "  PROVES Library Setup (macOS/Linux)"
echo "============================================================"
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 not found"
    echo "Please install Python 3.11+ from https://www.python.org/downloads/"
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 --version | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
REQUIRED_VERSION="3.11"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "[ERROR] Python 3.11+ required (found: $PYTHON_VERSION)"
    echo "Please install Python 3.11 or higher"
    exit 1
fi

# Run the Python setup script
python3 setup.py

# Check if setup was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "[SUCCESS] Setup complete!"
    echo ""
else
    echo ""
    echo "[FAILED] Setup encountered errors"
    exit 1
fi
