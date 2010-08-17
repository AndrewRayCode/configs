# base-files version 3.9-3

# To pick up the latest recommended .bash_profile content,
# look in /etc/defaults/etc/skel/.bash_profile

# Modifying /etc/skel/.bash_profile directly will prevent
# setup from updating it.

# The copy in your home directory (~/.bash_profile) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the cygwin mailing list.

# ~/.bash_profile: executed by bash for login shells.

# source the system wide bashrc if it exists
if [ -e /etc/bash.bashrc ] ; then
  source /etc/bash.bashrc
fi

# source the users bashrc if it exists
if [ -e "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# Set PATH so it includes user's private bin if it exists
# if [ -d "${HOME}/bin" ] ; then
#   PATH=${HOME}/bin:${PATH}
# fi

# Set MANPATH so it includes users' private man if it exists
# if [ -d "${HOME}/man" ]; then
#   MANPATH=${HOME}/man:${MANPATH}
# fi

# Set INFOPATH so it includes users' private info if it exists
# if [ -d "${HOME}/info" ]; then
#   INFOPATH=${HOME}/info:${INFOPATH}
# fi

# function parse_git_branch {
  # ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  # echo "("${ref#refs/heads/}")"
# }

# function num_git_commits_ahead {
    # num=$(git status | grep "Your branch is ahead of" | awk '{split($0,a," "); print a[9];}' 2> /dev/null) || return
    # if [[ "$num" != "" ]]; then
        # echo "+$num"
    # fi
# }

# RED="\[\033[0;31m\]"
# YELLOW="\[\033[0;33m\]"
# GREEN="\[\033[0;32m\]"
# WHITE="\[\033[0;37m\]"
# RESET="\[\033[0;00m\]"
# PS1="\n$YELLOW\u@$GREEN\w $YELLOW\$(parse_git_branch)
# $GREEN\$ $RESET"
