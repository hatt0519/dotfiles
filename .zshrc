# 補完
autoload -U compinit && compinit
setopt prompt_subst
setopt share_history
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# 普通の補完 + スペルミス補正
zstyle ':completion:*' completer _complete _approximate

# emacsのキーバインド 
bindkey -e

#alias
alias ls='ls -GF'
alias cd="cdls"
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='nvim'
alias vim='nvim'
alias t='tmux'
alias ks='t kill-session'
alias list='t list-session'

# コマンド履歴
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end

fpath=(/usr/local/share/zsh-completions $fpath)
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"
export PATH=/usr/local/mecab/bin:$PATH
export ANDROID_HOME=/Users/kazuki.hattori/Library/Android/sdk
export PATH=$PATH:${ANDROID_HOME}/platforms:${ANDROID_HOME}/tools
export PATH=$PATH:${ANDROID_HOME}/platform-tools
export PATH="$HOME/Library/Python/2.7/bin:$PATH"
export LANG=ja_JP.UTF-8
export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH=$HOME/google-cloud-sdk/bin:$PATH
export DANGER_GITHUB_HOST=https://github.com/
export DANGER_GITHUB_API_BASE_URL=https://github.com/api/v3/
export DANGER_OCTOKIT_VERIFY_SSL=true
export DANGER_GITHUB_API_TOKEN={}
export HOMEBREW_GITHUB_API_TOKEN=59a507caa58bb70d6e613a20e5566eb03a33ace3
export XDG_CONFIG_HOME=$HOME/.config
HISTSIZE=100000
SAVEHIST=100000

. $HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings/zsh/powerline.zsh

# 関数
function cdls () { \cd "$@" && ls }
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1

    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! is_exists 'tmux'; then
                echo 'Error: tmux command not found' 2>&1
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}

function propen() {
      local current_branch_name=$(git symbolic-ref --short HEAD | xargs perl -MURI::Escape -e 'print uri_escape($ARGV[0]);')
      git config --get remote.origin.url | sed -e "s/^.*[:\/]\(.*\/.*\).git$/http:\/\/github.lo.mixi.jp\/\1\//" | sed -e "s/$/pull\/${current_branch_name}/" | xargs open
}

tmux_automatically_attach_session
