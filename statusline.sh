#!/bin/bash
# Claude Code status line:
#   Opus 5.5 (medium) | ctx (6%) | 5h (3%) 1h58m | 7d (45%) 3d13h
# Requires: jq. Set CLAUDE_STATUSLINE_DEBUG=1 to save the last input JSON
# to ~/.claude/statusline-last-input.json.

input=$(cat)
[ -n "$CLAUDE_STATUSLINE_DEBUG" ] && echo "$input" > "$HOME/.claude/statusline-last-input.json"

j() { echo "$input" | jq -r "$1 // empty" 2>/dev/null; }

model=$(j '.model.display_name'); [ -z "$model" ] && model=$(j '.model.id')
effort=$(j '.effort.level')
ctx=$(j '.context_window.used_percentage')

# Seconds-until-reset -> "3d13h" / "1h58m" / "12m". Accepts epoch (s or ms) or ISO-8601 UTC.
until_reset() {
  local r="$1" target diff d h m
  [ -z "$r" ] && return
  if [[ "$r" =~ ^[0-9]+$ ]]; then
    target=$r; [ "$target" -gt 100000000000 ] && target=$((target / 1000))
  else
    target=$(date -u -d "$r" +%s 2>/dev/null ||
             date -j -u -f "%Y-%m-%dT%H:%M:%S" "${r%%.*}" +%s 2>/dev/null) || return
  fi
  diff=$((target - $(date +%s))); [ "$diff" -lt 0 ] && diff=0
  d=$((diff / 86400)); h=$((diff % 86400 / 3600)); m=$((diff % 3600 / 60))
  if   [ "$d" -gt 0 ]; then echo "${d}d${h}h"
  elif [ "$h" -gt 0 ]; then echo "${h}h${m}m"
  else echo "${m}m"; fi
}

R=$'\e[0m'; BOLD=$'\e[1m'; WHITE=$'\e[97m'
CYAN=$'\e[36m'; MAG=$'\e[35m'; GRN=$'\e[32m'; YEL=$'\e[33m'; RED=$'\e[31m'

# green < 50%, yellow < 80%, red >= 80%
color_pct() {
  local n; n=$(printf "%.0f" "$1")
  if [ "$n" -ge 80 ]; then c=$RED; elif [ "$n" -ge 50 ]; then c=$YEL; else c=$GRN; fi
  printf "%s%s%%%s" "$c" "$n" "$R"
}

sep=" ${WHITE}|${R} "
out="${BOLD}${CYAN}${model:-?}${R}"
[ -n "$effort" ] && out="$out ${MAG}($effort)${R}"
[ -n "$ctx" ] && out="$out${sep}${WHITE}ctx${R} ($(color_pct "$ctx"))"

for win in five_hour:5h seven_day:7d; do
  key=${win%%:*}; label=${win##*:}
  p=$(j ".rate_limits.$key.used_percentage")
  [ -z "$p" ] && continue
  t=$(until_reset "$(j ".rate_limits.$key.resets_at")")
  out="$out${sep}${WHITE}$label${R} ($(color_pct "$p"))${t:+ ${WHITE}$t${R}}"
done

printf "%s\n" "$out"
