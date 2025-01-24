# Lines configured by zsh-newuser-install
source /home/meyyh/.config/zsh/zsh-autosuggestions.zsh

HISTFILE=~/.config/zsh/histfile
HISTSIZE=1000
SAVEHIST=1000

setopt extendedglob
setopt HIST_IGNORE_ALL_DUPS
#write to histfile after every command
setopt INC_APPEND_HISTORY
setopt prompt_subst
setopt correct
unsetopt beep

bindkey -e
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char

export WGETRC=~/.config/wget/wgetrc
export CARGO_HOME=~/.lang/rust/cargo
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export STARSHIP_CACHE=~/.config/starship/cache

alias ls="ls --color"
alias la="ls -a"
alias ll="ls -lh"
alias lla="ls -alh"
alias lal="ls -alh"

alias icat="kitten icat"
alias ssh="TERM=xterm-256color ssh"
alias hyprconf="vim ~/.config/hypr/hyprland.conf"
alias clear="printf '\\033[2J\\033[3J\\033[1;1H'"
alias vim="nvim"

autoload -U promptinit && promptinit
autoload -Uz compinit && compinit

# Find and set branch name var if in git repository.
function git_branch_name()
{
    local branch_name="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"

    if [ -z "$branch_name" ]; then
        echo ""
    else
        echo " [$branch_name]"
    fi
}

PROMPT="%n@%m %F{#0c8ffa}%~%f"'$(git_branch_name)'">"

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle :compinstall filename '/home/meyyh/.zshrc'

# Colorize completions using default `ls` colors. 
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

LS_COLORS="\
rs=0:\
di=01;34:\
ln=01;36:\
mh=00:\
pi=40;33:\
so=01;35:\
do=01;35:\
bd=40;33;01:\
cd=40;33;01:\
or=40;31;01:\
mi=00:\
su=37;41:\
sg=30;43:\
ca=00:\
tw=30;42:\
ow=34;42:\
st=37;44:\
ex=01;32:\
*.7z=01;93:\
*.zip=01;93:\
*.gz=01;93:\
*.rar=01;93:\
*.xz=01;93:\
*.tar=01;93:\
*.bz=01;93:\
*.bz2=01;93:\
*.lz=01;93:\
*.lz4=01;93:\
*.lzh=01;93:\
*.lzma=01;93:\
*.apk=01;31:\
*.deb=01;31:\
*.rpm=01;31:\
*.pkg.tar.zst=01;31:\
*.jar=01;38;2;139;69;19:\
*.wim=01;31:\
*.avif=01;38;2;10;204;188:\
*.jpg=01;38;2;10;204;188:\
*.jpeg=01;38;2;10;204;188:\
*.bmp=01;38;2;10;204;188:\
*.tif=01;38;2;10;204;188:\
*.tiff=01;38;2;10;204;188:\
*.png=01;38;2;10;204;188:\
*.svg=01;38;2;10;204;188:\
*.webp=01;38;2;10;204;188:\
*.gif=01;35
*.mov=01;35:\
*.mpeg=01;35:\
*.mkv=01;35:\
*.webm=01;35:\
*.mp4=01;35:\
*.m4v=01;35:\
*.avi=01;35:\
*.yuv=01;35:\
*.aac=00;36:\
*.flac=00;36:\
*.m4a=00;36:\
*.midi=00;36:\
*.mka=00;36:\
*.mp3=00;36:\
*.wav=00;36:\
*~=00;90:\
*#=00;90:\
*.bak=00;90:\
*.bup=00;90:\
*.old=00;90:\
*.orig=00;90:\
*.part=00;90:\
*.swp=00;90:\
*.tmp=00;90:\
";
export LS_COLORS
zstyle $pattern list-colors ${(s[:])LS_COLORS}

eval "$(starship init zsh)"
