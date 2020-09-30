# Path to your oh-my-zsh installation.
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac

HIST_STAMPS="mm/dd/yyyy"

# 標準エディタの設定
export EDITOR=emacs

plugins=(brew brew-cask cdd gem git rbenv vagrant)
#source $ZSH/oh-my-zsh.sh

export PATH="/usr/local/bin:$PATH"

autoload -Uz colors && colors # 色を使用できるようにする

setopt auto_cd # ディレクトリ名だけで飛べるようになる

setopt auto_pushd # cd -[tab] で過去のディレクトリに飛べるようになる

setopt pushd_ignore_dups # ディレクトリスタックと重複したディレクトリを追加しない

setopt auto_menu # 補完キーを押したときに候補順に自動で補完

setopt correct # コマンドが間違っているときにもしかして：を出す

setopt list_packed # compacked complete list display

setopt noautoremoveslash # ディレクトリ名の最後のスラッシュを外さない

# no beep sound when complete list displayed
setopt no_beep 
setopt no_list_beep
setopt no_hist_beep

setopt print_eight_bit # print Japanese file name

#setopt print_exit_value # 0 以外のステータスで終わった時にステータスを表示する

setopt ignore_eof # Ctrl-D でシェルからログアウトしない

setopt interactive_comments # #以降をコメントと認識

# = 以降にも補完が効くようにする
setopt magic_equal_subst

## Keybind configuration
# emacs like keybind (e.x. Ctrl-a gets to line head and Ctrl-e gets
#   to end) and something additions
bindkey -e
bindkey "^[[1~" beginning-of-line # Home gets to line head
bindkey "^[[4~" end-of-line # End gets to line end
bindkey "^[[3~" delete-char # Del

## Command history configuration
HISTFILE=${HOME}/.zsh_history
HISTSIZE=100000000
SAVEHIST=100000000
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # 同時に起動した zsh 間でヒストリーを共有
setopt hist_ignore_all_dups # 同じコマンドはヒストリーに残さない
setopt hist_ignore_space    # スペースから始まるコマンドはヒストリーに残さない
setopt hist_reduce_blanks   # ヒストリーに保存する際、余分なスペースを削除
setopt inc_append_history # 履歴をすぐに追加する
# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end

bindkey "\e[Z" reverse-menu-complete # reverse menu completion binded to Shift-Tab

# 単語の区切り文字を指定
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " \=;@:{},|"
zstyle ':zle:*' word-chars word-style unspecified


################################################################
# 補完に関する設定
fpath=(/path/to/homebrew/share/zsh-completion $fpath)
autoload -U compinit
compinit -u
# aliased ls needs if file/dir completions work
setopt complete_aliases
zstyle ':completion:*:processes' command 'ps x -o pid,s,args' # ps のあとでプロセス名を補完できるようにする

zstyle ':completion:*' completer _complete _match _approximate _history _prefix
zstyle ':completion:*' group-name ''
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors "${LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache true
zstyle ':completion:*' verbose yes
zstyle ':completion:*:default' menu select=2
#zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:options' description 'yes'
################################################################

## zsh editor
autoload zed

# URL をエスケープする
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# git の情報を見れるようにする
autoload -Uz vcs_info
setopt prompt_subst

#formats 設定項目で %c,%u が使用可
zstyle ':vcs_info:git:*' check-for-changes true

# commit されていないものがあるとき
zstyle ':vcs_info:git:*' stagedstr "⚡️"
# add されていないファイルがあるとき
zstyle ':vcs_info:git:*' unstagedstr "✝️"
# 通常時
zstyle ':vcs_info:*' formats "[%b]%c%u%f"
# そのほか merge conflect などのとき
zstyle ':vcs_info:*' actionformats '[%b|%a]'

precmd() { vcs_info }

#prompt
SUCCESS=$'\(\๑´\ڡ\`\๑%) \ノ  '
FAILED=$'\(\｡>\﹏<\｡%) \メ  '

