#!/usr/bin/env bash
set -euo pipefail

# @describe Fetch a web page as plain text using w3m --dump.
# @option --url! URL to fetch. Example: `https://www.nikkei.com`
# @option --stdin HTML text piped to w3m instead of fetching a URL. Requires url to be set to `-T text/html`.
# @env LLM_OUTPUT=/dev/stdout The output path.

emit() {
    if [[ -n "${LLM_OUTPUT:-}" ]]; then
        cat >> "$LLM_OUTPUT"
    else
        cat
    fi
}

main() {
    local url=""
    local stdin_text=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --url)
                [[ $# -ge 2 ]] || { echo "missing value for --url" >&2; exit 2; }
                url="$2"
                shift 2
                ;;
            --stdin)
                [[ $# -ge 2 ]] || { echo "missing value for --stdin" >&2; exit 2; }
                stdin_text="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: fn_w3m.sh --url <URL> [--stdin <HTML>]"
                exit 0
                ;;
            *)
                echo "unknown option: $1" >&2
                exit 2
                ;;
        esac
    done

    [[ -n "$url" ]] || { echo "--url is required." >&2; exit 2; }
    command -v w3m >/dev/null 2>&1 || { echo "w3m not found in PATH." >&2; exit 127; }

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | w3m -dump "$url" | emit
    else
        w3m -dump "$url" | emit
    fi
}

main "$@"
