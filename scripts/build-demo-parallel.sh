#!/usr/bin/env bash
set -euo pipefail

# Build all three demo variants in parallel with status tracking
# Outputs JSON status files for dashboard consumption

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"
STATUS_DIR="$DEMO_DIR/dashboard/status"
LOG_DIR="$DEMO_DIR/logs"

# Ensure directories exist
mkdir -p "$STATUS_DIR" "$LOG_DIR"

# Initialize status files
init_status() {
  local variant="$1"
  cat > "$STATUS_DIR/${variant}.json" <<EOF
{
  "variant": "$variant",
  "status": "pending",
  "phase": "init",
  "start_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "end_time": null,
  "error": null
}
EOF
}

# Update status file
update_status() {
  local variant="$1"
  local status="$2"
  local phase="$3"
  local error="${4:-null}"

  local end_time="null"
  if [[ "$status" == "completed" || "$status" == "failed" ]]; then
    end_time="\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
  fi

  cat > "$STATUS_DIR/${variant}.json" <<EOF
{
  "variant": "$variant",
  "status": "$status",
  "phase": "$phase",
  "start_time": "$(jq -r .start_time "$STATUS_DIR/${variant}.json" 2>/dev/null || echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)")",
  "end_time": $end_time,
  "error": $([[ "$error" == "null" ]] && echo "null" || echo "\"$error\"")
}
EOF
}

# Build function for each variant
build_variant() {
  local variant="$1"
  local build_script="$SCRIPT_DIR/build-demo-${variant}.sh"
  local log_file="$LOG_DIR/build-${variant}.log"

  init_status "$variant"

  if [[ ! -f "$build_script" ]]; then
    update_status "$variant" "failed" "build" "Build script not found: $build_script"
    echo "ERROR: Build script not found: $build_script" | tee -a "$log_file"
    return 1
  fi

  # Build phase
  update_status "$variant" "running" "build"
  echo "=== Building $variant variant ===" | tee "$log_file"
  if ! "$build_script" >> "$log_file" 2>&1; then
    update_status "$variant" "failed" "build" "Build failed (see logs)"
    echo "ERROR: Build failed for $variant" | tee -a "$log_file"
    return 1
  fi

  # Scan phase
  update_status "$variant" "running" "scan"
  echo "=== Scanning $variant variant ===" | tee -a "$log_file"
  if ! "$SCRIPT_DIR/scan-demo.sh" "$variant" >> "$log_file" 2>&1; then
    update_status "$variant" "failed" "scan" "Scan failed (see logs)"
    echo "ERROR: Scan failed for $variant" | tee -a "$log_file"
    return 1
  fi

  # Complete
  update_status "$variant" "completed" "scan"
  echo "✅ $variant variant built and scanned successfully" | tee -a "$log_file"
  return 0
}

echo "========================================="
echo "  Parallel Demo Build (UBI + RHHI + bootc)"
echo "========================================="
echo ""
echo "Building all three variants in parallel..."
echo "Status: $STATUS_DIR/"
echo "Logs: $LOG_DIR/"
echo ""

# Launch builds in parallel
build_variant "ubi" &
pid_ubi=$!

build_variant "rhhi" &
pid_rhhi=$!

build_variant "bootc" &
pid_bootc=$!

# Wait for all builds
wait $pid_ubi
result_ubi=$?

wait $pid_rhhi
result_rhhi=$?

wait $pid_bootc
result_bootc=$?

# Summary
echo ""
echo "========================================="
echo "  Build Summary"
echo "========================================="
echo "UBI:   $(jq -r .status "$STATUS_DIR/ubi.json")"
echo "RHHI:  $(jq -r .status "$STATUS_DIR/rhhi.json")"
echo "bootc: $(jq -r .status "$STATUS_DIR/bootc.json")"
echo ""

# Exit with error if any build failed
if [[ $result_ubi -ne 0 || $result_rhhi -ne 0 || $result_bootc -ne 0 ]]; then
  echo "❌ One or more builds failed"
  exit 1
fi

echo "✅ All builds completed successfully"
exit 0
