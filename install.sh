#!/bin/sh

set -eu

marketplace="udayan"
marketplace_source="udayangx/codex-plugins"
plugin="learn@udayan"
prompt_name="learn.md"
prompt_destination="${CODEX_HOME:-${HOME}/.codex}/prompts/${prompt_name}"
log_file=$(mktemp "${TMPDIR:-/tmp}/learn-install.XXXXXX")

cleanup() {
  status=$?
  rm -f "$log_file"
  exit "$status"
}

trap cleanup EXIT
trap 'exit 1' HUP INT TERM

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  accent='\033[38;5;208m'
  success='\033[38;5;114m'
  muted='\033[38;5;244m'
  bold='\033[1m'
  reset='\033[0m'
else
  accent=''
  success=''
  muted=''
  bold=''
  reset=''
fi

fail() {
  printf '\n%bError:%b %s\n' "$accent$bold" "$reset" "$1" >&2
  exit 1
}

run_step() {
  label=$1
  shift

  : >"$log_file"
  "$@" >"$log_file" 2>&1 &
  command_pid=$!

  if [ -t 1 ]; then
    frame=0
    while kill -0 "$command_pid" 2>/dev/null; do
      case $((frame % 4)) in
        0) glyph='◐' ;;
        1) glyph='◓' ;;
        2) glyph='◑' ;;
        3) glyph='◒' ;;
      esac
      printf '\r  %b%s%b %s' "$accent" "$glyph" "$reset" "$label"
      frame=$((frame + 1))
      sleep 0.08
    done
  fi

  if wait "$command_pid"; then
    if [ -t 1 ]; then
      printf '\r  %b✓%b %s\033[K\n' "$success" "$reset" "$label"
    else
      printf '✓ %s\n' "$label"
    fi
    return 0
  fi

  if [ -t 1 ]; then
    printf '\r  %b×%b %s\033[K\n' "$accent" "$reset" "$label" >&2
  else
    printf 'x %s\n' "$label" >&2
  fi
  sed 's/^/    /' "$log_file" >&2
  exit 1
}

marketplace_root() {
  codex plugin list 2>/dev/null | awk -v name="$marketplace" '
    $0 == "Marketplace `" name "`" {
      getline
      print
      exit
    }
  '
}

celebrate() {
  if [ -t 1 ]; then
    for glyph in '·' '✦' '✧' '◈'; do
      printf '\r\033[K  %b%s%b Learning compounds.' "$accent$bold" "$glyph" "$reset"
      sleep 0.12
    done
    printf '\r\033[K'
  fi

  printf '\n%b╭────────────────────────────────────────╮%b\n' "$accent" "$reset"
  printf '%b│%b  %b◈ Learn is ready%b                       %b│%b\n' "$accent" "$reset" "$bold" "$reset" "$accent" "$reset"
  printf '%b│%b  Restart Codex, then run %b/learn%b.        %b│%b\n' "$accent" "$reset" "$bold" "$reset" "$accent" "$reset"
  printf '%b╰────────────────────────────────────────╯%b\n\n' "$accent" "$reset"
}

printf '\n%b%s%b\n' "$accent$bold" '  ◈ LEARN FOR CODEX' "$reset"
printf '%b%s%b\n\n' "$muted" '  Turn hard-won lessons into reusable project memory.' "$reset"

command -v codex >/dev/null 2>&1 || fail 'Codex CLI is not installed or is not on PATH.'

root=$(marketplace_root)
if [ -n "$root" ]; then
  run_step 'Refreshing the Udayan marketplace' codex plugin marketplace upgrade "$marketplace"
else
  run_step 'Adding the Udayan marketplace' codex plugin marketplace add "$marketplace_source"
fi

if codex plugin list 2>/dev/null | grep -Eq '^learn@udayan[[:space:]]+installed'; then
  printf '  %b✓%b %s\n' "$success" "$reset" 'Learn plugin already installed'
else
  run_step 'Installing the Learn plugin' codex plugin add "$plugin"
fi

root=$(marketplace_root)
[ -n "$root" ] || fail 'Codex installed the marketplace, but its root could not be found.'

prompt_source="$root/prompts/$prompt_name"
[ -f "$prompt_source" ] || fail "Prompt not found at $prompt_source"

run_step 'Installing the /learn prompt' mkdir -p "$(dirname "$prompt_destination")"
run_step 'Copying the prompt into Codex' cp "$prompt_source" "$prompt_destination"

celebrate
