#!/usr/bin/env bash
set -euo pipefail

# @describe Run awk for pattern matching and column-based text processing.
# Typical usage hints: field extraction (`{print $1}`), filtering (`$3 > 10`), delimiter control (`-F ','`).
# Provide all awk CLI arguments via --args.
# @option --args! awk CLI arguments string. Example: `-F ',' '{print $1}' data.csv`
# @option --stdin Input text piped to awk. Useful for inline processing.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
awk.sh
- Purpose: line/field-oriented text processing.
- Required: --args with valid awk CLI arguments.
- Optional: --stdin for inline input text.
Examples:
  --args "'{print $1}' file.txt"
  --args "-F ',' '{sum += $3} END {print sum}'" --stdin 'a,b,1\nx,y,2'
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
    command -v awk >/dev/null 2>&1 || { echo "awk command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | awk "${parsed_args[@]}" | emit
    else
        awk "${parsed_args[@]}" | emit
    fi
}

main "$@"
