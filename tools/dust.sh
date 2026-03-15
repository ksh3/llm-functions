#!/usr/bin/env bash
set -euo pipefail

# @describe Run dust for disk-usage visualization.
# Typical usage hints: inspect directory sizes, limit depth (`-d`), reverse sort (`-r`).
# Provide all dust CLI arguments via --args.
# @option --args! dust CLI arguments string. Example: `-d 3 .`
# @option --stdin Input text piped to dust when applicable.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
dust.sh
- Purpose: show readable disk usage by directory/file.
- Required: --args with valid dust CLI arguments.
- Optional: --stdin only for specialized usage.
Examples:
  --args "."
  --args "-d 2 -r /Users"
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
    command -v dust >/dev/null 2>&1 || { echo "dust command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | dust "${parsed_args[@]}" | emit
    else
        dust "${parsed_args[@]}" | emit
    fi
}

main "$@"
