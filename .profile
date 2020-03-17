# Exports
export PATH=$HOME/.binaries:$HOME/.homebrew/bin:$PATH
export CLICOLOR=1
export CURRENT_SHELL=$(sh -c "ps -p $$ 2>/dev/null" | tail -n 1 | awk '{ print $4 }' | tr -d '-')
export PS1='\[\033[1;32m\]\u@\h\[\033[00m\] \[\033[1;34m\]\W\[\033[00m\] \[\033[38;5;245m\](${CURRENT_SHELL})\[\033[00m\] % '
export BASH_SILENCE_DEPRECATION_WARNING=1