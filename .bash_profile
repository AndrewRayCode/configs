# NOTHING CURRENTLY SOURCES THIS FILE and iTerm2 shells don't either
if [ -e "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# http://grnds.askbot.com/question/345/how-do-i-set-up-my-ipsec-with-the-vpn-psk-that-is-emailed-to-me-how-do-i-connect-to-uat/?answer=346#post-id-346
export IPSEC_SECRETS_FILE=/etc/ipsec.secrets
export KEY_SUFFIX=grandrounds.com

#source /usr/local/share/chruby/chruby.sh
#source /usr/local/share/chruby/auto.sh
#chruby ruby-2.1.5

# These were installed by the bin/setup script of the jarvis repo, however
# they seem to be not needed, and cause errors like:
#
# $ rake db:setup jarvis:dev
# chruby: unknown Ruby: ruby-2.1.5
#
# if using rvm. So commenting out for now.
#source /usr/local/share/chruby/chruby.sh
#source /usr/local/share/chruby/auto.sh

#test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

if [ -e /Users/andrewray/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/andrewray/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer


#### FIG ENV VARIABLES ####
[[ -s ~/.fig/fig.sh ]] && source ~/.fig/fig.sh
#### END FIG ENV VARIABLES ####


