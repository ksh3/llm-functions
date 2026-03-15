#!/usr/bin/env bash
set -euo pipefail

# @describe Run head for quick preview of the beginning of files or streams.
# Typical usage hints: first N lines (`-n 50`), first bytes (`-c 200`).
# Provide all head CLI arguments via --args.
# @option --args! head CLI arguments string. Example: `-n 40 logs/app.log`
# @option --stdin Input text piped to head.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
head.sh
- Purpose: preview the top of file/stream content.
- Required: --args with valid head CLI arguments.
- Optional: --stdin for inline text.
Examples:
  --args "-n 30 README.md"
  --args "-n 2" --stdin 'a\nb\nc'
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
    command -v head >/dev/null 2>&1 || { echo "head command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | head "${parsed_args[@]}" | emit
    else
        head "${parsed_args[@]}" | emit
    fi
}

main "$@"
