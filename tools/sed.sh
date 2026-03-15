#!/usr/bin/env bash
set -euo pipefail

# @describe Run sed for stream editing.
# Typical usage hints: substitute (`s/old/new/g`), print ranges (`-n '10,20p'`), in-place edits (`-i`) when needed.
# Provide all sed CLI arguments via --args.
# @option --args! sed CLI arguments string. Example: `-n '1,20p' README.md`
# @option --stdin Input text piped to sed.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
sed.sh
- Purpose: non-interactive text replacement and extraction.
- Required: --args with valid sed CLI arguments.
- Optional: --stdin for inline text.
Examples:
  --args "-n '1,40p' app.log"
  --args "'s/error/warn/g'" --stdin 'error: disk full'
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
    command -v sed >/dev/null 2>&1 || { echo "sed command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | sed "${parsed_args[@]}" | emit
    else
        sed "${parsed_args[@]}" | emit
    fi
}

main "$@"
