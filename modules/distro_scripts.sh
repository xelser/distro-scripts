#!/bin/bash

git config --global user.email "dkzenzuri@gmail.com"
git config --global user.name "${USER}"

# === CONFIGURATION ===
GITHUB_DIR="/mnt/Home/Documents/Github"
SSH_DIR="$HOME/.ssh"
PRIVATE_KEY="$GITHUB_DIR/id_ed25519"
PUBLIC_KEY="$GITHUB_DIR/id_ed25519.pub"
TOKEN_FILE="$GITHUB_DIR/token.txt"

# === STEP 1: Create ~/.ssh and Symlink Keys ===
echo "🔗 Setting up SSH key symlinks..."
mkdir -p "$SSH_DIR"
ln -sf "$PRIVATE_KEY" "$SSH_DIR/id_ed25519"
ln -sf "$PUBLIC_KEY" "$SSH_DIR/id_ed25519.pub"
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR/id_ed25519"
chmod 644 "$SSH_DIR/id_ed25519.pub"

# === STEP 2: Start SSH Agent and Add Key ===
echo "🚀 Starting ssh-agent and adding key..."
eval "$(ssh-agent -s)"
ssh-add "$SSH_DIR/id_ed25519"

# === STEP 3: Authenticate with GitHub CLI ===
echo "🔐 Authenticating with GitHub CLI..."
if ! gh auth status &>/dev/null; then
    if [ -f "$TOKEN_FILE" ]; then
        gh auth login --with-token < "$TOKEN_FILE"
    else
        echo "❌ Token file not found at $TOKEN_FILE"
        exit 1
    fi
else
    echo "✅ GitHub CLI already authenticated."
fi

# === STEP 4: Test SSH Connection to GitHub ===
echo "🧪 Testing SSH connection to GitHub..."
ssh-keyscan github.com >> "$SSH_DIR/known_hosts"
ssh -T git@github.com

echo "🎉 Setup complete! You can now use git over SSH."

########

cd $HOME/Documents && git clone git@github.com:xelser/distro-scripts && rm $HOME/distro_scripts.sh
