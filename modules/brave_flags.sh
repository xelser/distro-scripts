#!/bin/bash

# === Configurable Paths ===
WRAPPER="$HOME/.local/bin/brave"
DESKTOP_SRC="/usr/share/applications/brave-browser.desktop"
DESKTOP_DEST="$HOME/.local/share/applications/brave-browser.desktop"

# === Flags to apply globally ===
FLAGS="--enable-features=UseOzonePlatform,VaapiVideoDecoder \
--ozone-platform=wayland \
--enable-gpu-rasterization \
--enable-zero-copy \
--ignore-gpu-blocklist \
--password-store=basic"

# === Create wrapper ===
mkdir -p "$(dirname "$WRAPPER")"
cat > "$WRAPPER" <<EOF
#!/bin/bash
exec /usr/bin/brave-browser $FLAGS "\$@"
EOF

chmod +x "$WRAPPER"
echo "✅ Wrapper created at $WRAPPER"

# === Override desktop entry ===
mkdir -p "$(dirname "$DESKTOP_DEST")"
if [[ -f "$DESKTOP_SRC" ]]; then
  cp "$DESKTOP_SRC" "$DESKTOP_DEST"
  sed -i "s|Exec=.*|Exec=$WRAPPER %U|" "$DESKTOP_DEST"
  echo "✅ Desktop entry overridden at $DESKTOP_DEST"
else
  echo "⚠️ Could not find $DESKTOP_SRC. Skipping desktop override."
fi

# === Optional: Refresh launcher cache ===
update-desktop-database ~/.local/share/applications &>/dev/null || true

echo "🎉 Done. You can now launch Brave with full flags via terminal or launcher."
