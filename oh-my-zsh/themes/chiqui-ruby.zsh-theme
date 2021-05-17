# vim:ft=zsh ts=2 sw=2 sts=2
function prompt_char {
  echo '⊗'
}
# Must use Powerline font, for \uE0A0 to render.
ZSH_THEME_GIT_PROMPT_PREFIX="on %B%{$fg[magenta]%}\uE0A0 "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%b"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg_bold[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"
PROMPT='
%B%F{yellow}%n%f%b at %{$fg_bold[green]%}%~%{$reset_color%} $(git_prompt_info)
%B%F{yellow}$(prompt_char)%{$reset_color%}%b '
RPROMPT='$(ruby_prompt_info)'
