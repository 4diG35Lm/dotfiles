if status is-interactive
    # Commands to run in interactive sessions can go here
end

# fish
function fish_greeting
  echo ""
end

function cd
  builtin cd $argv
    ls -a
end

# Env {{{
  set -gx XDG_CONFIG_HOME $HOME/.config
  set -U fish_user_paths $HOME/bin  $HOME/.local/bin /usr/local/bin /usr/local/sbin /usr/sbin $fish_user_paths
  set -gx SUDO_EDITOR nvim
# }}}
# Color {{{
#  # Base16 Shell
#if status --is-interactive
#     set BASE16_SHELL "$HOME/.config/base16-shell/"
#     source "$BASE16_SHELL/profile_helper.fish"
# end
# base16-oceanicnext
# }}}
# color Schema {{{
  set fish_theme dracula
# }}}
# nerd font {{{
  set -g theme_powerline_fonts no
  set -g theme_nerd_fonts yes
# }}}
# {{{
  set -g theme_display_cmd_duration yes
# }}}
# shell{{{
  set -g theme_title_display_user no
  set -g theme_title_display_process yes
  set -g theme_title_display_path no
# }}}

# exit{{{
  set -g theme_show_exit_status yes
# }}}

# Fish git prompt {{{
  set __fish_git_prompt_showdirtystate 'yes'
  set __fish_git_prompt_showstashstate 'yes'
  set __fish_git_prompt_showuntrackedfiles 'yes'
  set __fish_git_prompt_showupstream 'yes'
  set __fish_git_prompt_color_branch yellow
  set __fish_git_prompt_color_upstream_ahead green
  set __fish_git_prompt_color_upstream_behind red
# }}}

# Status Chars {{{
  set __fish_git_prompt_char_dirtystate '⚡'
  set __fish_git_prompt_char_stagedstate '→'
  set __fish_git_prompt_char_untrackedfiles '☡'
  set __fish_git_prompt_char_stashstate '↩'
  set __fish_git_prompt_char_upstream_ahead '+'
  set __fish_git_prompt_char_upstream_behind '-'
# }}}

# anynenv {{{
  set -x PATH $HOME/.anyenv/bin $PATH
  eval (anyenv init - fish | source)
  set -U FZF_LEGACY_KEYBINDINGS 0
  set -U FZF_REVERSE_ISEARCH_OPTS "--reverse --height=100%"
# }}}
# pyenv {{{
  while set pyenv_index (contains -i -- "$HOME/.anyenv/envs/pyenv/shims" $PATH)
  set -eg PATH[$pyenv_index]; end; set -e pyenv_index
  set -gx PATH "$HOME/.anyenv/envs/pyenv/shims" $PATH
  set -gx PYENV_SHELL fish
  source $HOME/.anyenv/envs/pyenv/libexec/../completions/pyenv.fish
  command pyenv rehash 2>/dev/null
  function pyenv
    set command $argv[1]
    set -e argv[1]

    switch "$command"
    case rehash shell
      source (pyenv "sh-$command" $argv|psub)
    case '*'
      command pyenv "$command" $argv
    end
  end
  set -x PYENV_ROOT (pyenv root)
  #direnv
  direnv hook fish | source
  set -g direnv_fish_mode eval_on_arrow    # trigger direnv at prompt, and on every arrow-based directory change (default)
  set -g direnv_fish_mode eval_after_arrow # trigger direnv at prompt, and only after arrow-based directory changes before executing command
  set -g direnv_fish_mode disable_arrow    # trigger direnv at prompt only, this is similar functionality to the original behavior

#}}}
# goenv {{{
  set -gx GOENV_SHELL fish
  set -gx GOENV_ROOT $HOME/.anyenv/envs/goenv
  if not contains $GOENV_ROOT/shims $PATH
    set -gx PATH $PATH $GOENV_ROOT/shims
  end
  source $HOME/.anyenv/envs/goenv/libexec/../completions/goenv.fish
  command goenv rehash 2>/dev/null
  function goenv
    set command $argv[1]
    set -e argv[1]

    switch "$command"
    case rehash shell
      source (goenv "sh-$command" $argv|psub)
    case '*'
      command goenv "$command" $argv
    end
  end
  goenv rehash --only-manage-paths
#}}}

# nodenv {{{
 set -gx PATH '$HOME/.anyenv/envs/nodenv/shims' $PATH
 set -gx NODENV_SHELL fish
 command nodenv rehash 2>/dev/null
 function nodenv
   set command $argv[1]
   set -e argv[1]

   switch "$command"
   case rehash shell
     nodenv "sh-$command" $argv|source
   case '*'
     command nodenv "$command" $argv
   end
 end
 set -gx NODE_OPTIONS "--openssl-legacy-provider"
#}}}
#{{{ rbenv
  set -gx PATH "$HOME/.anyenv/envs/rbenv/shims" $PATH
  set -gx RBENV_SHELL fish
  command rbenv rehash 2>/dev/null
  function rbenv
    set command $argv[1]
    set -e argv[1]

    switch "$command"
    case rehash shell
      rbenv "sh-$command" $argv|source
    case '*'
      command rbenv "$command" $argv
    end
  end
