#!/usr/bin/env bash
# prompt segments, see .p10k.zsh
function prompt_t_node () {
  NVM_NODE_VERSION=$(echo $NVM_BIN | sed -e "s#$HOME/.nvm/versions/node/##" | cut -d "/" -f1)
  # fall back to $NODE_VERSION from ~/.config/dotfiles/source/exports
  if [[ -d $HOME/.nvm ]] &> /dev/null
  then
    NODE_VERSION=${NVM_NODE_VERSION:-$NODE_VERSION}
    NPM_VERSION=$(cat $HOME/.nvm/versions/node/$NODE_VERSION/lib/node_modules/npm/package.json | jq -r .version)
    p10k segment -t "%F{green}$NODE_VERSION %F{yellow}$NPM_VERSION"
  fi
}

function prompt_t_java () {
  case $(uname) in
    Linux)
      if command -v archlinux-java &> /dev/null
      then
        p10k segment -t "%F{green}$(archlinux-java get)"
      fi
      ;;
    Darwin)
      if [ $(ls /Library/Java/JavaVirtualMachines/ | wc -l) != 0 ]; then
        DEFAULT_JAVA=$(/usr/libexec/java_home)
        JAVA_VERSION=$(echo ${JAVA_HOME:-$DEFAULT_JAVA} | tr "/" " " | awk '{print $4}')
        p10k segment -t "%F{green}$JAVA_VERSION"
      fi
      ;;
  esac
}

function prompt_t_git () {
  GIT_VERSION=$(command -v git 2>&1 > /dev/null && git --version | awk '{print $3}')
  p10k segment -t "%F{green}$GIT_VERSION"
}

function prompt_t_terraform () {
  p10k segment -t "%F{green}$(terraform --version | head -n1 | cut -d " " -f2)"
}

function prompt_t_terragrunt () {
  p10k segment -t "%F{green}$(terragrunt --version | head -n1 | cut -d " " -f3)"
}

function prompt_t_gcloud () {
  # https://cloud.google.com/sdk/docs/configurations#activating_a_configuration
  env=${CLOUDSDK_ACTIVE_CONFIG_NAME:-default}
  if [ -f "$HOME/.config/gcloud/configurations/config_$env" ]; then
    project=$(cat $HOME/.config/gcloud/configurations/config_$env | rg project | sed -e "s/project = //")
    email=$(cat $HOME/.config/gcloud/configurations/config_$env | rg account | sed -e "s/account = //")
    p10k segment -t "%F{green}${email}%F{red}@%F{yellow}${project}"
  fi
}

function prompt_t_npm () {
  NPM_SCRIPTS=$([[ -f package.json ]] && cat package.json | jq -er '.scripts | keys? | sort | join(" ")' || echo "no package.json")
  p10k segment -t "%F{orange}$NPM_SCRIPTS"
}

# https://github.com/romkatv/powerlevel10k/issues/2445
function p10k-on-post-widget() {
  if [[ $PREBUFFER$BUFFER =~ '^(java|javac|javap|kotlin|clj|clojure|jdk|jdks|gradle|gw)\ ?' ]]; then
    p10k display '*/t_java'=show
  elif [[ $PREBUFFER$BUFFER =~ '^(python|python3|pip|pip3|pyenv)' ]]; then
    p10k display '*/virtualenv'=show
  elif [[ $PREBUFFER$BUFFER =~ '^(terraform|tfenv)' ]]; then
    p10k display '*/t_terraform'=show
  elif [[ $PREBUFFER$BUFFER =~ '^(terragrunt|tgenv)' ]]; then
    p10k display '*/t_terragrunt'=show
  elif [[ $PREBUFFER$BUFFER =~ '^npm run' ]]; then
    p10k display '*/t_npm'=show
  elif [[ $PREBUFFER$BUFFER =~ '^(node|npm|nvm|npx|ts-node|tsc)' ]]; then
    p10k display '*/t_node'=show
  elif [[ $PREBUFFER$BUFFER =~ '^(gcloud|gsutil|gcs|terragrunt|terraform)' ]]; then
    p10k display '*/t_gloud'=show
  elif [[ $PREBUFFER$BUFFER =~ '^git' ]]; then
    p10k display '*/t_git'=show
  else
    p10k display '*/t_*'=hide
  fi
}

