#!/usr/bin/env bash
set -euo pipefail

# Build bootc (bootable container) demo image
# This creates a full OS image, not just an application container

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"
BOOTC_DIR="$DEMO_DIR/bootc"

IMAGE_NAME="ghcr.io/jkirklan/demo-bootc:latest"

echo "=== Building Bootable Container Image (bootc) ==="
echo "Directory: $BOOTC_DIR"
echo "Image: $IMAGE_NAME"
echo ""

# Build context is parent directory to access webapp/
cd "$BOOTC_DIR"

echo "Building for AMD64 platform..."
podman build \
  --platform linux/amd64 \
  --tag "$IMAGE_NAME" \
  --file Containerfile \
  ..

echo ""
echo "✅ bootc image built successfully"
echo "   Image: $IMAGE_NAME"
echo "   Size: $(podman images "$IMAGE_NAME" --format '{{.Size}}')"
echo ""
echo "Note: bootc images are full OS images (1-2GB), not minimal application containers"
