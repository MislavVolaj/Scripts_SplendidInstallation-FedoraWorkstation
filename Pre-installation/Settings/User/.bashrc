# .bashrc
shopt -s -q autocd cdspell

export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTTIMEFORMAT="%d.%m.%Y. %T  "

# Source global definitions
if [[ -f /etc/bashrc ]]
then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

echo Welcome back, $(whoami).

# User specific aliases and functions
md() { [ $# = 1 ] && mkdir --parents "$@" && cd "$@" || echo "Error: No directory name passed!"; }

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias copy="rsync --archive --human-readable --progress"
alias update="sudo dnf upgrade --refresh && sudo flatpak update"

