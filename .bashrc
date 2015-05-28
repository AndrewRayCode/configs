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

# git
function _c() {
    cur=${COMP_WORDS[COMP_CWORD]}
    branches=`git for-each-ref --sort=-committerdate refs/heads/ | head -n 10`

    output=''
    for branch in $branches
    do
        output+=`echo "$branch" | sed 's/.*refs\/heads\///'`
        # creative way to get color here? echo messes everything up
        # (http://unix.stackexchange.com/questions/107417/what-are-the-special-characters-to-print-from-a-script-to-move-the-cursor ?)
        #output+=" '`git show --quiet $(echo $branch | cut -d' ' -f1) --pretty=format:"%C(Yellow)%h %Cred<%an>%Creset %s %C(cyan)(%cr)%Creset'"`"$'\n'
        #echo " \'`git show --quiet $(echo $branch | cut -d' ' -f1) --pretty=format:"%C(Yellow)%h %Cred<%an>%Creset %s %C(cyan)(%cr)%Creset\'"`"$'\n'
        output+=" \'`git show --quiet $(echo $branch | cut -d' ' -f1) --pretty=format:"%h <%an> %s (%cr)\'"`"$'\n'
    done

    response=''
    for branch in $output
    do
        lowerBranch=`echo $branch | tr '[:upper:]' '[:lower:]'`
        if [[ $branch =~ .*$cur.* ]]; then
            response+=$branch$'\n'
        fi
    done

    COMPREPLY=( $( compgen -W "$response" -- $cur ) )
}

# Diff of things between here and dev
function ddiff() {
    git diff `git merge-base upstream/dev HEAD`..HEAD

}

# Log of everything on this braynch
function dlog() {
    git log -p `git merge-base upstream/dev HEAD`..HEAD

}