#}}}
#{{{ yarn
  set -U fish_user_paths $HOME/.anyenv/envs/nodenv/shims/yarn $fish_user_paths
##}}}

# neovim {{{
  set -U EDITOR nvim
  alias vim /usr/local/bin/nvim
  alias vi  /usr/local/bin/nvim
# }}}
# exa {{{
#alias ls lsd
  if command -v exa > /dev/null
    alias e 'exa --icons'
    alias l e
    alias ls e
    alias ea 'exa -a --icons'
    alias la ea
    alias ee 'exa -aal --icons'
    alias ll ee
    alias et 'exa -T -L 3 -a -I "node_modules|.git|.cache" --icons'
    alias lt et
    alias eta 'exa -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
    alias lta eta
  end
#}}}
# plugins {{{
  set fish_plugins theme git rbenv rails  bundler gem pbcopy better-alias gi peco z poerty
# }}}
# peco {{{
# set peco find history
  set fish_plugins theme peco
  function fish_user_key_bindings
    bind \cr peco_select_history
  end
#}}}

# Git {{{
  set last_status $status
  printf '%s ' (__fish_git_prompt)
  set_color normal
  function lg
    set -gx LAZYGIT_NEW_DIR_FILE ~/.lazygit/newdir

    lazygit $argv

    if test -f $LAZYGIT_NEW_DIR_FILE
      cd (cat $LAZYGIT_NEW_DIR_FILE)
      rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    end
  end
# }}}
# GPG {{{
  set -gx GPG_TTY (tty)
  set -l GPG_AGENT_INFO (gpg-agent --daemon | sed -e 's/^.*=\(.*\);.*$/\1/' )
  function gpg-agent-start
    if test -n $GPG_AGENT_INFO
        return
    end

    if test -n (which gpg-agent ^ /dev/null)
        set -gx GPG_TTY (tty)
        LANG=C gpg-connect-agent updatestartuptty /bye
        set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
    else
        echo "gpg-agent NOT exists"
    end
  end
  gpg-agent-start
# }}}
# opam {{{
  set -U fish_user_paths $fish_user_paths $HOME/.opam/default/bin
  eval (opam env)
  source $HOME/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
# }}}

#RUST {{{
  set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin
  set -U RUSTUP_TOOLCHAIN stable
  set -U  CARGO_TARGET_DIR target
# }}}

#fzf {{{
  set -U FZF_DISABLE_KEYBINDINGS 1
  source $XDG_CONFIG_HOME/fish/plugins/fzf.fish
# 履歴からコマンドを絞り込み実行する
  bind \cr __fzf_reverse_isearch
# alt+cで配下のディレクトを絞り込み移動する
  bind \ec __fzf_cd
  bind \c] __ghq_repository_search
  bind \cb fzf_git_recent_branch
# }}}

#{{{ z
set -U Z_DATA "$HOME/.local/share/z"
#}}}

# PATH {{{
set -U fish_user_paths (echo $fish_user_paths | tr ' ' '\n' | sort -u)
# }}}

## Tmux {{{
#function attach_tmux_session_if_needed
#  set ID (tmux list-sessions)
#  if test -z "$ID"
#    tmux new-session
#    return
#  end
#
#  set new_session "Create New Session"
#  set ID (echo $ID\n$new_session | peco --on-cancel=error | cut -d: -f1)
#  if test "$ID" = "$new_session"
#    tmux new-session
#  else if test -n "$ID"
#    tmux attach-session -t "$ID"
#  end
#end
#
#if test -z $TMUX && status --is-login
#  #attach_tmux_session_if_needed
#  fish $HOME/bin/tmuxWorkspace.fish
#end
#
#function precmd
#  if test ! -z $TMUX
#    tmux refresh-client -S
#  end
#  tmux -f ~/.tmux.conf
#end
#set TMUXP_CONFIGDIR $HOME/.config/tmuxp
# }}}
# Alacritty {{{
alias alacritty /usr/local/bin/alacritty
set -gx ALACRITTY_HOME $XDG_CONFIG_HOME/alacritty
source $ALACRITTY_HOME/extra/completions/alacritty.fish
# }}}
# Zellij {{{
set -gx ZELLIJ_CONFIG_DIR $XDG_CONFIG_HOME/zellij
eval (zellij setup --generate-completion fish | source)
# }}}
#{{{ starship
source (/usr/local/bin/starship init fish --print-full-init | psub)
set -gx STARSHIP_CACHE $HOME/.starship/cache
set -gx STARSHIP_LOG trace starship module timings rust bug-report
function starship_transient_prompt_func
  starship module time
end
starship init fish | source
enable_transience
#}}}
# aws {{{
  set -U fish_user_paths $HOME/aws/bin $fish_user_paths
# }}}
# Start X at login {{{
if status is-login
  if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
    exec startx -- -keeptty
  end
end
# }}}

# functions {{{
function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
  bind \cx\ck peco_kill
  bind \c] peco_select_ghq_repository
  bind \cx\cr peco_recentd
end
# }}}
