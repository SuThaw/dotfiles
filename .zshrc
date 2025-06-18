# Minimal .zshrc optimized for TS, Node.js, and Go development
# with focus on Neovim, VS Code, tmux, and terminal tools

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Completion system
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Basic key bindings
bindkey -e  # emacs key bindings
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# Path setup
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Go configuration
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# Node.js/NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Bun configuration
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Editor configuration
export EDITOR='nvim'
export VISUAL='nvim'

# Set TERM for proper colors in tmux
export TERM="xterm-256color"

# Add commonly used directories to cdpath for quick navigation
cdpath=(. $HOME/projects $GOPATH/src/github.com)

# Source tmux aliases
[ -f "$HOME/.zsh/tmux_aliases.zsh" ] && source "$HOME/.zsh/tmux_aliases.zsh"

# Aliases for improved tools
if command -v eza &> /dev/null; then
  alias ls="eza --icons"
  alias ll="eza -la --icons"
  alias lt="eza --tree --icons"
fi

if command -v bat &> /dev/null; then
  alias cat="bat"
fi

if command -v rg &> /dev/null; then
  alias grep="rg"
fi

# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Git aliases
alias g="git"
alias gs="git status"
alias gc="git commit"
alias gco="git checkout"
alias gb="git branch"
alias gp="git push"
alias gl="git log --oneline --graph"
alias gd="git diff"
alias ga="git add"
alias gaa="git add --all"

# Node.js/npm/yarn aliases
alias ni="npm install"
alias nid="npm install --save-dev"
alias nig="npm install -g"
alias nr="npm run"
alias nrs="npm run start"
alias nrd="npm run dev"
alias nrb="npm run build"
alias nrt="npm run test"
alias y="yarn"
alias yd="yarn dev"
alias yb="yarn build"
alias ys="yarn start"

# Bun aliases
alias bi="bun install"
alias bid="bun install --dev"
alias ba="bun add"
alias bad="bun add --dev"
alias br="bun run"
alias bx="bun x"
alias bd="bun dev"
alias bs="bun start"
alias bb="bun build"
alias bt="bun test"

# TypeScript aliases
alias tsc="npx tsc"
alias tsn="ts-node"

# Go aliases
alias gr="go run"
alias gt="go test"
alias gtv="go test -v"
alias gb="go build"
alias gta="go test ./..."
alias gf="go fmt ./..."

# Docker aliases
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"

# tmux aliases
alias t="tmux"
alias ta="tmux attach"
alias tls="tmux ls"
alias tn="tmux new -s"

# Neovim aliases
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

# VSCode
alias code="code"

# Utility functions
# Create a new directory and enter it
mcd() {
  mkdir -p "$1" && cd "$1"
}

# Find file by name
ff() {
  find . -type f -name "*$1*"
}

# Find directory by name
fd() {
  find . -type d -name "*$1*"
}

# tmux create or attach
tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1")
  else
    tmux $change -t $(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) 2>/dev/null || tmux
  fi
}

# FZF configuration for fuzzy finding
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load zsh-autosuggestions if installed
if [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Load zsh-syntax-highlighting if installed (must be at the end)
if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Initialize Starship prompt
eval "$(starship init zsh)"

# Added by Windsurf
export PATH="/Users/suthaw/.codeium/windsurf/bin:$PATH"
