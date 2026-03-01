#!/usr/bin/env bash
# ~/Flake/modules/neovim/install-nvchad.sh

set -e

NVIM_DIR="$HOME/.config/nvim"

if [ ! -d "$NVIM_DIR" ]; then
    echo "📦 Installing NvChad..."
    git clone https://github.com/NvChad/starter "$NVIM_DIR"
    echo "✅ NvChad installed"
else
    echo "✅ NvChad already installed"
fi

echo "🔄 Updating plugins..."
nvim --headless -c 'Lazy! sync' -c 'quitall' 2>/dev/null || true
echo "✅ Plugins updated"
