#!/bin/bash

set -e

THEME="${1}"
THEME_DIR="$HOME/themes"
INSTALL_DIR="$HOME/.config"

# Interactive mode if no argument
if [[ -z "$THEME" ]]; then
    echo "Select theme:"
    echo "1) Green"
    echo "2) Mono"
    read -p "Choice [1-2]: " choice
    case "$choice" in
        1) THEME="green" ;;
        2) THEME="mono" ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
fi

usage() {
    echo "Usage: $0 [green|mono|toggle|interactive]"
    echo ""
    echo "  green   - Apply green theme"
    echo "  mono    - Apply monochrome theme"
    echo "  toggle  - Toggle between green and mono"
    echo "  (no arg) - Interactive selection"
    exit 1
}

get_current_theme() {
    # Check a known symlink to determine current theme
    local link="$INSTALL_DIR/nvim/colors/zet/colors/zet.lua"
    if [[ -L "$link" ]]; then
        local target="$(readlink -f "$link")"
        if [[ "$target" == *"/mono"* ]]; then
            echo "mono"
        else
            echo "green"
        fi
    else
        echo "unknown"
    fi
}

link_or_copy() {
    local src="$1"
    local dest="$2"
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"
    
    if [[ -L "$dest" ]]; then
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        mv "$dest" "${dest}.bak"
    fi
    ln -sf "$src" "$dest"
}

apply_theme() {
    local theme="$1"
    local src_dir="$THEME_DIR/$theme"

    echo "Applying $theme theme..."

    # Kitty
    link_or_copy "$src_dir/theme.conf" "$INSTALL_DIR/kitty/theme.conf"

    # Qutebrowser CSS
    link_or_copy "$src_dir/green-black.css" "$INSTALL_DIR/qutebrowser/green-black.css"

    # Qutebrowser config (all workspaces)
    cp "$src_dir/qutebrowser-config.py" "$INSTALL_DIR/qutebrowser/config/config.py"
    cp "$src_dir/qutebrowser-config.py" "$INSTALL_DIR/qutebrowser/workspace/hacking/config/config.py"
    cp "$src_dir/qutebrowser-config.py" "$INSTALL_DIR/qutebrowser/workspace/study/config/config.py"
    cp "$src_dir/qutebrowser-config.py" "$INSTALL_DIR/qutebrowser/workspace/z6/config/config.py"

    # Bat
    link_or_copy "$src_dir/z6.tmTheme" "$INSTALL_DIR/bat/themes/z6/z6.tmTheme"

    # Neovim
    link_or_copy "$src_dir/zet.lua" "$INSTALL_DIR/nvim/colors/zet/colors/zet.lua"
    link_or_copy "$src_dir/zet.lua" "$INSTALL_DIR/nvim/colors/zet/lua/lush_theme/zet.lua"

    # Neovim Lualine
    cp "$src_dir/lualine.lua" "$INSTALL_DIR/nvim/lua/plugins/lualine.lua"
    local lualine_theme="zet"
    if [[ "$theme" == "mono" ]]; then
        lualine_theme="zet-mono"
    fi
    cp "/home/z6/opencode/theme/themes/$theme/lualine-theme.lua" "$INSTALL_DIR/nvim/lua/lualine/themes/zet.lua"

    # i3
    link_or_copy "$src_dir/config" "$INSTALL_DIR/i3/config"

    # Tmux
    cp "$src_dir/tmux.conf" "$HOME/.tmux.conf"

    # Rofi
    link_or_copy "$src_dir/z6.rasi" "$INSTALL_DIR/rofi/config.rasi"

    # Polybar
    local polybar_color="green"
    if [[ "$theme" == "mono" ]]; then
        polybar_color="bw"
    fi
    link_or_copy "/home/z6/opencode/theme/polybar/cuts/colors-${polybar_color}.ini" "$INSTALL_DIR/polybar/cuts/colors.ini"

    # Oh My Posh (~/.themes/z6.omp.json)
    link_or_copy "$src_dir/z6.omp.json" "$HOME/.themes/z6.omp.json"

    # Spinner (virt spinner)
    local spinner_name="green-spinner.sh"
    if [[ "$theme" == "mono" ]]; then
        spinner_name="mono-spinner.sh"
    fi
    link_or_copy "$THEME_DIR/$theme/$spinner_name" "$HOME/app/spiner.sh"

    echo "$theme theme applied!"
    echo ""
    echo "Restarting programs to apply changes..."
    
    # Restart i3 to apply config and wallpaper
    i3-msg reload
    
    # Restart polybar
    pkill -f polybar || true
    ~/.config/polybar/launch.sh --cuts &
    
    # Restart qutebrowser
    pkill -f qutebrowser || true

    # Restart nvim (send :LvimReloadCmd if running)
    nvim --headless +":LvimReload" +q 2>/dev/null || true

    # Reload tmux config
    tmux source-file ~/.tmux.conf 2>/dev/null || true
    
    echo "Done! Please restart any remaining programs manually."
}

case "$THEME" in
    green)
        apply_theme "green"
        ;;
    mono)
        apply_theme "mono"
        ;;
    toggle)
        current=$(get_current_theme)
        if [[ "$current" == "mono" ]]; then
            apply_theme "green"
        else
            apply_theme "mono"
        fi
        ;;
    *)
        usage
        ;;
esac
