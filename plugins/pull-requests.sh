section "🦾 My Pull Requests"

check_dependencies gh jq

cached_fetch prs "/tmp/dash_prs.json" "gh search prs --author=@me --state=open --json number,title,repository --limit 5"

if [ -z "$prs" ] || [ "$prs" = "[]" ]; then
  empty_state "No open PRs - go ship something!"
else
  # Parse the list once into a newline-separated "number|title|owner/repo".
  pr_entries=$(echo "$prs" | jq -r '.[] | "\(.number)|\(.title)|\(.repository.nameWithOwner)"' 2>/dev/null)

  # Fan out per-PR detail fetches in parallel. Each call is cached under /tmp
  # using the same D_CACHE_TTL policy as the rest of the dashboard so warm runs
  # are free.
  detail_pids=()
  while IFS='|' read -r number _title nwo; do
    [[ -z "$number" || -z "$nwo" ]] && continue
    owner="${nwo%%/*}"
    repo="${nwo##*/}"
    cache_file="/tmp/dash_pr_${owner}_${repo}_${number}.json"
    cmd="gh pr view ${number} --repo ${nwo} --json statusCheckRollup,reviewDecision"
    # cached_fetch assigns to a variable we don't need here; we only care
    # that the cache file on disk is warm before rendering.
    cached_fetch _pr_detail_discard "$cache_file" "$cmd" &
    detail_pids+=($!)
  done <<< "$pr_entries"

  # Wait for all detail fetches (silence "no such job" noise if any exited fast).
  for pid in "${detail_pids[@]}"; do
    wait "$pid" 2>/dev/null || true
  done

  # Render each PR: title line + single metadata line with checks & review.
  while IFS='|' read -r number title nwo; do
    [[ -z "$number" || -z "$nwo" ]] && continue
    owner="${nwo%%/*}"
    repo="${nwo##*/}"
    cache_file="/tmp/dash_pr_${owner}_${repo}_${number}.json"

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
  done <<< "$pr_entries"
fi
