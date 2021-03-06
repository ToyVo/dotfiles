#
# ~/.zshrc
#

# add local bin to path
export PATH=$PATH:$HOME/.local/bin

# set default editor
export EDITOR=nvim

# aliases
alias ls='ls --color=auto'

HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt nomatch globdots
unsetopt autocd beep extendedglob notify
bindkey -v

zstyle :compinstall filename '/home/toyvo/.zshrc'
zstyle ':completion:*' matcher-list '' '+m:{a-zA-Z}={A-Za-z}' '+r:|[._-]=* r:|=*' '+l:|=* r:|=*'

autoload -Uz compinit && compinit

# run neofetch at launch
neofetch

# prompt
eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
