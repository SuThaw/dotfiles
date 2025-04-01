#!/bin/bash
# Dotfiles uninstallation script for fullstack development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Variables
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"
FORCE_MODE=false
COMPONENT=""

# Help function
show_help() {
    echo "Usage: $0 [options] [component]"
    echo
    echo "Options:"
    echo "  --force         Skip all confirmations"
    echo "  --help, -h      Show this help message"
    echo
    echo "Components:"
    echo "  all             Remove all components (default)"
    echo "  zsh             Remove ZSH configuration"
    echo "  starship        Remove Starship configuration"
    echo "  tmux            Remove tmux configuration"
    echo "  wezterm         Remove WezTerm configuration"
    echo "  ghostty         Remove Ghostty configuration"
    echo "  git             Remove Git configuration"
    echo "  vscode          Remove VS Code configuration"
    echo "  neovim          Remove Neovim/LazyVim configuration"
    echo "  bun             Remove Bun configuration"
    echo
    echo "Examples:"
    echo "  $0                      # Interactive removal of all components"
    echo "  $0 --force              # Force removal of all components"
    echo "  $0 tmux                 # Remove only tmux configuration"
    echo "  $0 --force zsh          # Force remove only ZSH configuration"
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_MODE=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        all|zsh|starship|tmux|wezterm|ghostty|git|vscode|neovim|bun)
            COMPONENT="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Set default component to "all" if not specified
if [ -z "$COMPONENT" ]; then
    COMPONENT="all"
fi

# Helper functions
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}==>${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}==>${NC} $1"
}

remove_symlink() {
    if [ -L "$1" ]; then
        rm -f "$1"
        print_success "Removed symlink: $1"
    fi
}