# Generated by Powerlevel10k configuration wizard on 2022-12-17 at 14:07 CET.
# Based on romkatv/powerlevel10k/config/p10k-pure.zsh, checksum 13301.
# Wizard options: compatible, pure, snazzy, rpromt, 24h time, 2 lines, sparse,
# instant_prompt=quiet.
# Type `p10k configure` to generate another config.
#
# Config file for Powerlevel10k with the style of Pure (https://github.com/sindresorhus/pure).
#
# Differences from Pure:
#
#   - Git:
#     - `@c4d3ec2c` instead of something like `v1.4.0~11` when in detached HEAD state.
#     - No automatic `git fetch` (the same as in Pure with `PURE_GIT_PULL=0`).
#
# Apart from the differences listed above, the replication of Pure prompt is exact. This includes
# even the questionable parts. For example, just like in Pure, there is no indication of Git status
# being stale; prompt symbol is the same in command, visual and overwrite vi modes; when prompt
# doesn't fit on one line, it wraps around with no attempt to shorten it.
#
# If you like the general style of Pure but not particularly attached to all its quirks, type
# `p10k configure` and pick "Lean" style. This will give you slick minimalist prompt while taking
# advantage of Powerlevel10k features that aren't present in Pure.

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  autoload -Uz is-at-least && is-at-least 5.1 || return

  # Prompt colors, catpuccin ish
  local grey='242'
  local red='#EA746F'
  local yellow='##E2BE82'
  local blue='##69ABE6'
  local magenta='#B97BD5'
  local cyan='#8EDCF8'
  local white='#DCDCDC'
  local green='#9EBB6F'

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 ]=========================
    context                   # user@host
    dir                       # current directory
    vcs                       # git status
    command_execution_time  # previous command duration
    # =========================[ Line #2 ]=========================
    newline                   # \n
    # virtualenv              # python virtual environment
    prompt_char               # prompt symbol
  )

  # Right prompt segments.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 ]=========================
    # command_execution_time    # previous command duration
    # context                   # user@host
    # background_jobs
    # google_app_cred
    time                      # current time

    newline

    virtualenv                # python virtual environment
    t_gcloud
    t_java
    t_git
    t_node
    direnv

    newline

    t_npm

    # torgeir too slow
    # t_terraform
    # t_terragrunt
    # =========================[ Line #2 ]=========================
  )

  typeset -g POWERLEVEL9K_GCLOUD_FOREGROUND=30

  # Basic style options that define the overall prompt look.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # no segment icons

  # Add an empty line before each prompt except the first. This doesn't emulate the bug
  # in Pure that makes prompt drift down whenever you use the Alt-C binding from fzf or similar.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Magenta prompt symbol if the last command succeeded.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=$green
  # Red prompt symbol if the last command failed.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=$red
  # Default prompt symbol.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='>'
  # Prompt symbol in command vi mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='<'
  # Prompt symbol in visual vi mode is the same as in command mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='<'
  # Prompt symbol in overwrite vi mode is the same as in command mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=false

  # Python Virtual Environment.
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$green
  # Don't show Python version.
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  # Blue current directory.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$blue

  # Context format when root: user@host. The first part white, the rest grey.
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE="%F{$white}%n%f%F{$grey}@%m%f"
  # Context format when not root: user@host. The whole thing grey.
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE="%F{$grey}%n@%m%f"
  # Don't show context unless root or in SSH.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=

  # Show previous command duration only if it's >= 5s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=1
  # Show fractional seconds. Thus, 7s rather than 7.3s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
  # Duration format: 1d 2h 3m 4s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  # Yellow previous command duration.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$yellow

  # Grey Git prompt. This makes stale prompts indistinguishable from up-to-date ones.
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=$grey

  # Disable async loading indicator to make directories that aren't Git repositories
  # indistinguishable from large Git repositories without known state.
  typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=

  typeset -g POWERLEVEL9K_VCS_TAG_ICON="X"

  # Don't wait for Git status even for a millisecond, so that prompt always updates
  # asynchronously when Git state changes.
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0

  # Cyan ahead/behind arrows.
  typeset -g POWERLEVEL9K_VCS_{INCOMING,OUTGOING}_CHANGESFORMAT_FOREGROUND=$cyan

  # Don't show remote branch, current tag or stashes.
  # typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind)
  # 
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON="%F{green}X"
  # When in detached HEAD state, show @commit where branch normally goes.
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'

  # Don't show staged, unstaged, untracked indicators.
  # 
  # Show '*' when there are staged, unstaged or untracked files.
  typeset -g POWERLEVEL9K_VCS_DIRTY_ICON='X%F{red}*'
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON="%F{yellow}+"
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON="%F{blue}!"
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON="%F{cyan}?"
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='⇣'
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='⇡'
  typeset -g POWERLEVEL9K_VCS_{COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=10
  # Remove all spaces, replace X with spaces
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${${P9K_CONTENT// /}//\X/ }'


  # Grey current time.
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$cyan
  # Format for the current time: 09:51:02. See `man 3 strftime`.
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  # If set to true, time will update when you hit enter. This way prompts for the past
  # commands will contain the start times of their commands rather than the end times of
  # their preceding commands.
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=true

  # Transient prompt works similarly to the builtin transient_rprompt option. It trims down prompt
  # when accepting a command line. Supported values:
  #
  #   - off:      Don't change prompt when accepting a command line.
  #   - always:   Trim down prompt when accepting a command line.
  #   - same-dir: Trim down prompt when accepting a command line unless this is the first command
  #               typed after changing current working directory.
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

  # Instant prompt mode.
  #
  #   - off:     Disable instant prompt. Choose this if you've tried instant prompt and found
  #              it incompatible with your zsh configuration files.
  #   - quiet:   Enable instant prompt and don't print warnings when detecting console output
  #              during zsh initialization. Choose this if you've read and understood
  #              https://github.com/romkatv/powerlevel10k/blob/master/README.md#instant-prompt.
  #   - verbose: Enable instant prompt and print a warning when detecting console output during
  #              zsh initialization. Choose this if you've never tried instant prompt, haven't
  #              seen the warning, or if you are unsure what this all means.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  # Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
  # For example, you can type POWERLEVEL9K_BACKGROUND=red and see your prompt turn red. Hot reload
  # can slow down prompt by 1-2 milliseconds, so it's better to keep it turned off unless you
  # really need it.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # If p10k is already loaded, reload configuration.
  # This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
  (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
