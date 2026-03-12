#!/usr/bin/env bash
# ============================================================================
# Adapter: Claude Code (claude)
# Maps the generic agent interface to Claude Code CLI flags
# ============================================================================

# Required: AGENT_BIN, PROMPT, OUTPUT_FILE
# Optional: SKIP_PERMISSIONS, EFFECTIVE_TIMEOUT

AGENT_BIN="${AGENT_BIN:-claude}"

adapter_build_flags() {
    local flags=()
    flags+=(--print)
    flags+=(-p)

    if [ "${SKIP_PERMISSIONS:-false}" = "true" ]; then
        flags+=(--dangerously-skip-permissions)
    fi

    echo "${flags[@]}"
}

adapter_run() {
    local prompt="$1"
    local output_file="$2"
    local timeout_sec="${3:-9000}"

    local flags
    flags=$(adapter_build_flags)

    # shellcheck disable=SC2086
    timeout "$timeout_sec" "$AGENT_BIN" $flags "$prompt" \
        > "$output_file" 2>&1
    return $?
}

adapter_check_rate_limit() {
    local output_file="$1"
    grep -qi "rate.limit\|too many\|429\|quota" "$output_file" 2>/dev/null
}

adapter_check_completion() {
    local output_file="$1"
    local signal="${2:-NIGHT_SHIFT_COMPLETE}"
    grep -q "$signal" "$output_file" 2>/dev/null
}

adapter_name() {
    echo "Claude Code"
}

adapter_verify() {
    command -v "$AGENT_BIN" &>/dev/null
}
