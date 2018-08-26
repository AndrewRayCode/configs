# NOTHING CURRENTLY SOURCES THIS FILE and iTerm2 shells don't either
if [ -e "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# node modules path
export PATH=./node_modules/.bin:$PATH

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# http://grnds.askbot.com/question/345/how-do-i-set-up-my-ipsec-with-the-vpn-psk-that-is-emailed-to-me-how-do-i-connect-to-uat/?answer=346#post-id-346
export IPSEC_SECRETS_FILE=/etc/ipsec.secrets
export KEY_SUFFIX=grandrounds.com

source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
chruby ruby-2.1.5
