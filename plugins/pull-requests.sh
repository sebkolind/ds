section "🦾  My Pull Requests"

check_dependencies gh jq

prs=$(gh search prs --author=@me --state=open --json number,title,repository --limit 5 2>/dev/null)

if [ -z "$prs" ] || [ "$prs" = "[]" ]; then
  empty_state "No open PRs - go ship something!"
else
  echo "$prs" | jq -r '.[] | "\(.number)|\(.title)|\(.repository.nameWithOwner)"' 2>/dev/null | while IFS='|' read -r key title nwo; do
    repo="${nwo##*/}"
    printf "  %s\n" "$title"
    printf "  ${BLUE}#%s${R} ${DIM}[%s]${R}\n" "$key" "$repo"
  done
fi
