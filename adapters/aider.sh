#!/usr/bin/env bash
# ============================================================================
# Adapter: Aider (aider)
# Maps the generic agent interface to Aider CLI flags
# ============================================================================

AGENT_BIN="${AGENT_BIN:-aider}"

adapter_build_flags() {
    local flags=()
    flags+=(--yes-always)
    flags+=(--no-auto-commits)

    echo "${flags[@]}"
}

adapter_run() {
    local prompt="$1"
    local output_file="$2"
    local timeout_sec="${3:-9000}"

    local flags
    flags=$(adapter_build_flags)

    # shellcheck disable=SC2086
    timeout "$timeout_sec" "$AGENT_BIN" $flags --message "$prompt" \
        > "$output_file" 2>&1
    return $?
}

adapter_check_rate_limit() {
    local output_file="$1"
    grep -qi "rate.limit\|too many\|429\|quota\|RateLimitError" "$output_file" 2>/dev/null
}

adapter_check_completion() {
    local output_file="$1"
    local signal="${2:-NIGHT_SHIFT_COMPLETE}"
    grep -q "$signal" "$output_file" 2>/dev/null
}

adapter_name() {
    echo "Aider"
}

adapter_verify() {
    command -v "$AGENT_BIN" &>/dev/null
}
