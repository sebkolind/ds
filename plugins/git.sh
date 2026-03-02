section "🐙  Git"

check_dependencies git

if [[ "${#GIT_REPOS[@]}" -eq 0 ]]; then
  empty_state "No repos configured. Add paths to GIT_REPOS in your config."
  return
fi

if [[ "${#GIT_REPOS[@]}" -gt 5 ]]; then
  empty_state "Too many repos configured. The maximum is 5."
  return
fi

for repo in "${GIT_REPOS[@]}"; do
  if [[ ! -d "$repo" ]]; then
    continue
  fi

  name=$(basename "$repo")
  branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null)
  dirty=$(git -C "$repo" status --porcelain 2>/dev/null)

  git -C "$repo" fetch --quiet 2>/dev/null &
  spinner $!

  upstream=$(git -C "$repo" rev-parse --abbrev-ref "@{u}" 2>/dev/null)
  ahead=$(git -C "$repo" rev-list --count "${upstream}..HEAD" 2>/dev/null)
  behind=$(git -C "$repo" rev-list --count "HEAD..${upstream}" 2>/dev/null)

  status=""

  if [[ -n "$dirty" ]]; then
    status+="${YELLOW}~dirty${R} "
  fi

  if [[ "${ahead:-0}" -gt 0 ]]; then
    status+="${BOLD}${GREEN}↑ ${ahead}${R} "
  fi

  if [[ "${behind:-0}" -gt 0 ]]; then
    status+="${BOLD}${RED}↓ ${behind}${R} "
  fi

  if [[ -z "$status" ]]; then
    status="${DIM}clean${R}"
  fi

  printf "  %s ${DIM}(%s)${R}\n" "$name" "$branch"
  printf "  %b\n" "$status"
done
