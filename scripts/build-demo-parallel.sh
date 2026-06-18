#!/usr/bin/env bash
set -euo pipefail

# Build all four demo variants in parallel with status tracking
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
  local start_time=$(date +%s)

  # Clear log file from previous runs
  > "$log_file"

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

  # Calculate total time
  local end_time=$(date +%s)
  local total_time=$((end_time - start_time))
  local total_min=$((total_time / 60))
  local total_sec=$((total_time % 60))

  # Get CVE counts from SBOM files
  local cve_count=0
  if [[ "$variant" == "bootc" || "$variant" == "bootc-rhhi" ]]; then
    # bootc variants have single image
    local component_name="${variant/bootc-/bootc-}"  # bootc or bootc-rhhi
    local sbom_file="$DEMO_DIR/sboms/demo-${component_name}-${component_name}-$(date +%Y%m%d).json"
    cve_count=$(grep -c "HIGH\|CRITICAL" "$sbom_file" 2>/dev/null || echo "0")
    # Remove leading zeros (handle 00, 01, etc from grep -c)
    cve_count=${cve_count#0}  # Strip one leading zero
    cve_count=${cve_count#0}  # Strip another if present
    cve_count=${cve_count:-0} # Default to 0 if empty
  else
    # Container variants have webapp + db
    local webapp_sbom="$DEMO_DIR/sboms/demo-webapp-${variant}-$(date +%Y%m%d).json"
    local db_sbom="$DEMO_DIR/sboms/demo-db-${variant}-$(date +%Y%m%d).json"
    local webapp_cves=$(grep -c "HIGH\|CRITICAL" "$webapp_sbom" 2>/dev/null || echo "0")
    local db_cves=$(grep -c "HIGH\|CRITICAL" "$db_sbom" 2>/dev/null || echo "0")
    # Remove leading zeros (handle 00, 01, etc from grep -c)
    webapp_cves=${webapp_cves#0}; webapp_cves=${webapp_cves#0}; webapp_cves=${webapp_cves:-0}
    db_cves=${db_cves#0}; db_cves=${db_cves#0}; db_cves=${db_cves:-0}
    cve_count=$((webapp_cves + db_cves))
  fi

  # Complete with statistics
  update_status "$variant" "completed" "scan"
  echo "" | tee -a "$log_file"
  echo "✅ $variant variant completed at $(date '+%Y-%m-%d %H:%M:%S %Z')" | tee -a "$log_file"
  echo "📊 Total time: ${total_min}m ${total_sec}s | CVEs: $cve_count HIGH/CRITICAL" | tee -a "$log_file"
  echo "" | tee -a "$log_file"
  return 0
}

echo "========================================="
echo "  Parallel Demo Build (4 tracks)"
echo "========================================="
echo ""
echo "Building all four variants in parallel..."
echo "  1. UBI containers"
echo "  2. RHHI containers"
echo "  3. UBI bootc"
echo "  4. RHHI bootc"
echo ""
echo "Status: $STATUS_DIR/"
echo "Logs: $LOG_DIR/"
echo ""

# Launch builds in parallel (fastest first, UBI bootc last)
# Order: RHHI containers, UBI containers, RHHI bootc, then UBI bootc
build_variant "rhhi" &
pid_rhhi=$!

build_variant "ubi" &
pid_ubi=$!

build_variant "bootc-rhhi" &
pid_bootc_rhhi=$!

# 1-minute delay before starting UBI bootc (slowest build - let others get ahead)
echo "⏸️  Delaying UBI bootc start by 1 minute to prioritize faster builds..."
sleep 60

build_variant "bootc" &
pid_bootc=$!

# Wait for all builds (RHHI → UBI → RHHI bootc → UBI bootc)
wait $pid_rhhi
result_rhhi=$?

wait $pid_ubi
result_ubi=$?

wait $pid_bootc
result_bootc=$?

wait $pid_bootc_rhhi
result_bootc_rhhi=$?

# Summary
echo ""
echo "========================================="
echo "  Build Summary"
echo "========================================="
printf "%-15s %-12s %-15s %s\n" "Variant" "Status" "Time" "CVEs"
printf "%-15s %-12s %-15s %s\n" "---------------" "------------" "---------------" "----"

for variant in ubi rhhi bootc bootc-rhhi; do
  status=$(jq -r .status "$STATUS_DIR/${variant}.json" 2>/dev/null || echo "unknown")
  start=$(jq -r .start_time "$STATUS_DIR/${variant}.json" 2>/dev/null)
  end=$(jq -r .end_time "$STATUS_DIR/${variant}.json" 2>/dev/null)

  # Calculate time
  if [[ "$end" != "null" && "$start" != "null" ]]; then
    start_epoch=$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$start" +%s 2>/dev/null || date -d "$start" +%s 2>/dev/null)
    end_epoch=$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$end" +%s 2>/dev/null || date -d "$end" +%s 2>/dev/null)
    duration=$((end_epoch - start_epoch))
    duration_min=$((duration / 60))
    duration_sec=$((duration % 60))
    time_str="${duration_min}m ${duration_sec}s"
  else
    time_str="-"
  fi

  # Get CVE count
  if [[ "$variant" == "bootc" || "$variant" == "bootc-rhhi" ]]; then
    component_name="${variant/bootc-/bootc-}"
    sbom_file="$DEMO_DIR/sboms/demo-${component_name}-${component_name}-$(date +%Y%m%d).json"
    cve_count=$(grep -c "HIGH\|CRITICAL" "$sbom_file" 2>/dev/null || echo "0")
    # Remove leading zeros (handle 00, 01, etc from grep -c)
    cve_count=${cve_count#0}; cve_count=${cve_count#0}; cve_count=${cve_count:-0}
  else
    webapp_sbom="$DEMO_DIR/sboms/demo-webapp-${variant}-$(date +%Y%m%d).json"
    db_sbom="$DEMO_DIR/sboms/demo-db-${variant}-$(date +%Y%m%d).json"
    webapp_cves=$(grep -c "HIGH\|CRITICAL" "$webapp_sbom" 2>/dev/null || echo "0")
    db_cves=$(grep -c "HIGH\|CRITICAL" "$db_sbom" 2>/dev/null || echo "0")
    # Remove leading zeros (handle 00, 01, etc from grep -c)
    webapp_cves=${webapp_cves#0}; webapp_cves=${webapp_cves#0}; webapp_cves=${webapp_cves:-0}
    db_cves=${db_cves#0}; db_cves=${db_cves#0}; db_cves=${db_cves:-0}
    cve_count=$((webapp_cves + db_cves))
  fi

  printf "%-15s %-12s %-15s %s\n" "$variant" "$status" "$time_str" "$cve_count"
done

echo ""

# Exit with error if any build failed
if [[ $result_ubi -ne 0 || $result_rhhi -ne 0 || $result_bootc -ne 0 || $result_bootc_rhhi -ne 0 ]]; then
  echo "❌ One or more builds failed"
  exit 1
fi

echo "✅ All builds completed successfully"
exit 0
