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

# export PATH=/usr/local/share/python:/usr/local/Cellar/python/2.7.1/bin:/usr/local/bin:/usr/local/sbin:$PATH
export PATH=/Users/aray/apache-maven-2.1.0/bin:/usr/local/share/python:/usr/local/bin:/usr/local/sbin:$PATH

#Fix shitty characters in RXVT
export LANG=US.UTF-8
export LC_ALL=C

# bitbucket setup
export WORKON_HOME="$HOME/Documents/Envs"
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

function hg_conflicts {
    ref=$(hg resolve -l 2> /dev/null | grep "U " | awk '{split($0,a," "); print a[2];}' 2> /dev/null) || return
    if [[ "$ref" != "" ]]; then
        echo -e " \033[0;31m(\033[0;33m\xE2\x98\xA0 \033[0;31m${ref})"
    fi
}

PS1="\n$YELLOW\u@$GREEN\w$PURPLE\$(hg_ps1)$YELLOW\$(parse_git_branch)$RED\$(hg_conflicts)$RESET \$ "
