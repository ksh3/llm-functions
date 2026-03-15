#!/usr/bin/env bash
set -euo pipefail

# @describe Run tail for viewing end of files or streams.
# Typical usage hints: last N lines (`-n 100`), follow mode (`-f`).
# Provide all tail CLI arguments via --args.
# @option --args! tail CLI arguments string. Example: `-n 50 app.log`
# @option --stdin Input text piped to tail.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
tail.sh
- Purpose: inspect end of file/stream.
- Required: --args with valid tail CLI arguments.
- Optional: --stdin for inline text.
Examples:
  --args "-n 40 server.log"
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
    command -v tail >/dev/null 2>&1 || { echo "tail command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | tail "${parsed_args[@]}" | emit
    else
        tail "${parsed_args[@]}" | emit
    fi
}

main "$@"