PROMPT='%~: (%W %*)%f%b
%(?.%B%F{green}$SUCCESS.%B%F{magenta}$FAILED)%f%b'
# 右プロンプト
RPROMPT='${vcs_info_msg_0_}'
PROMPT2='%B%F{green}%_> %f%b'
# もしかしてのプロンプト指定
SPROMPT="%{$fg[red]%}%{$suggest%}(｡ŏ﹏ŏ%)? < もしかして %B%r%b %{$fg[red]%}かな? [そうだョ!(y), 違うョ!(n),a,e]:${reset_color} "

alias where="command -v"
alias j="jobs -l"

case "${OSTYPE}" in
freebsd*|darwin*)
    alias ls="ls -G -w"
    ;;
linux*)
    alias ls="ls --color"
    ;;
esac

# peco settings
# Ctrl-r でコマンド履歴が peco によって検索できる
function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

###########################################################
# powered_cd という関数によって cd した履歴をもとに移動できる
# c にエイリアスしている
function chpwd() {
  powered_cd_add_log
}

function powered_cd_add_log() {
  local i=0
  cat ~/.powered_cd.log | while read line; do
    (( i++ ))
    if [ i = 30 ]; then
      sed -i -e "30,30d" ~/.powered_cd.log
    elif [ "$line" = "$PWD" ]; then
      sed -i -e "${i},${i}d" ~/.powered_cd.log 
    fi
  done
  echo "$PWD" >> ~/.powered_cd.log
}

function powered_cd() {
  if [ $# = 0 ]; then
    cd $(gtac ~/.powered_cd.log | peco)
  elif [ $# = 1 ]; then
    cd $1
  else
    echo "powered_cd: too many arguments"
  fi
}

_powered_cd() {
  _files -/
}

compdef _powered_cd powered_cd

[ -e ~/.powered_cd.log ] || touch ~/.powered_cd.log
alias c="powered_cd"
###########################################################



# sudo の後ろでもエイリアスを効くようにする
alias sudo='sudo '

alias ...="../.."
alias ....="../../../"

alias sl="ls"
alias la="ls -a"
alias lf="ls -F"
alias ll="ls -la"

alias du="du -h"
alias df="df -h"

alias su="su -l"

alias e="emacs"
alias ema="emacs"

# homebrew
alias b="brew"
alias bc="brew cask"
alias bup="brew update"
alias bug="brew upgrade"
alias bcl="brew cleanup"
alias bcug="brew cask upgrade"
alias bse="brew search"
alias bcse="brew cask search"
alias bin="brew install"
alias bcin="brew cask install"
alias bli="brew list"
alias bcli="brew cask list"
alias bdo="brew doctor"
alias bccl="brew cask cleanup"

# rm は結構危険なので一旦ゴミ箱に入れるようにする
alias rm="trash"

alias pip="pip3"

# git
alias g="git"
#alias gs="git status"
#alias grm="git rm --cached"


# python を ./test.py で実行できる
alias -s py=python
export PATH=/usr/local/opt/python/libexec/bin:$PATH

# ./test.tar.gz などと入れるだけで圧縮ファイルを展開できる
function extract() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.tar.xz) tar Jxvf $1;;
    *.zip) unzip $1;;
    *.lzh) lha e $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.tar.Z) tar zxvf $1;;
    *.gz) gzip -d $1;;
    *.bz2) bzip2 -dc $1;;
    *.Z) uncompress $1;;
    *.tar) tar xvf $1;;
    *.arj) unarj $1;;
  esac
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract


## terminal configuration
#
case "${TERM}" in
screen)
    TERM=xterm
    ;;
esac

case "${TERM}" in
xterm|xterm-color)
    export LSCOLORS=exfxcxdxbxegedabagacad
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
kterm-color)
    stty erase '^H'
    export LSCOLORS=exfxcxdxbxegedabagacad
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
kterm)
    stty erase '^H'
    ;;
cons25)
    unset LANG
    export LSCOLORS=ExFxCxdxBxegedabagacad
    export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
jfbterm-color)
    export LSCOLORS=gxFxCxdxBxegedabagacad
    export LS_COLORS='di=01;36:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;36;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
esac

# set terminal title including current directory
case "${TERM}" in
xterm|xterm-color|kterm|kterm-color)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac
export PATH="/usr/local/sbin:$PATH"
