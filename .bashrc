# Don't wait for job termination notification
set -o notify

# vim bindings in terminal
set -o vi

# Git aliases
alias 'dff'='git diff --color'
alias 'lg'='git log --color'
alias ga='git add'
alias gp='git push'
alias gc='git commit -m'
alias gca='git commit -am'
alias gb='git branch'
alias gco='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'

alias here='open .'
alias st='git status'

export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/Cellar/python/2.7/bin/:$PATH

#Fix shitty characters in RXVT
export LANG=C.ASCII

# bitbucket setup
export WORKON_HOME="$HOME/Envs"
export PIP_RESPECT_VIRTUALENV=true \
       PIP_VIRTUALENV_BASE="$WORKON_HOME" \
       VIRTUALENV_USE_DISTRIBUTE=1
[[ -n "$(command -v virtualenvwrapper.sh)" ]] && source virtualenvwrapper.sh

# Colors for prompt
RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
PURPLE="\[\033[0;35m\]"
GREEN="\[\033[0;32m\]"
WHITE="\[\033[0;37m\]"
RESET="\[\033[0;00m\]"

# Command to get current git branch if it exists
function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo " ("${ref#refs/heads/}")"
}

# NOT USED: function to show how many local commits you have ahead of upstream
function num_git_commits_ahead {
    num=$(git status | grep "Your branch is ahead of" | awk '{split($0,a," "); print a[9];}' 2> /dev/null) || return
    if [[ "$num" != "" ]]; then
        echo "+$num"
    fi
}

# Function to get mercurial branch, needs hg-prompt from https://bitbucket.org/sjl/hg-prompt/src
function hg_ps1 {
    ref=$(hg prompt "{branch}" 2> /dev/null) || return
    echo " (${ref})"
}

PS1="\n$YELLOW\u@$GREEN\w$PURPLE\$(hg_ps1)$YELLOW\$(parse_git_branch)$RESET \$ "
