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
function dvcs_prompt {
    # Figure out what repo we are in
    gitBranch=""
    hgBranch=$(hg prompt "{branch}" 2> /dev/null)

    # Done for speed reasons. Feel free to swap
    if [[ "$hgBranch" == "" ]]; then
        gitBranch=$(git symbolic-ref HEAD 2> /dev/null)
    fi

    # Build the prompt
    prompt=""
    files=""

    # If we are in git ...
    if [[ "$gitBranch" != "" ]]; then
        # find current branch
        prompt=$prompt"$YELLOW ("${gitBranch#refs/heads/}")$RESET"

        # How many local commits do you have ahead of origin?
        num=$(git status | grep "Your branch is ahead of" | awk '{split($0,a," "); print a[9];}' 2> /dev/null) || return
        if [[ "$num" != "" ]]; then
            prompt=$prompt"$LIGHTBLUE +$num"
        fi

        # any conflicts?
        files=$(git ls-files -u | cut -f 2 | sort -u | sed -e :a -e '$!N;s/\n/, /;ta' -e 'P;D')
    fi

    # If we are in mercurial ...
    if [[ "$hgBranch" != "" ]]; then
        # Get branch
        prompt=$prompt"$PURPLE (${hgBranch})"

        # How many local changes are there. This isn't exactly acurate because it doesn't contact the server, but 
        # I'm using it as an at-a-glance thing
        num=$(hg summary | grep "update:" | wc -l | sed -e 's/^ *//')
        if [[ "$num" != "" ]]; then
            prompt=$prompt"$LIGHTBLUE +$num"
        fi

        # Conflicts?
        files=$(hg resolve -l 2> /dev/null | grep "U " | awk '{split($0,a," "); print a[2];}' 2> /dev/null) || return
    fi

    # Show conflicted files if any
    if [[ "$files" != "" ]]; then
        prompt=$prompt" $RED($YELLOW\xE2\x98\xA0 $RED${files})"
    fi

    echo -e $prompt
}

PS1="\n$YELLOW\u@$GREEN\w\$(dvcs_prompt)$RESET \$ "
