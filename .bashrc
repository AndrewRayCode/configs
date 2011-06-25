# Don't wait for job termination notification
set -o notify

# vim bindings in terminal
set -o vi

alias here='open .'

#######################################
# distributed version control section #
#######################################

alias dff=dvcs_diff
alias lg=dvcs_lg
alias add=dvcs_add
alias push=dvcs_push
alias ct=dvcs_commit
alias cta=dvcs_commit_all
alias st=dvcs_sts
alias gca='git commit -am'
alias gb='git branch'
alias gco='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'

function dvcs_diff {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git diff --color "$@"
    else
        hg diff "$@"
    fi
}

function dvcs_lg {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git log --color "$@"
    else
        hg log "$@"
    fi
}

function dvcs_add {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git add "$@"
    else
        hg add "$@"
    fi
}

function dvcs_push {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git push "$@"
    else
        hg push "$@"
    fi
}

function dvcs_commit {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git commit -m "$@"
    else
        hg ci -m "$@"
    fi
}

function dvcs_sts {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git log --color "$@"
    else
        hg st "$@"
    fi
}

function dvcs_commit_all {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git commit -am "$@"
    else
        hg ci -m "$@"
    fi
}

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

# Mercurial conflicts
function hg_conflicts {
    ref=$(hg resolve -l 2> /dev/null | grep "U " | awk '{split($0,a," "); print a[2];}' 2> /dev/null) || return
    if [[ "$ref" != "" ]]; then
        echo -e " \033[0;31m(\033[0;33m\xE2\x98\xA0 \033[0;31m${ref})"
    fi
}

PS1="\n$YELLOW\u@$GREEN\w$PURPLE\$(hg_ps1)$YELLOW\$(parse_git_branch)\$(hg_conflicts)$RESET \$ "
