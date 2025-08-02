
#!/bin/bash

set -e

echo "🔧 Installing dependencies..."
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

echo "📁 Cloning sup2srt repository..."
git clone https://github.com/retrontology/sup2srt.git
cd sup2srt

echo "🏗️ Creating build directory..."
mkdir -p build
cd build

echo "⚙️ Running CMake..."
cmake ..

echo "🚀 Building sup2srt..."
make -j"$(nproc)"

echo "📦 Installing sup2srt system-wide..."
sudo make install

echo "✅ sup2srt installed successfully with Tesseract 'best' model!"

