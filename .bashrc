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
    if [[ "$IS_SVN_DIR" == "true" ]]; then
        svn diff "$@" | colordiff | less -R
    fi
}

function dvcs_lg {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git log --color "$@"
    fi
    if [[ "$IS_HG_DIR" == "true" ]]; then
        hg log "$@"
    fi
}

function dvcs_add {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git add "$@"
    fi
    if [[ "$IS_HG_DIR" == "true" ]]; then
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
    fi
    if [[ "$IS_HG_DIR" == "true" ]]; then
        hg ci -m "$@"
    fi
}

function dvcs_sts {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git status "$@"
    fi
    if [[ "$IS_HG_DIR" == "true" ]]; then
        hg status "$@"
    fi
    if [[ "$IS_SVN_DIR" == "true" ]]; then
        svn status "$@"
    fi
}

function dvcs_commit_all {
    source ~/which_repo.sh
    if [[ "$IS_GIT_DIR" == "true" ]]; then
        git commit -am "$@"
    fi
    if [[ "$IS_HG_DIR" == "true" ]]; then
        hg ci -m "$@"
    fi
}

#Fix shitty characters in RXVT
export LANG=US.UTF-8
export LC_ALL=C

DELTA_CHAR="༇ "
#DELTA_CHAR="△ "

#CONFLICT_CHAR="☠"
CONFLICT_CHAR="௰"

# Requirements (other than git, svn and hg):
#   hg-prompt: https://bitbucket.org/sjl/hg-prompt/src
#   ack
# props to http://www.codeography.com/2009/05/26/speedy-bash-prompt-git-and-subversion-integration.html
dvcs_prompt="# Figure out what repo we are in
    gitBranch=\"\"
    svnInfo=\"\"
    files=\"\"
    prompt=\"\"

    hgBranch=$(hg prompt \"{branch}\" 2> /dev/null)

    # Done for speed reasons. Feel free to swap
    if [[ \"$hgBranch\" == \"\" ]]; then
        gitBranch=$(git symbolic-ref HEAD 2> /dev/null)

        # Svn?
        if [[ \"$gitBranch\" == \"\" ]]; then
            svnInfo=$(svn info 2> /dev/null)
        fi
    fi

    # If we are in git ...
    if [[ \"$gitBranch\" != \"\" ]]; then
        # find current branch
        gitStatus=$(git status)

        # changed *tracked* files in local directory?
        change=$(echo $gitStatus | ack "modified:|deleted:|new file:")
        if [[ \"$change\" != \"\" ]]; then
            change=\" \"$DELTA_CHAR
        fi

        # output the branch and changed character if present
        prompt=$prompt$COLOR_YELLOW\" (\"${gitBranch#refs/heads/}\"$change)\"

        # How many local commits do you have ahead of origin?
        num=$(echo "$gitStatus" | grep "Your branch is ahead of" | awk '{split($0,a," "); print a[9];}') || return
        if [[ \"$num\" != \"\" ]]; then
            color_light_cyan \" +$num\"
        fi

        # any conflicts? (sed madness is to remove line breaks)
        #files=$(git ls-files -u | cut -f 2 | sort -u | sed -e :a -e '$!N;s/\n/, /;ta' -e 'P;D')
    fi

    echo -e \"asdf$prompt\"
    ${dvcs_prompt:-}"


exit_code() {
    if [[ "$?" = "0" ]]; then
        echo "$COLOR_LIGHT_GREEN"
    else
        echo "$COLOR_LIGHT_RED"
    fi
}

COLOR_RED=$(tput sgr0 && tput setaf 1)
COLOR_GREEN=$(tput sgr0 && tput setaf 2)
COLOR_YELLOW=$(tput sgr0 && tput setaf 3)
COLOR_PURPLE=$(tput sgr0 && tput setaf 5)
COLOR_LIGHT_GREEN=$(tput sgr0 && tput bold && tput setaf 2)
COLOR_LIGHT_RED=$(tput sgr0 && tput bold && tput setaf 1)
COLOR_LIGHT_CYAN=$(tput sgr0 && tput bold && tput setaf 6)
COLOR_RESET=$(tput sgr0)

#PS1='\n$(color_yellow \u)$(error_test "@")$(color_green "\w")$(dvcs_prompt) \$ '


# PS1="${PS1}\$(${ps1_command})\\\$ "

PS1='\[$(exit_code)\]@'
PS1="\n\[$COLOR_YELLOW\]\u${PS1}\[$COLOR_GREEN\]\w\$(${dvcs_prompt})\[$COLOR_RESET\] \$ "

#PS1='\[$BOLD_FORMAT\]\[$ERROR_FORMAT\]$(exit_code)\[$RESET_FORMAT\]'
# PS1='\n$(function_error_test)'
#$(function_error_test "@")$(color_green "\w")$(dvcs_prompt) \$ "
