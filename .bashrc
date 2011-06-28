# Don't wait for job termination notification
set -o notify

# vim bindings in terminal
set -o vi

# Do this on first load stupid:
# git config --global color.ui "auto"

# Uncomment the appropriate
source ~/.machine_loaner
# source ~/.machine_work

alias here='open .'

#######################################
# distributed version control section #
#######################################

alias dff=dvcs_diff
alias lg=dvcs_lg
alias add=dvcs_add
alias push=dvcs_push
alias ct=dvcs_commit
alias ca=dvcs_commit_all
alias st=dvcs_sts
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
    fi
    if [[ "$IS_HG_DIR" == "true" ]]; then
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
    fi
    if [[ "$IS_HG_DIR" == "true" ]]; then
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
        git status
    else
        hg status
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

#Fix shitty characters in RXVT
export LANG=US.UTF-8
export LC_ALL=C

# Colors for prompt
RED="\033[0;31m"
YELLOW="\033[0;33m"
LIGHTBLUE="\033[0;36m"
PURPLE="\033[0;35m"
GREEN="\033[0;32m"
WHITE="\033[0;37m"
RESET="\033[0;00m"

# Needs hg-prompt from https://bitbucket.org/sjl/hg-prompt/src

# Command to get current git branch if it exists
function parse_branch {
    source ~/which_repo.sh

    if [[ "$IS_GIT_DIR" == "true" ]]; then
        ref=$(git symbolic-ref HEAD)
        echo -e " $YELLOW("${ref#refs/heads/}")"
    fi

    if [[ "$IS_HG_DIR" == "true" ]]; then
        ref=$(hg prompt "{branch}")
        echo -e " $PURPLE(${ref})"
    fi
}

function num_commits_ahead {
    source ~/which_repo.sh

    if [[ "$IS_GIT_DIR" == "true" ]]; then
        num=$(git status | grep "Your branch is ahead of" | awk '{split($0,a," "); print a[9];}' 2> /dev/null) || return
        if [[ "$num" != "" ]]; then
            echo -e "$LIGHTBLUE+$num"
        fi
    fi

    if [[ "$IS_HG_DIR" == "true" ]]; then
        # TODO
        echo ""
    fi

}

# Mercurial conflicts
function conflicts {
    source ~/which_repo.sh

    if [[ "$IS_GIT_DIR" == "true" ]]; then
        # TODO
        echo ""
    fi

    if [[ "$IS_HG_DIR" == "true" ]]; then
        ref=$(hg resolve -l 2> /dev/null | grep "U " | awk '{split($0,a," "); print a[2];}' 2> /dev/null) || return
        if [[ "$ref" != "" ]]; then
            echo -e " $YELLOW($RED\xE2\x98\xA0 $YELLOW${ref})"
        fi
    fi
}

PS1="\n$YELLOW\u@$GREEN\w\$(parse_branch)\$(num_commits_ahead)\$(conflicts)$RESET \$ "
