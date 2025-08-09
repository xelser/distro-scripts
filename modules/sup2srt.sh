
#!/bin/bash

# This script combines the installation steps for sup2srt
# on both Ubuntu/Debian-based systems and Arch Linux.
# It automatically detects the operating system and installs
# the correct dependencies.

set -e

# Define a function to install dependencies for Ubuntu/Debian
install_ubuntu_deps() {
    echo "🔧 Detected Ubuntu/Debian. Installing dependencies..."
    sudo apt update && sudo apt install -y build-essential git wget \
        cmake libtiff-dev libleptonica-dev libtesseract-dev \
        libavcodec-dev libavformat-dev libavutil-dev \
        tesseract-ocr

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
}

# Define a function to install dependencies for Arch Linux
install_arch_deps() {
    echo "🔧 Detected Arch Linux. Installing dependencies and Tesseract best model..."
    # Install build-time dependencies using --as-deps for easy cleanup later.
    sudo pacman -S --needed --noconfirm --asdeps cmake
    
    # Install runtime dependencies and the 'best' Tesseract model from AUR using yay.
    echo "Using 'yay' to install tesseract-data-best-eng from the AUR."
    yay -S --needed --noconfirm git base-devel wget libtiff leptonica tesseract ffmpeg tesseract-data-best-eng
}

# --- Main Script Logic ---

# Check the /etc/os-release file to determine the operating system ID.
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
        install_ubuntu_deps
    elif [ "$ID" = "arch" ]; then
        install_arch_deps
    else
        echo "🚨 Unsupported OS: $ID"
        echo "Please install dependencies manually before running this script."
        exit 1
    fi
else
    echo "🚨 Could not detect OS from /etc/os-release."
    echo "Please install dependencies manually before running this script."
    exit 1
fi

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

