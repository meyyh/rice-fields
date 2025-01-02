#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# Immediately persist commands to history
PROMPT_COMMAND='history -a'

alias hde="hyprctl dispatch exec"
alias ssh="TERM=xterm ssh"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
