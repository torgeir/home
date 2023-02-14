# bash what does -f, -s, -n etc mean
# man [

if [[ -n "${INSIDE_EMACS+1}" ]]; then
  # don't
else
  [[ -f "$HOME/.cache/wal/sequences" ]] && cat ~/.cache/wal/sequences
fi

source $HOME/dotfiles/source/aliases
source $HOME/dotfiles/source/functions

# default owner rw
umask 77

# make gpg from emacs prompt in shell (may need to open emacs from command line)
# linux likes this.
# Note, needs to happen before powerlevel10 instant prompt, it redirects too /dev/null
# so tty says "not a tty" if it happens after.
# export GPG_TTY=$(tty)
# TODO this is supposed to be faster?
# https://github.com/romkatv/powerlevel10k#how-do-i-export-gpg_tty-when-using-instant-prompt
export GPG_TTY=$TTY

# load zsh plugins
for plug in \
  $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh \
  $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  $HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ;
do
  if [[ -f $plug ]]; then
    #echo "Loading plugin $plug"
    source $plug
  fi

done

if [[ -f $HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  # debug these codes with cat -v
  bindkey "^P" history-substring-search-up
  bindkey "^N" history-substring-search-down
fi

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
if [[ -f $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  # toggle off with <s-tab> - no, s-tab to complete backwards is useful
  bindkey "^T" autosuggest-toggle
fi

# e.g. C-o describe-key-briefly <ret>
bindkey '^O' execute-named-cmd
bindkey '^H' describe-key-briefly

# prompt install
if [[ ! -d "$HOME/powerlevel10k" ]]; then
  pushd $HOME
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git
  source $HOME/powerlevel10k/powerlevel10k.zsh-theme
  p10k configure
  popd
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# nvm use x is too slow for every shell
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm
# default is set by hand in exports

case $(uname) in
  Linux)
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
    ;;
esac

# Loads nvm bash_completion
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

[[ -d "$HOME/powerlevel10k" ]] && source $HOME/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# jump around like z
case $(uname) in
  Linux)
    [[ -s /home/torgeir/.autojump/etc/profile.d/autojump.sh ]] && source /home/torgeir/.autojump/etc/profile.d/autojump.sh
    ;;
  Darwin)
    [[ -s /usr/local/etc/profile.d/autojump.sh ]] && source /usr/local/etc/profile.d/autojump.sh
    ;;
esac

case $(uname) in
  Linux)
    if command -v xmodmap &> /dev/null
    then
      xmodmap ~/.Xmodmap
    fi

    # movement bindings in Thunar, like in os x Finder
    [[ -d "$HOME/.config/Thunar/" ]] && echo '(gtk_accel_path "<Actions>/ThunarWindow/open-parent" "BackSpace")' >> $HOME/.config/Thunar/accels.scm
    [[ -d "$HOME/.config/Thunar/" ]] && echo '(gtk_accel_path "<Actions>/ThunarWindow/open-parent" "<Alt>Up")' >> $HOME/.config/Thunar/accels.scm
    [[ -f "$HOME/.config/Thunar/" ]] && echo '(gtk_accel_path "<Actions>/ThunarLauncher/open" "<Alt>Down")' >> $HOME/.config/Thunar/accels.scm
    ;;
  Darwin)
    ;;
esac

# https://thevaluable.dev/zsh-completion-guide-examples/

# find new executables in $PATH automatically
zstyle ':completion:*' rehash true
zstyle ':completion:*' menu select
# zstyle ':completion:*' file-list all
zstyle ':completion:*' group-name ''
# cd fuzzy
zstyle ':completion:*' matcher-list '' '' 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=** r:|=** l:|=*'
# cd case insensitive
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# zstyle ':completion:*:*:cp:*' file-sort modification
# zstyle ':completion:*' file-sort modification
# TODO torgeir var denne noe lur da? autocompleter andre ting enn match
# zstyle ':completion:*' completer _extensions _expand _complete _ignored _approximate
zstyle ':completion:*:options' list-colors '=^(-- *)=34'
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

autoload -U select-word-style
select-word-style bash

# load custom completions, e.g. from brew
fpath=(~/.zsh $fpath)

