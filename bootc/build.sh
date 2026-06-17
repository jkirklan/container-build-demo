#!/bin/bash
# Build bootable container image for the demo task tracker
# This creates a full OS image, not an application container

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_ROOT="$(dirname "$SCRIPT_DIR")"

IMAGE_NAME="${IMAGE_NAME:-demo-bootc}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
PLATFORM="${PLATFORM:-linux/amd64}"

echo "========================================="
echo "  Building Bootable Container Image"
echo "========================================="
echo ""
echo "Image: $IMAGE_NAME:$IMAGE_TAG"
echo "Platform: $PLATFORM"
echo "Context: $DEMO_ROOT"
echo ""

# Build bootable container image
# Note: Context is parent directory to access webapp/
podman build \
  --platform "$PLATFORM" \
  -t "$IMAGE_NAME:$IMAGE_TAG" \
  -f "$SCRIPT_DIR/Containerfile" \
  "$DEMO_ROOT"

echo ""
echo "✅ Build complete: $IMAGE_NAME:$IMAGE_TAG"
echo ""
echo "Next steps:"
echo "  1. Test locally: ./test-vm.sh"
echo "  2. Push to registry: podman push $IMAGE_NAME:$IMAGE_TAG"
echo "  3. Deploy: bootc switch $IMAGE_NAME:$IMAGE_TAG"
echo ""
echo "⚠️  This is a bootable OS image, not a container!"
echo "    Deploy with bootc, not podman run."
echo ""
