#!/bin/bash

# This script combines the installation steps for sup2srt
# and automatically detects the package manager to install
# the correct dependencies on various Linux systems.

set -e

echo "🔧 Detecting package manager to install dependencies..."

# --- Distro-Agnostic Dependency Installation ---

# Check for apt (Debian/Ubuntu)
if command -v apt &> /dev/null; then
    echo "📦 Detected apt. Installing dependencies..."
    sudo apt update
    sudo apt install -y build-essential git wget cmake \
        libtiff-dev libleptonica-dev libtesseract-dev \
        libavcodec-dev libavformat-dev libavutil-dev tesseract-ocr

# Check for yay (Arch-based distros)
elif command -v yay &> /dev/null; then
    echo "📦 Detected yay. Installing dependencies..."
    # Install foundational and runtime dependencies normally.
    yay -S --needed --noconfirm git base-devel wget \
        libtiff leptonica tesseract ffmpeg
    # Install cmake as a build dependency.
    yay -S --needed --noconfirm --asdeps cmake
    
# Check for pacman (Arch Linux)
elif command -v pacman &> /dev/null; then
    echo "📦 Detected pacman. Installing dependencies..."
    # Install foundational and runtime dependencies normally.
    sudo pacman -S --needed --noconfirm git base-devel wget \
        libtiff leptonica tesseract ffmpeg
    # Install cmake as a build dependency.
    sudo pacman -S --needed --noconfirm --asdeps cmake

# Fallback for unsupported systems
else
    echo "🚨 Could not detect a supported package manager (apt, yay, pacman)."
    echo "Please install dependencies manually before running this script."
    exit 1
fi

# --- Tesseract 'best' Model Installation (Distro-Agnostic) ---
echo "📦 Swapping in Tesseract 'best' English model..."
TESSDATA_DIR="/usr/share/tesseract-ocr/5/tessdata"
BEST_MODEL_URL="https://raw.githubusercontent.com/tesseract-ocr/tessdata_best/main/eng.traineddata"
TARGET_MODEL="$TESSDATA_DIR/eng.traineddata"
BACKUP_MODEL="$TESSDATA_DIR/eng.traineddata.bak"

# Ensure tessdata directory exists
sudo mkdir -p "$TESSDATA_DIR"

# Backup existing model if not already backed up
if [ -f "$TARGET_MODEL" ] && [ ! -f "$BACKUP_MODEL" ]; then
    echo "🗂️ Backing up existing model to eng.traineddata.bak..."
    sudo cp "$TARGET_MODEL" "$BACKUP_MODEL"
fi

# Download and replace with best model
echo "⬇️ Downloading 'best' model..."
sudo wget -O "$TARGET_MODEL" "$BEST_MODEL_URL"

# --- Main Sup2srt Build Logic (Distro-Agnostic) ---
echo "📁 Cloning sup2srt repository..."
git clone https://github.com/retrontology/sup2srt.git
cd sup2srt

echo "🏗️ Creating build directory..."
mkdir -p build
cd build

echo "⚙️ Running CMake..."
cmake ..

echo "🚀 Building sup2srt..."
# Use all available CPU cores for a faster build
make -j"$(nproc)"

echo "📦 Installing sup2srt system-wide..."
sudo make install

echo "✅ sup2srt installed successfully!"