case $(uname) in
  Darwin)
    # zsh git completion needs git-completion.bash
    zstyle ':completion:*:*:git:*' script /usr/local/Cellar/git/$(git --version | awk '{print $3}')/share/zsh/site-functions/git-completion.bash
    # TODO torgeir still works after extracting 5.8?
    fpath=($(brew --prefix)/share/zsh/$(zsh --version | cut -d " " -f2)/site-functions $fpath)
    ;;
esac

# allow bash style comments in interactive shells
setopt interactivecomments

# dont store space prefixex commands in history
setopt HIST_IGNORE_SPACE

autoload -Uz compinit && compinit -u

# enable ctrl-x-e to edit command line
autoload -U edit-command-line
# emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# peder sin gauth
# source $HOME/Code/gauth/gauth.sh

case $(uname) in
  Darwin)
    # The next line updates PATH for the Google Cloud SDK.
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
    # The next line enables zsh completion for gcloud.
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc

    # don't type the password on every git pull
    ssh-add -K ~/.ssh/id_rsa > /dev/null 2>&1
    ;;
  Linux)
    if command -v ssh-agent &> /dev/null
    then
      #SSH_AGENT_PID=""
      #SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"

      # launch ssh agent before ssh-add
      #eval `ssh-agent -s` > /dev/null 2>&1

      # https://wiki.archlinux.org/title/SSH_keys
      # https://linuxhint.com/solve-gpg-decryption-failed-no-secret-key-error/
      eval $(keychain --eval --quiet id_ed25519)

      # if you use multiple terminals simultaneously and want gpg-agent to ask for passphrase via pinentry-curses from the same terminal
      gpg-connect-agent updatestartuptty /bye >/dev/null
    fi
    ;;
esac

# https://github.com/akermu/emacs-libvterm#directory-tracking-and-prompt-tracking
if command -v autoload &> /dev/null
then
  autoload -U add-zsh-hook
  add-zsh-hook -Uz chpwd (){ vterm_set_directory }
fi

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
# init-pyenv

# gpg
# 
# Test decryption
#   gpg --no-tty -q --batch -d ~/.authinfo.gpg
#
# Reload gpg agent
#  killall gpg-agent && gpg-connect-agent reloadagent /bye 
#
# Sign something to check presens of cached key
#   echo "1234" | gpg --local-user 77836712DAEA8B95 -as -
#   echo "1234" | gpg --local-user 922E681804CA8D82F1FAFCB177836712DAEA8B95 -as -
# 
case $(uname) in
  Darwin)

    # Nescessary to make the following passphrase preset to work
    gpg-connect-agent updatestartuptty /bye >/dev/null

    # Preset it from 1password. Try signing with it first, only preset it if it fails.
    # https://stackoverflow.com/questions/11381123/how-to-use-gpg-command-line-to-check-passphrase-is-correct
    PRESET_KEY=$(gpg --pinentry-mode error --local-user 922E681804CA8D82F1FAFCB177836712DAEA8B95 -aso /dev/null <(echo 1234) 2>/dev/null && echo "yes" || echo "no")
    if [[ "$PRESET_KEY" = "no" ]]; then
      $(gpgconf --list-dirs libexecdir)/gpg-preset-passphrase \
        -c \
        -P "$(op item get keybase.io --format json | jq -j '.fields[] | select(.id == "password") | .value')" \
        $(gpg --fingerprint --with-keygrip torgeir@keybase.io | awk '/Keygrip/ {print $3}' | tail -n 1)
    fi

    # I don't get this, but the first time around, after the initial signing (gpg -as) failed in the previous step, I need to actually use the key to make the agent cache it. Decrypt an encrypted file to make it stick.
    gpg -q --batch -d ~/.authinfo.gpg > /dev/null
  ;;
esac


case $(uname) in
  Darwin)
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
;;
esac

# debug escape codes with cat
# directory keybindings, c-up and c-down
cd_undo()   { popd     && zle accept-line }
cd_parent() { pushd .. && zle accept-line }
zle -N cd_parent
zle -N cd_undo
bindkey '^[[1;5A' cd_parent
bindkey '^[[1;5B' cd_undo
