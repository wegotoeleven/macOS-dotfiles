# Exports
export PATH=$HOME/.binaries:$HOME/.homebrew/bin:$PATH
export CLICOLOR=1
export CURRENTSHELL=$(echo $(sh -c 'ps -p $$ -o ppid=' | xargs ps -o comm= -p | tr -d '-'))
export PS1='\[\033[38;5;240m\](${CURRENTSHELL})\[\033[00m\] \[\033[1;32m\]\u@\h\[\033[00m\] \[\033[1;34m\]\W\[\033[00m\] % '
export BASH_SILENCE_DEPRECATION_WARNING=1