function c() {
    newBranch=""
    inputted=""

    if [[ -z "$1" ]]; then
        branchOutput=`git for-each-ref --sort=-committerdate refs/heads/ | head -n 10`

        declare -a branches
        let xx=0

        # Find all system config files that aren't vim swap files and loop through them
        IFS=$'\n'
        pad=$(printf '%0.1s' " "{1..32})
        padlength=32
        for branch in $branchOutput
        do
            # Show them in a list with a counter
            xx=`expr $xx + 1`
            branches=("${branches[@]}" "$branch")
            branchName=`echo "$branch" | sed 's/.*refs\/heads\///'`
            string1="$COLOR_PURPLE$xx. $COLOR_PINK $branchName"
            uncolor="$xx.  $branchName"
            printf '%s' $string1
            printf '%*.*s' 0 $((padlength - ${#uncolor} )) "$pad"
            printf '%s\n' `git show --quiet $branchName --pretty=format:"%C(Yellow)%h %Cred<%an>%Creset %s %C(cyan)(%cr)%Creset"`
        done

        # Prompt user for file. -n means no line break after echo
        echo -n "$COLOR_YELLOW?$COLOR_RESET "
        read branchNumber

        let "branchNumber+=-1"

        if [[ "$branchNumber" =~ ^[0-9]+$ ]]; then
            newBranch=`echo "${branches[@]:$branchNumber:1}" | sed 's/.*refs\/heads\///'`

            if [[ -z "$newBranch" ]]; then
                echo "Not real."
                return 1
            fi
        else
            echo "Wtf?"
            return 1
        fi
    else
        inputted=1
        newBranch=`echo "$1" | cut -d' ' -f1`
    fi

    if [[ -n "$1" ]]; then
        echo `git show --quiet "$newBranch" --pretty=format:"%C(Yellow)%h %Cred<%an>%Creset %s %C(cyan)(%cr)%Creset"`
    fi

    if [[ $newBranch =~ ^pr ]]; then
        echo -e "\ngit fetch $newBranch && git checkout $newBranch"
        git fetch $newBranch && git checkout $newBranch
    else
        echo -e "\ngit checkout $newBranch"
        git checkout $newBranch
    fi

}
complete -F _c  c

function rbd() {
    git fetch upstream && git rebase upstream/dev
}

# required for grunt ct
export LANG=en_US.UTF-8
export LC_ALL=

# required for dojo install of api (canvas dependency)
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/X11/lib/pkgconfig

# Don't wait for job termination notification
set -o notify

# vim bindings in terminal
set -o vi

source ~/.bash_config

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

alias here='open .'
alias vim='mvim'

# Hack to show the version of an installed perl module.
function cpanversion() {
    perl -le 'eval "require $ARGV[0]" and print $ARGV[0]->VERSION' $1
}

function audiosize() {
    latestAudio=`ls -dt ~/Downloads/*.{wav,mp3,flac,mp4,m4a} 2> /dev/null | head -1`

    ext=`echo $latestAudio | awk -F . '{print $NF}'`

    if [[ ! -f "$latestAudio" ]]; then
        echo "${COLOR_PINK}Nothing here, ${COLOR_RED}asshole!!!${COLOR_RESET}"
        return 1
    fi

    # Hack to get around file names with spaces
    # http://stackoverflow.com/questions/7194192/basename-with-spaces-in-a-bash-script
    baseFile=$(basename "$latestAudio")
    exiftool -filename -AudioBitrate "$latestAudio"

    echo -e "$COLOR_BLUE\nWhere you wanna move this?\n$COLOR_RESET"

    # Save array of files and a counter
    declare -a files
    let xx=0

    mroot="/Users/andrewray/Music/Extended Mixes"
    # Find all system config files that aren't vim swap files and loop through them
    for file in `ls "$mroot"`
    do
        # Show them in a list with a counter
        xx=`expr $xx + 1`
        files=("${files[@]}" "$file")
        subs=$COLOR_YELLOW`ls -F "$mroot/$file" | grep -v \/ | head -1`$COLOR_RESET
        if [[ -z "$subs" ]]; then
            subs="${COLOR_BLUE}None${COLOR_RED}"
        fi
        echo " $COLOR_PURPLE$xx$COLOR_RESET:  $COLOR_BLUE$file$COLOR_RESET ($subs)"
    done

    xx=`expr $xx + 1`
    echo " $COLOR_PURPLE${xx} or p$COLOR_RESET: Preview"

    xy=`expr $xx + 1`
    echo " $COLOR_RED${xy} or d$COLOR_RESET: ${COLOR_RED}Hell$COLOR_RESET (delete)"

    # Prompt user for file. -n means no line break after echo
    echo -n "$COLOR_YELLOW?$COLOR_RESET "
    read dirSet

    if [[ "$dirSet" == "$xx" || "$dirSet" == "d" ]]; then
        echo "${COLOR_RED}Deleting${COLOR_RESET} $latestAudio"
        rm "$latestAudio"
    fi

    if [[ "$dirSet" == $xy || "$dirSet" == "p" ]]; then
        echo "${COLOR_PINK}Previewing${COLOR_RESET} $latestAudio"
        open "$latestAudio"
    fi

    # If they entered a nubmer, look up that file in the array
    if [[ "$dirSet" =~ ^[0-9]+$ ]]; then
        let "dirSet+=-1"
        config=${files[@]:$dirSet:1}


        if [[ "$ext" == "wav" ]]; then

            hasLame=$(which lame)
            if [[ -z $hasLame ]]; then
                echo "${COLOR_YELLOW}Lame not found on path. Please brew install lame...${COLOR_RESET}"
                return 1
            fi

            echo "${COLOR_BLUE}Converting ${COLOR_YELLOW}wav${COLOR_BLUE} to ${COLOR_PINK}mp3${COLOR_BLUE}...${COLOR_RESET}"
            lame -S --preset insane "$latestAudio"

            rm "$latestAudio"
            latestAudio=`ls -dt *.mp3 2> /dev/null | head -1`
            baseFile=$(basename "$latestAudio")
        fi

        mv "$latestAudio" "$mroot/$config"
        echo -ne "\n${COLOR_GREEN}Moved to '${COLOR_PINK}$mroot/$config/"
        # Without this, filenames with spaces are broken across multiple lines???
        echo -n $baseFile
        echo -ne "${COLOR_GREEN}'!$COLOR_RESET\n"

        # Hack to move a file name with spaces
        # http://superuser.com/questions/170087/in-the-osx-terminal-how-do-i-open-a-file-with-a-space-in-its-name
        open_command() {
            open -Rn "$mroot/$config/$baseFile"
        }
        open_command
    fi
}

function fack() {
    find . -name "*$1*"
}

# vim conflicted files
function vc() {
    _git_root=`git rev-parse --show-toplevel`
    (cd $_git_root && mvim -n -c 'call EditConflitedArgs()' $(git diff --name-only --diff-filter=U))
}

# Generate git format string on the fly to get the right top level directory
_gen_format_string() {
    echo "<a href=\"https://github.com/Crowdtilt/`basename $(git rev-parse --show-toplevel)`/commit/%h\" style='font-family:\"Courier new\"; color:red; font-weight:bold; text-decoration:none'>%h</a> %s <span style=\"color:green\">(%cr)</span> &lt;<span style=\"color:blue; font-weight:bold;\">%an</span>&gt;<br />"
}

# Generate the html output for this repo's deploy commits
_gen_html_output() {
    (
        cd $2
        git fetch upstream
        format=`_gen_format_string`
        output=`git log --no-merges -10 --pretty=format:"$format" --abbrev-commit`
        if [ -n "$output" ]; then
            echo "<b style=\"font-size:16px;\">$3:</b><br /> <div class=\"anchor\"> <br />" >> $1
            echo $output >> $file
            echo "</div><br /><br />" >> $file
        fi
    )
}

gen_deploy_email () {
    if [ -z $1 ]; then
        echo "Usage: gen_deploy_email /path/to/crowdtilt/root"
        return 1
    fi

    file="/tmp/deploys.html"
    echo "<div style=\"font-family:sans-serif; font-size:13px;\">" > $file

    # Start format
    _gen_html_output "$file" "$1/crowdtilt-public-site" "Public Site"
    _gen_html_output "$file" "$1/crowdtilt-internal-api" "API"
    _gen_html_output "$file" "$1/crowdtilt-internal-admin-site" "Admin Site"

    echo "</div>" >> $file

    open $file
}

# safe checkout
sco () {
    if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
        echo "${COLOR_RED}Cannot safe checkout with ${COLOR_LIGHT_RED}dirty files${COLOR_RED} (you naughty boy).$COLOR_RESET"
        return 1
    HEAD=$(git symbolic-ref HEAD 2> /dev/null)
    [ -z $HEAD ] && return # Return if no head
    MSG=`git log -n1 --pretty=%s`
    CUR_BRANCH=${HEAD#refs/heads/}
    fi
    git fetch upstream && git checkout $1 && git reset --hard upstream/$1
}

gpf () {
    HEAD=$(git symbolic-ref HEAD 2> /dev/null)
    [ -z $HEAD ] && return 1 # Return if no head
    CUR_BRANCH=${HEAD#refs/heads/}

    if [[ "$CUR_BRANCH" == "dev" || "$CUR_BRANCH" == "master" ]]; then
        echo "${COLOR_RED}Cannot push to ${COLOR_LIGHT_RED}dev${COLOR_RED} nor ${COLOR_LIGHT_RED}master${COLOR_RED} (you naughty boy).$COLOR_RESET"
        return 1
    fi

    git push -f origin $CUR_BRANCH
}

alias pstart="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"
alias pstop="pg_ctl -D /usr/local/var/postgres stop -s -m fast"

# Compact, colorized git log
alias gl="git log --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

alias deploys="git fetch origin; gl --no-merges origin/master..origin/dev"
alias ios="open /Applications/Xcode.app/Contents/Developer/Applications/iOS\ Simulator.app"

achrome () {
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --allow-file-access-from-files --enable-file-cookies&
}

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
    # If no inputs, ssh to main
    if [ -z $1 ]; then
        ssh ct
    else
        # If it's in config file, ssh to it regularly
        if [ -n "$(cat ~/.ssh/config | grep "Host $1")" ]; then
            ssh $1
        # Otherwise tunnel to it
        else
            ssh -t ct "ssh -t $1";
        fi
    fi
}

prod() {
    osascript ~/prod.applescript
}

pullreq() {
    [ -z $BRANCH ] && BRANCH="dev"
    HEAD=$(git symbolic-ref HEAD 2> /dev/null)
    [ -z $HEAD ] && return # Return if no head
    MSG=`git log -n1 --pretty=%s`
    CUR_BRANCH=${HEAD#refs/heads/}

    if [[ "$CUR_BRANCH" == "dev" || "$CUR_BRANCH" == "master" ]]; then
        echo "You can't push directly to $CUR_BRANCH, thicky"
        return
    fi
    git push origin $CUR_BRANCH
    hub pull-request -b $BRANCH -h Crowdtilt:$CUR_BRANCH
}

fpr() {
    [ -z $BRANCH ] && BRANCH="dev"
    HEAD=$(git symbolic-ref HEAD 2> /dev/null)
    [ -z $HEAD ] && return # Return if no head
    MSG=`git log -n1 --pretty=%s`
    CUR_BRANCH=${HEAD#refs/heads/}

    if [[ "$CUR_BRANCH" == "dev" || "$CUR_BRANCH" == "master" ]]; then
        echo "You can't push directly to $CUR_BRANCH, thicky"
        return
    fi
    git push origin $CUR_BRANCH
    msg=`git log -n1 --pretty=%B`
    hub pull-request -b crowdtilt:$BRANCH -h DelvarWorld:$CUR_BRANCH
}

psg() {
    ps axu | grep -v grep | grep "$@" -i --color=auto;
}

#Git ProTip - Delete all local branches that have been merged into HEAD
git_purge_local_branches() {
    BRANCHES=`git branch --merged | grep -v '^*' | grep -v 'master' | grep -v 'dev' | tr -d '\n'`
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
CHERRY_PICK_TEXT="[🍒  cherry-pick]"
NOBRANCH_TEXT="no branch!"

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

        # Figure out if we are cherry-picking
        is_cherry_pick=\"\"
        if [[ -a \"\$_git_dir/.git/CHERRY_PICK_HEAD\" ]]; then
            is_cherry_pick=1
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

        cherryPickPrompt=\"\"
        if [ -n \"\$is_cherry_pick\" ]; then
            cherryPickPrompt=\" \\[\$COLOR_PINK\\]\$CHERRY_PICK_TEXT\\[\$COLOR_YELLOW\\]\"
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

        prompt=\$prompt\$prefix\$gitBranch\$cherryPickPrompt\$bisecting\$rebase_prompt
        prompt=\$prompt\"\$gitChange)\\[\$COLOR_RESET\\]\"

        # How many local commits do you have ahead of origin?
        num=\$(echo \$gitStatus | grep \"Your branch is ahead of\" | awk '{split(\$0,a,\" \"); print a[11];}') || return
        if [ -n \"\$num\" ]; then
            prompt=\$prompt\"\\[\$COLOR_LIGHT_CYAN\\] +\$num\"
        fi

        # MODIFIED BY HAND How far behind are you?
        num=\$(echo \$gitStatus | grep \"Your branch is behind\" | awk '{split(\$0,a,\" \"); print a[10];}') || return
        if [ -n \"\$num\" ]; then
            prompt=\$prompt\"\\[\$COLOR_PINK\\] -\$num\"
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

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export NVM_DIR="/Users/andrewray/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
