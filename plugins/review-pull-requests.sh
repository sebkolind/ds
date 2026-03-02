section "👀  Review Requests"

check_dependencies gh jq

cached_fetch review_prs "/tmp/dash_review_prs.json" "gh search prs --review-requested=@me --state=open --json number,title,repository,author --limit 5"

if [ -z "$review_prs" ] || [ "$review_prs" = "[]" ]; then
  empty_state "No reviews waiting - inbox zero!"
else
  echo "$review_prs" | jq -r '.[] | "\(.number)|\(.title)|\(.repository.name)"' 2>/dev/null | while IFS='|' read -r key title repo; do
    printf "  %s\n" "$title"
    printf "  ${BLUE}#%s${R} ${DIM}[%s]${R}\n" "$key" "$repo"
  done
fi
