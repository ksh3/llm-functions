#!/usr/bin/env bash
set -euo pipefail

# @describe Run cat for file concatenation and raw text output.
# Typical usage hints: read files in order, include line numbers (`-n`) when needed.
# Provide all cat CLI arguments via --args.
# @option --args! cat CLI arguments string. Example: `-n README.md`
# @option --stdin Input text piped to cat.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
cat.sh
- Purpose: output file or stdin content.
- Required: --args with valid cat CLI arguments.
- Optional: --stdin for inline content.
Examples:
  --args "README.md"
  --args "-n file1.txt file2.txt"
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
    command -v cat >/dev/null 2>&1 || { echo "cat command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | cat "${parsed_args[@]}" | emit
    else
        cat "${parsed_args[@]}" | emit
    fi
}

main "$@"
