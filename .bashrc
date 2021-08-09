#!/bin/bash

################################################################################
##### Colors ###################################################################
################################################################################
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
BOLD=$(tput bold)

################################################################################
##### Path utilities (used by all scripts) #####################################
################################################################################
pathadd() {
    newelement=${1%/}
    if [ -d "$1" ] && ! echo "$PATH" | grep -E -q "(^|:)$newelement($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH="$PATH:$newelement"
        else
            PATH="$newelement:$PATH"
        fi
    fi
}

pathrm() {
    PATH="$(echo $PATH | sed -e "s;\(^\|:\)${1%/}\(:\|\$\);\1\2;g" -e 's;^:\|:$;;g' -e 's;::;:;g')"
}

################################################################################
##### Generic Settings #########################################################
################################################################################

# shellcheck disable=SC1091
ITERM_SHELL_INTEGRATION="${HOME}.iterm2_shell_integration.bash"
if [ -f "$ITERM_SHELL_INTEGRATION" ]; then
    source "$ITERM_SHELL_INTEGRATION"
fi

# vim bindings in terminal. Comment left in to help you find .inputrc
#set -o vi

# Don't wait for job termination notification
set -o notify

# Configuration for the command line tool "hh" (history searcher to replace ctrl-r, brew install hh)
export HH_CONFIG=hicolor,rawhistory,favorites   # get more colors
shopt -s histappend              # append new history items to .bash_history
#export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)

# From awscli tools "Add the following to ~/.bashrc to enable bash completion:"
complete -C aws_completer aws

################################################################################
##### Generic Aliases ##########################################################
################################################################################

alias blender=/Applications/blender.app/Contents/MacOS/blender
alias here='open .'
alias vim='mvim'
alias vscode='code'

alias ios="open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"

chrome () {
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --allow-file-access-from-files --enable-file-cookies&
}

# brew services - lists everything it knows about
# brew services start postgres
alias pstart="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"
alias pstop="pg_ctl -D /usr/local/var/postgres stop -s -m fast"

################################################################################
##### Generic Helpers ##########################################################
################################################################################

# Tail a file and search for a pattern, and colorize the matches (I think?)
t() {
    tail -f $1 | perl -pe "s/$2/\e[1;31;43m$&\e[0m/g"
}

# Grep PS output and keep color
psg() {
    ps axu | grep -v grep | grep "$@" -i --color=auto;
}

# Search files by name
function fack() {
    find . -iname "*$1*"
}

function alert() {
    message=$1
    if [[ -z "$message" ]]; then
        message='Completed'
    fi
    toast $1
    say -v Bells ${message}
}

function toast() {
    message=$1
    osascript -e "display notification \"${message}\" with title \"${message}\""
}

# make sound good
function ding() {
    afplay /System/Library/Sounds/Glass.aiff > /dev/null 2>&1 &
}
function blorf() {
    afplay /System/Library/Sounds/Basso.aiff > /dev/null 2>&1 &
}
alias blorb=blorf
alias blort=blorf

# Networking
# -----------------------------------------------------------------------------

function what-is-listening-on-port() {
    lsof -n -i4TCP:"$1" | grep LISTEN
}

function kport() {
    local procc
    procc=$(lsof -n -i4TCP:"$1" | grep LISTEN)

    if [[ -z $procc ]]; then
        echo "Nothing listening on port $1"
    else
        local pid
        pid=$(echo "$procc" | awk '{print $2}')
        echo "kill -2 $pid"
        kill -2 "$pid"
    fi
}

# I'm addicted to audio
# -----------------------------------------------------------------------------

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
    exiftool -filesize -filename -AudioBitrate "$latestAudio"

    echo -e "$COLOR_BLUE\nWhere you wanna move this?\n$COLOR_RESET"

    # Save array of files and a counter
    declare -a files
    let xx=0

    mroot="/Users/andrewray/Music/Extended Mixes"
    # Find all system config files that aren't vim swap files and loop through them
    for file in $mroot
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

# The next line updates PATH for the Google Cloud SDK.
if [ -f /Users/andrewray/google-cloud-sdk/path.bash.inc ]; then
  source '/Users/andrewray/google-cloud-sdk/path.bash.inc'
fi

# The next line enables shell command completion for gcloud.
if [ -f /Users/andrewray/google-cloud-sdk/completion.bash.inc ]; then
  source '/Users/andrewray/google-cloud-sdk/completion.bash.inc'
fi

################################################################################
##### Application / Intergration Specific ######################################
################################################################################


#### Pivotal Tracker #####
# -----------------------------------------------------------------------------

