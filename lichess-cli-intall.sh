#!/bin/bash

set -e

# Define paths
REPO_URL="https://github.com/mattcanty/lichess-cli.git"
INSTALL_DIR="$HOME/.local/bin"
REPO_NAME="lichess-cli"

# Install Go if not found
if ! command -v go &> /dev/null; then
    echo "Go not found. Installing..."
    sudo xbps-install -Sy go
fi

# Install Git if not found
if ! command -v git &> /dev/null; then
    echo "Git not found. Installing..."
    sudo xbps-install -Sy git
fi

# Create install dir if missing
mkdir -p "$INSTALL_DIR"

# Clone repo
echo "Cloning $REPO_URL..."
rm -rf "$REPO_NAME"
git clone "$REPO_URL"
cd "$REPO_NAME"

# Prepare Go modules
echo "Tidying Go modules..."
go mod tidy

# Build binary
echo "Building lichess-cli..."
go build -o lichess-cli

# Install binary
echo "Installing to $INSTALL_DIR..."
install -Dm755 lichess-cli "$INSTALL_DIR/lichess-cli"

# Add to PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
    echo "Added $INSTALL_DIR to PATH. Restart your shell or run: source ~/.bashrc"
fi

echo "✅ lichess-cli installed successfully!"

