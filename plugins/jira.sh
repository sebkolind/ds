section "📋  Jira"

check_dependencies acli jq

statuses=""
for status in "${JIRA_STATUSES[@]}"; do
  s_name=$(echo $status | cut -d'|' -f1)
  statuses+="${statuses:+,}'$s_name'"
done

get_status_color() {
  local name="$1"
  for status in "${JIRA_STATUSES[@]}"; do
    local s_name=$(echo $status | cut -d'|' -f1)
    local s_color=$(echo $status | cut -d'|' -f2)
    if [[ "$s_name" == "$name" ]]; then
      echo "$s_color"
      return
    fi
  done
}

jira_items=$(acli jira workitem search --jql "assignee = currentUser() AND status in ($statuses)" --fields "key,summary,status" --limit 5 --json 2>/dev/null)

if [ -z "$jira_items" ] || [ "$jira_items" = "[]" ]; then
  empty_state "Nothing assigned to you - pick up a ticket!"
else
  echo "$jira_items" | jq -r '.[] | "\(.key)|\(.fields.summary)|\(.fields.status.name)"' 2>/dev/null | while IFS='|' read -r key summary status; do
    color=$(get_status_color "$status")
    printf "  %s\n" "$summary"
    printf "  ${BLUE}%s${R} ${color}%b${R}\n" "$key" "$status"
  done
fi
