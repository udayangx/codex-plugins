#!/bin/sh

set -eu

marketplace="udayan"
marketplace_source="udayangx/codex-plugins"
plugin="learn@udayan"
prompt_name="learn.md"
archive_url="${LEARN_ARCHIVE_URL:-https://github.com/udayangx/codex-plugins/archive/refs/heads/main.tar.gz}"
download_root=$(mktemp -d "${TMPDIR:-/tmp}/learn-install.XXXXXX")
log_file="$download_root/install.log"

cleanup() {
  status=$?
  rm -rf "$download_root"
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
  codex plugin marketplace list 2>/dev/null | awk -v name="$marketplace" '
    $1 == name {
      $1 = ""
      sub(/^[[:space:]]+/, "")
      print
      exit
    }
  '
}

marketplace_configured_source() {
  codex plugin marketplace list --json 2>/dev/null | awk -v name="$marketplace" '
    $0 ~ "\"name\"[[:space:]]*:[[:space:]]*\"" name "\"" { found = 1 }
    found && $0 ~ /"source"[[:space:]]*:/ {
      line = $0
      sub(/^.*"source"[[:space:]]*:[[:space:]]*"/, "", line)
      sub(/"[,[:space:]]*$/, "", line)
      print line
      exit
    }
  '
}

download_repository() {
  archive="$download_root/codex-plugins.tar.gz"
  unpacked="$download_root/source"
  mkdir -p "$unpacked"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$archive_url" -o "$archive"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$archive" "$archive_url"
  else
    printf '%s\n' 'Learn needs curl or wget to download its files.' >&2
    return 1
  fi

  command -v tar >/dev/null 2>&1 || {
    printf '%s\n' 'Learn needs tar to unpack its files.' >&2
    return 1
  }
  tar -xzf "$archive" -C "$unpacked"
}

copy_skill() {
  source=$1
  destination=$2
  parent=$(dirname "$destination")
  mkdir -p "$parent"
  stage=$(mktemp -d "$parent/.learn-stage.XXXXXX")
  backup=''

  if ! cp -R "$source/." "$stage/"; then
    rm -rf "$stage"
    return 1
  fi

  if [ -e "$destination" ] || [ -L "$destination" ]; then
    backup=$(mktemp -d "$parent/.learn-backup.XXXXXX")
    rmdir "$backup"
    if ! mv "$destination" "$backup"; then
      rm -rf "$stage"
      return 1
    fi
  fi

  if mv "$stage" "$destination"; then
    [ -z "$backup" ] || rm -rf "$backup"
    return 0
  else
    status=$?
    rm -rf "$stage"
    if [ -n "$backup" ] && [ -e "$backup" ]; then
      mv "$backup" "$destination"
    fi
    return "$status"
  fi
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
  printf '%b│%b  %b◈ Learn is ready%b                      %b│%b\n' "$accent" "$reset" "$bold" "$reset" "$accent" "$reset"
  printf '%b│%b  Restart your agent and invoke Learn.  %b│%b\n' "$accent" "$reset" "$accent" "$reset"
  printf '%b╰────────────────────────────────────────╯%b\n\n' "$accent" "$reset"
  printf '%b%s%b\n\n' "$muted" '  Use /learn where supported; otherwise ask your agent to use $learn.' "$reset"
}

printf '\n%b%s%b\n' "$accent$bold" '  ◈ LEARN' "$reset"
printf '%b%s%b\n' "$muted" '  Turn hard-won lessons into reusable project memory.' "$reset"
printf '%b%s%b\n\n' "$muted" '  One installer. Every agent.' "$reset"

installed_codex=false
installed_claude=false
installed_portable=false
repository_root="${LEARN_SOURCE_ROOT:-}"

if command -v codex >/dev/null 2>&1; then
  root=$(marketplace_root)
  if [ -n "$root" ]; then
    configured_source=$(marketplace_configured_source)
    case "$configured_source" in
      "$marketplace_source"|"https://github.com/$marketplace_source"|"https://github.com/$marketplace_source.git"|"git@github.com:$marketplace_source.git") ;;
      *) fail "Marketplace '$marketplace' already exists with a different source: $configured_source" ;;
    esac
    run_step 'Refreshing the Codex marketplace' codex plugin marketplace upgrade "$marketplace"
  else
    run_step 'Adding the Codex marketplace' codex plugin marketplace add "$marketplace_source"
  fi

  run_step 'Installing or updating the Codex plugin' codex plugin add "$plugin"

  root=$(marketplace_root)
  [ -n "$root" ] || fail 'Codex installed the marketplace, but its root could not be found.'
  [ -n "$repository_root" ] || repository_root=$root

  prompt_source="$root/prompts/$prompt_name"
  prompt_destination="${CODEX_HOME:-${HOME}/.codex}/prompts/${prompt_name}"
  [ -f "$prompt_source" ] || fail "Prompt not found at $prompt_source"
  run_step 'Installing the Codex /learn prompt' mkdir -p "$(dirname "$prompt_destination")"
  run_step 'Copying the Codex prompt' cp "$prompt_source" "$prompt_destination"
  installed_codex=true
fi

if [ -z "$repository_root" ]; then
  run_step 'Downloading the Learn skill' download_repository
  repository_root=$(find "$download_root/source" -mindepth 1 -maxdepth 1 -type d -print | head -n 1)
fi

skill_source="$repository_root/plugins/learn/skills/learn"
[ -f "$skill_source/SKILL.md" ] || fail "Learn skill not found at $skill_source"

if command -v claude >/dev/null 2>&1; then
  claude_destination="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}/skills/learn"
  run_step 'Preparing the Claude Code skill directory' mkdir -p "$(dirname "$claude_destination")"
  run_step 'Installing the Claude Code skill' copy_skill "$skill_source" "$claude_destination"
  installed_claude=true
fi

portable_destination="${AGENTS_HOME:-${HOME}/.agents}/skills/learn"
run_step 'Preparing the portable skill directory' mkdir -p "$(dirname "$portable_destination")"
run_step 'Installing the portable Agent Skill' copy_skill "$skill_source" "$portable_destination"
installed_portable=true

printf '\n  %bInstalled for:%b\n' "$bold" "$reset"
[ "$installed_codex" = false ] || printf '  %b✓%b Codex\n' "$success" "$reset"
[ "$installed_claude" = false ] || printf '  %b✓%b Claude Code\n' "$success" "$reset"
[ "$installed_portable" = false ] || printf '  %b✓%b Agent Skills-compatible tools\n' "$success" "$reset"

celebrate
