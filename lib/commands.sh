case "$1" in
  --sync|-s)
    rm -f /tmp/dash_*.json
    ;;
  --help|-h)
    echo "Usage: ds [options]"
    echo "  -s, --sync      Clear cache and force a fresh fetch"
    echo "  -h, --help      Show this help message"
    exit 0
    ;;
esac
