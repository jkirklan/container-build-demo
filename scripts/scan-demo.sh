#!/bin/bash
set -e

VARIANT="${1:-ubi}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"

# Find Trivy in common locations
if [ -n "$TRIVY_BIN" ] && [ -f "$TRIVY_BIN" ]; then
  # Use environment variable if set
  :
elif [ -f "$HOME/.local/bin/trivy" ]; then
  TRIVY_BIN="$HOME/.local/bin/trivy"
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

for COMPONENT in webapp db; do
  IMAGE="ghcr.io/jkirklan/demo-${COMPONENT}-${VARIANT}:latest"

  echo "🔍 Scanning $IMAGE..."
  echo ""

  # Scan 1: Secret detection
  echo "  🔐 Secret scan..."
  SECRET_RESULT=$($TRIVY_BIN image --scanners secret "$IMAGE" 2>&1 || true)
  if echo "$SECRET_RESULT" | grep -q "HIGH\|CRITICAL"; then
    echo "  ❌ SECRETS FOUND - Security gate FAILED!"
    echo "$SECRET_RESULT"
    exit 1
  else
    echo "  ✅ No secrets detected"
  fi

  # Scan 2: Vulnerability scan
  echo "  🛡️  CVE scan..."
  $TRIVY_BIN image --severity HIGH,CRITICAL "$IMAGE" || true

  # Scan 3: Generate SBOM
  echo "  📋 SBOM generation..."
  SBOM_FILE="$DEMO_DIR/sboms/demo-${COMPONENT}-${VARIANT}-$(date +%Y%m%d).json"
  $TRIVY_BIN image --format cyclonedx --output "$SBOM_FILE" "$IMAGE"

  echo ""
  echo "✅ $COMPONENT scanned, SBOM: $SBOM_FILE"
  echo ""
done

echo "✅ All $VARIANT images scanned"
echo ""
echo "SBOMs saved to: $DEMO_DIR/sboms/"
ls -lh "$DEMO_DIR/sboms/"
