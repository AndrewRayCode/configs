# Usage:
# chmod +x install.sh
#
# ./install.sh [cname]
#
#     cname
#       If provided, links ~/.bash_profile to configs/.bash_config_cname. .bashrc
#       sources .bash_profile so it must exist. If not provided, prompts for name

# lol fun stuff
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

echo
echo $COLOR_LIGHT_RED'                                    __ _         '
echo '                                   / _|_)          '
echo ' _ __ '$COLOR_YELLOW'__ _ '$COLOR_LIGHT_RED'_   _    ___ ___  _ __ | |_ _  __ _ ___ '
echo '| `__'$COLOR_YELLOW'/ _` |'$COLOR_LIGHT_RED' | | |  / __/ _ \| `_ \|  _| |/ _` / __|'
echo '| | '$COLOR_YELLOW'| (_| |'$COLOR_LIGHT_RED' |_| | | (_| (_) | | | | | | | (_| \__ \'
echo '|_|  '$COLOR_YELLOW'\__,_|'$COLOR_LIGHT_RED'\__, |  \___\___/|_| |_|_| |_|\__, |___/'
echo '            __/ |                         __/ |    '
echo '           |___/                         |___/     '$COLOR_RESET
echo
symlinks=0
pw=`pwd`/

# If no command line args given ($1 is first arg after script name, -z tests
# for empty string)...
if [ -z "$1" ]; then
    echo "Which config would you like to install? Available configs:"

    # Save array of files and a counter
    declare -a files
    let xx=0

    # Find all system config files that aren't vim swap files and loop through them
    for file in `find . -type f -depth 1 -name ".bash_config*" | grep -v .swp`
    do
        # Show them in a list with a counter
        xx=`expr $xx + 1` 
        files=("${files[@]}" "$file")
        echo " $COLOR_PURPLE$xx$COLOR_RESET:  $COLOR_BLUE$file$COLOR_RESET"
    done
    echo "$COLOR_PURPLE or$COLOR_RESET: type in a name to create it (ex: 'work' becomes .bash_config_work)"

    # Prompt user for file. -n means no line break after echo
    echo -n "$COLOR_YELLOW?$COLOR_RESET "
    read profile

    # If they entered a nubmer, look up that file in the array
    if [[ "$profile" =~ ^[0-9]+$ ]] ; then
        let "profile+=-1"
        config=${files[@]:$profile:1}
        # If not a number, set it to .bash_config_whatever. Regex out
        # bash_config first in case dumb user typed it
    else
        config=".bash_config_${profile/.bash_config/}"
    fi
else
    tmp=$1
    config=".bash_config_${tmp/.bash_config/}"
fi

echo

# Create the config file if it doesn't exist, and add it to git. Without adding,
# as it's a dotfile, it won't show up in git status by default. Let user commit
if [[ ! -f $config ]]; then
    echo $COLOR_GREEN"Creating $COLOR_LIGHT_GREEN$config $COLOR_GREEN..."
    touch $config
    git add $config
fi

# Link ~/.bash_config to the specified one in our dir
echo $COLOR_GREEN"Linking $COLOR_LIGHT_GREEN$config $COLOR_GREEN...$COLOR_RESET"
ln -s -f $pw$config ${HOME}/.bash_config
let "symlinks+=1"

# Loop through all dotfiles...
for f in `find . -type f -depth 1 -name ".*" | grep -v .swp`
do
    # If it's not a config file...
    if ! [[ -n `echo $f | grep bash_config` ]]; then
        f=${f/\.\//}
        to="${HOME}/$f"
        # If the file exists, and it's not a symlink, bail
        if [[ -f $to && ! -h $to ]]; then
            echo "$COLOR_LIGHT_RED$to$COLOR_RED file exists and is not a symlink! Can't touch this!"
            echo $COLOR_LIGHT_RED"Continuing..."$COLOR_RESET
        else
            let "symlinks+=1"
            ln -f -s $pw$f $to
        fi
    fi
done

# Symlink vimmy vim vim
vim="${HOME}/.vim"
if [[ -d $vim && ! -h $vim ]]; then
    echo $COLOR_LIGHT_RED$vim$COLOR_RED" is a directory! Can't touch this!"$COLOR_RESET
else
    echo $COLOR_GREEN"Linking VIM directory at $COLOR_LIGHT_GREEN$vim $COLOR_GREEN...$COLOR_RESET"
    ln -f -s $pw.vim $vim
fi

# Install fonts
fonts=/Library/Fonts
if [[ ! -d $fonts ]]; then
    echo $COLOR_LIGHT_RED$fonts$COLOR_RED" does not exist! Please manually install the fonts in this dir that I'm too lazy to list"$COLOR_RESET
else
    for font in `find . -type f -depth 1 -name "*.otf"`
    do
        echo $COLOR_GREEN"Installing font $COLOR_LIGHT_GREEN$font$COLOR_GREEN to$COLOR_LIGHT_GREEN $fonts$COLOR_GREEN...$COLOR_RESET"
        cp $font $fonts
    done
fi

# Link which repo script used for testing if we are in a git / svn / hg / etc repo
ln -s -f ${pw}which_repo.sh ${HOME}/which_repo.sh
let "symlinks+=2"

# Color git
if [ -z "`which node`" ]; then echo "${COLOR_LIGHT_RED}node not installed. Suggest ${COLOR_LIGHT_BLUE}brew install node$COLOR_RESET"; fi
if [ -z "`which npm`" ]; then echo "${COLOR_LIGHT_RED}npm not installed. Suggest ${COLOR_LIGHT_BLUE}curl http://npmjs.org/install.sh | sh$COLOR_RESET"; fi
if [ -z "`which jshint`" ]; then echo "${COLOR_LIGHT_RED}npm not installed. Suggest ${COLOR_LIGHT_BLUE}npm install -g jshint$COLOR_RESET"; fi
if [ -z "`which hub`" ]; then echo "${COLOR_LIGHT_RED}hub not installed. Suggest ${COLOR_LIGHT_BLUE}brew install hub$COLOR_RESET"; fi

echo $COLOR_GREEN"Making git color by default...$COLOR_RESET"
git config --global color.ui "auto"

echo $COLOR_GREEN"Running $COLOR_LIGHT_GREEN.osx$COLOR_GREEN (give me passwords)..."
sudo ./.osx
echo $COLOR_RESET

# Toilets!
echo $COLOR_GREEN"Done!"$COLOR_LIGHT_GREEN $symlinks$COLOR_GREEN symlinks were created.$COLOR_RESET
