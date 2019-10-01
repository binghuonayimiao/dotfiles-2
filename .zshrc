# Set up the prompt

# promptinit
# prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz promptinit
# compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# PROMPT=%#
# RPROMPT=[%?]

mkcd() {
    mkdir $1
    cd $1
}

# Autostart if not already in tmux.
if [[ ! -n $TMUX ]]; then
    tmux new-session
fi

# aliases

alias gh='ghq get'
alias SZ='source ~/.zshrc'

source ~/.zplug/init.zsh

# Go
export GOPATH=~/go
export PATH="$PATH:$GOPATH/bin"

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init - zsh)"

# ghq
# export GHQ_ROOT = "$HOME/ghq"

# 読み込み順序を設定する
# 例: "zsh-syntax-highlighting" は compinit の後に読み込まれる必要がある
# (2 以上は compinit 後に読み込まれるようになる)
zplugin light "zsh-users/zsh-syntax-highlighting"
zplugin light "zsh-users/zsh-history-substring-search"
zplugin light "mollifier/cd-gitroot"
zplugin light "mollifier/anyframe"
zplugin light "zsh-users/zsh-completions"
# zplugin light "tsub/f4036e067a59b242a161fc3c8a5f01dd" # history-fzf.zsh
# zplugin light "tsub/81ac9b881cf2475977c9cb619021ef3c" # ssh-fzf.zsh
# zplugin light "tsub/90e63082aa227d3bd7eb4b535ade82a0" # git-branch-fzf.zsh
# zplugin light "tsub/29bebc4e1e82ad76504b1287b4afba7c" # tree-fzf.zsh

ghq-fzf() {
    local selected_dir=$(ghq list | fzf --query="$LBUFFER")

    if [ -n "$selected_dir" ]; then
        BUFFER="cd $(ghq root)/${selected_dir}"
    fi

    zle reset-prompt
}

zle -N ghq-fzf
bindkey "^g" ghq-fzf

function history-fzf() {
    local tac

    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi

    BUFFER=$(history -n 1 | eval $tac | fzf --query "$LBUFFER")
    CURSOR=$#BUFFER

zle reset-prompt
}

zle -N history-fzf
bindkey '^r' history-fzf

function ssh-fzf () {
    local selected_host=$(grep "Host " ~/.ssh/config | grep -v '*' | cut -b 6- | fzf --query "$LBUFFER")

    if [ -n "$selected_host" ]; then
        BUFFER="ssh ${selected_host}"
        zle accept-line
    fi
    zle reset-prompt
}

zle -N ssh-fzf
bindkey '^\' ssh-fzf

function git-branch-fzf() {
    local selected_branch=$(git for-each-ref --format='%(refname)' --sort=-committerdate refs/heads | perl -pne 's{^refs/heads/}{}' | fzf --query "$LBUFFER")

    if [ -n "$selected_branch" ]; then
        BUFFER="git checkout ${selected_branch}"
        zle accept-line
    fi

    zle reset-prompt
}

zle -N git-branch-fzf
bindkey "^b" git-branch-fzf

function tree-fzf() {
    local SELECTED_FILE=$(tree --charset=o -f | fzf --query "$LBUFFER" | tr -d '\||`|-' | xargs echo)

    if [ "$SELECTED_FILE" != "" ]; then
        BUFFER="$EDITOR $SELECTED_FILE"
        zle accept-line
    fi

    zle reset-prompt
}

zle -N tree-fzf
bindkey "^t" tree-fzf

function precmd() {
    if [ ! -z $TMUX ]; then
        tmux refresh-client -S
    fi
}

# fzf本体
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# fzf-bin にホスティングされているので注意
# またファイル名が fzf-bin となっているので file:fzf としてリネームする
zplug "junegunn/fzf-bin"

# 依存管理
# "emoji-cli" は "jq" があるときにのみ読み込まれる

# テーマファイルを読み込む
# zplug "dracula/zsh", as:theme
# zplug "agkozak/agkozak-zsh-prompt"

zplugin light "denysdovhan/spaceship-prompt"

SPACESHIP_DIR_TRUNC=0
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_PROMPT_DEFAULT_PREFIX=( )

SPACESHIP_GIT_PREFIX=( )

SPACESHIP_PACKAGE_PREFIX=( )

SPACESHIP_EXEC_TIME_PREFIX=( )
SPACESHIP_EXEC_TIME_ELAPSED=0

SPACESHIP_PROMPT_ORDER=(dir package node ruby elixir golang php rust haskell docker venv pyenv exit_code git line_sep exec_time char)

<< comment

setopt prompt_subst # Make sure prompt is able to be generated properly.
zplug "caiogondim/bullet-train.zsh", use:bullet-train.zsh-theme, defer:3 # defer until other plugins like oh-my-zsh is loaded

BULLETTRAIN_PROMPT_ORDER=(dir git status virtualenv nvm ruby go)

comment

# 未インストール項目をインストールする
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# zplug 'zplug/zplug', hook-build:'zplug --self-manage

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load --verbose

# opam configuration
test -r /home/peacock/.opam/opam-init/init.zsh && . /home/peacock/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# neovim
export XDG_CONFIG_HOME="$HOME/.config"
export NVIM_CACHE_HOME="$HOME/.vim/bundles"
export EDITOR=nvim

neofetch --disable cpu gpu memory

### Added by Zplugin's installer
source '/home/peacock/.zplugin/bin/zplugin.zsh'
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin installer's chunk
