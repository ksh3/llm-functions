#!/usr/bin/env bash
set -euo pipefail

# @describe Aggregate values with `sort | uniq`.
# Typical usage hints: count duplicates (`uniq -c`), ignore case (`sort -f`, `uniq -i`).
# @option --sort-args Optional sort arguments string. Example: `-f`
# @option --uniq-args Optional uniq arguments string. Example: `-c`
# @option --stdin Input text to aggregate.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
sort_uniq.sh
- Purpose: aggregation pipeline using sort then uniq.
- Optional: --sort-args
- Optional: --uniq-args
- Optional: --stdin (if omitted, reads from stdin directly)
Examples:
  --uniq-args "-c" --stdin 'a\nb\na\n'
  --sort-args "-f" --uniq-args "-ci" --stdin 'A\na\nB\n'
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
    local sort_args=""
    local uniq_args=""
    local stdin_text=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --sort-args)
                [[ $# -ge 2 ]] || { echo "missing value for --sort-args" >&2; exit 2; }
                sort_args="$2"
                shift 2
                ;;
            --uniq-args)
                [[ $# -ge 2 ]] || { echo "missing value for --uniq-args" >&2; exit 2; }
                uniq_args="$2"
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

    command -v sort >/dev/null 2>&1 || { echo "sort command not found in PATH." >&2; exit 127; }
    command -v uniq >/dev/null 2>&1 || { echo "uniq command not found in PATH." >&2; exit 127; }

    local -a parsed_sort=()
    local -a parsed_uniq=()
    [[ -n "$sort_args" ]] && eval "parsed_sort=($sort_args)"
    [[ -n "$uniq_args" ]] && eval "parsed_uniq=($uniq_args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | sort "${parsed_sort[@]}" | uniq "${parsed_uniq[@]}" | emit
    else
        sort "${parsed_sort[@]}" | uniq "${parsed_uniq[@]}" | emit
    fi
}

main "$@"
