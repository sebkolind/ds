# Plugins
# A small script loaded as a section
#
# Can be configured with a plugin-specific `.config/dash/plugins/{plugin_name}.sh` file.

# Sets the variable named by <result_var> to the fetched (or cached) content.
# Usage: cached_fetch <result_var> <cache_file> <cmd>
cached_fetch() {
  local result_var="$1"
  local cache_file="$2"
  local cmd="$3"

  if [[ "$D_CACHE_TTL" -gt 0 ]] && [[ -f "$cache_file" ]]; then
    local mtime
    # Either Linux or macOS modified time
    mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
    if (( $(date +%s) - mtime < D_CACHE_TTL )); then
      printf -v "$result_var" '%s' "$(cat "$cache_file")"
      return
    fi
  fi

  eval "$cmd" >"$cache_file" 2>/dev/null &
  spinner $!
  printf -v "$result_var" '%s' "$(cat "$cache_file")"
}

# Load config for a plugin.
load_config() {
  local plugin_name="$1"
  local file="${CONFIG_DIR}/plugins/${plugin_name}.sh"
  if [[ -f "$file" ]]; then
    debug "Loading config for plugin: $plugin_name"
    source "$file"
  fi
}

# No plugins configured.
if [[ "${#D_PLUGINS[@]}" -eq 0 ]]; then
  echo ""
  printf "  You have no plugins configured. Available plugins:\n"
  printf "  ${BLUE}Jira${R} (jira), ${BLUE}GitHub${R} (pull-requests & review-pull-requests).\n\n"
  printf "  You can configure plugins by adding them to your ${BLUE}D_PLUGINS${R} array in your config file.\n"
  printf "  Your config file is located at: ${CONFIG_DIR}/config.sh.\n"
  return
fi

# Load plugins.
for plugin in "${D_PLUGINS[@]}"; do
  load_config "$plugin"
  source "./plugins/$plugin.sh"
done
