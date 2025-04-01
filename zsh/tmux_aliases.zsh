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
