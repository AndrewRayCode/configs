# Don't wait for job termination notification
set -o notify

# vim bindings in terminal
set -o vi

# Do this on first load stupid:
# git config --global color.ui "auto"

source ~/.bash_config

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
    if [[ "$IS_SVN_DIR" == "true" ]]; then
        svn ci --message "$@"
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

# Colors for prompt
COLOR_RED=$(tput sgr0 && tput setaf 1)
COLOR_GREEN=$(tput sgr0 && tput setaf 2)
COLOR_YELLOW=$(tput sgr0 && tput setaf 3)
COLOR_BLUE=$(tput sgr0 && tput setaf 6)
COLOR_PURPLE=$(tput sgr0 && tput setaf 5)
COLOR_LIGHT_GREEN=$(tput sgr0 && tput bold && tput setaf 2)
COLOR_LIGHT_RED=$(tput sgr0 && tput bold && tput setaf 1)
COLOR_LIGHT_CYAN=$(tput sgr0 && tput bold && tput setaf 6)
COLOR_RESET=$(tput sgr0)

dvcs_function="
    # Figure out what repo we are in
    gitBranch=\"\"
    svnInfo=\"\"
    hgBranch=\$(hg prompt \"{branch}\" 2> /dev/null)

    # Done for speed reasons. Feel free to swap
    if [[ \"\$hgBranch\" == \"\" ]]; then
        gitBranch=\$(git symbolic-ref HEAD 2> /dev/null)

        # Svn?
        if [[ \"\$gitBranch\" == \"\" ]]; then
            svnInfo=\$(svn info 2> /dev/null)
        fi
    fi

    # Build the prompt!
    prompt=\"\"
    files=\"\"

    # If we are in git ...
    if [[ \"\$gitBranch\" != \"\" ]]; then
        # find current branch
        gitStatus=\$(git status)

        # changed *tracked* files in local directory?
        change=\$(echo \$gitStatus | ack 'modified:|deleted:|new file:')
        if [[ \"\$change\" != \"\" ]]; then
            change=\" \"\[\$DELTA_CHAR\]
        fi

        # output the branch and changed character if present
        prompt=\$prompt\"\\[\$COLOR_YELLOW\\] (\"\${gitBranch#refs/heads/}\"\$change)\\[\$COLOR_RESET\\]\"

        # How many local commits do you have ahead of origin?
        num=\$(echo \"\$gitStatus\" | grep \"Your branch is ahead of\" | awk '{split(\$0,a,\" \"); print a[9];}') || return
        if [[ \"\$num\" != \"\" ]]; then
            prompt=\$prompt\"\\[\$COLOR_LIGHT_CYAN\\] +\$num\"
        fi

        # any conflicts? (sed madness is to remove line breaks)
        files=\$(git ls-files -u | cut -f 2 | sort -u | sed -e :a -e '\$!N;s/\\\n/, /;ta' -e 'P;D')
    fi

    # If we are in mercurial ...
    if [[ \"\$hgBranch\" != \"\" ]]; then
        # changed files in local directory?
        hgChange=\$(hg status | ack '^M|^!')
        if [[ \"\$hgChange\" != \"\" ]]; then
            hgChange=\" \"\$DELTA_CHAR
        else
            hgChange=\"\"
        fi

        # output branch and changed character if present
        prompt=\$prompt\"\[\$COLOR_PURPLE\] (\${hgBranch}\$hgChange)\"

        # I guess we don't want this (better version?)
        #num=\$(hg summary | grep \"update:\" | wc -l | sed -e 's/^ *//')
        #if [[ \"\$num\" != \"\" ]]; then
            #prompt=\$prompt\"\[\$COLOR_LIGHT_CYAN\] +\$num\"
        #fi

        # Conflicts?
        files=\$(hg resolve -l | grep \"U \" | awk '{split(\$0,a,\" \"); print a[2];}') || return
    fi

    # If we are in subversion ...
    if [[ \"\$svnInfo\" != \"\" ]]; then

        # changed files in local directory? NOTE: This command is the slowest of the bunch
        svnChange=\$(svn status | ack \"^M|^!\" | wc -l)
        if [[ \"\$svnChange\" != \"       0\" ]]; then
            svnChange=\" \"\$DELTA_CHAR
        else
            svnChange=\"\"
        fi

        # revision number (instead of branch name, silly svn)
        revNo=\$(echo \"\$svnInfo\" | sed -n -e '/^Revision: \([0-9]*\).*\$/s//\1/p')
        prompt=\$prompt\[\$COLOR_BLUE\]\" (svn:\$revNo\$svnChange)\"
    fi

    # Show conflicted files if any
    if [[ \"\$files\" != \"\" ]]; then
        prompt=\$prompt\" \[\$COLOR_RED\](\[\$COLOR_YELLOW\]\[\$CONFLICT_CHAR\] \[\$COLOR_RED\]\${files})\"
    fi

    echo -e \$prompt"

function error_test() {
    if [[ $? = "0" ]]; then
        echo -e "$LIGHTGREEN"
    else
        echo -e "$LIGHTRED"
    fi
}

PS1="\n\[$COLOR_YELLOW\]\u\[\$(error_test)\]@\[$COLOR_GREEN\]\w\$(${dvcs_function})\[$COLOR_RESET\] \$ "
