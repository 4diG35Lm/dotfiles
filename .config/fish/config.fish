# fish
function fish_greeting
  echo ""
end

function cd
  builtin cd $argv
    ls -a
end

# ls
if test ! -e ~/.dircolors/dircolors.ansi-dark
  git clone https://github.com/seebi/dircolors-solarized.git ~/.dircolors
end
eval (dircolors -c ~/.dircolors/dircolors.ansi-dark)
# Env {{{
set -gx XDG_CONFIG_HOME $HOME/.config
set -U fish_user_paths $HOME/bin  $HOME/.local/bin /usr/local/bin /usr/local/sbin /usr/sbin $fish_user_paths
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
set -gx PATH '$HOME/.anyenv/envs/pyenv/shims' $PATH
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
#}}}
# goenv {{{
set -gx GOENV_SHELL fish
set -gx GOENV_ROOT /home/a2c/.anyenv/envs/goenv
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
#}}}

# neovim {{{
set -U EDITOR nvim

alias vim nvim
alias vi  nvim
# }}}
# LSDeluxe {{{
alias ls lsd
#}}}
# plugins {{{
set fish_plugins theme git rbenv rails  bundler gem pbcopy better-alias gi peco z tmux
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
# }}}

# opam {{{
set -U fish_user_paths $fish_user_paths $HOME/.opam/default/bin
source $HOME/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
# }}}

#RUST {{{
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin
# }}}

#fzf {{{
set -U FZF_DISABLE_KEYBINDINGS 1
source $XDG_CONFIG_HOME/fish/plugins/fzf.fish
# }}}

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
## }}}
## Alacritty {{{
set -gx ALACRITTY_CONFIG_DIR $XDG_CONFIG_HOME/alacritty
source $ALACRITTY_CONFIG_DIR/extra/completions/alacritty.fish
# }}}
## Zellij {{{
set -gx ZELLIJ_CONFIG_DIR $XDG_CONFIG_HOME/zellij
eval (zellij setup --generate-completion fish | source)
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
source (/usr/local/bin/starship init fish --print-full-init | psub)