# Do this first stupid:
# Add this to ~/.gitconfig to make browser work (look into)
# git config --global web.browser ff
# git config --global browser.ff.cmd "open -a Firefox.app"

# Don't wait for job termination notification
set -o notify

# vim bindings in terminal
set -o vi

source ~/.bash_config
source ~/configs/z.sh

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

alias here='open .'
alias vim='mvim'

# Compact, colorized git log
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Exctract annnnything
extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# Tail a file and search for a pattern
t() {
    tail -f $1 | perl -pe "s/$2/\e[1;31;43m$&\e[0m/g"
}

shc() {
    ssh -t ct "ssh -t $1";
}

prod() {
    osascript ~/prod.applescript
}

pullreq() {
    [ -z $BRANCH ] && BRANCH="dev"
    HEAD=$(git symbolic-ref HEAD 2> /dev/null)
    [ -z $HEAD ] && return # Return if no head
    REMOTE=`cat .git/config | grep "remote \"origin\"" -A 2 | tail -n1 | sed 's/.*:\([^\/]*\).*/\1/'`
    MSG=`git log -n1 --pretty=%s`
    CUR_BRANCH=${HEAD#refs/heads/}

    if [[ "$CUR_BRANCH" == "dev" || "$CUR_BRANCH" == "master" ]]; then
        echo "You can't push directly to $CUR_BRANCH, thicky"
        return
    fi
    git push origin $CUR_BRANCH
    hub pull-request -b $BRANCH -h $REMOTE:$CUR_BRANCH
}

psg() {
    ps axu | grep -v grep | grep "$@" -i --color=auto;
}

#Git ProTip - Delete all local branches that have been merged into HEAD
git_purge_local_branches() {
    [ -z $1 ] && return
    #git branch -d `git branch --merged $1 | grep -v '^*' | grep -v 'master' | grep -v 'dev' | tr -d '\n'`
    BRANCHES=`git branch --merged $1 | grep -v '^*' | grep -v 'master' | grep -v 'dev' | grep -v "/$1$" | tr -d '\n'`
    echo "Running: git branch -d $BRANCHES"
    git branch -d $BRANCHES
}

#Bonus - Delete all remote branches that are merged into HEAD (thanks +Kyle Neath)
git_purge_remote_branches() {
    [ -z $1 ] && return
    git remote prune origin

    BRANCHES=`git branch -r --merged $1 | grep 'origin' | grep -v '/master$' | grep -v '/dev$' | grep -v "/$1$" | sed 's/origin\//:/g' | tr -d '\n'`
    echo "Running: git push origin $BRANCHES"
    git push origin $BRANCHES
}

git_purge() {
    branch=$1
    [ -z $branch ] && branch="dev"
    git_purge_local_branches $branch
    git_purge_remote_branches $branch
}

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
    if [[ "$IS_SVN_DIR" == "true" ]]; then
        svn log -v --limit 50 "$@" | colordiff | less -R
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

# This code was auto generated by with these options:
#  - file:///Users/aray/bash-prompt-builder/index.html#git=true&git-prefix=false&git-ahead=true&git-modified=true&git-conflicted=true&git-revno=false&git-bisect=true&hg=true&hg-prefix=false&hg-modified=true&hg-conflicted=true&hg-revno=false&hg-bisect=true&hg-patches=true&svn=true&svn-modified=true&svn-revno=true&comments=false&modified-char=%E2%9C%8E&conflict-char=%E2%98%A2&max-conflicted-files=2&no-branch-text=no%20branch!&bisecting-text=%CF%9F
#
# Requirements (other than git, svn and hg):
#   hg-prompt: https://bitbucket.org/sjl/hg-prompt/src
#   svnversion (you probably have it if you have svn)
#   ack
# props to http://www.codeography.com/2009/05/26/speedy-bash-prompt-git-and-subversion-integration.html

MAX_CONFLICTED_FILES=2
DELTA_CHAR="✎"
CONFLICT_CHAR="☢"
BISECTING_TEXT="ϟ"
REBASE_TEXT="✂ ʀebase"
NOBRANCH_TEXT="no branch!"

# Colors for prompt
COLOR_RED=$(tput sgr0 && tput setaf 1)
COLOR_GREEN=$(tput sgr0 && tput setaf 2)
COLOR_YELLOW=$(tput sgr0 && tput setaf 3)
COLOR_DARK_BLUE=$(tput sgr0 && tput setaf 4)
COLOR_BLUE=$(tput sgr0 && tput setaf 6)
COLOR_PURPLE=$(tput sgr0 && tput setaf 5)
COLOR_PINK=$(tput sgr0 && tput bold && tput setaf 5)
COLOR_LIGHT_GREEN=$(tput sgr0 && tput bold && tput setaf 2)
COLOR_LIGHT_RED=$(tput sgr0 && tput bold && tput setaf 1)
COLOR_LIGHT_CYAN=$(tput sgr0 && tput bold && tput setaf 6)
COLOR_RESET=$(tput sgr0)

_hg_dir=""
function _hg_check {
    [ -d ".hg" ] && _hg_dir=`pwd`
    base_dir="."
    while [ -d "$base_dir/../.hg" ]; do base_dir="$base_dir/.."; done
    if [ -d "$base_dir/.hg" ]; then
        _hg_dir=`cd "$base_dir"; pwd`
        return 0
    else
        return 1
    fi
}

_svn_dir=""
function _svn_check {
    parent=""
    grandparent="."

    while [ -d "$grandparent/.svn" ]; do
        parent=$grandparent
        grandparent="$parent/.."
    done

    if [ ! -z "$parent" ]; then
        _svn_dir=`cd "$parent"; pwd`
        return 0
    else
        return 1
    fi
}

_git_dir=""
_git_svn_dir=""
function _git_check {
    _git_dir=`git rev-parse --show-toplevel 2> /dev/null`
    if [[ "$_git_dir" == "" ]]; then
        return 1
    else
        _gsvn_check=`cd "$_git_dir"; ls .git/svn/.metadata 2> /dev/null`

        if [[ ! -z "$_gsvn_check" ]]; then
            _git_svn_dir=$_git_dir
        fi
        return 0
    fi
}

if [ -z "`echo $(hg prompt \"abort\" 2>&1) | grep abort`" ]; then
    echo "hg-prompt not installed. Suggest http://sjl.bitbucket.org/hg-prompt/installation/"
fi

dvcs_function="
    # Figure out what repo we are in
    _git_check || _hg_check || _svn_check

    # Build the prompt!
    prompt=\"\"

    # If we are in git ...
    if [ -n \"\$_git_dir\" ]; then
        # find current branch
        gitBranch=\$(git symbolic-ref HEAD 2> /dev/null)
        gitStatus=\`git status\`

        # Figure out if we are rebasing
        is_rebase=\"\"
        if [[ -d \"\$_git_dir/.git/rebase-apply\" || -d \"\$_git_dir/.git/rebase-merge\" ]]; then
            is_rebase=1
        fi

        # Figure out current branch, or if we are bisecting, or lost in space
        bisecting=\"\"
        if [ -z \"\$gitBranch\" ]; then
            if [ -n \"\$is_rebase\" ]; then
                rebase_prompt=\"\\[\$COLOR_LIGHT_CYAN\\]\$REBASE_TEXT\\[\$COLOR_YELLOW\\]\"
            else
                bisect=\$(git rev-list --bisect 2> /dev/null | cut -c1-7)
                if [ -z \"\$bisect\" ]; then
                    gitBranch=\"\\[\$COLOR_RED\\]\$NOBRANCH_TEXT\\[\$COLOR_YELLOW\\]\"
                else
                    bisecting=\"\\[\$COLOR_PURPLE\\]\$BISECTING_TEXT:\"\$bisect\"\\[\$COLOR_YELLOW\\]\"
                    gitBranch=\"\"
                fi
            fi
        fi
        gitBranch=\${gitBranch#refs/heads/}
        if [ -z \"\$bisect\" ]; then
            if [ -n \"\$_git_svn_dir\" ]; then
                gitBranch=\"\\[\$COLOR_DARK_BLUE\\]git-svn\\[\$COLOR_YELLOW\\] \$gitBranch\"
            fi
        fi

        if [ -z \"\$is_rebase\" ]; then
            # changed *tracked* files in local directory?
            gitChange=\$(echo \$gitStatus | ack 'modified:|deleted:|new file:')
            if [ -n \"\$gitChange\" ]; then
                gitChange=\" \\[`tput sc`\\]  \\[`tput rc`\\]\\[\$DELTA_CHAR\\] \"
            fi
        fi

        # output the branch and changed character if present
        prompt=\$prompt\"\\[\$COLOR_YELLOW\\] (\"

        prompt=\$prompt\$prefix\$gitBranch\$bisecting\$rebase_prompt
        prompt=\$prompt\"\$gitChange)\\[\$COLOR_RESET\\]\"

        # How many local commits do you have ahead of origin?
        num=\$(echo \$gitStatus | grep \"Your branch is ahead of\" | awk '{split(\$0,a,\" \"); print a[13];}') || return
        if [ -n \"\$num\" ]; then
            prompt=\$prompt\"\\[\$COLOR_LIGHT_CYAN\\] +\$num\"
        fi

        # any conflicts? (sed madness is to remove line breaks)
        files=\$(git ls-files -u | cut -f 2 | sort -u | sed '$(($MAX_CONFLICTED_FILES+1)),1000d' |  sed -e :a -e '\$!N;s/\\\n/, /;ta' -e 'P;D')
    fi

    # If we are in mercurial ...
    if [ -n \"\$_hg_dir\" ]; then
        hgBranch=\`cat \"\$_hg_dir/.hg/branch\"\`

        hgPrompt=\"s\"
        hgPrompt=\"\$hgPrompt{status|modified}\"

        hgPrompt=\"\$hgPrompt n\"

        hgPrompt=\"\$hgPrompt p\"
        hgPrompt=\"\$hgPrompt{patches|hide_unapplied|join(,)}\"

        promptOptions=(\`hg prompt \"\$hgPrompt\" | tr -s ':' ' '\`)

        hgm=\${promptOptions[0]:1}
        if [ -n \"\$hgm\" ]; then
            hgChange=\" \\[`tput sc`\\]  \\[`tput rc`\\]\\[\$DELTA_CHAR\\] \"
        fi

        # output branch and changed character if present
        prompt=\$prompt\"\\[\$COLOR_PURPLE\\] (\"
        
        prompt=\$prompt\"\${prefix}\${hgBranch}\"

        bisecting=\$(hg bisect 2> /dev/null | head -n 1)
        bisecting=\${bisecting:20:7}

        if [ -z \"\$bisecting\" ]; then
            prompt=\$prompt
        else
            prompt=\"\$prompt\\[\$COLOR_YELLOW\\]:\$BISECTING_TEXT:\"\$bisecting\"\\[\$COLOR_PURPLE\\]\"
        fi
        prompt=\$prompt\"\$hgChange\"
        patches=\${promptOptions[2]:1}
        if [ -n \"\$patches\" ];then
            prompt=\$prompt\"\\[\$COLOR_YELLOW\\] [\$patches]\\[\$COLOR_PURPLE\\]\"
        fi
        prompt=\$prompt\")\"

    # Conflicts?
        files=\$(hg resolve -l | grep \"U \" | sed '$(($MAX_CONFLICTED_FILES+1)),1000d' | awk '{split(\$0,a,\" \"); print a[2];}') || return
    fi

    # If we are in subversion ...
    if [ -n \"\$_svn_dir\" ]; then

        # changed files in local directory? NOTE: This command is the slowest of the bunch
        svnChange=\$(svn status | ack \"^M|^!\" | wc -l)
        if [[ \"\$svnChange\" != \"       0\" ]]; then
            svnChange=\" \\[`tput sc`\\]  \\[`tput rc`\\]\\[\$DELTA_CHAR\\] \"
        else
            svnChange=\"\"
        fi

        # revision number (instead of branch name, silly svn)
        revNo=\`svnversion --no-newline\`
        prompt=\$prompt\"\\[\$COLOR_BLUE\\] (svn\"
        prompt=\$prompt\":\$revNo\"
        prompt=\$prompt\"\$svnChange)\\[\$COLOR_RESET\\]\"
    fi

    # Show conflicted files if any
    if [ -n \"\$files\" ]; then
        prompt=\$prompt\" \\[\$COLOR_RED\\](\\[\$COLOR_YELLOW\\]\"
        prompt=\$prompt\"\\[`tput sc`\\]  \\[`tput rc`\\]\\[\$CONFLICT_CHAR\\] \"
        prompt=\$prompt\"\\[\$COLOR_RED\\] \${files})\"
    fi

    echo -e \$prompt"
# End code auto generated by http://andrewray.me/bash-prompt-builder/index.html

function error_test() {
    if [[ $? = "0" ]]; then
        printf "$COLOR_LIGHT_GREEN"
    else
        printf "$COLOR_LIGHT_RED"
    fi
}

PS1="\n\[$COLOR_YELLOW\]\u\[\$(error_test)\]@\[$COLOR_GREEN\]\w\$(${dvcs_function})\[$COLOR_RESET\] \$ "

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
