#!/usr/bin/env bash

set -euo pipefail

# Define target directory
TARGET_DIR="/usr/lib/jellyfin-ffmpeg"
TMP_DIR="$(mktemp -d)"
ARCHIVE_NAME="jellyfin-ffmpeg.tar.xz"

# Fetch latest release URL
echo "🔍 Fetching latest jellyfin-ffmpeg release info..."
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/jellyfin/jellyfin-ffmpeg/releases/latest \
  | grep browser_download_url \
  | grep portable_linux64-gpl \
  | cut -d '"' -f 4)

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "❌ Failed to find portable GPL build. Exiting."
  exit 1
fi

echo "⬇️ Downloading: $DOWNLOAD_URL"
curl -L "$DOWNLOAD_URL" -o "$TMP_DIR/$ARCHIVE_NAME"

echo "📦 Extracting archive..."
mkdir -p "$TMP_DIR/extracted"
tar -xf "$TMP_DIR/$ARCHIVE_NAME" -C "$TMP_DIR/extracted"

echo "🚚 Installing to $TARGET_DIR..."
sudo mkdir -p "$TARGET_DIR"
sudo cp "$TMP_DIR/extracted/ffmpeg" "$TARGET_DIR/"
sudo chmod +x "$TARGET_DIR/ffmpeg"

echo "✅ Installed jellyfin-ffmpeg to $TARGET_DIR"
echo "🧪 Run '$TARGET_DIR/ffmpeg -codecs' to verify codec support"

# Cleanup
rm -rf "$TMP_DIR"

