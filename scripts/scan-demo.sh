#!/bin/bash
set -e

VARIANT="${1:-ubi}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"
LOCK_FILE="/tmp/trivy-scan.lock"

# Find Trivy in common locations
if [ -n "$TRIVY_BIN" ] && [ -f "$TRIVY_BIN" ]; then
  # Use environment variable if set
  :
elif [ -f "$HOME/.local/bin/trivy" ]; then
  TRIVY_BIN="$HOME/.local/bin/trivy"
elif [ -f "/home/linuxbrew/.linuxbrew/bin/trivy" ]; then
  TRIVY_BIN="/home/linuxbrew/.linuxbrew/bin/trivy"
elif command -v trivy >/dev/null 2>&1; then
  TRIVY_BIN=$(command -v trivy)
else
  echo "❌ Trivy not found"
  echo "Install with: brew install trivy"
  exit 1
fi

echo "=== Scanning Demo Images ($VARIANT) ==="
echo "Trivy: $TRIVY_BIN"
echo ""

mkdir -p "$DEMO_DIR/sboms"

# bootc variants are full OS images (not separate webapp+db containers)
if [ "$VARIANT" = "bootc" ]; then
  IMAGES=("ghcr.io/jkirklan/demo-bootc:latest")
  COMPONENTS=("bootc")
elif [ "$VARIANT" = "bootc-rhhi" ]; then
  IMAGES=("ghcr.io/jkirklan/demo-bootc-rhhi:latest")
  COMPONENTS=("bootc-rhhi")
else
  IMAGES=("ghcr.io/jkirklan/demo-webapp-${VARIANT}:latest" "ghcr.io/jkirklan/demo-db-${VARIANT}:latest")
  COMPONENTS=("webapp" "db")
fi

for i in "${!IMAGES[@]}"; do
  IMAGE="${IMAGES[$i]}"
  COMPONENT="${COMPONENTS[$i]}"

  echo "🔍 Scanning $IMAGE..."
  echo ""

  # Acquire exclusive lock to prevent Trivy cache conflicts
  exec 200>"$LOCK_FILE"
  if ! flock -n -x 200; then
    echo "  ⏳ Waiting for another Trivy scan to complete..."
    flock -x 200
  fi

  # Vulnerability scan (secrets handled by gitleaks pre-commit)
  echo "  🛡️  CVE scan..."
  $TRIVY_BIN image --scanners vuln --parallel 1 --severity HIGH,CRITICAL "$IMAGE" || true

  # Generate SBOM
  echo "  📋 SBOM generation..."
  SBOM_FILE="$DEMO_DIR/sboms/demo-${COMPONENT}-${VARIANT}-$(date +%Y%m%d).json"
  $TRIVY_BIN image --scanners vuln --parallel 1 --format cyclonedx --output "$SBOM_FILE" "$IMAGE"

  # Release lock
  flock -u 200

  echo ""
  echo "✅ $COMPONENT scanned, SBOM: $SBOM_FILE"
  echo ""
done

echo "✅ All $VARIANT images scanned"
echo ""
echo "SBOMs saved to: $DEMO_DIR/sboms/"
ls -lh "$DEMO_DIR/sboms/"
