#!/usr/bin/env bash
set -euo pipefail

# Build RHHI bootc (bootable container) demo image
# Uses Hummingbird Community bootc OS base

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"
BOOTC_RHHI_DIR="$DEMO_DIR/bootc-rhhi"
START_TIME=$(date +%s)

IMAGE_NAME="ghcr.io/jkirklan/demo-bootc-rhhi:latest"

echo "=== Building RHHI Bootable Container Image (bootc) ==="
echo "Directory: $BOOTC_RHHI_DIR"
echo "Image: $IMAGE_NAME"
echo ""

# Build context is demo directory to access webapp/
cd "$DEMO_DIR"

echo "Building for AMD64 platform..."
podman rmi -f "$IMAGE_NAME" 2>/dev/null || true
podman build \
  --platform linux/amd64 \
  --tag "$IMAGE_NAME" \
  --file bootc-rhhi/Containerfile \
  .

echo ""
echo "✅ RHHI bootc image built successfully"
echo ""

# Calculate build time
END_TIME=$(date +%s)
BUILD_TIME=$((END_TIME - START_TIME))
BUILD_MIN=$((BUILD_TIME / 60))
BUILD_SEC=$((BUILD_TIME % 60))

# Get image size and CVE count
IMAGE_SIZE=$(podman images "$IMAGE_NAME" --format '{{.Size}}')
IMAGE_CVES=$(grep -c "HIGH\|CRITICAL" "$DEMO_DIR/sboms/demo-bootc-rhhi-bootc-rhhi-$(date +%Y%m%d).json" 2>/dev/null || echo "0")

echo "📊 Build Statistics:"
echo "  ⏱️  Total time: ${BUILD_MIN}m ${BUILD_SEC}s"
echo "  📦 Image: $IMAGE_SIZE | CVEs: $IMAGE_CVES HIGH/CRITICAL"
echo ""
echo "ℹ️  Note: RHHI bootc uses Hummingbird Community OS (Fedora-based minimal)"
