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
ln -s -f $config ${HOME}/.bash_config
let "symlinks+=1"

# Loop through all dotfiles...
for f in `find . -type f -depth 1 -name ".*" | grep -v .swp`
do
        # If it's not a config file...
	if ! [[ -n `echo $f | grep bash_config` ]]; then
                f=${f/\.\//}
                to="${HOME}/$f"
                # If the file exists, and it's not a symlink, bail
                if [[ -f $to ]]; then
                        echo "$COLOR_LIGHT_RED$to$COLOR_RED file exists and is not a symlink! Can't touch this!"
                        echo $COLOR_LIGHT_RED"Continuing..."$COLOR_RESET
                else
                        let "symlinks+=1"
                        ln -f -s $f $to
                fi
        fi
done

vim="${HOME}/.vim"
if [[ ! -d $vim ]]; then
        echo $COLOR_GREEN"Creating VIM directory at $COLOR_LIGHT_GREEN$vim $COLOR_GREEN...$COLOR_RESET"
        mkdir $vim
fi

ln -s -f bundle $vim/bundle
ln -s -f which_repo.sh ${HOME}/which_repo.sh
let "symlinks+=2"

echo $COLOR_GREEN"Done!"$COLOR_LIGHT_GREEN $symlinks$COLOR_GREEN symlinks were created.$COLOR_RESET