restore_backup() {
    # Find the most recent backup
    local most_recent=$(ls -td "$BACKUP_DIR"/* 2>/dev/null | head -n 1)
    
    if [ -n "$most_recent" ] && [ -e "$most_recent/$1" ]; then
        cp -R "$most_recent/$1" "$(dirname "$1")"
        print_success "Restored $1 from backup"
    fi
}

confirm() {
    if [ "$FORCE_MODE" = true ]; then
        return 0  # Always return true in force mode
    else
        read -p "$1 (y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Uninstall function for each component
uninstall_zsh() {
    print_step "Removing ZSH configuration..."
    remove_symlink "$HOME/.zshrc"
    restore_backup "$HOME/.zshrc"
    
    if [ "$COMPONENT" = "all" ] && confirm "Do you want to remove ZSH plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf completion)?"; then
        rm -rf "$HOME/.zsh"
        rm -f "$HOME/.fzf.zsh"
        rm -f "$HOME/.fzf.bash"
        print_success "Removed ZSH plugins and fzf completion"
    fi
}

uninstall_starship() {
    print_step "Removing Starship configuration..."
    remove_symlink "$HOME/.config/starship.toml"
    restore_backup "$HOME/.config/starship.toml"
}

uninstall_tmux() {
    print_step "Removing tmux configuration..."
    remove_symlink "$HOME/.config/tmux/tmux.conf"
    restore_backup "$HOME/.config/tmux/tmux.conf"
    
    if [ "$COMPONENT" = "all" ] && confirm "Do you want to remove tmux plugins?"; then
        rm -rf "$HOME/.tmux"
        print_success "Removed tmux plugins"
    fi
}

uninstall_wezterm() {
    print_step "Removing WezTerm configuration..."
    remove_symlink "$HOME/.config/wezterm/wezterm.lua"
    restore_backup "$HOME/.config/wezterm/wezterm.lua"
}

uninstall_ghostty() {
    print_step "Removing Ghostty configuration..."
    remove_symlink "$HOME/.config/ghostty/config"
    restore_backup "$HOME/.config/ghostty/config"
}

uninstall_git() {
    print_step "Removing Git configuration..."
    remove_symlink "$HOME/.gitconfig"
    restore_backup "$HOME/.gitconfig"
    remove_symlink "$HOME/.gitignore_global"
    restore_backup "$HOME/.gitignore_global"
}

uninstall_vscode() {
    print_step "Removing VS Code configuration..."
    remove_symlink "$HOME/Library/Application Support/Code/User/settings.json"
    restore_backup "$HOME/Library/Application Support/Code/User/settings.json"
}

uninstall_neovim() {
    print_step "Handling Neovim configuration..."
    if [ "$COMPONENT" = "all" ]; then
        if confirm "Do you want to completely remove LazyVim/Neovim configuration?"; then
            if [ -d "$HOME/.config/nvim" ]; then
                rm -rf "$HOME/.config/nvim"
                print_success "Removed Neovim configuration"
            fi
        else
            # Find all symlinks in nvim directory and remove them
            print_step "Removing only symlinked Neovim configuration files..."
            if [ -d "$HOME/.config/nvim" ]; then
                find "$HOME/.config/nvim" -type l -exec rm {} \; -exec echo "Removed symlink: {}" \;
            fi
        fi
    else
        # When specifically uninstalling neovim, just remove the symlinks by default
        print_step "Removing symlinked Neovim configuration files..."
        if [ -d "$HOME/.config/nvim" ]; then
            find "$HOME/.config/nvim" -type l -exec rm {} \; -exec echo "Removed symlink: {}" \;
        fi
        
        if confirm "Do you want to completely remove LazyVim/Neovim configuration?"; then
            if [ -d "$HOME/.config/nvim" ]; then
                rm -rf "$HOME/.config/nvim"
                print_success "Removed Neovim configuration"
            fi
        fi
    fi
}

uninstall_bun() {
    print_step "Removing Bun configuration..."
    
    # Remove Bun path from .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        # Make a backup if it's not a symlink (our symlink would already be handled)
        if [ ! -L "$HOME/.zshrc" ]; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
            print_warning "Backed up .zshrc to .zshrc.bak"
            
            # Remove Bun-related lines from .zshrc
            sed -i '' '/# Bun configuration/d' "$HOME/.zshrc"
            sed -i '' '/export BUN_INSTALL/d' "$HOME/.zshrc"
            sed -i '' '/export PATH="$BUN_INSTALL\/bin:$PATH"/d' "$HOME/.zshrc"
            sed -i '' '/# Bun aliases/d' "$HOME/.zshrc"
            sed -i '' '/alias bi=/d' "$HOME/.zshrc"
            sed -i '' '/alias bid=/d' "$HOME/.zshrc"
            sed -i '' '/alias ba=/d' "$HOME/.zshrc"
            sed -i '' '/alias bad=/d' "$HOME/.zshrc"
            sed -i '' '/alias br=/d' "$HOME/.zshrc"
            sed -i '' '/alias bx=/d' "$HOME/.zshrc"
            sed -i '' '/alias bd=/d' "$HOME/.zshrc"
            sed -i '' '/alias bs=/d' "$HOME/.zshrc"
            sed -i '' '/alias bb=/d' "$HOME/.zshrc"
            sed -i '' '/alias bt=/d' "$HOME/.zshrc"
            
            print_success "Removed Bun configuration from .zshrc"
        fi
    fi
    
    if [ "$COMPONENT" = "all" ] || confirm "Do you want to completely uninstall Bun?"; then
        if [ -d "$HOME/.bun" ]; then
            rm -rf "$HOME/.bun"
            print_success "Removed Bun installation directory"
        fi
    fi
}

final_cleanup() {
    # Only run for "all" component
    if [ "$COMPONENT" = "all" ]; then
        if confirm "Do you want to remove the dotfiles directory ($DOTFILES_DIR)?"; then
            print_step "Removing dotfiles directory..."
            rm -rf "$DOTFILES_DIR"
            print_success "Removed dotfiles directory"
        fi

        if confirm "Do you want to keep the backup files?"; then
            print_success "Keeping backup files in $BACKUP_DIR"
        else
            print_step "Removing backup files..."
            rm -rf "$BACKUP_DIR"
            print_success "Removed backup files"
        fi
    fi
}

# Main execution
if [ "$COMPONENT" != "all" ]; then
    print_step "Uninstalling $COMPONENT configuration..."
    if ! confirm "Are you sure you want to uninstall your $COMPONENT configuration?"; then
        print_warning "Uninstallation cancelled"
        exit 0
    fi
else
    print_step "Starting full uninstallation process..."
    if ! confirm "Are you sure you want to uninstall your entire dotfiles setup?"; then
        print_warning "Uninstallation cancelled"
        exit 0
    fi
fi

# Execute the appropriate uninstall function(s)
case $COMPONENT in
    all)
        uninstall_zsh
        uninstall_starship
        uninstall_tmux
        uninstall_wezterm
        uninstall_ghostty
        uninstall_git
        uninstall_vscode
        uninstall_neovim
        uninstall_bun
        final_cleanup
        ;;
    zsh)
        uninstall_zsh
        ;;
    starship)
        uninstall_starship
        ;;
    tmux)
        uninstall_tmux
        ;;
    wezterm)
        uninstall_wezterm
        ;;
    ghostty)
        uninstall_ghostty
        ;;
    git)
        uninstall_git
        ;;
    vscode)
        uninstall_vscode
        ;;
    neovim)
        uninstall_neovim
        ;;
    bun)
        uninstall_bun
        ;;
esac

print_success "Uninstallation of $COMPONENT complete!"
print_warning "Some changes may require restarting your terminal or applications to take effect."

if [ "$COMPONENT" = "all" ]; then
    echo ""
    echo "If you want to completely remove all developer tools, you'll need to manually uninstall:"
    echo "- Homebrew (and all packages installed with it)"
    echo "- Node.js/NVM"
    echo "- Go"
    echo "- Docker"
    echo "- VS Code"
fi
