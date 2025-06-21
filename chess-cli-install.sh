#!/bin/bash

set -e

# Step 1: Install chess-cli
echo "[+] Installing chess-cli..."
go install github.com/nemo984/chess-cli@latest

# Step 2: Add $HOME/go/bin to PATH in .bashrc if not already present
if ! grep -q 'export PATH="$HOME/go/bin:$PATH"' "$HOME/.bashrc"; then
    echo '[+] Adding $HOME/go/bin to PATH in .bashrc...'
    echo 'export PATH="$HOME/go/bin:$PATH"' >> "$HOME/.bashrc"
else
    echo '[=] $HOME/go/bin already in PATH.'
fi

# Step 3: Reload .bashrc
echo "[+] Reloading .bashrc..."
source "$HOME/.bashrc"

# Step 4: Verify installation
echo "[+] Verifying chess-cli installation..."
if command -v chess-cli >/dev/null 2>&1; then
    echo "[✓] chess-cli installed successfully!"
    chess-cli --help
else
    echo "[✗] chess-cli not found in PATH. Try restarting your terminal."
    exit 1
fi

