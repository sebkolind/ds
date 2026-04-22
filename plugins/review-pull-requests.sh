section "👀 Review Requests"

check_dependencies gh jq

cached_fetch review_prs "/tmp/dash_review_prs.json" "gh search prs --review-requested=@me --state=open --json number,title,repository,author --limit 5"

if [ -z "$review_prs" ] || [ "$review_prs" = "[]" ]; then
  empty_state "No reviews waiting - inbox zero!"
else
  # Parse the list once into a newline-separated "number|title|owner/repo".
  review_entries=$(echo "$review_prs" | jq -r '.[] | "\(.number)|\(.title)|\(.repository.nameWithOwner)"' 2>/dev/null)

  # Fan out per-PR detail fetches in parallel. Distinct cache prefix from the
  # "My PRs" plugin so TTL invalidation stays independent.
  detail_pids=()
  while IFS='|' read -r number _title nwo; do
    [[ -z "$number" || -z "$nwo" ]] && continue
    owner="${nwo%%/*}"
    repo="${nwo##*/}"
    cache_file="/tmp/dash_review_pr_${owner}_${repo}_${number}.json"
    cmd="gh pr view ${number} --repo ${nwo} --json statusCheckRollup,reviewDecision"
    cached_fetch _pr_detail_discard "$cache_file" "$cmd" &
    detail_pids+=($!)
  done <<< "$review_entries"

  for pid in "${detail_pids[@]}"; do
    wait "$pid" 2>/dev/null || true
  done

  # Render each PR: title line + single metadata line with checks & review.
  while IFS='|' read -r number title nwo; do
    [[ -z "$number" || -z "$nwo" ]] && continue
    owner="${nwo%%/*}"
    repo="${nwo##*/}"
    cache_file="/tmp/dash_review_pr_${owner}_${repo}_${number}.json"

    rollup=""
    review=""
    if [[ -s "$cache_file" ]]; then
      rollup=$(jq -c '.statusCheckRollup // []' < "$cache_file" 2>/dev/null)
      review=$(jq -r '.reviewDecision // ""' < "$cache_file" 2>/dev/null)
    fi

    if [[ -z "$rollup" ]]; then
      checks_label="${DIM}Checks unknown${R}"
      review_label="${DIM}Review unknown${R}"
    else
      checks_label=$(pr_checks_label "$rollup")
      review_label=$(pr_review_label "$review")
    fi

    printf "  %s\n" "$title"
    printf "  ${BLUE}#%s${R} ${DIM}[%s]${R} %b ${DIM}·${R} %b\n" \
      "$number" "$repo" "$checks_label" "$review_label"
  done <<< "$review_entries"
fi
