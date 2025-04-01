#!/bin/bash
# Dotfiles installation script for fullstack development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Variables
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

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

backup_file() {
  if [ -e "$1" ] && [ ! -L "$1" ]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$1")"
    mv "$1" "$BACKUP_DIR/$1"
    print_warning "Backed up $1 to $BACKUP_DIR/$1"
  elif [ -L "$1" ]; then
    rm -f "$1"
    print_warning "Removed symlink $1"
  fi
}

create_symlink() {
  mkdir -p "$(dirname "$2")"
  ln -sf "$1" "$2"
  print_success "Created symlink $1 -> $2"
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Install Homebrew if not installed
print_step "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  print_step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH
  if [[ $(uname -m) == 'arm64' ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>$HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >>$HOME/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  print_success "Homebrew already installed"
fi

# Install dependencies from Brewfile
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  print_step "Installing dependencies from Brewfile..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  print_success "Dependencies installed"
else
  print_error "Brewfile not found"
fi

# Setup ZSH
print_step "Setting up ZSH configuration..."
backup_file "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Create directories for zsh plugins
mkdir -p "$HOME/.zsh/zsh-autosuggestions"
mkdir -p "$HOME/.zsh/zsh-syntax-highlighting"

# Install zsh plugins if not already installed
print_step "Installing ZSH plugins..."
if [ ! -d "$HOME/.zsh/zsh-autosuggestions/.git" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
fi

if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting/.git" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/zsh-syntax-highlighting"
fi

# Setup ZSH components (aliases, functions, etc.)
print_step "Setting up ZSH components..."
if [ -d "$DOTFILES_DIR/zsh" ]; then
  mkdir -p "$HOME/.zsh"
  for file in "$DOTFILES_DIR/zsh"/*.zsh; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      create_symlink "$file" "$HOME/.zsh/$filename"
    fi
  done
else
  mkdir -p "$DOTFILES_DIR/zsh"
  # Create tmux aliases file if it doesn't exist
  if [ ! -f "$DOTFILES_DIR/zsh/tmux_aliases.zsh" ]; then
    print_step "Creating tmux aliases file..."
    cat >"$DOTFILES_DIR/zsh/tmux_aliases.zsh" <<'EOF'
# tmux aliases
# Quick session starters
alias td='tmux new -s dev -c ~/dev/projects'
alias ti='tmux new -s infra -c ~/dev/infra'
alias tl='tmux new -s learn -c ~/dev/learning'

# Quick attach
alias tad='tmux attach -t dev'
alias tai='tmux attach -t infra'
alias tal='tmux attach -t learn'

# List sessions
alias tls='tmux ls'

# Kill sessions
alias tkd='tmux kill-session -t dev'
alias tki='tmux kill-session -t infra'
alias tkl='tmux kill-session -t learn'
EOF
    print_success "Created tmux aliases file"
  fi
fi

# Install fzf
print_step "Installing fzf..."
# fzf is installed via Homebrew now, just set up completions
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

# Setup Starship
print_step "Setting up Starship..."
mkdir -p "$HOME/.config"
backup_file "$HOME/.config/starship.toml"
create_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

# Install Starship if not installed
if ! command -v starship &>/dev/null; then
  print_step "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh
fi

# Setup tmux
print_step "Setting up tmux..."
mkdir -p "$HOME/.config/tmux"
backup_file "$HOME/.config/tmux/tmux.conf"
create_symlink "$DOTFILES_DIR/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Setup tmux reset configuration
backup_file "$HOME/.config/tmux/tmux.reset.conf"
create_symlink "$DOTFILES_DIR/.config/tmux/tmux.reset.conf" "$HOME/.config/tmux/tmux.reset.conf"

# Install tpm (tmux plugin manager) if not installed
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  print_step "Installing tmux plugin manager..."
  mkdir -p "$HOME/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Setup terminal emulator (WezTerm or Ghostty)
print_step "Setting up terminal configuration..."

# WezTerm setup
mkdir -p "$HOME/.config/wezterm"
backup_file "$HOME/.config/wezterm/wezterm.lua"
create_symlink "$DOTFILES_DIR/.config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

# Ghostty setup
mkdir -p "$HOME/.config/ghostty"
backup_file "$HOME/.config/ghostty/config"
create_symlink "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"

# Git configuration
print_step "Setting up Git configuration..."
backup_file "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
backup_file "$HOME/.gitignore_global"
create_symlink "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"

# VS Code setup
print_step "Setting up VSCode configuration..."
mkdir -p "$HOME/Library/Application Support/Code/User"
backup_file "$HOME/Library/Application Support/Code/User/settings.json"
create_symlink "$DOTFILES_DIR/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"

# Install VS Code extensions
if command -v code &>/dev/null; then
  print_step "Installing VS Code extensions..."
  # Read extensions from a file and install them
  if [ -f "$DOTFILES_DIR/vscode/extensions.txt" ]; then
    while read -r extension; do
      [ -n "$extension" ] && code --install-extension "$extension" --force
    done <"$DOTFILES_DIR/vscode/extensions.txt"
  fi
fi

# Setup Go environment
print_step "Setting up Go environment..."
mkdir -p "$HOME/go/bin"
mkdir -p "$HOME/go/src"
mkdir -p "$HOME/go/pkg"

# NVM setup for Node.js
print_step "Setting up NVM for Node.js..."
if [ ! -d "$HOME/.nvm" ]; then
  mkdir -p "$HOME/.nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  npm install -g typescript ts-node nodemon yarn
fi

# Bun setup
print_step "Setting up Bun..."
if ! command -v bun &>/dev/null; then
  print_step "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  print_success "Bun installed"
else
  print_success "Bun already installed"
fi

# LazyVim setup (if not already installed)
print_step "Setting up LazyVim..."
if [ ! -d "$HOME/.config/nvim/.git" ]; then
  # Backup existing neovim config
  if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim"
  fi
  # Clone LazyVim starter
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  # Remove git directory to prepare for customization
  rm -rf "$HOME/.config/nvim/.git"
  print_success "LazyVim installed"
else
  print_success "LazyVim already installed"
fi

# Link custom Neovim configurations
print_step "Setting up custom Neovim configurations..."
mkdir -p "$DOTFILES_DIR/.config/nvim/lua/plugins"
mkdir -p "$DOTFILES_DIR/.config/nvim/lua/config"

# Create placeholder files if they don't exist
if [ ! -f "$DOTFILES_DIR/.config/nvim/lua/plugins/user.lua" ]; then
  echo "-- Your custom plugins" >"$DOTFILES_DIR/.config/nvim/lua/plugins/user.lua"
  echo "return {" >>"$DOTFILES_DIR/.config/nvim/lua/plugins/user.lua"
  echo "  -- Add your plugins here" >>"$DOTFILES_DIR/.config/nvim/lua/plugins/user.lua"
  echo "}" >>"$DOTFILES_DIR/.config/nvim/lua/plugins/user.lua"
fi

if [ ! -f "$DOTFILES_DIR/.config/nvim/lua/config/keymaps.lua" ]; then
  echo "-- Your custom keymaps" >"$DOTFILES_DIR/.config/nvim/lua/config/keymaps.lua"
  echo "local keymap = vim.keymap.set" >>"$DOTFILES_DIR/.config/nvim/lua/config/keymaps.lua"
  echo "local opts = { noremap = true, silent = true }" >>"$DOTFILES_DIR/.config/nvim/lua/config/keymaps.lua"
  echo "" >>"$DOTFILES_DIR/.config/nvim/lua/config/keymaps.lua"
  echo "-- Example keymap" >>"$DOTFILES_DIR/.config/nvim/lua/config/keymaps.lua"
  echo "-- keymap(\"n\", \"<leader>nh\", \":nohl<CR>\", { desc = \"Clear search highlight\" })" >>"$DOTFILES_DIR/.config/nvim/lua/config/keymaps.lua"
fi

if [ ! -f "$DOTFILES_DIR/.config/nvim/lua/config/options.lua" ]; then
  echo "-- Your custom options" >"$DOTFILES_DIR/.config/nvim/lua/config/options.lua"
  echo "-- Add your options here" >>"$DOTFILES_DIR/.config/nvim/lua/config/options.lua"
  echo "-- vim.opt.relativenumber = true" >>"$DOTFILES_DIR/.config/nvim/lua/config/options.lua"
fi

# Create symlinks for Neovim configurations
create_symlink "$DOTFILES_DIR/.config/nvim/lua/plugins/user.lua" "$HOME/.config/nvim/lua/plugins/user.lua"
create_symlink "$DOTFILES_DIR/.config/nvim/lua/config/keymaps.lua" "$HOME/.config/nvim/lua/config/keymaps.lua"
create_symlink "$DOTFILES_DIR/.config/nvim/lua/config/options.lua" "$HOME/.config/nvim/lua/config/options.lua"

print_success "All dotfiles have been installed!"
print_warning "Please restart your terminal for all changes to take effect."