TRACKER_FLOW_PATH="$GR_HOME/tracker-flow"
if [ -d "$TRACKER_FLOW_PATH" ]; then
  pathadd "$TRACKER_FLOW_PATH"
  . "$TRACKER_FLOW_PATH/tracker_completion.bash"
fi

# Check out file to branch and unstage it
function fb() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo 'Usage: filebranch branchname filename'
    fi
    dqt='"'
    echo "git checkout ${dbq}${1}${dbq} -- ${dbq}${2}${dbq} && git reset HEAD ${dbq}${2}${dbq}"
    git checkout "$1" -- "$2" && git reset HEAD "$2"
    git status --untracked-files=no
}

################################################################################
##### Programming Language Specific ############################################
################################################################################

#### Ruby / Rails #######
# -----------------------------------------------------------------------------

# Kill stanky Rails Console
function kc() {
    ps aux | grep -E 'bin/rails c|rails_console' | grep -v 'grep' | awk '{print $2}' | xargs kill -9
}

# Chruby
CHRUBY_PATH="/usr/local/share/chruby/"
if [ -d "$CHRUBY_PATH" ]; then
    source "${CHRUBY_PATH}chruby.sh"
    source "${CHRUBY_PATH}auto.sh"

    # Run this to set a default ruby on new terminals
    # echo "ruby-2.5.1" > ~/.ruby-version
    # from https://github.com/postmodern/chruby#default-ruby
fi

####### Python ##########
# -----------------------------------------------------------------------------

MINI_CONDA_PATH="${HOME}/miniconda3/bin"
if [ -d "$MINI_CONDA_PATH" ]; then
  pathadd "$MINI_CONDA_PATH"
fi

pathadd /Users/aray/miniconda3/bin:$PATH

####### Scala ###########
# -----------------------------------------------------------------------------

BAZEL_COMPLETION="${HOME}/usr/local/etc/bash_completion.d/bazel-complete.bash"
if [ -s "$BAZEL_COMPLETION" ]; then
    source "${HOME}/usr/local/etc/bash_completion.d/bazel-complete.bash"
fi

####### Perl ############
# -----------------------------------------------------------------------------

# Hack to show the version of an installed perl module.
function cpanversion() {
    perl -le 'eval "require $ARGV[0]" and print $ARGV[0]->VERSION' $1
}

####### Android #########
# -----------------------------------------------------------------------------

# Android SDK
pathadd "${HOME}/Library/Android/sdk/tools:${HOME}/Library/Android/sdk/platform-tools"

####### Node ############
# -----------------------------------------------------------------------------


export NVM_DIR="$HOME/.nvm"

# NVM setup
if [[ -d "$NVM_DIR" ]]; then
    # One of these is for home and one is for work? Maybe? Where did the second line come from?
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"   # This loads nvm
    # loads nvm bash_completion
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

################################################################################
##### Utility CLI Specific #####################################################
################################################################################

###### Terraform ########
# -----------------------------------------------------------------------------

if type "bat" > /dev/null 2>&1; then
    alias ccat='/bin/cat'
    alias cat='bat --theme=TwoDark'
else
    echo 'bat not found'
    echo 'Suggest: brew install bat'
fi

alias cat='bat --theme=TwoDark'

###### Terraform ########
# -----------------------------------------------------------------------------

LEGACY_TERRAFORM_PATH="/usr/local/opt/terraform@0.11/bin"
if [ -d "$LEGACY_TERRAFORM_PATH" ]; then
  pathadd "$LEGACY_TERRAFORM_PATH"
fi

################################################################################
##### Command Line Tooling #####################################################
################################################################################

######## Ripgrep ########
# -----------------------------------------------------------------------------

# Ripgrep refuses to build a good UI https://github.com/BurntSushi/ripgrep/issues/196
alias rg='rg --ignore-case --max-columns 200'

######## FZF ########
# -----------------------------------------------------------------------------

# Some normal junk
fzf_opts="--multi --layout=reverse --border"

# Preview files to the right, in bat for colorizing
fzf_opts="${fzf_opts} --preview 'bat --style=numbers --color=always {}'"

# Doesn't work?
# Make file list use ripgrep, which auto-ignores git and node_modules by default
# export FZF_DEFAULT_COMMAND='rg --files'

export FZF_DEFAULT_OPTS="$fzf_opts"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

######## Git ########
# -----------------------------------------------------------------------------

# My C quick branch switcher script
if [[ -d "${HOME}/c" ]]; then
    #export PATH="${HOME}/c:${PATH}"
    pathadd "${HOME}/c"
    source ~/c/c_recent_branches_completer
fi

