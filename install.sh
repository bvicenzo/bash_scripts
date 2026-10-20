#!/usr/bin/env bash
#
# install.sh
#
# Interactive installer for bash_scripts. It is safe to run it as many times as
# needed: whatever is already in place is skipped, and nothing that exists is
# replaced without asking first (a timestamped backup is always kept).
#
# Step by step:
#   1. Links the dotfiles into their XDG locations (~/.config/...), offering to
#      remove legacy files (~/.tmux.conf, ~/.rspec...) that would shadow them.
#   2. Includes dotfiles/gitconfig from the machine's global git config and makes
#      sure user.name and user.email are set for this machine.
#   3. Adds the source of dotfiles/profile to ~/.bashrc and/or ~/.zshrc.
#
# Notes:
#   - The repository can be cloned anywhere: every path is resolved from this file.
#   - When there is no answer (e.g. stdin is not a terminal), the default answer
#     is used, and the defaults never replace or remove anything.

set -u

REPO_PATH="$(builtin cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_PATH="$REPO_PATH/dotfiles"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_SUFFIX="backup-$(date +%Y%m%d%H%M%S)"
BACKUPS=()

if [ -t 1 ]; then
  BOLD=$'\e[1m' GREEN=$'\e[32m' YELLOW=$'\e[33m' BLUE=$'\e[34m' DIM=$'\e[2m' RESET=$'\e[0m'
else
  BOLD="" GREEN="" YELLOW="" BLUE="" DIM="" RESET=""
fi

function title { printf '\n%s==> %s%s\n' "$BOLD$BLUE" "$1" "$RESET"; }
function ok    { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
function warn  { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$1"; }
function skip  { printf '  %s- %s%s\n' "$DIM" "$1" "$RESET"; }

# Shows paths under $HOME as ~/...
function pretty_path {
  echo "${1/#$HOME/\~}"
}

# ask "Question?" y|n
# Returns 0 for yes. An empty answer (or no input at all) picks the default.
function ask {
  local question=$1 default=$2 hint answer
  [ "$default" = "y" ] && hint="Y/n" || hint="y/N"

  read -r -p "  ? $question [$hint] " answer || { echo; answer=""; }
  answer="${answer:-$default}"
  [[ "$answer" =~ ^[YySs] ]]
}

# Moves a file (or link) away, keeping it next to the original with a timestamp.
function backup {
  local path=$1
  mv -- "$path" "$path.$BACKUP_SUFFIX"
  BACKUPS+=("$path.$BACKUP_SUFFIX")
  warn "Backup: $(pretty_path "$path.$BACKUP_SUFFIX")"
}

function describe {
  local path=$1
  if [ -L "$path" ]; then
    echo "a link to $(pretty_path "$(readlink -- "$path")")"
  elif [ -d "$path" ]; then
    echo "a directory"
  else
    echo "a file"
  fi
}

# link_dotfile <source, relative to dotfiles/> <target> <required command or ""> [legacy paths...]
#
# Legacy paths are older locations of the same file: they are either obsolete or
# would shadow the new target (e.g. tmux reads ~/.tmux.conf before ~/.config/tmux/tmux.conf).
function link_dotfile {
  local source="$DOTFILES_PATH/$1" target=$2 required_command=$3
  shift 3

  if [ -n "$required_command" ] && ! command -v "$required_command" > /dev/null; then
    skip "$(pretty_path "$target"): $required_command is not installed"
    return
  fi

  if [ -L "$target" ] && [ "$(readlink -f -- "$target")" = "$(readlink -f -- "$source")" ]; then
    ok "$(pretty_path "$target") is already linked"
  elif [ -e "$target" ] || [ -L "$target" ]; then
    warn "$(pretty_path "$target") already exists ($(describe "$target"))"
    local answer
    while true; do
      read -r -p "  ? [k]eep it, [r]eplace it with the link (keeping a backup) or see the [d]iff? [K/r/d] " answer || { echo; answer=""; }
      case "${answer:-k}" in
        [Rr]*)
          backup "$target"
          ln -s -- "$source" "$target"
          ok "$(pretty_path "$target") -> $(pretty_path "$source")"
          break ;;
        [Dd]*)
          diff -u --color=auto -- "$target" "$source" | sed 's/^/    /'
          ;;
        *)
          skip "Kept $(pretty_path "$target")"
          break ;;
      esac
    done
  else
    mkdir -p -- "$(dirname -- "$target")"
    ln -s -- "$source" "$target"
    ok "$(pretty_path "$target") -> $(pretty_path "$source")"
  fi

  local legacy
  for legacy in "$@"; do
    if [ -e "$legacy" ] || [ -L "$legacy" ]; then
      warn "$(pretty_path "$legacy") is a legacy location ($(describe "$legacy")): it is either no longer used or shadows $(pretty_path "$target")"
      if ask "Move $(pretty_path "$legacy") away (keeping a backup)?" n; then
        backup "$legacy"
      fi
    fi
  done
}

