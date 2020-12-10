#### Exports

# Set path envar to homebrew directory at $HOME/.homebrew/, and custom binary folder at $HOME/.binaries
export PATH=$HOME/.binaries:$HOME/.homebrew/bin:$PATH

# Enable cli colours
export CLICOLOR=1

# Set variables
export CURRENT_SHELL=$(ps -p $$ 2>/dev/null | tail -n 1 | awk '{ print $4 }' | tr -d '-')

# Set prompt
export PS1='\[\033[1;32m\]\u@\h\[\033[00m\] \[\033[1;34m\]\W\[\033[00m\] \[\033[38;5;245m\](${CURRENT_SHELL})\[\033[00m\] % '

# Set options
export BASH_SILENCE_DEPRECATION_WARNING=1