# vim conflicted files
function vc() {
    _git_root=`git rev-parse --show-toplevel`
    (cd $_git_root && mvim -n -c 'call EditConflitedArgs()' $(git diff --name-only --diff-filter=U))
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

# Replacement for st?
alias gs="git status --untracked-files=no"

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# Git add selected files with FZF
alias ga="git ls-files -m --exclude-standard | fzf --print0 -m --preview 'git diff --color=always {}' | xargs -0 -t -o git add"

# Git undo changes to selected files with FZF
alias gx="git ls-files -m --exclude-standard | fzf --print0 -m --preview 'git diff --color=always {}' | xargs -0 -t -o git checkout -- "

# Compact, colorized git log
alias gl="git log --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# aliased to "sw"
# Easily checkout git branches, listed from a dialog menu
# dialog settings may be set in ~/.dialogrc
# switch_dialog
function switch_dialog {
  curr_branch=`git rev-parse --abbrev-ref HEAD`
  if [ -z $curr_branch ]; then
    return
  fi

  DIALOG_OK=0
  DIALOG_CANCEL=1
  DIALOG_ESC=255

  tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
  trap "rm -f $tempfile" 0 1 2 5 15

  curr_branch_index=""
  branches=`git branch | tr -s "*" " "`
  dialog_args=""

  counter1=0
  for b1 in $branches; do
    branch_line=""
    if [ $b1 = $curr_branch ]; then
      branch_line="> $b1"
      curr_branch_index=$counter1
    else
      branch_line="$counter1 $b1"
    fi
    dialog_args="$dialog_args $branch_line "
    let counter1+=1
  done

  dialog --keep-tite --title "git-checkout" \
          --menu "You are currently on branch:\n${curr_branch}\nSwitch to:" 0 0 0 \
          $dialog_args 2> $tempfile

  return_status=$?

  case $return_status in
    $DIALOG_OK)
      branch_entry=`cat $tempfile`

      if [ $branch_entry = ">" ]; then
        echo -e "\n\n-> git checkout $curr_branch"
        echo "Already on '${curr_branch}'"
        return
      fi

      counter2=0
      for b2 in $branches; do
        if [ $branch_entry = $counter2 ]; then
          echo -e "\n\n-> git checkout $b2"
          git checkout $b2
        fi
        let counter2+=1
      done
      ;;
    $DIALOG_CANCEL)
      echo -e "\n\nQuit."
      echo "On branch $curr_branch"
      ;;
    $DIALOG_ESC)
      echo -e "\n\nQuit."
      echo "On branch $curr_branch"
      ;;
    *)
      echo -e "\n\nInvalid operation."
      echo "On branch $curr_branch"
  esac
}

###### Docker #######
# -----------------------------------------------------------------------------

alias dcr='docker-compose run'
alias dce='docker-compose exec'

function docker_tag_exists() {
    path="https://index.docker.io/v1/repositories/$1/tags/$2"
    if curl --silent -f -lSL "$path" 2> /dev/null; then
        echo "${COLOR_GREEN}Found $1 $2 at${COLOR_RESET}"
        echo "    ${COLOR_LIGHT_GREEN}${path}${COLOR_RESET}"
    else
        echo "${COLOR_RED}Tag $1 $2 not found, checked path:${COLOR_RESET}"
        echo "    ${COLOR_LIGHT_RED}${path}${COLOR_RESET}"
    fi
}

# Docker logs for conatiner by name
dlog() {
    local cid=`docker ps -a | grep $1 | awk '{print $1}'`
    echo "docker logs -f ${cid}"
    docker logs -f ${cid}
}

# Start shell on container by name
dbash() {
    local cid=`docker ps -a | grep $1 | awk '{print $1}'`
    echo "docker exec -it ${cid} /bin/sh"
    docker exec -it ${cid} /bin/sh
}

deadbash() {
    local iid=`docker images | grep $1 | awk '{print $3}'`
    echo "docker run --rm -it ${iid} /bin/bash || docker run --rm -it ${iid} /bin/sh"
    docker run --rm -it ${iid} /bin/bash || docker run --rm -it ${iid} /bin/sh
}

################################################################################
##### GR #######################################################################
################################################################################
[ -f ~/.grrc ] && source ~/.grrc


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
        git diff --color --patience "$@"
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

function error_test() {
    if [[ $? = "0" ]]; then
        printf "$COLOR_LIGHT_GREEN"
    else
        printf "$COLOR_LIGHT_RED"
    fi
}

PS1="\n\[$COLOR_YELLOW\]\u\[\$(error_test)\]@\[$COLOR_GREEN\]\w\$(${dvcs_function})\[$COLOR_RESET\] \$ "

