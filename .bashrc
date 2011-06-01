# base-files version 3.7-1

# To pick up the latest recommended .bashrc content,
# look in /etc/defaults/etc/skel/.bashrc

# Modifying /etc/skel/.bashrc directly will prevent
# setup from updating it.

# The copy in your home directory (~/.bashrc) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benificial to all, please feel free to send
# a patch to the cygwin mailing list.

# User dependent .bashrc file


# Shell Options
# #############

# See man bash for more options...

# Don't wait for job termination notification
set -o notify

# Don't use ^D to exit
# set -o ignoreeof

# Use case-insensitive filename globbing
# shopt -s nocaseglob

# Make bash append rather than overwrite the history on disk
# shopt -s histappend

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell


# Completion options
# ##################

# These completion tuning parameters change the default behavior of bash_completion:

# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1

# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1

# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1

# If this shell is interactive, turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
# case $- in
#   *i*) [[ -f /etc/bash_completion ]] && . /etc/bash_completion ;;
# esac


# History Options
# ###############

# Don't put duplicate lines in the history.
export HISTCONTROL="ignoredups"

#Fix shitty characters in RXVT
export LANG=C.ASCII

# Ignore some controlling instructions
# export HISTIGNORE="[   ]*:&:bg:fg:exit"

# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"


# Aliases
# #######

# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.

# Interactive operation...
alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# Default to human readable figures
# alias df='df -h'
# alias du='du -h'

# Misc :)
# alias grep='grep --color'                     # show differences in colour

# Some shortcuts for different directory listings
function so {
eval "$@" |less -I~
}

#alias python='/cygdrive/c/Python26/python.exe'
# Functions
# #########

# Some example functions
# function settitle() { echo -ne "\e]2;$@\a\e]1;$@\a"; }

RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
PURPLE="\[\033[0;35m\]"
GREEN="\[\033[0;32m\]"
WHITE="\[\033[0;37m\]"
RESET="\[\033[0;00m\]"

function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo " ("${ref#refs/heads/}")"
}

function num_git_commits_ahead {
    num=$(git status | grep "Your branch is ahead of" | awk '{split($0,a," "); print a[9];}' 2> /dev/null) || return
    if [[ "$num" != "" ]]; then
        echo "+$num"
    fi
}

# https://bitbucket.org/sjl/hg-prompt/src
function hg_ps1 {
    ref=$(hg prompt "{branch}" 2> /dev/null) || return
    echo " (${ref})"
}

export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/Cellar/python/2.7/bin/:$PATH
set -o vi

# bitbucket setup
export WORKON_HOME="$HOME/Envs"
export PIP_RESPECT_VIRTUALENV=true \
       PIP_VIRTUALENV_BASE="$WORKON_HOME" \
       VIRTUALENV_USE_DISTRIBUTE=1

[[ -n "$(command -v virtualenvwrapper.sh)" ]] && source virtualenvwrapper.sh


PS1="\n$YELLOW\u@$GREEN\w$PURPLE\$(hg_ps1)$YELLOW\$(parse_git_branch)$RESET \$ "
