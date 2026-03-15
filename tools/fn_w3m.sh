#!/usr/bin/env bash
set -euo pipefail

# @describe Run w3m in dump mode (`--dump`) for text extraction from web pages or HTML.
# This wrapper always enforces `w3m --dump` and appends your --args.
# Typical usage hints: pass URL directly, tune width with `-cols`, provide HTML via --stdin plus `-T text/html`.
# @option --args! w3m CLI arguments string (without --dump). Example: `https://example.com`
# @option --stdin HTML text piped to w3m. Pair with args like `-T text/html` when needed.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
w3m.sh
- Purpose: text dump from web pages/HTML.
- Behavior: always runs w3m with --dump.
- Required: --args with URL or other w3m arguments.
- Optional: --stdin for inline HTML input.
Examples:
  --args "https://example.com"
  --args "-T text/html" --stdin '<html><body>Hello</body></html>'
USAGE
}

emit() {
    if [[ -n "${LLM_OUTPUT:-}" ]]; then
        cat >> "$LLM_OUTPUT"
    else
        cat
    fi
}

main() {
    local args=""
    local stdin_text=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --args)
                [[ $# -ge 2 ]] || { echo "missing value for --args" >&2; exit 2; }
                args="$2"
                shift 2
                ;;
            --stdin)
                [[ $# -ge 2 ]] || { echo "missing value for --stdin" >&2; exit 2; }
                stdin_text="$2"
                shift 2
                ;;
            -h|--help)
                usage | emit
                exit 0
                ;;
            *)
                echo "unknown option: $1" >&2
                exit 2
                ;;
        esac
    done

    [[ -n "$args" ]] || { echo "--args is required. Use --help for usage." >&2; exit 2; }
    command -v w3m >/dev/null 2>&1 || { echo "w3m command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | w3m --dump "${parsed_args[@]}" | emit
    else
        w3m --dump "${parsed_args[@]}" | emit
    fi
}

main "$@"
