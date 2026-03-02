section "👀  Review Requests"

check_dependencies gh jq

gh search prs --review-requested=@me --state=open --json number,title,repository,author --limit 5 2>/dev/null >"/tmp/dash_review_prs.json" &
spinner $!
review_prs=$(cat /tmp/dash_review_prs.json)

if [ -z "$review_prs" ] || [ "$review_prs" = "[]" ]; then
  empty_state "No reviews waiting - inbox zero!"
else
  echo "$review_prs" | jq -r '.[] | "\(.number)|\(.title)|\(.repository.name)"' 2>/dev/null | while IFS='|' read -r key title repo; do
    printf "  %s\n" "$title"
    printf "  ${BLUE}#%s${R} ${DIM}[%s]${R}\n" "$key" "$repo"
  done
fi