function link_dotfiles {
  title "Dotfiles"
  link_dotfile "gitignore_global"  "$CONFIG_HOME/git/ignore"         ""           "$HOME/.gitignore_global"
  link_dotfile "rspec"             "$CONFIG_HOME/rspec/options"      ""           "$HOME/.rspec"
  link_dotfile "tmux.conf"         "$CONFIG_HOME/tmux/tmux.conf"     "tmux"       "$HOME/.tmux.conf"
  link_dotfile "tmate.conf"        "$HOME/.tmate.conf"               "tmate"
  link_dotfile "terminator/config" "$CONFIG_HOME/terminator/config"  "terminator"
}

# The global git config this machine uses: ~/.gitconfig when it is a regular
# file, otherwise the XDG one (which is what Omarchy, for instance, creates).
function git_global_config_path {
  if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    echo "$HOME/.gitconfig"
  else
    echo "$CONFIG_HOME/git/config"
  fi
}

function setup_git {
  title "Git"

  # Older installs linked ~/.gitconfig straight to the repository, so settings
  # meant for one machine (like its user.email) would end up committed here.
  if [ -L "$HOME/.gitconfig" ]; then
    warn "~/.gitconfig is $(describe "$HOME/.gitconfig")"
    if ask "Replace it with this machine's own config, which includes the repository one?" y; then
      backup "$HOME/.gitconfig"
    fi
  fi

  local config_path include_path
  config_path="$(git_global_config_path)"
  include_path="$(pretty_path "$DOTFILES_PATH/gitconfig")"

  if git config --file "$config_path" --get-all include.path 2> /dev/null | grep -qxF -e "$include_path" -e "$DOTFILES_PATH/gitconfig"; then
    ok "$(pretty_path "$config_path") already includes $include_path"
  elif ask "Include $include_path in $(pretty_path "$config_path")?" y; then
    # The include goes first, so this machine's own settings below it win.
    local tmp_file
    tmp_file="$(mktemp)"
    mkdir -p -- "$(dirname -- "$config_path")"
    {
      printf '[include]\n\tpath = %s\n' "$include_path"
      [ -f "$config_path" ] && cat -- "$config_path"
    } > "$tmp_file"
    cat -- "$tmp_file" > "$config_path"
    rm -f -- "$tmp_file"
    ok "Included $include_path in $(pretty_path "$config_path")"
  fi

  local key value
  for key in "user.name" "user.email"; do
    value="$(git config --global --get "$key")"
    if [ -n "$value" ]; then
      ok "$key = $value"
    else
      warn "$key is not set on this machine"
      read -r -p "  ? $key (leave it empty to skip): " value || { echo; value=""; }
      if [ -n "$value" ]; then
        git config --file "$config_path" "$key" "$value"
        ok "$key = $value"
      fi
    fi
  done

  value="$(git config --global --get core.excludesfile)"
  if [ -n "$value" ]; then
    warn "core.excludesfile = $value overrides ~/.config/git/ignore; remove it if that is not intended"
  fi
}

function setup_shell {
  title "Shell"

  local profile_ref="$DOTFILES_PATH/profile"
  [[ "$profile_ref" == "$HOME/"* ]] && profile_ref="\$HOME/${profile_ref#"$HOME/"}"

  local rc_file found=false
  for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc_file" ] || continue
    found=true

    if grep -qF "$profile_ref" "$rc_file"; then
      ok "$(pretty_path "$rc_file") already loads the profile"
      continue
    fi

    if grep -q "dotfiles/profile" "$rc_file"; then
      warn "$(pretty_path "$rc_file") loads a profile from another path:"
      grep -n "dotfiles/profile" "$rc_file" | sed 's/^/    /'
      ask "Add the source of $profile_ref anyway (review the old line by hand)?" n || continue
    elif ! ask "Load the profile at the end of $(pretty_path "$rc_file")?" y; then
      continue
    fi

    printf '\n# bash_scripts: aliases and functions (https://github.com/bvicenzo/bash_scripts)\n[ -f "%s" ] && . "%s"\n' "$profile_ref" "$profile_ref" >> "$rc_file"
    ok "$(pretty_path "$rc_file") now loads $profile_ref"
  done

  $found || warn "Neither ~/.bashrc nor ~/.zshrc exists: add '. \"$profile_ref\"' to your shell rc"
}

printf '%sbash_scripts installer%s %s(%s)%s\n' "$BOLD" "$RESET" "$DIM" "$(pretty_path "$REPO_PATH")" "$RESET"

link_dotfiles
setup_git
setup_shell

title "Done"
if [ ${#BACKUPS[@]} -gt 0 ]; then
  echo "  Backups created:"
  printf '    %s\n' "${BACKUPS[@]/#$HOME/\~}"
fi
echo "  Open a new terminal (or run: source ~/.bashrc) to load the aliases and functions."
